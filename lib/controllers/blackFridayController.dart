import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/storeConfig.dart';
import 'package:hyend/models/productModel.dart';

/// Keeps the global Black Friday switch in sync for EVERY user and gives the
/// admin the tools to turn it on/off and edit prices.
///
/// Firestore:  storeSettings/blackFriday  ->  { active: bool }
class BlackFridayController extends GetxController {
  static const String settingsCollection = 'storeSettings';
  static const String settingsDoc = 'blackFriday';

  /// Highest discount an admin can set.
  static const double maxPercent = 90;

  /// Get the controller, creating it (once, permanently) if needed.
  static BlackFridayController ensure() =>
      Get.isRegistered<BlackFridayController>()
      ? Get.find<BlackFridayController>()
      : Get.put(BlackFridayController(), permanent: true);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Same flag the product model reads — changing it updates every price.
  RxBool get isActive => BlackFridayState.active;

  final RxBool isSaving = false.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection(settingsCollection).doc(settingsDoc);

  //--------------------------------------------------
  // LIFECYCLE
  //--------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    _sub = _doc.snapshots().listen((snap) {
      BlackFridayState.active.value = snap.data()?['active'] == true;
    }, onError: (_) {});
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  //--------------------------------------------------
  // SWITCH
  //--------------------------------------------------

  Future<void> setActive(bool value) async {
    if (isSaving.value) return;

    final previous = BlackFridayState.active.value;
    BlackFridayState.active.value = value; // instant feedback

    try {
      isSaving.value = true;

      await _doc.set({
        'active': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      BlackFridayState.active.value = previous;
      Get.snackbar('Black Friday', 'Could not update: $e');
    } finally {
      isSaving.value = false;
    }
  }

  //--------------------------------------------------
  // PRICE HELPERS
  //--------------------------------------------------

  /// The price the admin typed at upload (before the platform fee).
  double sellerPriceOf(ProductModel p) =>
      p.originalPrice ?? p.regularPrice / (1 + StoreConfig.platformFeeRate);

  /// What customers pay for a given seller price (adds the platform fee).
  double sellingPriceFor(double sellerPrice) =>
      sellerPrice + sellerPrice * StoreConfig.platformFeeRate;

  //--------------------------------------------------
  // EDIT ONE PRODUCT
  //--------------------------------------------------

  /// Saves a new normal price and/or Black Friday percent.
  /// Pass only what changed. Returns true on success.
  Future<bool> saveProductPricing(
    ProductModel product, {
    double? sellerPrice,
    double? percent,
  }) async {
    final updates = <String, dynamic>{};

    if (sellerPrice != null) {
      if (sellerPrice <= 0) {
        Get.snackbar('Price', 'Enter a valid price');
        return false;
      }

      final fee = sellerPrice * StoreConfig.platformFeeRate;

      updates['originalPrice'] = sellerPrice;
      updates['platformFee'] = fee;
      updates['price'] = sellerPrice + fee;
    }

    if (percent != null) {
      if (percent < 0 || percent > maxPercent) {
        Get.snackbar(
          'Discount',
          'Discount must be between 0 and ${maxPercent.toInt()}%',
        );
        return false;
      }

      updates['blackFridayPercent'] = percent;
    }

    if (updates.isEmpty) return true;

    try {
      isSaving.value = true;

      await _firestore
          .collection(StoreConfig.productsCollection)
          .doc(product.id)
          .update(updates);

      return true;
    } catch (e) {
      Get.snackbar('Pricing', 'Could not save: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  //--------------------------------------------------
  // BULK
  //--------------------------------------------------

  /// Sets the same Black Friday discount on every product
  /// (0 removes all discounts). Returns how many products were updated.
  Future<int> applyPercentToAll(double percent) async {
    if (percent < 0 || percent > maxPercent) {
      Get.snackbar(
        'Discount',
        'Discount must be between 0 and ${maxPercent.toInt()}%',
      );
      return 0;
    }

    try {
      isSaving.value = true;

      final snap = await _firestore
          .collection(StoreConfig.productsCollection)
          .get();

      var batch = _firestore.batch();
      var inBatch = 0;
      var total = 0;

      for (final doc in snap.docs) {
        batch.update(doc.reference, {'blackFridayPercent': percent});
        inBatch++;
        total++;

        if (inBatch == 400) {
          await batch.commit();
          batch = _firestore.batch();
          inBatch = 0;
        }
      }

      if (inBatch > 0) await batch.commit();

      return total;
    } catch (e) {
      Get.snackbar('Black Friday', 'Could not update products: $e');
      return 0;
    } finally {
      isSaving.value = false;
    }
  }
}
