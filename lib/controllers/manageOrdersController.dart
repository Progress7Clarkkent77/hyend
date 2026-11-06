import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/storeConfig.dart';
import 'package:hyend/models/orderModel.dart';

class ManageOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;

  final List<String> trackingLocations = const [
    'Order Received',
    'Processing',
    'Packed',
    'Dispatched',
    'In Transit',
    'Arrived Local Hub',
    'Out For Delivery',
    'Delivered',
  ];

  @override
  void onInit() {
    super.onInit();
    listenOrders();
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    super.onClose();
  }

  void listenOrders() {
    isLoading.value = true;

    _ordersSub?.cancel();

    _ordersSub = _firestore
        .collection(StoreConfig.ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            orders.assignAll(
              snapshot.docs.map((e) => OrderModel.fromMap(e.id, e.data())),
            );
            isLoading.value = false;
          },
          onError: (Object e) {
            isLoading.value = false;
            Get.snackbar('Error', 'Unable to load orders');
          },
        );
  }

  Future<void> updateOrder({
    required String orderId,
    required bool delivered,
    required String currentLocation,
    required String status,
  }) async {
    try {
      await _firestore
          .collection(StoreConfig.ordersCollection)
          .doc(orderId)
          .update({
            'delivered': delivered,
            'status': status,
            'currentLocation': currentLocation,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      Get.snackbar('Success', 'Order updated');
    } catch (e) {
      Get.snackbar('Update Failed', e.toString());
    }
  }
}
