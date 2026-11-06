import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/storeConfig.dart';
import 'package:hyend/models/productModel.dart';

class EcommerceStoreController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //==================================================
  // PRODUCTS
  //==================================================

  final RxList<ProductModel> products = <ProductModel>[].obs;

  /// Every product that matches the current search/category (ALL products are
  /// searchable). Only a slice of it is ever shown on screen.
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  /// The slice of [filteredProducts] actually rendered (8 at a time).
  final RxList<ProductModel> visibleProducts = <ProductModel>[].obs;

  static const int pageSize = 8;
  final RxBool hasMore = false.obs;

  /// Bumps whenever the list is reset (new search / category) so the page
  /// can jump back to the top.
  final RxInt pageResetTick = 0.obs;
  bool _loadingMore = false;

  //==================================================
  // CATEGORIES
  //==================================================

  final RxList<String> categories = <String>['All'].obs;
  final RxString selectedCategory = 'All'.obs;

  //==================================================
  // SEARCH
  //==================================================

  final RxString searchText = ''.obs;
  final TextEditingController searchCtrl = TextEditingController();

  //==================================================
  // STATE
  //==================================================

  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;

  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _productsSubscription;

  //==================================================
  // LIFECYCLE
  //==================================================

  @override
  void onInit() {
    super.onInit();
    initializeStore();
  }

  @override
  void onClose() {
    _productsSubscription?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }

  //==================================================
  // INITIALIZE
  //==================================================

  Future<void> initializeStore() async {
    if (isInitialized.value) return;

    isLoading.value = true;

    try {
      await loadProducts();
      isInitialized.value = true;
    } catch (e) {
      debugPrint('Store initialization failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  //==================================================
  // LOAD PRODUCTS (REALTIME)
  //==================================================

  Future<void> loadProducts() async {
    await _productsSubscription?.cancel();

    _productsSubscription = _firestore
        .collection(StoreConfig.productsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            products.assignAll(
              snapshot.docs.map((d) => ProductModel.fromMap(d.id, d.data())),
            );

            _loadCategoriesFromProducts();
            // keep the user's scroll depth when data changes in realtime
            filterProducts(resetPage: false);
          },
          onError: (Object error) => debugPrint('Product stream error: $error'),
        );
  }

  void _loadCategoriesFromProducts() {
    final unique =
        products
            .map((e) => e.category.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    categories.assignAll(['All', ...unique]);

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
  }

  //==================================================
  // FILTER
  //==================================================

  void filterProducts({bool resetPage = true}) {
    Iterable<ProductModel> result = products;

    if (selectedCategory.value != 'All') {
      result = result.where((p) => p.category == selectedCategory.value);
    }

    final query = searchText.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where(
        (p) =>
            p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.price.toString().contains(query),
      );
    }

    filteredProducts.assignAll(result);

    final count = resetPage
        ? pageSize
        : math.max(pageSize, visibleProducts.length);
    final shown = math.min(count, filteredProducts.length);

    visibleProducts.assignAll(filteredProducts.take(shown));
    hasMore.value = shown < filteredProducts.length;

    if (resetPage) pageResetTick.value++;
  }

  /// Appends the next [pageSize] products (Temu-style infinite scroll).
  Future<void> loadMore() async {
    if (_loadingMore || !hasMore.value) return;
    _loadingMore = true;

    // tiny delay so the spinner is seen and the append doesn't land mid-fling
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final start = visibleProducts.length;
    final end = math.min(start + pageSize, filteredProducts.length);

    if (start < end) {
      visibleProducts.addAll(filteredProducts.sublist(start, end));
    }
    hasMore.value = end < filteredProducts.length;

    _loadingMore = false;
  }

  void updateSearch(String value) {
    searchText.value = value;
    filterProducts();
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    filterProducts();
  }

  void selectProduct(ProductModel product) => selectedProduct.value = product;

  //==================================================
  // REFRESH / RESET
  //==================================================

  Future<void> refreshStore() async {
    isInitialized.value = false;
    await initializeStore();
  }

  Future<void> resetStore() async {
    await _productsSubscription?.cancel();

    products.clear();
    filteredProducts.clear();
    visibleProducts.clear();
    hasMore.value = false;
    categories.assignAll(['All']);
    selectedCategory.value = 'All';
    searchText.value = '';
    searchCtrl.clear();
    isInitialized.value = false;
  }
}
