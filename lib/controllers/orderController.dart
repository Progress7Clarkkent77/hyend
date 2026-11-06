import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/ecommerceCartController.dart';
import 'package:hyend/controllers/storeConfig.dart';
import 'package:hyend/models/orderItemModel.dart';
import 'package:hyend/models/orderModel.dart';
import 'package:hyend/userAuth/authController.dart';

/// HyEnd orders are agreed on WhatsApp (no online payment).
///
/// Every order is saved with `confirmed: false`. Once the customer and HyEnd
/// have agreed on WhatsApp, the team flips `confirmed` to true on that order
/// and it appears on the customer's My Orders page (matched by their login,
/// i.e. `customerUid`) where it can be tracked as normal.
class OrderController extends GetxController {
  /// Name of the Firestore boolean that controls visibility on My Orders.
  static const String confirmedField = 'confirmed';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final EcommerceCartController cartCtrl = Get.find<EcommerceCartController>();
  final AuthController authCtrl = Get.find<AuthController>();

  final RxBool isPlacingOrder = false.obs;

  /// Only CONFIRMED orders (the ones shown on My Orders).
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  /// Orders the customer sent that HyEnd has not confirmed yet.
  final RxInt awaitingCount = 0.obs;

  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();

  /// Text shown on the checkout page's blur overlay while an order is saved.
  final RxString processingMessage = 'Please wait...'.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;
  StreamSubscription<User?>? _authSub;

  /// Longest we keep the customer waiting while the order is written.
  static const Duration _orderWriteTimeout = Duration(seconds: 8);

  //==================================================
  // LIFECYCLE
  //==================================================

  @override
  void onInit() {
    super.onInit();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _ordersSub?.cancel();
        orders.clear();
        awaitingCount.value = 0;
      } else {
        loadOrders();
      }
    });
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  void selectOrder(OrderModel order) => selectedOrder.value = order;

  //==================================================
  // LOAD ORDERS
  //==================================================

  /// Requires a composite index: orders (customerUid ASC, createdAt DESC).
  ///
  /// The `confirmed` filter is applied here in the app, so no extra index is
  /// needed. Orders that have no `confirmed` field at all (placed before this
  /// feature existed) are treated as confirmed so they do not disappear.
  Future<void> loadOrders() async {
    final uid = authCtrl.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    await _ordersSub?.cancel();

    _ordersSub = _firestore
        .collection(StoreConfig.ordersCollection)
        .where('customerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final confirmed = <OrderModel>[];
          var awaiting = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();

            if (data[confirmedField] == false) {
              awaiting++;
            } else {
              confirmed.add(OrderModel.fromMap(doc.id, data));
            }
          }

          orders.assignAll(confirmed);
          awaitingCount.value = awaiting;
        }, onError: (Object e) => Get.log('Orders stream error: $e'));
  }

  //==================================================
  // SAVED SHIPPING DETAILS
  //==================================================

  DocumentReference<Map<String, dynamic>>? get _shippingRef {
    final uid = authCtrl.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;

    return _firestore.collection(StoreConfig.shippingCollection).doc(uid);
  }

  /// Returns {'phone': ..., 'address': ...} or null when nothing is saved.
  Future<Map<String, String>?> loadSavedShipping() async {
    final ref = _shippingRef;
    if (ref == null) return null;

    try {
      final doc = await ref.get();
      final data = doc.data();
      if (!doc.exists || data == null) return null;

      final phone = (data['phone'] ?? '').toString();
      final address = (data['address'] ?? '').toString();

      if (phone.isEmpty && address.isEmpty) return null;

      return {'phone': phone, 'address': address};
    } catch (e) {
      Get.log('Failed to load saved shipping details: $e');
      return null;
    }
  }

  Future<void> saveShipping({
    required String phone,
    required String address,
  }) async {
    final ref = _shippingRef;
    if (ref == null) return;

    try {
      await ref.set({
        'phone': phone,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      Get.log('Failed to save shipping details: $e');
    }
  }

  Future<void> clearSavedShipping() async {
    try {
      await _shippingRef?.delete();
    } catch (e) {
      Get.log('Failed to clear shipping details: $e');
    }
  }

  //==================================================
  // PLACE ORDER (WHATSAPP)
  //==================================================

  /// Saves the cart as an order with `confirmed: false` and returns its id,
  /// or null if it could not be saved. The cart is NOT cleared here, so the
  /// caller can still build the WhatsApp message from it first.
  Future<String?> createWhatsAppOrder({
    required String phone,
    required String address,
    bool rememberShipping = true,
  }) async {
    if (isPlacingOrder.value) return null;

    if (cartCtrl.cartItems.isEmpty) {
      Get.snackbar('Cart Empty', 'Add items to your cart first');
      return null;
    }

    final user = authCtrl.currentUser;

    if (user == null) {
      Get.snackbar('Login Required', 'Please login to continue');
      return null;
    }

    // Snapshot everything first so the order matches what the customer saw.
    final id = 'order-${DateTime.now().millisecondsSinceEpoch}';
    final subtotal = cartCtrl.subtotal;
    final deliveryFee = cartCtrl.deliveryFee;
    final totalAmount = cartCtrl.grandTotal;
    final deliveryZone =
        cartCtrl.deliveryZone.value.name; // 'enugu' | 'outside'

    final items = cartCtrl.cartItems
        .map(
          (e) => OrderItemModel(
            productId: e.product.id,
            productName: e.product.name,
            price: e.product.price,
            quantity: e.quantity,
            // the image that shows the colour the customer chose
            image: e.image,
            colorName: e.colorName,
            colorHex: e.colorHex,
          ),
        )
        .toList();

    try {
      // Locks the checkout page (blur + back button blocked) straight away.
      isPlacingOrder.value = true;
      processingMessage.value = 'Sending your order to HyEnd...';

      final customerName = await _resolveCustomerName(user);

      final order = OrderModel(
        id: id,
        customerUid: user.uid,
        customerName: customerName,
        customerPhoneNumber: phone,
        customerDeliveryAddress: address,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        deliveryZone: deliveryZone,
        delivered: false,
        currentLocation: 'Order Received',
        status: 'Pending',
        items: items,
      );

      final data = <String, dynamic>{
        ...order.toMap(),
        'customerUid': user.uid,
        'customerEmail': user.email ?? '',
        'channel': 'whatsapp',
        // Hidden from the customer's My Orders until HyEnd flips this to true.
        confirmedField: false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final write = _firestore
          .collection(StoreConfig.ordersCollection)
          .doc(id)
          .set(data);

      try {
        await write.timeout(_orderWriteTimeout);
      } on TimeoutException {
        // Firestore keeps the write queued and syncs it as soon as the
        // connection allows, so the order is not lost.
        unawaited(write.catchError((_) {}));
      }

      if (rememberShipping) {
        unawaited(saveShipping(phone: phone, address: address));
      }

      return id;
    } catch (e) {
      Get.log('Failed to create order: $e');

      isPlacingOrder.value = false;

      await _showResultDialog(
        icon: Icons.error_outline_rounded,
        color: Colors.red,
        title: 'Order Not Sent',
        message:
            'Something went wrong and your order was not sent. '
            'Please check your connection and try again.',
      );

      return null;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  /// Uses the name saved at signup (e-users/{uid}.name); falls back to email.
  Future<String> _resolveCustomerName(User user) async {
    try {
      final doc = await _firestore
          .collection('e-users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 4));
      final name = (doc.data()?['name'] ?? '').toString().trim();
      if (name.isNotEmpty) return name;
    } catch (_) {}
    return user.email ?? '';
  }

  //==================================================
  // DIALOGS
  //==================================================

  Future<void> _showResultDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    String confirmLabel = 'OK',
  }) async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
