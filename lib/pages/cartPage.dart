// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:hyend/controllers/ecommerceCartController.dart';
// // import 'package:hyend/controllers/theme_controller.dart';
// // import 'package:hyend/models/cartItemModel.dart';
// // import 'package:hyend/models/productModel.dart';
// // import 'package:hyend/pages/deliveryZoneSelector.dart';
// // import 'package:hyend/pages/ecommerce_routes.dart';
// // import 'package:hyend/pages/storeUi.dart';

// // class CartPage extends StatelessWidget {
// //   CartPage({super.key});

// //   final EcommerceLiveNavController nav = Get.find();
// //   final EcommerceCartController cartCtrl = Get.find();

// //   // ThemeController is created at login; fall back safely on cold start.
// //   final ThemeController themeCtrl = Get.isRegistered<ThemeController>()
// //       ? Get.find<ThemeController>()
// //       : Get.put(ThemeController());

// //   bool _unavailable(CartItemModel item) =>
// //       !item.product.isActive || item.product.stock <= 0;

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDesktop = MediaQuery.of(context).size.width > 900;

// //     return Obx(() {
// //       final p = StorePalette(themeCtrl.isDarkMode.value);
// //       final items = cartCtrl.cartItems;
// //       final isEmpty = items.isEmpty;
// //       final count = cartCtrl.cartCount;

// //       return Scaffold(
// //         backgroundColor: p.bg,
// //         appBar: AppBar(
// //           backgroundColor: p.bg,
// //           surfaceTintColor: Colors.transparent,
// //           elevation: 0,
// //           scrolledUnderElevation: 0,
// //           iconTheme: IconThemeData(color: p.text),
// //           centerTitle: false,
// //           title: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 'Cart',
// //                 style: TextStyle(
// //                   color: p.text,
// //                   fontWeight: FontWeight.w800,
// //                   letterSpacing: -0.3,
// //                 ),
// //               ),
// //               if (!isEmpty)
// //                 Text(
// //                   '$count ${count == 1 ? 'item' : 'items'}',
// //                   style: TextStyle(
// //                     color: p.muted,
// //                     fontSize: 12,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //             ],
// //           ),
// //           actions: [
// //             if (!isEmpty)
// //               TextButton(
// //                 onPressed: () => _confirmClear(p),
// //                 child: Text(
// //                   'Clear',
// //                   style: TextStyle(
// //                     color: StorePalette.danger,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //               ),
// //             const SizedBox(width: 8),
// //           ],
// //         ),
// //         bottomNavigationBar: (isEmpty || isDesktop) ? null : _bottomBar(p),
// //         body: isEmpty
// //             ? _emptyState(p)
// //             : Align(
// //                 alignment: Alignment.topCenter,
// //                 child: ConstrainedBox(
// //                   constraints: const BoxConstraints(maxWidth: 1200),
// //                   child: isDesktop
// //                       ? Row(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Expanded(
// //                               child: _itemsList(p, includeSummary: false),
// //                             ),
// //                             SizedBox(
// //                               width: 400,
// //                               child: SingleChildScrollView(
// //                                 padding: const EdgeInsets.fromLTRB(
// //                                   0,
// //                                   8,
// //                                   20,
// //                                   24,
// //                                 ),
// //                                 child: _summaryCard(p, withButton: true),
// //                               ),
// //                             ),
// //                           ],
// //                         )
// //                       : _itemsList(p, includeSummary: true),
// //                 ),
// //               ),
// //       );
// //     });
// //   }

// //   //==================================================
// //   // EMPTY STATE
// //   //==================================================

// //   Widget _emptyState(StorePalette p) {
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(32),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               width: 96,
// //               height: 96,
// //               decoration: BoxDecoration(
// //                 color: p.tile,
// //                 borderRadius: BorderRadius.circular(28),
// //               ),
// //               child: Icon(
// //                 Icons.shopping_bag_outlined,
// //                 size: 44,
// //                 color: p.muted,
// //               ),
// //             ),
// //             const SizedBox(height: 22),
// //             Text(
// //               'Your cart is empty',
// //               style: TextStyle(
// //                 color: p.text,
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.w800,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'Looks like you haven\'t added anything yet.',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(color: p.muted, fontSize: 14),
// //             ),
// //             const SizedBox(height: 26),
// //             ElevatedButton(
// //               onPressed: () => Get.offAllNamed(EcommerceLiveRoutes.home),
// //               style: ElevatedButton.styleFrom(
// //                 elevation: 0,
// //                 minimumSize: const Size(190, 52),
// //                 backgroundColor: p.accent,
// //                 foregroundColor: p.onAccent,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 textStyle: const TextStyle(fontWeight: FontWeight.w700),
// //               ),
// //               child: const Text('Start shopping'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   //==================================================
// //   // ITEMS
// //   //==================================================

// //   Widget _itemsList(StorePalette p, {required bool includeSummary}) {
// //     final items = cartCtrl.cartItems.toList();

// //     return ListView(
// //       padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
// //       children: [
// //         for (final item in items) ...[
// //           _itemCard(p, item),
// //           const SizedBox(height: 14),
// //         ],
// //         if (includeSummary) ...[
// //           const SizedBox(height: 6),
// //           _summaryCard(p, withButton: false),
// //         ],
// //       ],
// //     );
// //   }

// //   Widget _colorTag(StorePalette p, CartItemModel item) {
// //     return Container(
// //       padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
// //       decoration: BoxDecoration(
// //         color: p.tile,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: p.border),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Container(
// //             width: 14,
// //             height: 14,
// //             decoration: BoxDecoration(
// //               color: item.color,
// //               shape: BoxShape.circle,
// //               border: Border.all(color: p.border),
// //             ),
// //           ),
// //           const SizedBox(width: 6),
// //           Text(
// //             item.colorName,
// //             style: TextStyle(
// //               color: p.text,
// //               fontSize: 11.5,
// //               fontWeight: FontWeight.w700,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _itemCard(StorePalette p, CartItemModel item) {
// //     final product = item.product;
// //     final unavailable = _unavailable(item);
// //     // stock is shared by every colour of the product
// //     final atLimit =
// //         product.stock > 0 && cartCtrl.qtyInCartFor(product.id) >= product.stock;

// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: p.surface,
// //         borderRadius: BorderRadius.circular(22),
// //         border: Border.all(
// //           color: unavailable ? StorePalette.danger.withOpacity(0.5) : p.border,
// //         ),
// //         boxShadow: p.shadow,
// //       ),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Product image (rounded square)
// //           Container(
// //             width: 96,
// //             height: 96,
// //             clipBehavior: Clip.antiAlias,
// //             decoration: BoxDecoration(
// //               color: p.tile,
// //               borderRadius: BorderRadius.circular(18),
// //             ),
// //             child: Base64Image(
// //               data: item.image,
// //               placeholder: Center(
// //                 child: Icon(Icons.image_outlined, color: p.muted),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 14),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Expanded(
// //                       child: Text(
// //                         product.name,
// //                         maxLines: 2,
// //                         overflow: TextOverflow.ellipsis,
// //                         style: TextStyle(
// //                           color: p.text,
// //                           fontSize: 15,
// //                           height: 1.25,
// //                           fontWeight: FontWeight.w700,
// //                         ),
// //                       ),
// //                     ),
// //                     InkWell(
// //                       onTap: () => cartCtrl.removeItem(item),
// //                       borderRadius: BorderRadius.circular(10),
// //                       child: Padding(
// //                         padding: const EdgeInsets.all(4),
// //                         child: Icon(
// //                           Icons.close_rounded,
// //                           size: 20,
// //                           color: p.muted,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 if (item.hasColor) ...[
// //                   const SizedBox(height: 6),
// //                   _colorTag(p, item),
// //                 ],
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   unavailable
// //                       ? 'No longer available'
// //                       : '${formatNaira(product.price)} each',
// //                   style: TextStyle(
// //                     color: unavailable ? StorePalette.danger : p.muted,
// //                     fontSize: 12.5,
// //                     fontWeight: unavailable ? FontWeight.w600 : FontWeight.w400,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Row(
// //                   children: [
// //                     _stepper(p, item, atLimit: atLimit),
// //                     const Spacer(),
// //                     Text(
// //                       formatNaira(item.total),
// //                       style: TextStyle(
// //                         color: p.text,
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.w800,
// //                         letterSpacing: -0.3,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 if (atLimit)
// //                   Padding(
// //                     padding: const EdgeInsets.only(top: 8),
// //                     child: Text(
// //                       'Maximum available quantity',
// //                       style: TextStyle(
// //                         color: StorePalette.warning,
// //                         fontSize: 11.5,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _stepper(StorePalette p, CartItemModel item, {required bool atLimit}) {
// //     Widget button(IconData icon, VoidCallback? onTap) {
// //       return InkWell(
// //         onTap: onTap,
// //         borderRadius: BorderRadius.circular(10),
// //         child: SizedBox(
// //           width: 34,
// //           height: 34,
// //           child: Icon(
// //             icon,
// //             size: 18,
// //             color: onTap == null ? p.muted.withOpacity(0.5) : p.text,
// //           ),
// //         ),
// //       );
// //     }

// //     return Container(
// //       padding: const EdgeInsets.all(3),
// //       decoration: BoxDecoration(
// //         color: p.tile,
// //         borderRadius: BorderRadius.circular(13),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           button(
// //             Icons.remove_rounded,
// //             item.quantity > 1 ? () => cartCtrl.decreaseQty(item) : null,
// //           ),
// //           SizedBox(
// //             width: 30,
// //             child: Text(
// //               '${item.quantity}',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 color: p.text,
// //                 fontSize: 14.5,
// //                 fontWeight: FontWeight.w800,
// //               ),
// //             ),
// //           ),
// //           button(
// //             Icons.add_rounded,
// //             atLimit || _unavailable(item)
// //                 ? null
// //                 : () => cartCtrl.increaseQty(item),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   //==================================================
// //   // SUMMARY
// //   //==================================================

// //   String _feeText(double fee) => fee > 0 ? formatNaira(fee) : 'Free';

// //   bool get _hasUnavailable => cartCtrl.cartItems.any(_unavailable);

// //   Widget _summaryCard(StorePalette p, {required bool withButton}) {
// //     return Container(
// //       padding: const EdgeInsets.all(22),
// //       decoration: BoxDecoration(
// //         color: p.surface,
// //         borderRadius: BorderRadius.circular(24),
// //         border: Border.all(color: p.border),
// //         boxShadow: p.shadow,
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'Order summary',
// //             style: TextStyle(
// //               color: p.text,
// //               fontSize: 18,
// //               fontWeight: FontWeight.w800,
// //               letterSpacing: -0.3,
// //             ),
// //           ),
// //           const SizedBox(height: 18),
// //           _row(
// //             p,
// //             'Subtotal (${cartCtrl.cartCount} items)',
// //             formatNaira(cartCtrl.subtotal),
// //           ),
// //           const SizedBox(height: 18),
// //           Text(
// //             'Deliver to',
// //             style: TextStyle(
// //               color: p.text,
// //               fontSize: 14,
// //               fontWeight: FontWeight.w800,
// //             ),
// //           ),
// //           const SizedBox(height: 10),
// //           DeliveryZoneSelector(
// //             zone: cartCtrl.deliveryZone.value,
// //             onChanged: cartCtrl.setDeliveryZone,
// //             tile: p.tile,
// //             border: p.border,
// //             accent: p.accent,
// //             onAccent: p.onAccent,
// //             text: p.text,
// //             muted: p.muted,
// //             enuguSubtitle: _feeText(
// //               cartCtrl.deliveryFeeForZone(DeliveryZone.enugu),
// //             ),
// //             outsideSubtitle: _feeText(
// //               cartCtrl.deliveryFeeForZone(DeliveryZone.outside),
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           _row(
// //             p,
// //             'Delivery',
// //             cartCtrl.deliveryFee > 0
// //                 ? formatNaira(cartCtrl.deliveryFee)
// //                 : 'Free',
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 16),
// //             child: Divider(height: 1, color: p.border),
// //           ),
// //           _row(p, 'Total', formatNaira(cartCtrl.grandTotal), emphasized: true),
// //           if (_hasUnavailable) ...[
// //             const SizedBox(height: 14),
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: StorePalette.danger.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(14),
// //               ),
// //               child: Row(
// //                 children: [
// //                   const Icon(
// //                     Icons.info_outline_rounded,
// //                     size: 18,
// //                     color: StorePalette.danger,
// //                   ),
// //                   const SizedBox(width: 10),
// //                   const Expanded(
// //                     child: Text(
// //                       'Remove unavailable items to continue.',
// //                       style: TextStyle(
// //                         color: StorePalette.danger,
// //                         fontSize: 12.5,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //           if (withButton) ...[const SizedBox(height: 20), _checkoutButton(p)],
// //           const SizedBox(height: 16),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.lock_outline_rounded, size: 14, color: p.muted),
// //               const SizedBox(width: 6),
// //               Text(
// //                 'Secure checkout with Paystack',
// //                 style: TextStyle(color: p.muted, fontSize: 12),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _row(
// //     StorePalette p,
// //     String label,
// //     String value, {
// //     bool emphasized = false,
// //   }) {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: Text(
// //             label,
// //             style: TextStyle(
// //               color: emphasized ? p.text : p.muted,
// //               fontSize: emphasized ? 16 : 14,
// //               fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
// //             ),
// //           ),
// //         ),
// //         Text(
// //           value,
// //           style: TextStyle(
// //             color: p.text,
// //             fontSize: emphasized ? 22 : 14.5,
// //             fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
// //             letterSpacing: emphasized ? -0.5 : 0,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _checkoutButton(StorePalette p) {
// //     final disabled = cartCtrl.cartItems.isEmpty || _hasUnavailable;

// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton(
// //         onPressed: disabled
// //             ? null
// //             : () => nav.goTo(EcommerceLiveRoutes.checkout),
// //         style: ElevatedButton.styleFrom(
// //           elevation: 0,
// //           minimumSize: const Size.fromHeight(54),
// //           backgroundColor: p.accent,
// //           foregroundColor: p.onAccent,
// //           disabledBackgroundColor: p.tile,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
// //         ),
// //         child: const Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text('Proceed to checkout', style: TextStyle(fontSize: 13)),
// //             SizedBox(width: 8),
// //             Icon(Icons.arrow_forward_rounded, size: 18),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _bottomBar(StorePalette p) {
// //     return Container(
// //       padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
// //       decoration: BoxDecoration(
// //         color: p.surface,
// //         border: Border(top: BorderSide(color: p.border)),
// //         boxShadow: const [
// //           BoxShadow(
// //             color: Color(0x14000000),
// //             blurRadius: 24,
// //             offset: Offset(0, -8),
// //           ),
// //         ],
// //       ),
// //       child: SafeArea(
// //         top: false,
// //         child: Row(
// //           children: [
// //             Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text('Total', style: TextStyle(color: p.muted, fontSize: 12)),
// //                 const SizedBox(height: 2),
// //                 Text(
// //                   formatNaira(cartCtrl.grandTotal),
// //                   style: TextStyle(
// //                     color: p.text,
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.w800,
// //                     letterSpacing: -0.4,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(width: 20),
// //             Expanded(child: _checkoutButton(p)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   //==================================================
// //   // CLEAR
// //   //==================================================

// //   Future<void> _confirmClear(StorePalette p) async {
// //     final ok = await Get.dialog<bool>(
// //       AlertDialog(
// //         backgroundColor: p.surface,
// //         surfaceTintColor: Colors.transparent,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
// //         title: Text(
// //           'Clear cart',
// //           style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
// //         ),
// //         content: Text(
// //           'Remove all items from your cart?',
// //           style: TextStyle(color: p.muted),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Get.back(result: false),
// //             child: Text('Cancel', style: TextStyle(color: p.muted)),
// //           ),
// //           ElevatedButton(
// //             onPressed: () => Get.back(result: true),
// //             style: ElevatedButton.styleFrom(
// //               elevation: 0,
// //               backgroundColor: StorePalette.danger,
// //               foregroundColor: Colors.white,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(14),
// //               ),
// //             ),
// //             child: const Text('Clear'),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (ok == true) await cartCtrl.clearCart();
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hyend/controllers/ecommerceCartController.dart';
// import 'package:hyend/controllers/theme_controller.dart';
// import 'package:hyend/models/cartItemModel.dart';
// import 'package:hyend/models/productModel.dart';
// import 'package:hyend/pages/deliveryZoneSelector.dart';
// import 'package:hyend/pages/ecommerce_routes.dart';
// import 'package:hyend/pages/storeUi.dart';

// class CartPage extends StatelessWidget {
//   CartPage({super.key});

//   final EcommerceLiveNavController nav = Get.find();
//   final EcommerceCartController cartCtrl = Get.find();

//   // ThemeController is created at login; fall back safely on cold start.
//   final ThemeController themeCtrl = Get.isRegistered<ThemeController>()
//       ? Get.find<ThemeController>()
//       : Get.put(ThemeController());

//   bool _unavailable(CartItemModel item) =>
//       !item.product.isActive || item.product.stock <= 0;

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 900;

//     return Obx(() {
//       final p = StorePalette(themeCtrl.isDarkMode.value);
//       final items = cartCtrl.cartItems;
//       final isEmpty = items.isEmpty;
//       final count = cartCtrl.cartCount;

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
//                 'Cart',
//                 style: TextStyle(
//                   color: p.text,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               if (!isEmpty)
//                 Text(
//                   '$count ${count == 1 ? 'item' : 'items'}',
//                   style: TextStyle(
//                     color: p.muted,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//             ],
//           ),
//           actions: [
//             if (!isEmpty)
//               TextButton(
//                 onPressed: () => _confirmClear(p),
//                 child: Text(
//                   'Clear',
//                   style: TextStyle(
//                     color: StorePalette.danger,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             const SizedBox(width: 8),
//           ],
//         ),
//         bottomNavigationBar: (isEmpty || isDesktop) ? null : _bottomBar(p),
//         body: isEmpty
//             ? _emptyState(p)
//             : Align(
//                 alignment: Alignment.topCenter,
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 1200),
//                   child: isDesktop
//                       ? Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: _itemsList(p, includeSummary: false),
//                             ),
//                             SizedBox(
//                               width: 400,
//                               child: SingleChildScrollView(
//                                 padding: const EdgeInsets.fromLTRB(
//                                   0,
//                                   8,
//                                   20,
//                                   24,
//                                 ),
//                                 child: _summaryCard(p, withButton: true),
//                               ),
//                             ),
//                           ],
//                         )
//                       : _itemsList(p, includeSummary: true),
//                 ),
//               ),
//       );
//     });
//   }

//   //==================================================
//   // EMPTY STATE
//   //==================================================

//   Widget _emptyState(StorePalette p) {
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
//                 Icons.shopping_bag_outlined,
//                 size: 44,
//                 color: p.muted,
//               ),
//             ),
//             const SizedBox(height: 22),
//             Text(
//               'Your cart is empty',
//               style: TextStyle(
//                 color: p.text,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Looks like you haven\'t added anything yet.',
//               textAlign: TextAlign.center,
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

//   //==================================================
//   // ITEMS
//   //==================================================

//   Widget _itemsList(StorePalette p, {required bool includeSummary}) {
//     final items = cartCtrl.cartItems.toList();

//     return ListView(
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
//       children: [
//         for (final item in items) ...[
//           _itemCard(p, item),
//           const SizedBox(height: 14),
//         ],
//         if (includeSummary) ...[
//           const SizedBox(height: 6),
//           _summaryCard(p, withButton: false),
//         ],
//       ],
//     );
//   }

//   Widget _colorTag(StorePalette p, CartItemModel item) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
//       decoration: BoxDecoration(
//         color: p.tile,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: p.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 14,
//             height: 14,
//             decoration: BoxDecoration(
//               color: item.color,
//               shape: BoxShape.circle,
//               border: Border.all(color: p.border),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             item.colorName,
//             style: TextStyle(
//               color: p.text,
//               fontSize: 11.5,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _itemCard(StorePalette p, CartItemModel item) {
//     final product = item.product;
//     final unavailable = _unavailable(item);
//     // stock is shared by every colour of the product
//     final atLimit =
//         product.stock > 0 && cartCtrl.qtyInCartFor(product.id) >= product.stock;

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: p.surface,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: unavailable ? StorePalette.danger.withOpacity(0.5) : p.border,
//         ),
//         boxShadow: p.shadow,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Product image (rounded square)
//           Container(
//             width: 96,
//             height: 96,
//             clipBehavior: Clip.antiAlias,
//             decoration: BoxDecoration(
//               color: p.tile,
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Base64Image(
//               data: item.image,
//               placeholder: Center(
//                 child: Icon(Icons.image_outlined, color: p.muted),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         product.name,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: p.text,
//                           fontSize: 15,
//                           height: 1.25,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () => cartCtrl.removeItem(item),
//                       borderRadius: BorderRadius.circular(10),
//                       child: Padding(
//                         padding: const EdgeInsets.all(4),
//                         child: Icon(
//                           Icons.close_rounded,
//                           size: 20,
//                           color: p.muted,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (item.hasColor) ...[
//                   const SizedBox(height: 6),
//                   _colorTag(p, item),
//                 ],
//                 const SizedBox(height: 4),
//                 Text(
//                   unavailable
//                       ? 'No longer available'
//                       : '${formatNaira(product.price)} each',
//                   style: TextStyle(
//                     color: unavailable ? StorePalette.danger : p.muted,
//                     fontSize: 12.5,
//                     fontWeight: unavailable ? FontWeight.w600 : FontWeight.w400,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     _stepper(p, item, atLimit: atLimit),
//                     const Spacer(),
//                     Text(
//                       formatNaira(item.total),
//                       style: TextStyle(
//                         color: p.text,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (atLimit)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       'Maximum available quantity',
//                       style: TextStyle(
//                         color: StorePalette.warning,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _stepper(StorePalette p, CartItemModel item, {required bool atLimit}) {
//     Widget button(IconData icon, VoidCallback? onTap) {
//       return InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: SizedBox(
//           width: 34,
//           height: 34,
//           child: Icon(
//             icon,
//             size: 18,
//             color: onTap == null ? p.muted.withOpacity(0.5) : p.text,
//           ),
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         color: p.tile,
//         borderRadius: BorderRadius.circular(13),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           button(
//             Icons.remove_rounded,
//             item.quantity > 1 ? () => cartCtrl.decreaseQty(item) : null,
//           ),
//           SizedBox(
//             width: 30,
//             child: Text(
//               '${item.quantity}',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: p.text,
//                 fontSize: 14.5,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           button(
//             Icons.add_rounded,
//             atLimit || _unavailable(item)
//                 ? null
//                 : () => cartCtrl.increaseQty(item),
//           ),
//         ],
//       ),
//     );
//   }

//   //==================================================
//   // SUMMARY
//   //==================================================

//   String _feeText(double fee) => fee > 0 ? formatNaira(fee) : 'Free';

//   bool get _hasUnavailable => cartCtrl.cartItems.any(_unavailable);

//   Widget _summaryCard(StorePalette p, {required bool withButton}) {
//     return Container(
//       padding: const EdgeInsets.all(22),
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
//             'Order summary',
//             style: TextStyle(
//               color: p.text,
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -0.3,
//             ),
//           ),
//           const SizedBox(height: 18),
//           _row(
//             p,
//             'Subtotal (${cartCtrl.cartCount} items)',
//             formatNaira(cartCtrl.subtotal),
//           ),
//           const SizedBox(height: 18),
//           Text(
//             'Deliver to',
//             style: TextStyle(
//               color: p.text,
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 10),
//           DeliveryZoneSelector(
//             zone: cartCtrl.deliveryZone.value,
//             onChanged: cartCtrl.setDeliveryZone,
//             tile: p.tile,
//             border: p.border,
//             accent: p.accent,
//             onAccent: p.onAccent,
//             text: p.text,
//             muted: p.muted,
//             enuguSubtitle: _feeText(
//               cartCtrl.deliveryFeeForZone(DeliveryZone.enugu),
//             ),
//             outsideSubtitle: _feeText(
//               cartCtrl.deliveryFeeForZone(DeliveryZone.outside),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _row(
//             p,
//             'Delivery',
//             cartCtrl.deliveryFee > 0
//                 ? formatNaira(cartCtrl.deliveryFee)
//                 : 'Free',
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: Divider(height: 1, color: p.border),
//           ),
//           _row(p, 'Total', formatNaira(cartCtrl.grandTotal), emphasized: true),
//           if (_hasUnavailable) ...[
//             const SizedBox(height: 14),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: StorePalette.danger.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.info_outline_rounded,
//                     size: 18,
//                     color: StorePalette.danger,
//                   ),
//                   const SizedBox(width: 10),
//                   const Expanded(
//                     child: Text(
//                       'Remove unavailable items to continue.',
//                       style: TextStyle(
//                         color: StorePalette.danger,
//                         fontSize: 12.5,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//           if (withButton) ...[const SizedBox(height: 20), _checkoutButton(p)],
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.chat_outlined, size: 14, color: p.muted),
//               const SizedBox(width: 6),
//               Text(
//                 'Order confirmed with HyEnd on WhatsApp',
//                 style: TextStyle(color: p.muted, fontSize: 12),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _row(
//     StorePalette p,
//     String label,
//     String value, {
//     bool emphasized = false,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               color: emphasized ? p.text : p.muted,
//               fontSize: emphasized ? 16 : 14,
//               fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
//             ),
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             color: p.text,
//             fontSize: emphasized ? 22 : 14.5,
//             fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
//             letterSpacing: emphasized ? -0.5 : 0,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _checkoutButton(StorePalette p) {
//     final disabled = cartCtrl.cartItems.isEmpty || _hasUnavailable;

//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: disabled
//             ? null
//             : () => nav.goTo(EcommerceLiveRoutes.checkout),
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           minimumSize: const Size.fromHeight(54),
//           backgroundColor: p.accent,
//           foregroundColor: p.onAccent,
//           disabledBackgroundColor: p.tile,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Proceed to checkout', style: TextStyle(fontSize: 13)),
//             SizedBox(width: 8),
//             Icon(Icons.arrow_forward_rounded, size: 18),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _bottomBar(StorePalette p) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
//       decoration: BoxDecoration(
//         color: p.surface,
//         border: Border(top: BorderSide(color: p.border)),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x14000000),
//             blurRadius: 24,
//             offset: Offset(0, -8),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           children: [
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Total', style: TextStyle(color: p.muted, fontSize: 12)),
//                 const SizedBox(height: 2),
//                 Text(
//                   formatNaira(cartCtrl.grandTotal),
//                   style: TextStyle(
//                     color: p.text,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: -0.4,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 20),
//             Expanded(child: _checkoutButton(p)),
//           ],
//         ),
//       ),
//     );
//   }

//   //==================================================
//   // CLEAR
//   //==================================================

//   Future<void> _confirmClear(StorePalette p) async {
//     final ok = await Get.dialog<bool>(
//       AlertDialog(
//         backgroundColor: p.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         title: Text(
//           'Clear cart',
//           style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
//         ),
//         content: Text(
//           'Remove all items from your cart?',
//           style: TextStyle(color: p.muted),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: Text('Cancel', style: TextStyle(color: p.muted)),
//           ),
//           ElevatedButton(
//             onPressed: () => Get.back(result: true),
//             style: ElevatedButton.styleFrom(
//               elevation: 0,
//               backgroundColor: StorePalette.danger,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//             child: const Text('Clear'),
//           ),
//         ],
//       ),
//     );

//     if (ok == true) await cartCtrl.clearCart();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hyend/controllers/ecommerceCartController.dart';
// import 'package:hyend/controllers/theme_controller.dart';
// import 'package:hyend/models/cartItemModel.dart';
// import 'package:hyend/models/productModel.dart';
// import 'package:hyend/pages/deliveryZoneSelector.dart';
// import 'package:hyend/pages/ecommerce_routes.dart';
// import 'package:hyend/pages/storeUi.dart';

// class CartPage extends StatelessWidget {
//   CartPage({super.key});

//   final EcommerceLiveNavController nav = Get.find();
//   final EcommerceCartController cartCtrl = Get.find();

//   // ThemeController is created at login; fall back safely on cold start.
//   final ThemeController themeCtrl = Get.isRegistered<ThemeController>()
//       ? Get.find<ThemeController>()
//       : Get.put(ThemeController());

//   bool _unavailable(CartItemModel item) =>
//       !item.product.isActive || item.product.stock <= 0;

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 900;

//     return Obx(() {
//       final p = StorePalette(themeCtrl.isDarkMode.value);
//       final items = cartCtrl.cartItems;
//       final isEmpty = items.isEmpty;
//       final count = cartCtrl.cartCount;

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
//                 'Cart',
//                 style: TextStyle(
//                   color: p.text,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               if (!isEmpty)
//                 Text(
//                   '$count ${count == 1 ? 'item' : 'items'}',
//                   style: TextStyle(
//                     color: p.muted,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//             ],
//           ),
//           actions: [
//             if (!isEmpty)
//               TextButton(
//                 onPressed: () => _confirmClear(p),
//                 child: Text(
//                   'Clear',
//                   style: TextStyle(
//                     color: StorePalette.danger,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             const SizedBox(width: 8),
//           ],
//         ),
//         bottomNavigationBar: (isEmpty || isDesktop) ? null : _bottomBar(p),
//         body: isEmpty
//             ? _emptyState(p)
//             : Align(
//                 alignment: Alignment.topCenter,
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 1200),
//                   child: isDesktop
//                       ? Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: _itemsList(p, includeSummary: false),
//                             ),
//                             SizedBox(
//                               width: 400,
//                               child: SingleChildScrollView(
//                                 padding: const EdgeInsets.fromLTRB(
//                                   0,
//                                   8,
//                                   20,
//                                   24,
//                                 ),
//                                 child: _summaryCard(p, withButton: true),
//                               ),
//                             ),
//                           ],
//                         )
//                       : _itemsList(p, includeSummary: true),
//                 ),
//               ),
//       );
//     });
//   }

//   //==================================================
//   // EMPTY STATE
//   //==================================================

//   Widget _emptyState(StorePalette p) {
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
//                 Icons.shopping_bag_outlined,
//                 size: 44,
//                 color: p.muted,
//               ),
//             ),
//             const SizedBox(height: 22),
//             Text(
//               'Your cart is empty',
//               style: TextStyle(
//                 color: p.text,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Looks like you haven\'t added anything yet.',
//               textAlign: TextAlign.center,
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

//   //==================================================
//   // ITEMS
//   //==================================================

//   Widget _itemsList(StorePalette p, {required bool includeSummary}) {
//     final items = cartCtrl.cartItems.toList();

//     return ListView(
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
//       children: [
//         for (final item in items) ...[
//           _itemCard(p, item),
//           const SizedBox(height: 14),
//         ],
//         if (includeSummary) ...[
//           const SizedBox(height: 6),
//           _summaryCard(p, withButton: false),
//         ],
//       ],
//     );
//   }

//   Widget _colorTag(StorePalette p, CartItemModel item) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
//       decoration: BoxDecoration(
//         color: p.tile,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: p.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 14,
//             height: 14,
//             decoration: BoxDecoration(
//               color: item.color,
//               shape: BoxShape.circle,
//               border: Border.all(color: p.border),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             item.colorName,
//             style: TextStyle(
//               color: p.text,
//               fontSize: 11.5,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _itemCard(StorePalette p, CartItemModel item) {
//     final product = item.product;
//     final unavailable = _unavailable(item);
//     // stock is shared by every colour of the product
//     final atLimit =
//         product.stock > 0 && cartCtrl.qtyInCartFor(product.id) >= product.stock;

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: p.surface,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: unavailable ? StorePalette.danger.withOpacity(0.5) : p.border,
//         ),
//         boxShadow: p.shadow,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Product image (rounded square)
//           Container(
//             width: 96,
//             height: 96,
//             clipBehavior: Clip.antiAlias,
//             decoration: BoxDecoration(
//               color: p.tile,
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Base64Image(
//               data: item.image,
//               placeholder: Center(
//                 child: Icon(Icons.image_outlined, color: p.muted),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         product.name,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: p.text,
//                           fontSize: 15,
//                           height: 1.25,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () => cartCtrl.removeItem(item),
//                       borderRadius: BorderRadius.circular(10),
//                       child: Padding(
//                         padding: const EdgeInsets.all(4),
//                         child: Icon(
//                           Icons.close_rounded,
//                           size: 20,
//                           color: p.muted,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (item.hasColor) ...[
//                   const SizedBox(height: 6),
//                   _colorTag(p, item),
//                 ],
//                 const SizedBox(height: 4),
//                 Text(
//                   unavailable
//                       ? 'No longer available'
//                       : '${formatNaira(product.price)} each',
//                   style: TextStyle(
//                     color: unavailable ? StorePalette.danger : p.muted,
//                     fontSize: 12.5,
//                     fontWeight: unavailable ? FontWeight.w600 : FontWeight.w400,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     _stepper(p, item, atLimit: atLimit),
//                     const Spacer(),
//                     Text(
//                       formatNaira(item.total),
//                       style: TextStyle(
//                         color: p.text,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (atLimit)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       'Maximum available quantity',
//                       style: TextStyle(
//                         color: StorePalette.warning,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _stepper(StorePalette p, CartItemModel item, {required bool atLimit}) {
//     Widget button(IconData icon, VoidCallback? onTap) {
//       return InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: SizedBox(
//           width: 34,
//           height: 34,
//           child: Icon(
//             icon,
//             size: 18,
//             color: onTap == null ? p.muted.withOpacity(0.5) : p.text,
//           ),
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         color: p.tile,
//         borderRadius: BorderRadius.circular(13),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           button(
//             Icons.remove_rounded,
//             item.quantity > 1 ? () => cartCtrl.decreaseQty(item) : null,
//           ),
//           SizedBox(
//             width: 30,
//             child: Text(
//               '${item.quantity}',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: p.text,
//                 fontSize: 14.5,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           button(
//             Icons.add_rounded,
//             atLimit || _unavailable(item)
//                 ? null
//                 : () => cartCtrl.increaseQty(item),
//           ),
//         ],
//       ),
//     );
//   }

//   //==================================================
//   // SUMMARY
//   //==================================================

//   String _feeText(double fee) => fee > 0 ? formatNaira(fee) : 'Free';

//   bool get _hasUnavailable => cartCtrl.cartItems.any(_unavailable);

//   Widget _summaryCard(StorePalette p, {required bool withButton}) {
//     return Container(
//       padding: const EdgeInsets.all(22),
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
//             'Order summary',
//             style: TextStyle(
//               color: p.text,
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -0.3,
//             ),
//           ),
//           const SizedBox(height: 18),
//           _row(
//             p,
//             'Subtotal (${cartCtrl.cartCount} items)',
//             formatNaira(cartCtrl.subtotal),
//           ),
//           const SizedBox(height: 18),
//           Text(
//             'Deliver to',
//             style: TextStyle(
//               color: p.text,
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 10),
//           DeliveryZoneSelector(
//             zone: cartCtrl.deliveryZone.value,
//             onChanged: cartCtrl.setDeliveryZone,
//             tile: p.tile,
//             border: p.border,
//             accent: p.accent,
//             onAccent: p.onAccent,
//             text: p.text,
//             muted: p.muted,
//             enuguSubtitle: _feeText(
//               cartCtrl.deliveryFeeForZone(DeliveryZone.enugu),
//             ),
//             outsideSubtitle: _feeText(
//               cartCtrl.deliveryFeeForZone(DeliveryZone.outside),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _row(
//             p,
//             'Delivery',
//             cartCtrl.deliveryFee > 0
//                 ? formatNaira(cartCtrl.deliveryFee)
//                 : 'Free',
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: Divider(height: 1, color: p.border),
//           ),
//           _row(p, 'Total', formatNaira(cartCtrl.grandTotal), emphasized: true),
//           if (_hasUnavailable) ...[
//             const SizedBox(height: 14),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: StorePalette.danger.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.info_outline_rounded,
//                     size: 18,
//                     color: StorePalette.danger,
//                   ),
//                   const SizedBox(width: 10),
//                   const Expanded(
//                     child: Text(
//                       'Remove unavailable items to continue.',
//                       style: TextStyle(
//                         color: StorePalette.danger,
//                         fontSize: 12.5,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//           if (withButton) ...[const SizedBox(height: 20), _checkoutButton(p)],
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.lock_outline_rounded, size: 14, color: p.muted),
//               const SizedBox(width: 6),
//               Text(
//                 'Secure checkout with Paystack',
//                 style: TextStyle(color: p.muted, fontSize: 12),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _row(
//     StorePalette p,
//     String label,
//     String value, {
//     bool emphasized = false,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               color: emphasized ? p.text : p.muted,
//               fontSize: emphasized ? 16 : 14,
//               fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
//             ),
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             color: p.text,
//             fontSize: emphasized ? 22 : 14.5,
//             fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
//             letterSpacing: emphasized ? -0.5 : 0,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _checkoutButton(StorePalette p) {
//     final disabled = cartCtrl.cartItems.isEmpty || _hasUnavailable;

//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: disabled
//             ? null
//             : () => nav.goTo(EcommerceLiveRoutes.checkout),
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           minimumSize: const Size.fromHeight(54),
//           backgroundColor: p.accent,
//           foregroundColor: p.onAccent,
//           disabledBackgroundColor: p.tile,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Proceed to checkout', style: TextStyle(fontSize: 13)),
//             SizedBox(width: 8),
//             Icon(Icons.arrow_forward_rounded, size: 18),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _bottomBar(StorePalette p) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
//       decoration: BoxDecoration(
//         color: p.surface,
//         border: Border(top: BorderSide(color: p.border)),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x14000000),
//             blurRadius: 24,
//             offset: Offset(0, -8),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           children: [
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Total', style: TextStyle(color: p.muted, fontSize: 12)),
//                 const SizedBox(height: 2),
//                 Text(
//                   formatNaira(cartCtrl.grandTotal),
//                   style: TextStyle(
//                     color: p.text,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: -0.4,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 20),
//             Expanded(child: _checkoutButton(p)),
//           ],
//         ),
//       ),
//     );
//   }

//   //==================================================
//   // CLEAR
//   //==================================================

//   Future<void> _confirmClear(StorePalette p) async {
//     final ok = await Get.dialog<bool>(
//       AlertDialog(
//         backgroundColor: p.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         title: Text(
//           'Clear cart',
//           style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
//         ),
//         content: Text(
//           'Remove all items from your cart?',
//           style: TextStyle(color: p.muted),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: Text('Cancel', style: TextStyle(color: p.muted)),
//           ),
//           ElevatedButton(
//             onPressed: () => Get.back(result: true),
//             style: ElevatedButton.styleFrom(
//               elevation: 0,
//               backgroundColor: StorePalette.danger,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//             child: const Text('Clear'),
//           ),
//         ],
//       ),
//     );

//     if (ok == true) await cartCtrl.clearCart();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/ecommerceCartController.dart';
import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/models/cartItemModel.dart';
import 'package:hyend/models/productModel.dart';
import 'package:hyend/pages/deliveryZoneSelector.dart';
import 'package:hyend/pages/ecommerce_routes.dart';
import 'package:hyend/pages/storeUi.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});

  final EcommerceLiveNavController nav = Get.find();
  final EcommerceCartController cartCtrl = Get.find();

  // ThemeController is created at login; fall back safely on cold start.
  final ThemeController themeCtrl = Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : Get.put(ThemeController());

  bool _unavailable(CartItemModel item) =>
      !item.product.isActive || item.product.stock <= 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Obx(() {
      final p = StorePalette(themeCtrl.isDarkMode.value);
      final items = cartCtrl.cartItems;
      final isEmpty = items.isEmpty;
      final count = cartCtrl.cartCount;

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
                'Cart',
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (!isEmpty)
                Text(
                  '$count ${count == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    color: p.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          actions: [
            if (!isEmpty)
              TextButton(
                onPressed: () => _confirmClear(p),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: StorePalette.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: (isEmpty || isDesktop) ? null : _bottomBar(p),
        body: isEmpty
            ? _emptyState(p)
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _itemsList(p, includeSummary: false),
                            ),
                            SizedBox(
                              width: 400,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  8,
                                  20,
                                  24,
                                ),
                                child: _summaryCard(p, withButton: true),
                              ),
                            ),
                          ],
                        )
                      : _itemsList(p, includeSummary: true),
                ),
              ),
      );
    });
  }

  //==================================================
  // EMPTY STATE
  //==================================================

  Widget _emptyState(StorePalette p) {
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
                Icons.shopping_bag_outlined,
                size: 44,
                color: p.muted,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Your cart is empty',
              style: TextStyle(
                color: p.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added anything yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.muted, fontSize: 14),
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

  //==================================================
  // ITEMS
  //==================================================

  Widget _itemsList(StorePalette p, {required bool includeSummary}) {
    final items = cartCtrl.cartItems.toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        for (final item in items) ...[
          _itemCard(p, item),
          const SizedBox(height: 14),
        ],
        if (includeSummary) ...[
          const SizedBox(height: 6),
          _summaryCard(p, withButton: false),
        ],
      ],
    );
  }

  Widget _colorTag(StorePalette p, CartItemModel item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
      decoration: BoxDecoration(
        color: p.tile,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
              border: Border.all(color: p.border),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            item.colorName,
            style: TextStyle(
              color: p.text,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(StorePalette p, CartItemModel item) {
    final product = item.product;
    final unavailable = _unavailable(item);
    // stock is shared by every colour of the product
    final atLimit =
        product.stock > 0 && cartCtrl.qtyInCartFor(product.id) >= product.stock;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unavailable ? StorePalette.danger.withOpacity(0.5) : p.border,
        ),
        boxShadow: p.shadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image (rounded square)
          Container(
            width: 96,
            height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: p.tile,
              borderRadius: BorderRadius.circular(18),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => cartCtrl.removeItem(item),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: p.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.hasColor) ...[
                  const SizedBox(height: 6),
                  _colorTag(p, item),
                ],
                const SizedBox(height: 4),
                Text(
                  unavailable
                      ? 'No longer available'
                      : '${formatNaira(product.price)} each',
                  style: TextStyle(
                    color: unavailable ? StorePalette.danger : p.muted,
                    fontSize: 12.5,
                    fontWeight: unavailable ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _stepper(p, item, atLimit: atLimit),
                    const Spacer(),
                    Text(
                      formatNaira(item.total),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                if (atLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Maximum available quantity',
                      style: TextStyle(
                        color: StorePalette.warning,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editQuantity(StorePalette p, CartItemModel item) async {
    final product = item.product;
    final minQty = cartCtrl.minOrderFor(product);
    final ctrl = TextEditingController(text: '${item.quantity}');

    final result = await Get.dialog<int>(
      AlertDialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Quantity',
          style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: p.text, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            helperText: product.stock > 0
                ? 'Minimum $minQty \u00b7 ${product.stock} in stock'
                : 'Minimum $minQty',
          ),
          onSubmitted: (v) => Get.back(result: int.tryParse(v)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: p.muted)),
          ),
          TextButton(
            onPressed: () => Get.back(result: int.tryParse(ctrl.text)),
            child: Text(
              'Update',
              style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    ctrl.dispose();

    if (result != null) await cartCtrl.setQuantity(item, result);
  }

  Widget _stepper(StorePalette p, CartItemModel item, {required bool atLimit}) {
    Widget button(IconData icon, VoidCallback? onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: onTap == null ? p.muted.withOpacity(0.5) : p.text,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.tile,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            Icons.remove_rounded,
            item.quantity > cartCtrl.minOrderFor(item.product)
                ? () => cartCtrl.decreaseQty(item)
                : null,
          ),
          // tap the number to type an exact quantity
          InkWell(
            onTap: _unavailable(item) ? null : () => _editQuantity(p, item),
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 38,
              height: 34,
              child: Center(
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          button(
            Icons.add_rounded,
            atLimit || _unavailable(item)
                ? null
                : () => cartCtrl.increaseQty(item),
          ),
        ],
      ),
    );
  }

  //==================================================
  // SUMMARY
  //==================================================

  String _feeText(double fee) => fee > 0 ? formatNaira(fee) : 'Free';

  bool get _hasUnavailable => cartCtrl.cartItems.any(_unavailable);

  Widget _summaryCard(StorePalette p, {required bool withButton}) {
    return Container(
      padding: const EdgeInsets.all(22),
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
            'Order summary',
            style: TextStyle(
              color: p.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 18),
          _row(
            p,
            'Subtotal (${cartCtrl.cartCount} items)',
            formatNaira(cartCtrl.subtotal),
          ),
          const SizedBox(height: 18),
          Text(
            'Deliver to',
            style: TextStyle(
              color: p.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          DeliveryZoneSelector(
            zone: cartCtrl.deliveryZone.value,
            onChanged: cartCtrl.setDeliveryZone,
            tile: p.tile,
            border: p.border,
            accent: p.accent,
            onAccent: p.onAccent,
            text: p.text,
            muted: p.muted,
            enuguSubtitle: _feeText(
              cartCtrl.deliveryFeeForZone(DeliveryZone.enugu),
            ),
            outsideSubtitle: _feeText(
              cartCtrl.deliveryFeeForZone(DeliveryZone.outside),
            ),
          ),
          const SizedBox(height: 16),
          _row(
            p,
            'Service fee',
            cartCtrl.deliveryFee > 0
                ? formatNaira(cartCtrl.deliveryFee)
                : 'Free',
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
          _row(p, 'Total', formatNaira(cartCtrl.grandTotal), emphasized: true),
          if (_hasUnavailable) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StorePalette.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: StorePalette.danger,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Remove unavailable items to continue.',
                      style: TextStyle(
                        color: StorePalette.danger,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (withButton) ...[const SizedBox(height: 20), _checkoutButton(p)],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_outlined, size: 14, color: p.muted),
              const SizedBox(width: 6),
              Text(
                'Order confirmed with HyEnd on WhatsApp',
                style: TextStyle(color: p.muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(
    StorePalette p,
    String label,
    String value, {
    bool emphasized = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? p.text : p.muted,
              fontSize: emphasized ? 16 : 14,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: p.text,
            fontSize: emphasized ? 22 : 14.5,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
            letterSpacing: emphasized ? -0.5 : 0,
          ),
        ),
      ],
    );
  }

  Widget _checkoutButton(StorePalette p) {
    final disabled = cartCtrl.cartItems.isEmpty || _hasUnavailable;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled
            ? null
            : () => nav.goTo(EcommerceLiveRoutes.checkout),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          disabledBackgroundColor: p.tile,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Proceed to checkout', style: TextStyle(fontSize: 13)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(StorePalette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: TextStyle(color: p.muted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  formatNaira(cartCtrl.grandTotal),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(child: _checkoutButton(p)),
          ],
        ),
      ),
    );
  }

  //==================================================
  // CLEAR
  //==================================================

  Future<void> _confirmClear(StorePalette p) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Clear cart',
          style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Remove all items from your cart?',
          style: TextStyle(color: p.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: p.muted)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: StorePalette.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (ok == true) await cartCtrl.clearCart();
  }
}
