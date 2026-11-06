import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/storeConfig.dart';

class EcommerceAdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;

  final RxInt productCount = 0.obs;
  final RxInt orderCount = 0.obs;
  final RxInt customerCount = 0.obs;

  final RxDouble revenue = 0.0.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;

  @override
  void onInit() {
    super.onInit();
    startRealtimeListeners();
  }

  /// (Re)starts the realtime listeners. Safe to call multiple times.
  void startRealtimeListeners() {
    isLoading.value = true;

    _productsSub?.cancel();
    _ordersSub?.cancel();

    _productsSub = _firestore
        .collection(StoreConfig.productsCollection)
        .snapshots()
        .listen(
          (snapshot) => productCount.value = snapshot.docs.length,
          onError: (Object e) => Get.log('Dashboard products error: $e'),
        );

    _ordersSub = _firestore
        .collection(StoreConfig.ordersCollection)
        .snapshots()
        .listen(
          (snapshot) {
            final customers = <String>{};
            double totalRevenue = 0;

            for (final doc in snapshot.docs) {
              final data = doc.data();

              final customerUid = (data['customerUid'] ?? '').toString();
              if (customerUid.isNotEmpty) customers.add(customerUid);

              // Only delivered orders count towards revenue.
              if (data['delivered'] == true) {
                totalRevenue += (data['totalAmount'] as num? ?? 0).toDouble();
              }
            }

            orderCount.value = snapshot.docs.length;
            customerCount.value = customers.length;
            revenue.value = totalRevenue;
            isLoading.value = false;
          },
          onError: (Object e) {
            Get.log('Dashboard orders error: $e');
            isLoading.value = false;
          },
        );
  }

  Future<void> loadDashboard() async => startRealtimeListeners();

  String formatAmount(double value) {
    if (value >= 1000000) return '₦${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '₦${(value / 1000).toStringAsFixed(1)}K';
    return '₦${value.toStringAsFixed(2)}';
  }

  @override
  void onClose() {
    _productsSub?.cancel();
    _ordersSub?.cancel();
    super.onClose();
  }
}
