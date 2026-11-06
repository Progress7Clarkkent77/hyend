// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:hyend/controllers/orderController.dart';
// import 'package:hyend/controllers/theme_controller.dart';
// import 'package:hyend/models/orderItemModel.dart';
// import 'package:hyend/models/orderModel.dart';
// import 'package:hyend/pages/ecommerce_routes.dart';
// import 'package:hyend/pages/storeUi.dart';
// import 'package:hyend/userAuth/authController.dart';
// import 'package:intl/intl.dart';

// //==================================================
// // SHARED ORDER HELPERS
// //==================================================

// ThemeController _theme() => Get.isRegistered<ThemeController>()
//     ? Get.find<ThemeController>()
//     : Get.put(ThemeController());

// class _Status {
//   const _Status(this.label, this.color);

//   final String label;
//   final Color color;
// }

// _Status _statusOf(OrderModel order) {
//   if (order.delivered) return const _Status('Delivered', StorePalette.success);

//   final label = order.status.trim().isEmpty ? 'Pending' : order.status.trim();
//   final lower = label.toLowerCase();

//   if (lower.contains('cancel') || lower.contains('fail')) {
//     return _Status(label, StorePalette.danger);
//   }
//   if (lower == 'pending') return _Status(label, StorePalette.warning);
//   if (lower == 'delivered') return _Status(label, StorePalette.success);

//   return _Status(label, StorePalette.info);
// }

// /// Index of the order's current stage within [kTrackingStages].
// int _stageIndex(OrderModel order) {
//   if (order.delivered) return kTrackingStages.length - 1;

//   final i = kTrackingStages.indexOf(order.currentLocation);
//   return i < 0 ? 0 : i;
// }

// String _formatDate(DateTime? date) =>
//     date == null ? '' : DateFormat('dd MMM yyyy, hh:mm a').format(date);

// Widget _statusPill(_Status status) {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//     decoration: BoxDecoration(
//       color: status.color.withOpacity(0.12),
//       borderRadius: BorderRadius.circular(20),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 7,
//           height: 7,
//           decoration: BoxDecoration(
//             color: status.color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 7),
//         Text(
//           status.label,
//           style: TextStyle(
//             color: status.color,
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// //==================================================
// // ORDERS LIST
// //==================================================

// class OrdersPage extends StatelessWidget {
//   OrdersPage({super.key});

//   final OrderController orderCtrl = Get.find<OrderController>();
//   final ThemeController themeCtrl = _theme();

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final p = StorePalette(themeCtrl.isDarkMode.value);
//       final orders = orderCtrl.orders;

//       return Scaffold(
//         backgroundColor: p.bg,
//         appBar: AppBar(
//           backgroundColor: p.bg,
//           surfaceTintColor: Colors.transparent,
//           elevation: 0,
//           scrolledUnderElevation: 0,
//           iconTheme: IconThemeData(color: p.text),
//           centerTitle: false,
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'My orders',
//                 style: TextStyle(
//                   color: p.text,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               if (orders.isNotEmpty)
//                 Text(
//                   '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}',
//                   style: TextStyle(color: p.muted, fontSize: 12),
//                 ),
//             ],
//           ),
//         ),
//         body: orders.isEmpty
//             ? _empty(p)
//             : Align(
//                 alignment: Alignment.topCenter,
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 820),
//                   child: ListView.separated(
//                     padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
//                     itemCount: orders.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 16),
//                     itemBuilder: (_, i) => _orderCard(p, orders[i]),
//                   ),
//                 ),
//               ),
//       );
//     });
//   }

//   Widget _empty(StorePalette p) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 96,
//               height: 96,
//               decoration: BoxDecoration(
//                 color: p.tile,
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               child: Icon(
//                 Icons.receipt_long_outlined,
//                 size: 44,
//                 color: p.muted,
//               ),
//             ),
//             const SizedBox(height: 22),
//             Text(
//               'No orders yet',
//               style: TextStyle(
//                 color: p.text,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Your placed orders will appear here.',
//               style: TextStyle(color: p.muted, fontSize: 14),
//             ),
//             const SizedBox(height: 26),
//             ElevatedButton(
//               onPressed: () => Get.offAllNamed(EcommerceLiveRoutes.home),
//               style: ElevatedButton.styleFrom(
//                 elevation: 0,
//                 minimumSize: const Size(190, 52),
//                 backgroundColor: p.accent,
//                 foregroundColor: p.onAccent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 textStyle: const TextStyle(fontWeight: FontWeight.w700),
//               ),
//               child: const Text('Start shopping'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _orderCard(StorePalette p, OrderModel order) {
//     final status = _statusOf(order);
//     final stage = _stageIndex(order);
//     final progress = (stage + 1) / kTrackingStages.length;
//     final firstImage = order.items.isEmpty ? '' : order.items.first.image;
//     final extra = order.items.length - 1;
//     final location = order.currentLocation.isEmpty
//         ? kTrackingStages.first
//         : order.currentLocation;

//     return Material(
//       color: p.surface,
//       clipBehavior: Clip.antiAlias,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(24),
//         side: BorderSide(color: p.border),
//       ),
//       child: InkWell(
//         onTap: () {
//           orderCtrl.selectOrder(order);
//           Get.to(() => OrderDetailsPage());
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(18),
//           child: Column(
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Container(
//                         width: 76,
//                         height: 76,
//                         clipBehavior: Clip.antiAlias,
//                         decoration: BoxDecoration(
//                           color: p.tile,
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         child: Base64Image(
//                           data: firstImage,
//                           placeholder: Center(
//                             child: Icon(Icons.image_outlined, color: p.muted),
//                           ),
//                         ),
//                       ),
//                       if (extra > 0)
//                         Positioned(
//                           right: -6,
//                           bottom: -6,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 7,
//                               vertical: 3,
//                             ),
//                             decoration: BoxDecoration(
//                               color: p.accent,
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: p.surface, width: 2),
//                             ),
//                             child: Text(
//                               '+$extra',
//                               style: TextStyle(
//                                 color: p.onAccent,
//                                 fontSize: 10.5,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Order #${shortOrderId(order.id)}',
//                           style: TextStyle(
//                             color: p.text,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: -0.2,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _formatDate(order.createdAt),
//                           style: TextStyle(color: p.muted, fontSize: 12.5),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
//                           style: TextStyle(color: p.muted, fontSize: 12.5),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   _statusPill(status),
//                 ],
//               ),
//               const SizedBox(height: 18),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(6),
//                 child: LinearProgressIndicator(
//                   value: progress,
//                   minHeight: 6,
//                   color: status.color,
//                   backgroundColor: p.tile,
//                 ),
//               ),
//               const SizedBox(height: 14),
//               Row(
//                 children: [
//                   Icon(Icons.location_on_outlined, size: 17, color: p.muted),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       location,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: p.muted,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     formatNaira(order.totalAmount),
//                     style: TextStyle(
//                       color: p.text,
//                       fontSize: 17,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: -0.3,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Icon(Icons.chevron_right_rounded, color: p.muted),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// //==================================================
// // ORDER DETAILS
// //==================================================

// class OrderDetailsPage extends StatelessWidget {
//   OrderDetailsPage({super.key});

//   final OrderController orderCtrl = Get.find<OrderController>();
//   final AuthController authCtrl = Get.find<AuthController>();
//   final ThemeController themeCtrl = _theme();

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 900;

//     return Obx(() {
//       final p = StorePalette(themeCtrl.isDarkMode.value);
//       final selected = orderCtrl.selectedOrder.value;

//       // Prefer the live copy so tracking updates appear without reopening.
//       final order = selected == null
//           ? null
//           : (orderCtrl.orders.firstWhereOrNull((o) => o.id == selected.id) ??
//                 selected);

//       final appBar = AppBar(
//         backgroundColor: p.bg,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         iconTheme: IconThemeData(color: p.text),
//         centerTitle: false,
//         title: Text(
//           'Order details',
//           style: TextStyle(
//             color: p.text,
//             fontWeight: FontWeight.w800,
//             letterSpacing: -0.3,
//           ),
//         ),
//       );

//       if (order == null) {
//         return Scaffold(
//           backgroundColor: p.bg,
//           appBar: appBar,
//           body: Center(
//             child: Text('Order not found', style: TextStyle(color: p.muted)),
//           ),
//         );
//       }

//       final email = authCtrl.currentUser?.email ?? '';

//       return Scaffold(
//         backgroundColor: p.bg,
//         appBar: appBar,
//         body: Align(
//           alignment: Alignment.topCenter,
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 1100),
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
//               child: isDesktop
//                   ? Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           flex: 6,
//                           child: Column(
//                             children: [
//                               _header(p, order),
//                               const SizedBox(height: 18),
//                               _itemsCard(p, order),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 20),
//                         Expanded(
//                           flex: 5,
//                           child: Column(
//                             children: [
//                               _trackingCard(p, order),
//                               const SizedBox(height: 18),
//                               _deliveryCard(p, order, email),
//                               const SizedBox(height: 18),
//                               _summaryCard(p, order),
//                             ],
//                           ),
//                         ),
//                       ],
//                     )
//                   : Column(
//                       children: [
//                         _header(p, order),
//                         const SizedBox(height: 18),
//                         _trackingCard(p, order),
//                         const SizedBox(height: 18),
//                         _itemsCard(p, order),
//                         const SizedBox(height: 18),
//                         _deliveryCard(p, order, email),
//                         const SizedBox(height: 18),
//                         _summaryCard(p, order),
//                       ],
//                     ),
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   //==================================================
//   // HEADER
//   //==================================================

//   Widget _header(StorePalette p, OrderModel order) {
//     final status = _statusOf(order);

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(26),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF0B0B0C), Color(0xFF2C2C30)],
//         ),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x26000000),
//             blurRadius: 30,
//             offset: Offset(0, 14),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Order #${shortOrderId(order.id)}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: -0.4,
//                   ),
//                 ),
//               ),
//               InkWell(
//                 borderRadius: BorderRadius.circular(10),
//                 onTap: () {
//                   Clipboard.setData(ClipboardData(text: order.id));
//                   Get.snackbar(
//                     'Copied',
//                     'Order reference copied',
//                     snackPosition: SnackPosition.BOTTOM,
//                     margin: const EdgeInsets.all(14),
//                   );
//                 },
//                 child: const Padding(
//                   padding: EdgeInsets.all(6),
//                   child: Icon(
//                     Icons.copy_rounded,
//                     size: 18,
//                     color: Colors.white70,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             _formatDate(order.createdAt),
//             style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
//           ),
//           const SizedBox(height: 22),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Total paid',
//                       style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       formatNaira(order.totalAmount),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: -0.6,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 7,
//                       height: 7,
//                       decoration: BoxDecoration(
//                         color: status.color,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 7),
//                     Text(
//                       status.label,
//                       style: const TextStyle(
//                         color: Color(0xFF0B0B0C),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   //==================================================
//   // TRACKING TIMELINE
//   //==================================================

//   Widget _trackingCard(StorePalette p, OrderModel order) {
//     final current = _stageIndex(order);

//     return _card(
//       p,
//       title: 'Tracking',
//       child: Column(
//         children: [
//           for (var i = 0; i < kTrackingStages.length; i++)
//             _timelineStep(
//               p,
//               label: kTrackingStages[i],
//               done: i < current,
//               active: i == current,
//               isLast: i == kTrackingStages.length - 1,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _timelineStep(
//     StorePalette p, {
//     required String label,
//     required bool done,
//     required bool active,
//     required bool isLast,
//   }) {
//     final reached = done || active;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           children: [
//             Container(
//               width: 22,
//               height: 22,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: reached ? p.accent : Colors.transparent,
//                 border: Border.all(
//                   color: reached ? p.accent : p.border,
//                   width: 2,
//                 ),
//               ),
//               child: done
//                   ? Icon(Icons.check_rounded, size: 13, color: p.onAccent)
//                   : (active
//                         ? Center(
//                             child: Container(
//                               width: 8,
//                               height: 8,
//                               decoration: BoxDecoration(
//                                 color: p.onAccent,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           )
//                         : null),
//             ),
//             if (!isLast)
//               Container(
//                 width: 2,
//                 height: 26,
//                 color: done ? p.accent : p.border,
//               ),
//           ],
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: SizedBox(
//             height: 22,
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   color: reached ? p.text : p.muted,
//                   fontSize: 14,
//                   fontWeight: active ? FontWeight.w800 : FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         if (active)
//           Padding(
//             padding: const EdgeInsets.only(top: 2),
//             child: Text(
//               'Current',
//               style: TextStyle(
//                 color: p.muted,
//                 fontSize: 11.5,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   //==================================================
//   // ITEMS
//   //==================================================

//   Widget _itemsCard(StorePalette p, OrderModel order) {
//     return _card(
//       p,
//       title: 'Items (${order.items.length})',
//       child: Column(
//         children: [
//           for (var i = 0; i < order.items.length; i++) ...[
//             _itemRow(p, order.items[i]),
//             if (i != order.items.length - 1)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 child: Divider(height: 1, color: p.border),
//               ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _itemRow(StorePalette p, OrderItemModel item) {
//     final double lineTotal = item.price * item.quantity;

//     return Row(
//       children: [
//         Container(
//           width: 64,
//           height: 64,
//           clipBehavior: Clip.antiAlias,
//           decoration: BoxDecoration(
//             color: p.tile,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Base64Image(
//             data: item.image,
//             placeholder: Center(
//               child: Icon(Icons.image_outlined, color: p.muted),
//             ),
//           ),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 item.productName,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: p.text,
//                   fontSize: 14.5,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '${item.quantity} × ${formatNaira(item.price)}',
//                 style: TextStyle(color: p.muted, fontSize: 12.5),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           formatNaira(lineTotal),
//           style: TextStyle(
//             color: p.text,
//             fontSize: 14.5,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ],
//     );
//   }

//   //==================================================
//   // DELIVERY
//   //==================================================

//   Widget _deliveryCard(StorePalette p, OrderModel order, String email) {
//     return _card(
//       p,
//       title: 'Delivery details',
//       child: Column(
//         children: [
//           _info(p, Icons.person_outline_rounded, 'Name', order.customerName),
//           if (email.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             _info(p, Icons.mail_outline_rounded, 'Email', email),
//           ],
//           const SizedBox(height: 16),
//           _info(p, Icons.phone_outlined, 'Phone', order.customerPhoneNumber),
//           const SizedBox(height: 16),
//           _info(
//             p,
//             Icons.home_outlined,
//             'Address',
//             order.customerDeliveryAddress,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _info(StorePalette p, IconData icon, String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 38,
//           height: 38,
//           decoration: BoxDecoration(
//             color: p.tile,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, size: 19, color: p.text),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label, style: TextStyle(color: p.muted, fontSize: 12)),
//               const SizedBox(height: 2),
//               Text(
//                 value.isEmpty ? '—' : value,
//                 style: TextStyle(
//                   color: p.text,
//                   fontSize: 14,
//                   height: 1.35,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   //==================================================
//   // SUMMARY
//   //==================================================

//   Widget _summaryCard(StorePalette p, OrderModel order) {
//     Widget row(String label, String value, {bool bold = false}) {
//       return Row(
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: bold ? p.text : p.muted,
//                 fontSize: bold ? 16 : 14,
//                 fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: p.text,
//               fontSize: bold ? 20 : 14.5,
//               fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
//             ),
//           ),
//         ],
//       );
//     }

//     return _card(
//       p,
//       title: 'Payment summary',
//       child: Column(
//         children: [
//           row('Subtotal', formatNaira(order.subtotal)),
//           const SizedBox(height: 12),
//           row(
//             'Delivery fee',
//             order.deliveryFee > 0 ? formatNaira(order.deliveryFee) : 'Free',
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: Divider(height: 1, color: p.border),
//           ),
//           row('Total', formatNaira(order.totalAmount), bold: true),
//         ],
//       ),
//     );
//   }

//   //==================================================
//   // CARD SHELL
//   //==================================================

//   Widget _card(StorePalette p, {required String title, required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: p.surface,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: p.border),
//         boxShadow: p.shadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: p.text,
//               fontSize: 17,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -0.3,
//             ),
//           ),
//           const SizedBox(height: 18),
//           child,
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/orderController.dart';
import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/models/orderItemModel.dart';
import 'package:hyend/models/orderModel.dart';
import 'package:hyend/pages/ecommerce_routes.dart';
import 'package:hyend/pages/storeUi.dart';
import 'package:hyend/userAuth/authController.dart';
import 'package:intl/intl.dart';

//==================================================
// SHARED ORDER HELPERS
//==================================================

ThemeController _theme() => Get.isRegistered<ThemeController>()
    ? Get.find<ThemeController>()
    : Get.put(ThemeController());

class _Status {
  const _Status(this.label, this.color);

  final String label;
  final Color color;
}

_Status _statusOf(OrderModel order) {
  if (order.delivered) return const _Status('Delivered', StorePalette.success);

  final label = order.status.trim().isEmpty ? 'Pending' : order.status.trim();
  final lower = label.toLowerCase();

  if (lower.contains('cancel') || lower.contains('fail')) {
    return _Status(label, StorePalette.danger);
  }
  if (lower == 'pending') return _Status(label, StorePalette.warning);
  if (lower == 'delivered') return _Status(label, StorePalette.success);

  return _Status(label, StorePalette.info);
}

/// Index of the order's current stage within [kTrackingStages].
int _stageIndex(OrderModel order) {
  if (order.delivered) return kTrackingStages.length - 1;

  final i = kTrackingStages.indexOf(order.currentLocation);
  return i < 0 ? 0 : i;
}

String _formatDate(DateTime? date) =>
    date == null ? '' : DateFormat('dd MMM yyyy, hh:mm a').format(date);

Widget _statusPill(_Status status) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: status.color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          status.label,
          style: TextStyle(
            color: status.color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

//==================================================
// ORDERS LIST
//==================================================

class OrdersPage extends StatelessWidget {
  OrdersPage({super.key});

  final OrderController orderCtrl = Get.find<OrderController>();
  final ThemeController themeCtrl = _theme();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = StorePalette(themeCtrl.isDarkMode.value);
      final orders = orderCtrl.orders;
      final awaiting = orderCtrl.awaitingCount.value;

      return Scaffold(
        backgroundColor: p.bg,
        appBar: AppBar(
          backgroundColor: p.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: p.text),
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My orders',
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (orders.isNotEmpty)
                Text(
                  '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}',
                  style: TextStyle(color: p.muted, fontSize: 12),
                ),
            ],
          ),
        ),
        body: orders.isEmpty
            ? _empty(p)
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    itemCount: orders.length + (awaiting > 0 ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      if (awaiting > 0) {
                        if (i == 0) return _awaitingBanner(p, awaiting);
                        return _orderCard(p, orders[i - 1]);
                      }
                      return _orderCard(p, orders[i]);
                    },
                  ),
                ),
              ),
      );
    });
  }

  Widget _awaitingBanner(StorePalette p, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StorePalette.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StorePalette.warning.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat_rounded, size: 20, color: StorePalette.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1
                  ? '1 order is waiting for HyEnd to confirm it with you on '
                        'WhatsApp. It will show up here for tracking once agreed.'
                  : '$count orders are waiting for HyEnd to confirm them with '
                        'you on WhatsApp. They will show up here for tracking '
                        'once agreed.',
              style: TextStyle(
                color: p.text,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(StorePalette p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: p.tile,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 44,
                color: p.muted,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No orders yet',
              style: TextStyle(
                color: p.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              orderCtrl.awaitingCount.value > 0
                  ? 'Your order is with HyEnd. It will appear here once we '
                        'confirm it with you on WhatsApp.'
                  : 'Orders confirmed by HyEnd on WhatsApp will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.muted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(EcommerceLiveRoutes.home),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size(190, 52),
                backgroundColor: p.accent,
                foregroundColor: p.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Start shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(StorePalette p, OrderModel order) {
    final status = _statusOf(order);
    final stage = _stageIndex(order);
    final progress = (stage + 1) / kTrackingStages.length;
    final firstImage = order.items.isEmpty ? '' : order.items.first.image;
    final extra = order.items.length - 1;
    final location = order.currentLocation.isEmpty
        ? kTrackingStages.first
        : order.currentLocation;

    return Material(
      color: p.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: p.border),
      ),
      child: InkWell(
        onTap: () {
          orderCtrl.selectOrder(order);
          Get.to(() => OrderDetailsPage());
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: p.tile,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Base64Image(
                          data: firstImage,
                          placeholder: Center(
                            child: Icon(Icons.image_outlined, color: p.muted),
                          ),
                        ),
                      ),
                      if (extra > 0)
                        Positioned(
                          right: -6,
                          bottom: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: p.accent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: p.surface, width: 2),
                            ),
                            child: Text(
                              '+$extra',
                              style: TextStyle(
                                color: p.onAccent,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${shortOrderId(order.id)}',
                          style: TextStyle(
                            color: p.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: TextStyle(color: p.muted, fontSize: 12.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                          style: TextStyle(color: p.muted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusPill(status),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: status.color,
                  backgroundColor: p.tile,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 17, color: p.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    formatNaira(order.totalAmount),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: p.muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==================================================
// ORDER DETAILS
//==================================================

class OrderDetailsPage extends StatelessWidget {
  OrderDetailsPage({super.key});

  final OrderController orderCtrl = Get.find<OrderController>();
  final AuthController authCtrl = Get.find<AuthController>();
  final ThemeController themeCtrl = _theme();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Obx(() {
      final p = StorePalette(themeCtrl.isDarkMode.value);
      final selected = orderCtrl.selectedOrder.value;

      // Prefer the live copy so tracking updates appear without reopening.
      final order = selected == null
          ? null
          : (orderCtrl.orders.firstWhereOrNull((o) => o.id == selected.id) ??
                selected);

      final appBar = AppBar(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: p.text),
        centerTitle: false,
        title: Text(
          'Order details',
          style: TextStyle(
            color: p.text,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      );

      if (order == null) {
        return Scaffold(
          backgroundColor: p.bg,
          appBar: appBar,
          body: Center(
            child: Text('Order not found', style: TextStyle(color: p.muted)),
          ),
        );
      }

      final email = authCtrl.currentUser?.email ?? '';

      return Scaffold(
        backgroundColor: p.bg,
        appBar: appBar,
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _header(p, order),
                              const SizedBox(height: 18),
                              _itemsCard(p, order),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _trackingCard(p, order),
                              const SizedBox(height: 18),
                              _deliveryCard(p, order, email),
                              const SizedBox(height: 18),
                              _summaryCard(p, order),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _header(p, order),
                        const SizedBox(height: 18),
                        _trackingCard(p, order),
                        const SizedBox(height: 18),
                        _itemsCard(p, order),
                        const SizedBox(height: 18),
                        _deliveryCard(p, order, email),
                        const SizedBox(height: 18),
                        _summaryCard(p, order),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  //==================================================
  // HEADER
  //==================================================

  Widget _header(StorePalette p, OrderModel order) {
    final status = _statusOf(order);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0B0C), Color(0xFF2C2C30)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${shortOrderId(order.id)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: order.id));
                  Get.snackbar(
                    'Copied',
                    'Order reference copied',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(14),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(order.createdAt),
            style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatNaira(order.totalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      status.label,
                      style: const TextStyle(
                        color: Color(0xFF0B0B0C),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //==================================================
  // TRACKING TIMELINE
  //==================================================

  Widget _trackingCard(StorePalette p, OrderModel order) {
    final current = _stageIndex(order);

    return _card(
      p,
      title: 'Tracking',
      child: Column(
        children: [
          for (var i = 0; i < kTrackingStages.length; i++)
            _timelineStep(
              p,
              label: kTrackingStages[i],
              done: i < current,
              active: i == current,
              isLast: i == kTrackingStages.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _timelineStep(
    StorePalette p, {
    required String label,
    required bool done,
    required bool active,
    required bool isLast,
  }) {
    final reached = done || active;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? p.accent : Colors.transparent,
                border: Border.all(
                  color: reached ? p.accent : p.border,
                  width: 2,
                ),
              ),
              child: done
                  ? Icon(Icons.check_rounded, size: 13, color: p.onAccent)
                  : (active
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: p.onAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 26,
                color: done ? p.accent : p.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 22,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  color: reached ? p.text : p.muted,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        if (active)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Current',
              style: TextStyle(
                color: p.muted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  //==================================================
  // ITEMS
  //==================================================

  Widget _itemsCard(StorePalette p, OrderModel order) {
    return _card(
      p,
      title: 'Items (${order.items.length})',
      child: Column(
        children: [
          for (var i = 0; i < order.items.length; i++) ...[
            _itemRow(p, order.items[i]),
            if (i != order.items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: p.border),
              ),
          ],
        ],
      ),
    );
  }

  Widget _itemRow(StorePalette p, OrderItemModel item) {
    final double lineTotal = item.price * item.quantity;

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.tile,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Base64Image(
            data: item.image,
            placeholder: Center(
              child: Icon(Icons.image_outlined, color: p.muted),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity} × ${formatNaira(item.price)}',
                style: TextStyle(color: p.muted, fontSize: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          formatNaira(lineTotal),
          style: TextStyle(
            color: p.text,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  //==================================================
  // DELIVERY
  //==================================================

  Widget _deliveryCard(StorePalette p, OrderModel order, String email) {
    return _card(
      p,
      title: 'Delivery details',
      child: Column(
        children: [
          _info(p, Icons.person_outline_rounded, 'Name', order.customerName),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 16),
            _info(p, Icons.mail_outline_rounded, 'Email', email),
          ],
          const SizedBox(height: 16),
          _info(p, Icons.phone_outlined, 'Phone', order.customerPhoneNumber),
          const SizedBox(height: 16),
          _info(
            p,
            Icons.home_outlined,
            'Address',
            order.customerDeliveryAddress,
          ),
        ],
      ),
    );
  }

  Widget _info(StorePalette p, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: p.tile,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: p.text),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: p.muted, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '—' : value,
                style: TextStyle(
                  color: p.text,
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //==================================================
  // SUMMARY
  //==================================================

  Widget _summaryCard(StorePalette p, OrderModel order) {
    Widget row(String label, String value, {bool bold = false}) {
      return Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: bold ? p.text : p.muted,
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: p.text,
              fontSize: bold ? 20 : 14.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return _card(
      p,
      title: 'Price summary',
      child: Column(
        children: [
          row('Subtotal', formatNaira(order.subtotal)),
          const SizedBox(height: 12),
          row(
            'Service fee',
            order.deliveryFee > 0 ? formatNaira(order.deliveryFee) : 'Free',
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: p.tile,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                Icon(Icons.public_rounded, size: 16, color: p.text),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What the service fee covers',
                        style: TextStyle(
                          color: p.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Shipping, customs clearing and other handling '
                        'charges for your bulk order, from our suppliers '
                        'to you.',
                        style: TextStyle(
                          color: p.muted,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: p.border),
          ),
          row('Total', formatNaira(order.totalAmount), bold: true),
        ],
      ),
    );
  }

  //==================================================
  // CARD SHELL
  //==================================================

  Widget _card(StorePalette p, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.border),
        boxShadow: p.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: p.text,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
