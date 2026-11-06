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
