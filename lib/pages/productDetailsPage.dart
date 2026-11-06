// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hyend/controllers/ecommerceCartController.dart';
// import 'package:hyend/controllers/ecommerceStoreController.dart';
// import 'package:hyend/controllers/theme_controller.dart';
// import 'package:hyend/models/productModel.dart';
// import 'package:hyend/pages/deliveryZoneSelector.dart';
// import 'package:hyend/pages/flyToCart.dart';
// import 'package:hyend/userAuth/authController.dart';

// import 'ecommerce_routes.dart';

// class ProductDetailsPage extends StatefulWidget {
//   const ProductDetailsPage({super.key});

//   @override
//   State<ProductDetailsPage> createState() => _ProductDetailsPageState();
// }

// class _ProductDetailsPageState extends State<ProductDetailsPage> {
//   final EcommerceLiveNavController nav = Get.find();
//   final AuthController authCtrl = Get.find();
//   final EcommerceStoreController storeCtrl = Get.find();
//   final EcommerceCartController cartCtrl = Get.find();

//   // ThemeController is created at login; fall back safely on cold start.
//   final ThemeController themeCtrl = Get.isRegistered<ThemeController>()
//       ? Get.find<ThemeController>()
//       : Get.put(ThemeController());

//   /// The product this page shows. Owned by the page itself (seeded from the
//   /// route argument), so it can never be lost to a controller being recreated.
//   final Rxn<ProductModel> _selected = Rxn<ProductModel>();

//   final RxInt quantity = 1.obs;
//   final RxInt imageIndex = 0.obs;
//   final RxBool busy = false.obs;

//   /// Key (RRGGBB) of the colour the customer picked; null = first colour.
//   final RxnString selectedColorKey = RxnString();
//   bool _lockColor = false;

//   /// Target of the fly-to-cart animation (the cart icon in the app bar).
//   final GlobalKey<CartFlyTargetState> _cartFlyKey =
//       GlobalKey<CartFlyTargetState>();

//   final PageController _pager = PageController();
//   final ScrollController _scroll = ScrollController();

//   /// Decoded image bytes, so base64 is decoded once instead of on every build.
//   final Map<String, Uint8List> _imageCache = {};

//   static const Color _green = Color(0xFF16A34A);
//   static const Color _amber = Color(0xFFD97706);
//   static const Color _red = Color(0xFFE5484D);

//   @override
//   void initState() {
//     super.initState();

//     final arg = Get.arguments;
//     if (arg is ProductModel) {
//       _selected.value = arg;
//       storeCtrl.selectProduct(arg);
//     } else {
//       _selected.value = storeCtrl.selectedProduct.value;
//     }
//   }

//   @override
//   void dispose() {
//     _pager.dispose();
//     _scroll.dispose();
//     super.dispose();
//   }

//   //==================================================
//   // HELPERS
//   //==================================================

//   String _naira(num value) {
//     final parts = value.toStringAsFixed(2).split('.');
//     final whole = parts[0].replaceAllMapped(
//       RegExp(r'\B(?=(\d{3})+(?!\d))'),
//       (_) => ',',
//     );
//     return parts[1] == '00' ? '₦$whole' : '₦$whole.${parts[1]}';
//   }

//   Uint8List _bytes(ProductModel product, int index) {
//     final key = '${product.id}:$index';
//     final cached = _imageCache[key];
//     if (cached != null) return cached;

//     try {
//       final decoded = base64Decode(product.images[index]);
//       _imageCache[key] = decoded;
//       return decoded;
//     } catch (_) {
//       return Uint8List(0);
//     }
//   }

//   bool _isAvailable(ProductModel product) =>
//       product.isActive && product.stock > 0;

//   void _snack(String title, String message, _P p) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: p.surface,
//       colorText: p.text,
//       borderRadius: 14,
//       margin: const EdgeInsets.all(14),
//     );
//   }

//   void _openProduct(ProductModel product) {
//     quantity.value = 1;
//     imageIndex.value = 0;
//     selectedColorKey.value = null;

//     if (_pager.hasClients) _pager.jumpToPage(0);

//     _selected.value = product;
//     storeCtrl.selectProduct(product);

//     if (_scroll.hasClients) {
//       _scroll.animateTo(
//         0,
//         duration: const Duration(milliseconds: 350),
//         curve: Curves.easeOutCubic,
//       );
//     }
//   }

//   bool _requireLogin(_P p) {
//     if (authCtrl.isAuthenticated) return true;

//     _snack('Login required', 'Please login to continue', p);
//     Get.toNamed(EcommerceLiveRoutes.login);
//     return false;
//   }

//   ProductColor? _selectedColor(ProductModel product) {
//     final options = product.colorOptions;
//     if (options.isEmpty) return null;

//     final key = selectedColorKey.value;
//     final match = key == null
//         ? null
//         : options.firstWhereOrNull((o) => o.color.key == key);

//     return (match ?? options.first).color;
//   }

//   /// Image that shows [color] (the one being viewed if it matches).
//   int _cartImageIndex(ProductModel product, ProductColor color) {
//     final current = imageIndex.value;
//     if (product.colorAt(current)?.key == color.key) return current;

//     final option = product.colorOptions.firstWhereOrNull(
//       (o) => o.color.key == color.key,
//     );
//     return option?.imageIndex ?? 0;
//   }

//   /// Plays the Temu-style "jump into the cart" animation.
//   void _flyToCart(BuildContext from, ProductModel product, _P p) {
//     final i = imageIndex.value;
//     final bytes = (i >= 0 && i < product.images.length)
//         ? _bytes(product, i)
//         : null;

//     FlyToCart.launch(
//       from: from,
//       to: _cartFlyKey,
//       trailColor: p.accent,
//       size: 64,
//       flyer: FlyToCart.thumbnail(
//         bytes: bytes,
//         background: p.tile,
//         ring: p.surface,
//         iconColor: p.text,
//       ),
//     );
//   }

//   Future<void> _selectColor(ProductModel product, ColorOption option) async {
//     selectedColorKey.value = option.color.key;

//     // already looking at an image of this colour
//     if (product.colorAt(imageIndex.value)?.key == option.color.key) return;

//     _lockColor = true; // don't let the sliding gallery flip the colour
//     await _goToImage(option.imageIndex);
//     _lockColor = false;
//   }

//   String _colorSuffix(ProductModel product) {
//     final c = _selectedColor(product);
//     return c == null ? '' : ' (${c.name})';
//   }

//   Future<bool> _addToCart(
//     ProductModel product,
//     _P p, {
//     VoidCallback? onAdded,
//   }) async {
//     if (busy.value || !_requireLogin(p)) return false;

//     try {
//       busy.value = true;

//       final color = _selectedColor(product);

//       return await cartCtrl.addToCart(
//         product,
//         quantity: quantity.value,
//         color: color,
//         imageIndex: color == null ? 0 : _cartImageIndex(product, color),
//         onAdded: onAdded,
//       );
//     } catch (e) {
//       _snack('Error', 'Could not update your cart. Please try again.', p);
//       return false;
//     } finally {
//       busy.value = false;
//     }
//   }

//   //==================================================
//   // BUILD
//   //==================================================

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final p = _P(themeCtrl.isDarkMode.value);
//       final product = _selected.value;

//       if (product == null) {
//         return Scaffold(
//           backgroundColor: p.bg,
//           appBar: AppBar(
//             backgroundColor: p.bg,
//             surfaceTintColor: Colors.transparent,
//             iconTheme: IconThemeData(color: p.text),
//           ),
//           body: Center(
//             child: Text('Product not found', style: TextStyle(color: p.muted)),
//           ),
//         );
//       }

//       final isDesktop = MediaQuery.of(context).size.width > 900;

//       return Scaffold(
//         backgroundColor: p.bg,
//         appBar: _appBar(p),
//         bottomNavigationBar: isDesktop ? null : _bottomBar(p, product),
//         body: Align(
//           alignment: Alignment.topCenter,
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 1200),
//             child: SingleChildScrollView(
//               controller: _scroll,
//               padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
//               child: isDesktop
//                   ? Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           flex: 5,
//                           child: _gallery(p, product, showArrows: true),
//                         ),
//                         const SizedBox(width: 40),
//                         Expanded(
//                           flex: 4,
//                           child: _details(p, product, isDesktop: true),
//                         ),
//                       ],
//                     )
//                   : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _gallery(p, product, showArrows: false),
//                         const SizedBox(height: 24),
//                         _details(p, product, isDesktop: false),
//                       ],
//                     ),
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   //==================================================
//   // APP BAR
//   //==================================================

//   PreferredSizeWidget _appBar(_P p) {
//     final count = cartCtrl.cartCount;

//     return AppBar(
//       backgroundColor: p.bg,
//       surfaceTintColor: Colors.transparent,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       iconTheme: IconThemeData(color: p.text),
//       centerTitle: false,
//       title: Text(
//         'Details',
//         style: TextStyle(
//           color: p.text,
//           fontWeight: FontWeight.w800,
//           letterSpacing: -0.3,
//         ),
//       ),
//       actions: [
//         CartFlyTarget(
//           key: _cartFlyKey,
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               IconButton(
//                 tooltip: 'Cart',
//                 icon: const Icon(Icons.shopping_bag_outlined),
//                 onPressed: () {
//                   if (_requireLogin(p)) nav.goTo(EcommerceLiveRoutes.cart);
//                 },
//               ),
//               if (count > 0)
//                 Positioned(
//                   right: 4,
//                   top: 4,
//                   child: Container(
//                     constraints: const BoxConstraints(minWidth: 18),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 5,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: p.accent,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       count > 99 ? '99+' : '$count',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: p.onAccent,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 8),
//       ],
//     );
//   }

//   //==================================================
//   // GALLERY
//   //==================================================

//   Widget _gallery(_P p, ProductModel product, {required bool showArrows}) {
//     final count = product.images.length;

//     Widget placeholder() =>
//         Center(child: Icon(Icons.image_outlined, size: 64, color: p.muted));

//     return Column(
//       children: [
//         AspectRatio(
//           aspectRatio: 1,
//           child: Container(
//             decoration: BoxDecoration(
//               color: p.surface,
//               borderRadius: BorderRadius.circular(28),
//               border: Border.all(color: p.border),
//               boxShadow: p.shadow,
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(27),
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: count == 0
//                         ? placeholder()
//                         : PageView.builder(
//                             key: ValueKey(product.id),
//                             controller: _pager,
//                             itemCount: count,
//                             onPageChanged: (i) {
//                               imageIndex.value = i;
//                               final c = product.colorAt(i);
//                               if (c != null && !_lockColor) {
//                                 selectedColorKey.value = c.key;
//                               }
//                             },
//                             itemBuilder: (_, i) => Image.memory(
//                               _bytes(product, i),
//                               fit: BoxFit.cover,
//                               gaplessPlayback: true,
//                               errorBuilder: (_, __, ___) => placeholder(),
//                             ),
//                           ),
//                   ),
//                   if (!_isAvailable(product))
//                     Positioned.fill(
//                       child: Container(
//                         color: const Color(0x66000000),
//                         alignment: Alignment.center,
//                         child: const Text(
//                           'UNAVAILABLE',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 2,
//                           ),
//                         ),
//                       ),
//                     ),
//                   if (product.hasColors)
//                     Positioned(
//                       left: 14,
//                       bottom: 14,
//                       child: Obx(() => _imageColorPill(product)),
//                     ),
//                   if (count > 1)
//                     Positioned(
//                       right: 14,
//                       bottom: 14,
//                       child: Obx(
//                         () => Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 5,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0x99000000),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             '${imageIndex.value + 1} / $count',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   if (showArrows && count > 1) ...[
//                     Positioned(
//                       left: 12,
//                       top: 0,
//                       bottom: 0,
//                       child: Center(
//                         child: _arrow(Icons.chevron_left_rounded, () {
//                           final i = imageIndex.value;
//                           _goToImage(i > 0 ? i - 1 : count - 1);
//                         }),
//                       ),
//                     ),
//                     Positioned(
//                       right: 12,
//                       top: 0,
//                       bottom: 0,
//                       child: Center(
//                         child: _arrow(Icons.chevron_right_rounded, () {
//                           final i = imageIndex.value;
//                           _goToImage(i < count - 1 ? i + 1 : 0);
//                         }),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//         if (count > 1) ...[
//           const SizedBox(height: 14),
//           SizedBox(
//             height: 68,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: count,
//               separatorBuilder: (_, __) => const SizedBox(width: 10),
//               itemBuilder: (_, i) => Obx(() {
//                 final selected = imageIndex.value == i;

//                 return GestureDetector(
//                   onTap: () => _goToImage(i),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     width: 68,
//                     height: 68,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: selected ? p.text : p.border,
//                         width: selected ? 2 : 1,
//                       ),
//                     ),
//                     child: Stack(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(14),
//                           child: Opacity(
//                             opacity: selected ? 1 : 0.7,
//                             child: Image.memory(
//                               _bytes(product, i),
//                               fit: BoxFit.cover,
//                               gaplessPlayback: true,
//                               errorBuilder: (_, __, ___) =>
//                                   Container(color: p.tile),
//                             ),
//                           ),
//                         ),
//                         if (product.colorAt(i) != null)
//                           Positioned(
//                             left: 6,
//                             bottom: 6,
//                             child: _colorDot(product.colorAt(i)!.color, 14),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Future<void> _goToImage(int index) async {
//     if (!_pager.hasClients) return;

//     await _pager.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOutCubic,
//     );
//   }

//   Widget _arrow(IconData icon, VoidCallback onTap) {
//     return Material(
//       color: const Color(0x99000000),
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Icon(icon, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   //==================================================
//   // DETAILS
//   //==================================================

//   Widget _details(_P p, ProductModel product, {required bool isDesktop}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: [
//             if (product.category.trim().isNotEmpty)
//               _chip(product.category, color: p.text, background: p.tile),
//             _stockChip(product),
//           ],
//         ),
//         const SizedBox(height: 14),
//         Text(
//           product.name,
//           style: TextStyle(
//             color: p.text,
//             fontSize: 28,
//             height: 1.15,
//             fontWeight: FontWeight.w800,
//             letterSpacing: -0.6,
//           ),
//         ),
//         const SizedBox(height: 14),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               _naira(product.price),
//               style: TextStyle(
//                 color: p.text,
//                 fontSize: 30,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: -0.6,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 5),
//               child: Obx(() {
//                 final fee = product.deliveryFeeFor(cartCtrl.deliveryZone.value);

//                 return Text(
//                   fee > 0 ? '+ ${_naira(fee)} delivery' : 'Free delivery',
//                   style: TextStyle(color: p.muted, fontSize: 13),
//                 );
//               }),
//             ),
//           ],
//         ),
//         if (product.hasColors) ...[
//           const SizedBox(height: 24),
//           _colorSection(p, product),
//         ],
//         const SizedBox(height: 24),
//         _deliverySection(p, product),
//         const SizedBox(height: 22),
//         Row(
//           children: [
//             Expanded(
//               child: _trust(
//                 p,
//                 Icons.lock_outline_rounded,
//                 'Secure checkout',
//                 'Powered by Paystack',
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _trust(
//                 p,
//                 Icons.local_shipping_outlined,
//                 'Order tracking',
//                 'Follow every step',
//               ),
//             ),
//           ],
//         ),
//         if (isDesktop) ...[
//           const SizedBox(height: 22),
//           Container(
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               color: p.surface,
//               borderRadius: BorderRadius.circular(22),
//               border: Border.all(color: p.border),
//               boxShadow: p.shadow,
//             ),
//             child: _purchase(p, product),
//           ),
//         ],
//         const SizedBox(height: 28),
//         _sectionTitle('Description', p),
//         const SizedBox(height: 10),
//         Text(
//           product.description.trim().isEmpty
//               ? 'No description provided.'
//               : product.description,
//           style: TextStyle(color: p.muted, fontSize: 14.5, height: 1.65),
//         ),
//         const SizedBox(height: 28),
//         _sectionTitle('Specifications', p),
//         const SizedBox(height: 12),
//         _specifications(p, product),
//         const SizedBox(height: 32),
//         _related(p, product),
//       ],
//     );
//   }

//   //==================================================
//   // COLOUR
//   //==================================================

//   Widget _colorDot(Color color, double size) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white, width: 1.5),
//         boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 3)],
//       ),
//     );
//   }

//   /// Name of the colour of the image currently on screen.
//   Widget _imageColorPill(ProductModel product) {
//     final c = product.colorAt(imageIndex.value);
//     if (c == null) return const SizedBox.shrink();

//     return Container(
//       padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
//       decoration: BoxDecoration(
//         color: const Color(0x99000000),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _colorDot(c.color, 12),
//           const SizedBox(width: 7),
//           Text(
//             c.name,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _colorSection(_P p, ProductModel product) {
//     final options = product.colorOptions;

//     return Obx(() {
//       final selected = _selectedColor(product);

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 'Colour',
//                 style: TextStyle(
//                   color: p.text,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   selected?.name ?? '',
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: p.muted,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: [
//               for (final o in options)
//                 _swatch(p, product, o, selected?.key == o.color.key),
//             ],
//           ),
//         ],
//       );
//     });
//   }

//   Widget _swatch(
//     _P p,
//     ProductModel product,
//     ColorOption option,
//     bool selected,
//   ) {
//     final dark =
//         ThemeData.estimateBrightnessForColor(option.color.color) ==
//         Brightness.dark;

//     return Tooltip(
//       message: option.color.name,
//       child: GestureDetector(
//         onTap: () => _selectColor(product, option),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           width: 48,
//           height: 48,
//           padding: const EdgeInsets.all(3.5),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: selected ? p.text : Colors.transparent,
//               width: 2,
//             ),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: option.color.color,
//               shape: BoxShape.circle,
//               border: Border.all(color: p.border),
//             ),
//             child: selected
//                 ? Icon(
//                     Icons.check_rounded,
//                     size: 18,
//                     color: dark ? Colors.white : Colors.black,
//                   )
//                 : null,
//           ),
//         ),
//       ),
//     );
//   }

//   //==================================================
//   // DELIVERY LOCATION
//   //==================================================

//   Widget _deliverySection(_P p, ProductModel product) {
//     String fee(double v) => v > 0 ? _naira(v) : 'Free';

//     return Obx(() {
//       final zone = cartCtrl.deliveryZone.value;

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Deliver to',
//             style: TextStyle(
//               color: p.text,
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 12),
//           DeliveryZoneSelector(
//             zone: zone,
//             onChanged: cartCtrl.setDeliveryZone,
//             tile: p.tile,
//             border: p.border,
//             accent: p.accent,
//             onAccent: p.onAccent,
//             text: p.text,
//             muted: p.muted,
//             enuguSubtitle: fee(product.deliveryFeeEnugu),
//             outsideSubtitle: fee(product.deliveryFeeOutside),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Icon(Icons.local_shipping_outlined, size: 15, color: p.muted),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   'Delivery ${zone.label.toLowerCase()}: '
//                   '${fee(product.deliveryFeeFor(zone))}',
//                   style: TextStyle(color: p.muted, fontSize: 12.5),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     });
//   }

//   Widget _sectionTitle(String text, _P p) {
//     return Text(
//       text,
//       style: TextStyle(
//         color: p.text,
//         fontSize: 18,
//         fontWeight: FontWeight.w800,
//         letterSpacing: -0.3,
//       ),
//     );
//   }

//   Widget _chip(
//     String label, {
//     required Color color,
//     required Color background,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: background,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: color,
//           fontSize: 12.5,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//   }

//   Widget _stockChip(ProductModel product) {
//     if (!_isAvailable(product)) {
//       return _chip(
//         'Out of stock',
//         color: _red,
//         background: const Color(0x1AE5484D),
//       );
//     }

//     if (product.stock <= 5) {
//       return _chip(
//         'Only ${product.stock} left',
//         color: _amber,
//         background: const Color(0x1AD97706),
//       );
//     }

//     return _chip(
//       'In stock',
//       color: _green,
//       background: const Color(0x1A16A34A),
//     );
//   }

//   Widget _trust(_P p, IconData icon, String title, String subtitle) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: p.surface,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: p.border),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: p.tile,
//               borderRadius: BorderRadius.circular(11),
//             ),
//             child: Icon(icon, size: 18, color: p.text),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: p.text,
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(color: p.muted, fontSize: 11),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _specifications(_P p, ProductModel product) {
//     final rows = <MapEntry<String, String>>[
//       MapEntry('Category', product.category.isEmpty ? '—' : product.category),
//       MapEntry(
//         'Availability',
//         _isAvailable(product) ? 'Available' : 'Unavailable',
//       ),
//       MapEntry('Units in stock', '${product.stock}'),
//       if (product.hasColors)
//         MapEntry(
//           'Colours',
//           product.colorOptions.map((o) => o.color.name).join(', '),
//         ),
//       MapEntry(
//         'Delivery · Within Enugu',
//         product.deliveryFeeEnugu > 0
//             ? _naira(product.deliveryFeeEnugu)
//             : 'Free',
//       ),
//       MapEntry(
//         'Delivery · Outside Enugu',
//         product.deliveryFeeOutside > 0
//             ? _naira(product.deliveryFeeOutside)
//             : 'Free',
//       ),
//     ];

//     final children = <Widget>[];

//     for (var i = 0; i < rows.length; i++) {
//       children.add(
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//           child: Row(
//             children: [
//               Text(
//                 rows[i].key,
//                 style: TextStyle(color: p.muted, fontSize: 13.5),
//               ),
//               const Spacer(),
//               Flexible(
//                 child: Text(
//                   rows[i].value,
//                   textAlign: TextAlign.end,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: p.text,
//                     fontSize: 13.5,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );

//       if (i != rows.length - 1) {
//         children.add(Divider(height: 1, color: p.border));
//       }
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: p.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: p.border),
//       ),
//       child: Column(children: children),
//     );
//   }

//   //==================================================
//   // PURCHASE PANEL (inline on desktop, bottom bar on mobile)
//   //==================================================

//   Widget _bottomBar(_P p, ProductModel product) {
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
//       child: SafeArea(top: false, child: _purchase(p, product)),
//     );
//   }

//   Widget _purchase(_P p, ProductModel product) {
//     final available = _isAvailable(product);

//     return Obx(() {
//       final qty = quantity.value;
//       final isBusy = busy.value;
//       final maxQty = product.stock > 0 ? product.stock : 1;

//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               _stepper(p, qty: qty, maxQty: maxQty, enabled: available),
//               const Spacer(),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'Subtotal',
//                     style: TextStyle(color: p.muted, fontSize: 12),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     _naira(product.price * qty),
//                     style: TextStyle(
//                       color: p.text,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: -0.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Row(
//             children: [
//               Expanded(
//                 child: Builder(
//                   builder: (btnCtx) => OutlinedButton.icon(
//                     onPressed: (!available || isBusy)
//                         ? null
//                         : () => _addToCart(
//                             product,
//                             p,
//                             // the cart icon replaces the snackbar as feedback
//                             onAdded: () => _flyToCart(btnCtx, product, p),
//                           ),
//                     icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
//                     label: const Text('Add to cart'),
//                     style: OutlinedButton.styleFrom(
//                       minimumSize: const Size.fromHeight(52),
//                       foregroundColor: p.text,
//                       side: BorderSide(color: p.text.withOpacity(0.35)),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       textStyle: const TextStyle(fontWeight: FontWeight.w700),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: (!available || isBusy)
//                       ? null
//                       : () async {
//                           final ok = await _addToCart(product, p);
//                           if (ok) nav.goTo(EcommerceLiveRoutes.cart);
//                         },
//                   style: ElevatedButton.styleFrom(
//                     elevation: 0,
//                     minimumSize: const Size.fromHeight(52),
//                     backgroundColor: p.accent,
//                     foregroundColor: p.onAccent,
//                     disabledBackgroundColor: p.tile,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     textStyle: const TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                   child: isBusy
//                       ? SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2.4,
//                             color: p.onAccent,
//                           ),
//                         )
//                       : Text(available ? 'Buy now' : 'Unavailable'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     });
//   }

//   Widget _stepper(
//     _P p, {
//     required int qty,
//     required int maxQty,
//     required bool enabled,
//   }) {
//     Widget button(IconData icon, VoidCallback? onTap) {
//       return InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: SizedBox(
//           width: 40,
//           height: 40,
//           child: Icon(
//             icon,
//             size: 20,
//             color: onTap == null ? p.muted.withOpacity(0.5) : p.text,
//           ),
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: p.tile,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           button(
//             Icons.remove_rounded,
//             enabled && qty > 1 ? () => quantity.value-- : null,
//           ),
//           SizedBox(
//             width: 36,
//             child: Text(
//               '$qty',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: p.text,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           button(
//             Icons.add_rounded,
//             enabled && qty < maxQty ? () => quantity.value++ : null,
//           ),
//         ],
//       ),
//     );
//   }

//   //==================================================
//   // RELATED
//   //==================================================

//   Widget _related(_P p, ProductModel product) {
//     final related = storeCtrl.products
//         .where((e) => e.category == product.category && e.id != product.id)
//         .take(10)
//         .toList();

//     if (related.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionTitle('You may also like', p),
//         const SizedBox(height: 14),
//         SizedBox(
//           height: 244,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: related.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 14),
//             itemBuilder: (_, i) => _relatedCard(p, related[i]),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _relatedCard(_P p, ProductModel item) {
//     return SizedBox(
//       width: 170,
//       child: Material(
//         color: p.surface,
//         clipBehavior: Clip.antiAlias,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//           side: BorderSide(color: p.border),
//         ),
//         child: InkWell(
//           onTap: () => _openProduct(item),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AspectRatio(
//                 aspectRatio: 1,
//                 child: item.images.isEmpty
//                     ? Container(
//                         color: p.tile,
//                         child: Icon(Icons.image_outlined, color: p.muted),
//                       )
//                     : Image.memory(
//                         _bytes(item, 0),
//                         fit: BoxFit.cover,
//                         gaplessPlayback: true,
//                         errorBuilder: (_, __, ___) => Container(color: p.tile),
//                       ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.name,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: p.text,
//                         fontSize: 13.5,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _naira(item.price),
//                       style: TextStyle(
//                         color: p.text,
//                         fontSize: 14.5,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// //==================================================
// // PALETTE
// //==================================================

// class _P {
//   const _P(this.isDark);

//   final bool isDark;

//   Color get bg => isDark ? const Color(0xFF0E0E10) : const Color(0xFFF6F6F7);
//   Color get surface => isDark ? const Color(0xFF1A1A1D) : Colors.white;
//   Color get border =>
//       isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE9E9EC);
//   Color get tile => isDark ? const Color(0xFF26262A) : const Color(0xFFF1F1F3);
//   Color get text => isDark ? Colors.white : const Color(0xFF0B0B0C);
//   Color get muted => isDark ? const Color(0xFF9A9AA2) : const Color(0xFF6B6B73);
//   Color get accent => isDark ? Colors.white : const Color(0xFF0B0B0C);
//   Color get onAccent => isDark ? const Color(0xFF0B0B0C) : Colors.white;

//   List<BoxShadow> get shadow => isDark
//       ? const []
//       : const [
//           BoxShadow(
//             color: Color(0x0A000000),
//             blurRadius: 18,
//             offset: Offset(0, 8),
//           ),
//         ];
// }

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/ecommerceCartController.dart';
import 'package:hyend/controllers/ecommerceStoreController.dart';
import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/models/productModel.dart';
import 'package:hyend/pages/deliveryZoneSelector.dart';
import 'package:hyend/pages/flyToCart.dart';
import 'package:hyend/userAuth/authController.dart';

import 'ecommerce_routes.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final EcommerceLiveNavController nav = Get.find();
  final AuthController authCtrl = Get.find();
  final EcommerceStoreController storeCtrl = Get.find();
  final EcommerceCartController cartCtrl = Get.find();

  // ThemeController is created at login; fall back safely on cold start.
  final ThemeController themeCtrl = Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : Get.put(ThemeController());

  /// The product this page shows. Owned by the page itself (seeded from the
  /// route argument), so it can never be lost to a controller being recreated.
  final Rxn<ProductModel> _selected = Rxn<ProductModel>();

  /// Units the customer is about to add. Starts at the wholesale minimum (5).
  final RxInt quantity = EcommerceCartController.minOrderQty.obs;
  final TextEditingController _qtyCtrl = TextEditingController(
    text: '${EcommerceCartController.minOrderQty}',
  );
  final RxInt imageIndex = 0.obs;
  final RxBool busy = false.obs;

  /// Key (RRGGBB) of the colour the customer picked; null = first colour.
  final RxnString selectedColorKey = RxnString();
  bool _lockColor = false;

  /// Target of the fly-to-cart animation (the cart icon in the app bar).
  final GlobalKey<CartFlyTargetState> _cartFlyKey =
      GlobalKey<CartFlyTargetState>();

  final PageController _pager = PageController();
  final ScrollController _scroll = ScrollController();

  /// Decoded image bytes, so base64 is decoded once instead of on every build.
  final Map<String, Uint8List> _imageCache = {};

  static const Color _green = Color(0xFF16A34A);
  static const Color _amber = Color(0xFFD97706);
  static const Color _red = Color(0xFFE5484D);

  @override
  void initState() {
    super.initState();

    final arg = Get.arguments;
    if (arg is ProductModel) {
      _selected.value = arg;
      storeCtrl.selectProduct(arg);
    } else {
      _selected.value = storeCtrl.selectedProduct.value;
    }

    final current = _selected.value;
    if (current != null) _resetQuantity(current);
  }

  @override
  void dispose() {
    _pager.dispose();
    _scroll.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  //==================================================
  // HELPERS
  //==================================================

  String _naira(num value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return parts[1] == '00' ? '₦$whole' : '₦$whole.${parts[1]}';
  }

  Uint8List _bytes(ProductModel product, int index) {
    final key = '${product.id}:$index';
    final cached = _imageCache[key];
    if (cached != null) return cached;

    try {
      final decoded = base64Decode(product.images[index]);
      _imageCache[key] = decoded;
      return decoded;
    } catch (_) {
      return Uint8List(0);
    }
  }

  /// Back to the minimum order for [product] (5, or what is left if less).
  void _resetQuantity(ProductModel product) {
    final min = cartCtrl.minOrderFor(product);
    quantity.value = min;
    _qtyCtrl.text = '$min';
  }

  /// Sets the quantity (never above the stock) and shows it in the input.
  void _setQty(ProductModel product, int value, {bool syncText = true}) {
    final capped = (product.stock > 0 && value > product.stock)
        ? product.stock
        : value;

    quantity.value = capped;

    if (syncText && _qtyCtrl.text != '$capped') {
      _qtyCtrl.value = TextEditingValue(
        text: '$capped',
        selection: TextSelection.collapsed(offset: '$capped'.length),
      );
    }
  }

  bool _isAvailable(ProductModel product) =>
      product.isActive && product.stock > 0;

  void _snack(String title, String message, _P p) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: p.surface,
      colorText: p.text,
      borderRadius: 14,
      margin: const EdgeInsets.all(14),
    );
  }

  void _openProduct(ProductModel product) {
    _resetQuantity(product);
    imageIndex.value = 0;
    selectedColorKey.value = null;

    if (_pager.hasClients) _pager.jumpToPage(0);

    _selected.value = product;
    storeCtrl.selectProduct(product);

    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  bool _requireLogin(_P p) {
    if (authCtrl.isAuthenticated) return true;

    _snack('Login required', 'Please login to continue', p);
    Get.toNamed(EcommerceLiveRoutes.login);
    return false;
  }

  ProductColor? _selectedColor(ProductModel product) {
    final options = product.colorOptions;
    if (options.isEmpty) return null;

    final key = selectedColorKey.value;
    final match = key == null
        ? null
        : options.firstWhereOrNull((o) => o.color.key == key);

    return (match ?? options.first).color;
  }

  /// Image that shows [color] (the one being viewed if it matches).
  int _cartImageIndex(ProductModel product, ProductColor color) {
    final current = imageIndex.value;
    if (product.colorAt(current)?.key == color.key) return current;

    final option = product.colorOptions.firstWhereOrNull(
      (o) => o.color.key == color.key,
    );
    return option?.imageIndex ?? 0;
  }

  /// Plays the Temu-style "jump into the cart" animation.
  void _flyToCart(BuildContext from, ProductModel product, _P p) {
    final i = imageIndex.value;
    final bytes = (i >= 0 && i < product.images.length)
        ? _bytes(product, i)
        : null;

    FlyToCart.launch(
      from: from,
      to: _cartFlyKey,
      trailColor: p.accent,
      size: 64,
      flyer: FlyToCart.thumbnail(
        bytes: bytes,
        background: p.tile,
        ring: p.surface,
        iconColor: p.text,
      ),
    );
  }

  Future<void> _selectColor(ProductModel product, ColorOption option) async {
    selectedColorKey.value = option.color.key;

    // already looking at an image of this colour
    if (product.colorAt(imageIndex.value)?.key == option.color.key) return;

    _lockColor = true; // don't let the sliding gallery flip the colour
    await _goToImage(option.imageIndex);
    _lockColor = false;
  }

  String _colorSuffix(ProductModel product) {
    final c = _selectedColor(product);
    return c == null ? '' : ' (${c.name})';
  }

  Future<bool> _addToCart(
    ProductModel product,
    _P p, {
    VoidCallback? onAdded,
  }) async {
    if (busy.value || !_requireLogin(p)) return false;

    final minQty = cartCtrl.minOrderFor(product);
    if (quantity.value < minQty) {
      _snack('Minimum order', 'The minimum order is $minQty units.', p);
      return false;
    }

    try {
      busy.value = true;

      final color = _selectedColor(product);

      return await cartCtrl.addToCart(
        product,
        quantity: quantity.value,
        color: color,
        imageIndex: color == null ? 0 : _cartImageIndex(product, color),
        onAdded: onAdded,
      );
    } catch (e) {
      _snack('Error', 'Could not update your cart. Please try again.', p);
      return false;
    } finally {
      busy.value = false;
    }
  }

  //==================================================
  // BUILD
  //==================================================

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = _P(themeCtrl.isDarkMode.value);
      final product = _selected.value;

      if (product == null) {
        return Scaffold(
          backgroundColor: p.bg,
          appBar: AppBar(
            backgroundColor: p.bg,
            surfaceTintColor: Colors.transparent,
            iconTheme: IconThemeData(color: p.text),
          ),
          body: Center(
            child: Text('Product not found', style: TextStyle(color: p.muted)),
          ),
        );
      }

      final isDesktop = MediaQuery.of(context).size.width > 900;

      return Scaffold(
        backgroundColor: p.bg,
        appBar: _appBar(p),
        bottomNavigationBar: isDesktop ? null : _bottomBar(p, product),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _gallery(p, product, showArrows: true),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 4,
                          child: _details(p, product, isDesktop: true),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _gallery(p, product, showArrows: false),
                        const SizedBox(height: 24),
                        _details(p, product, isDesktop: false),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  //==================================================
  // APP BAR
  //==================================================

  PreferredSizeWidget _appBar(_P p) {
    final count = cartCtrl.cartCount;

    return AppBar(
      backgroundColor: p.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: p.text),
      centerTitle: false,
      title: Text(
        'Details',
        style: TextStyle(
          color: p.text,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        CartFlyTarget(
          key: _cartFlyKey,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Cart',
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  if (_requireLogin(p)) nav.goTo(EcommerceLiveRoutes.cart);
                },
              ),
              if (count > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.onAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  //==================================================
  // GALLERY
  //==================================================

  Widget _gallery(_P p, ProductModel product, {required bool showArrows}) {
    final count = product.images.length;

    Widget placeholder() =>
        Center(child: Icon(Icons.image_outlined, size: 64, color: p.muted));

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: p.border),
              boxShadow: p.shadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: count == 0
                        ? placeholder()
                        : PageView.builder(
                            key: ValueKey(product.id),
                            controller: _pager,
                            itemCount: count,
                            onPageChanged: (i) {
                              imageIndex.value = i;
                              final c = product.colorAt(i);
                              if (c != null && !_lockColor) {
                                selectedColorKey.value = c.key;
                              }
                            },
                            itemBuilder: (_, i) => Image.memory(
                              _bytes(product, i),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (_, __, ___) => placeholder(),
                            ),
                          ),
                  ),
                  if (!_isAvailable(product))
                    Positioned.fill(
                      child: Container(
                        color: const Color(0x66000000),
                        alignment: Alignment.center,
                        child: const Text(
                          'UNAVAILABLE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  if (product.hasColors)
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Obx(() => _imageColorPill(product)),
                    ),
                  if (count > 1)
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x99000000),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${imageIndex.value + 1} / $count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (showArrows && count > 1) ...[
                    Positioned(
                      left: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _arrow(Icons.chevron_left_rounded, () {
                          final i = imageIndex.value;
                          _goToImage(i > 0 ? i - 1 : count - 1);
                        }),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _arrow(Icons.chevron_right_rounded, () {
                          final i = imageIndex.value;
                          _goToImage(i < count - 1 ? i + 1 : 0);
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => Obx(() {
                final selected = imageIndex.value == i;

                return GestureDetector(
                  onTap: () => _goToImage(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? p.text : p.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Opacity(
                            opacity: selected ? 1 : 0.7,
                            child: Image.memory(
                              _bytes(product, i),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: p.tile),
                            ),
                          ),
                        ),
                        if (product.colorAt(i) != null)
                          Positioned(
                            left: 6,
                            bottom: 6,
                            child: _colorDot(product.colorAt(i)!.color, 14),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _goToImage(int index) async {
    if (!_pager.hasClients) return;

    await _pager.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _arrow(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0x99000000),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  //==================================================
  // DETAILS
  //==================================================

  Widget _details(_P p, ProductModel product, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.category.trim().isNotEmpty)
              _chip(product.category, color: p.text, background: p.tile),
            _stockChip(product),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          product.name,
          style: TextStyle(
            color: p.text,
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _naira(product.price),
              style: TextStyle(
                color: p.text,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Obx(() {
                final fee = product.deliveryFeeFor(cartCtrl.deliveryZone.value);

                return Text(
                  fee > 0 ? '+ ${_naira(fee)} service fee' : 'No service fee',
                  style: TextStyle(color: p.muted, fontSize: 13),
                );
              }),
            ),
          ],
        ),
        if (product.hasColors) ...[
          const SizedBox(height: 24),
          _colorSection(p, product),
        ],
        const SizedBox(height: 24),
        _deliverySection(p, product),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _trust(
                p,
                Icons.lock_outline_rounded,
                'Secure checkout',
                'Powered by Paystack',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _trust(
                p,
                Icons.local_shipping_outlined,
                'Order tracking',
                'Follow every step',
              ),
            ),
          ],
        ),
        if (isDesktop) ...[
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: p.border),
              boxShadow: p.shadow,
            ),
            child: _purchase(p, product),
          ),
        ],
        const SizedBox(height: 28),
        _sectionTitle('Description', p),
        const SizedBox(height: 10),
        Text(
          product.description.trim().isEmpty
              ? 'No description provided.'
              : product.description,
          style: TextStyle(color: p.muted, fontSize: 14.5, height: 1.65),
        ),
        const SizedBox(height: 28),
        _sectionTitle('Specifications', p),
        const SizedBox(height: 12),
        _specifications(p, product),
        const SizedBox(height: 32),
        _related(p, product),
      ],
    );
  }

  //==================================================
  // COLOUR
  //==================================================

  Widget _colorDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 3)],
      ),
    );
  }

  /// Name of the colour of the image currently on screen.
  Widget _imageColorPill(ProductModel product) {
    final c = product.colorAt(imageIndex.value);
    if (c == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: BoxDecoration(
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _colorDot(c.color, 12),
          const SizedBox(width: 7),
          Text(
            c.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorSection(_P p, ProductModel product) {
    final options = product.colorOptions;

    return Obx(() {
      final selected = _selectedColor(product);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Colour',
                style: TextStyle(
                  color: p.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selected?.name ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final o in options)
                _swatch(p, product, o, selected?.key == o.color.key),
            ],
          ),
        ],
      );
    });
  }

  Widget _swatch(
    _P p,
    ProductModel product,
    ColorOption option,
    bool selected,
  ) {
    final dark =
        ThemeData.estimateBrightnessForColor(option.color.color) ==
        Brightness.dark;

    return Tooltip(
      message: option.color.name,
      child: GestureDetector(
        onTap: () => _selectColor(product, option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(3.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? p.text : Colors.transparent,
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: option.color.color,
              shape: BoxShape.circle,
              border: Border.all(color: p.border),
            ),
            child: selected
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: dark ? Colors.white : Colors.black,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  //==================================================
  // DELIVERY LOCATION
  //==================================================

  Widget _deliverySection(_P p, ProductModel product) {
    String fee(double v) => v > 0 ? _naira(v) : 'Free';

    return Obx(() {
      final zone = cartCtrl.deliveryZone.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deliver to',
            style: TextStyle(
              color: p.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          DeliveryZoneSelector(
            zone: zone,
            onChanged: cartCtrl.setDeliveryZone,
            tile: p.tile,
            border: p.border,
            accent: p.accent,
            onAccent: p.onAccent,
            text: p.text,
            muted: p.muted,
            enuguSubtitle: fee(product.deliveryFeeEnugu),
            outsideSubtitle: fee(product.deliveryFeeOutside),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.public_rounded, size: 15, color: p.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Service fee ${zone.label.toLowerCase()}: '
                  '${fee(product.deliveryFeeFor(zone))}',
                  style: TextStyle(color: p.muted, fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
        ],
      );
    });
  }

  Widget _sectionTitle(String text, _P p) {
    return Text(
      text,
      style: TextStyle(
        color: p.text,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _chip(
    String label, {
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _stockChip(ProductModel product) {
    if (!_isAvailable(product)) {
      return _chip(
        'Out of stock',
        color: _red,
        background: const Color(0x1AE5484D),
      );
    }

    if (product.stock <= 5) {
      return _chip(
        'Only ${product.stock} left',
        color: _amber,
        background: const Color(0x1AD97706),
      );
    }

    return _chip(
      'In stock',
      color: _green,
      background: const Color(0x1A16A34A),
    );
  }

  Widget _trust(_P p, IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.tile,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: p.text),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specifications(_P p, ProductModel product) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Category', product.category.isEmpty ? '—' : product.category),
      MapEntry(
        'Availability',
        _isAvailable(product) ? 'Available' : 'Unavailable',
      ),
      MapEntry('Units in stock', '${product.stock}'),
      if (product.hasColors)
        MapEntry(
          'Colours',
          product.colorOptions.map((o) => o.color.name).join(', '),
        ),
      MapEntry(
        'Service fee · Within Enugu',
        product.deliveryFeeEnugu > 0
            ? _naira(product.deliveryFeeEnugu)
            : 'Free',
      ),
      MapEntry(
        'Service fee · Outside Enugu',
        product.deliveryFeeOutside > 0
            ? _naira(product.deliveryFeeOutside)
            : 'Free',
      ),
    ];

    final children = <Widget>[];

    for (var i = 0; i < rows.length; i++) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Text(
                rows[i].key,
                style: TextStyle(color: p.muted, fontSize: 13.5),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  rows[i].value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (i != rows.length - 1) {
        children.add(Divider(height: 1, color: p.border));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Column(children: children),
    );
  }

  //==================================================
  // PURCHASE PANEL (inline on desktop, bottom bar on mobile)
  //==================================================

  Widget _bottomBar(_P p, ProductModel product) {
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
      child: SafeArea(top: false, child: _purchase(p, product)),
    );
  }

  Widget _purchase(_P p, ProductModel product) {
    final available = _isAvailable(product);
    final minQty = cartCtrl.minOrderFor(product);

    return Obx(() {
      final qty = quantity.value;
      final isBusy = busy.value;
      final maxQty = product.stock > 0 ? product.stock : 1;
      final valid = qty >= minQty && qty <= maxQty;
      final canAdd = available && valid && !isBusy;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (available) ...[
            _quickQuantities(p, product, qty: qty, maxQty: maxQty),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              _stepper(
                p,
                product,
                qty: qty,
                minQty: minQty,
                maxQty: maxQty,
                enabled: available,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(color: p.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _naira(product.price * (valid ? qty : 0)),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (available)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  qty < minQty
                      ? 'Minimum order is $minQty units'
                      : qty >= maxQty
                      ? 'Maximum available: $maxQty units'
                      : 'Wholesale \u00b7 minimum $minQty units',
                  style: TextStyle(
                    color: qty < minQty ? _red : p.muted,
                    fontSize: 12,
                    fontWeight: qty < minQty
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (btnCtx) => OutlinedButton.icon(
                    onPressed: !canAdd
                        ? null
                        : () => _addToCart(
                            product,
                            p,
                            // the cart icon replaces the snackbar as feedback
                            onAdded: () => _flyToCart(btnCtx, product, p),
                          ),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: const Text('Add to cart'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: p.text,
                      side: BorderSide(color: p.text.withOpacity(0.35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: !canAdd
                      ? null
                      : () async {
                          final ok = await _addToCart(product, p);
                          if (ok) nav.goTo(EcommerceLiveRoutes.cart);
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: p.accent,
                    foregroundColor: p.onAccent,
                    disabledBackgroundColor: p.tile,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: isBusy
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: p.onAccent,
                          ),
                        )
                      : Text(available ? 'Buy now' : 'Unavailable'),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  /// One-tap quantities: 5, 10, 15, 20 (only those the stock allows) and the
  /// full stock when it is more than that.
  Widget _quickQuantities(
    _P p,
    ProductModel product, {
    required int qty,
    required int maxQty,
  }) {
    const steps = [5, 10, 15, 20];

    final options = <int>[...steps.where((n) => n <= maxQty)];
    if (!options.contains(maxQty)) options.add(maxQty);

    Widget chip(int n) {
      final selected = qty == n;
      final isMax = n == maxQty && !steps.contains(n);

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () => _setQty(product, n),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? p.accent : p.tile,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? p.accent : p.border),
            ),
            child: Text(
              isMax ? 'Max $n' : '$n',
              style: TextStyle(
                color: selected ? p.onAccent : p.text,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [for (final n in options) chip(n)]),
    );
  }

  Widget _stepper(
    _P p,
    ProductModel product, {
    required int qty,
    required int minQty,
    required int maxQty,
    required bool enabled,
  }) {
    Widget button(IconData icon, VoidCallback? onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? p.muted.withOpacity(0.5) : p.text,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.tile,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled && qty < minQty ? _red : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            Icons.remove_rounded,
            enabled && qty > minQty ? () => _setQty(product, qty - 1) : null,
          ),
          // type any quantity from the minimum up to the stock
          SizedBox(
            width: 64,
            child: TextField(
              controller: _qtyCtrl,
              enabled: enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
              cursorColor: p.text,
              style: TextStyle(
                color: p.text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n == null) {
                  quantity.value = 0; // empty: add buttons stay disabled
                  return;
                }
                // over the stock: clamp now; below the minimum: let them keep
                // typing (e.g. "1" on the way to "15") and flag it in red.
                _setQty(product, n, syncText: n > maxQty);
              },
              onSubmitted: (_) {
                if (quantity.value < minQty) _setQty(product, minQty);
              },
            ),
          ),
          button(
            Icons.add_rounded,
            enabled && qty < maxQty ? () => _setQty(product, qty + 1) : null,
          ),
        ],
      ),
    );
  }

  //==================================================
  // RELATED
  //==================================================

  Widget _related(_P p, ProductModel product) {
    final related = storeCtrl.products
        .where((e) => e.category == product.category && e.id != product.id)
        .take(10)
        .toList();

    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('You may also like', p),
        const SizedBox(height: 14),
        SizedBox(
          height: 244,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _relatedCard(p, related[i]),
          ),
        ),
      ],
    );
  }

  Widget _relatedCard(_P p, ProductModel item) {
    return SizedBox(
      width: 170,
      child: Material(
        color: p.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.border),
        ),
        child: InkWell(
          onTap: () => _openProduct(item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: item.images.isEmpty
                    ? Container(
                        color: p.tile,
                        child: Icon(Icons.image_outlined, color: p.muted),
                      )
                    : Image.memory(
                        _bytes(item, 0),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => Container(color: p.tile),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _naira(item.price),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==================================================
// PALETTE
//==================================================

class _P {
  const _P(this.isDark);

  final bool isDark;

  Color get bg => isDark ? const Color(0xFF0E0E10) : const Color(0xFFF6F6F7);
  Color get surface => isDark ? const Color(0xFF1A1A1D) : Colors.white;
  Color get border =>
      isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE9E9EC);
  Color get tile => isDark ? const Color(0xFF26262A) : const Color(0xFFF1F1F3);
  Color get text => isDark ? Colors.white : const Color(0xFF0B0B0C);
  Color get muted => isDark ? const Color(0xFF9A9AA2) : const Color(0xFF6B6B73);
  Color get accent => isDark ? Colors.white : const Color(0xFF0B0B0C);
  Color get onAccent => isDark ? const Color(0xFF0B0B0C) : Colors.white;

  List<BoxShadow> get shadow => isDark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ];
}
