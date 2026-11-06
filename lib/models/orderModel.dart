import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hyend/models/orderItemModel.dart';

class OrderModel {
  final String id;

  final String customerUid;

  final String customerName;
  final String customerPhoneNumber;
  final String customerDeliveryAddress;

  final double subtotal;
  final double deliveryFee;
  final double totalAmount;

  /// 'enugu' or 'outside' ('' for older orders).
  final String deliveryZone;

  final bool delivered;

  final String currentLocation;

  final String status;

  final List<OrderItemModel> items;

  final DateTime? createdAt;

  OrderModel({
    required this.id,

    required this.customerUid,
    required this.customerName,
    required this.customerPhoneNumber,
    required this.customerDeliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    this.deliveryZone = '',
    required this.delivered,
    required this.currentLocation,
    required this.status,
    required this.items,
    this.createdAt,
  });

  /// Human readable delivery location ('' for older orders).
  String get deliveryZoneLabel => deliveryZone == 'outside'
      ? 'Outside Enugu State'
      : deliveryZone == 'enugu'
      ? 'Within Enugu State'
      : '';

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,

      customerUid: data['customerUid'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhoneNumber: data['customerPhoneNumber'] ?? '',
      customerDeliveryAddress: data['customerDeliveryAddress'] ?? '',
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      deliveryZone: data['deliveryZone'] ?? '',
      delivered: data['delivered'] ?? false,
      currentLocation: data['currentLocation'] ?? '',
      status: data['status'] ?? 'Pending',
      items: (data['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerUid': customerUid,
      'customerName': customerName,
      'customerPhoneNumber': customerPhoneNumber,
      'customerDeliveryAddress': customerDeliveryAddress,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'deliveryZone': deliveryZone,
      'delivered': delivered,
      'currentLocation': currentLocation,
      'status': status,
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
