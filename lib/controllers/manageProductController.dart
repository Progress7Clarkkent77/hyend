import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/storeConfig.dart';
import 'package:hyend/models/productModel.dart';

class ManageProductsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxString searchQuery = ''.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productsSub;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection(StoreConfig.productsCollection);

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) return products;

    return products.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    listenProducts();
  }

  @override
  void onClose() {
    _productsSub?.cancel();
    super.onClose();
  }

  void listenProducts() {
    isLoading.value = true;

    _productsSub?.cancel();

    _productsSub = _productsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            products.assignAll(
              snapshot.docs.map((e) => ProductModel.fromMap(e.id, e.data())),
            );
            isLoading.value = false;
          },
          onError: (Object e) {
            isLoading.value = false;
            Get.snackbar('Error', 'Unable to load products');
          },
        );
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productsRef.doc(productId).delete();
      Get.snackbar('Success', 'Product deleted');
    } catch (e) {
      Get.snackbar('Delete Failed', e.toString());
    }
  }

  static const int maxSpecLength = 40;

  /// Saves minimum order quantity (1 = no minimum) plus size, weight and
  /// length ('' = not set) for one product. Returns true on success.
  ///
  /// Uses update(), so products uploaded before these fields existed get
  /// them created the first time they are saved.
  Future<bool> updateProductDetails(
    ProductModel product, {
    required int minOrder,
    required String size,
    required String weight,
    required String length,
  }) async {
    if (minOrder < 1) {
      Get.snackbar('Minimum order', 'Minimum order must be 1 or more');
      return false;
    }

    if (product.stock > 0 && minOrder > product.stock) {
      Get.snackbar(
        'Minimum order',
        'Minimum order ($minOrder) cannot be more than the stock '
            '(${product.stock})',
      );
      return false;
    }

    final specs = {'Size': size, 'Weight': weight, 'Length': length};
    for (final entry in specs.entries) {
      if (entry.value.length > maxSpecLength) {
        Get.snackbar(
          entry.key,
          '${entry.key} must be $maxSpecLength characters or fewer',
        );
        return false;
      }
    }

    try {
      await _productsRef.doc(product.id).update({
        'minOrderQuantity': minOrder,
        'size': size,
        'weight': weight,
        'length': length,
      });
      return true;
    } catch (e) {
      Get.snackbar('Update Failed', e.toString());
      return false;
    }
  }

  Future<void> toggleProductStatus(ProductModel product) async {
    try {
      await _productsRef.doc(product.id).update({
        'isActive': !product.isActive,
      });
    } catch (e) {
      Get.snackbar('Update Failed', e.toString());
    }
  }
}
