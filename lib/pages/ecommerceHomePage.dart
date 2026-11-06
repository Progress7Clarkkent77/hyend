// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:hyend/controllers/blackFridayController.dart';
// import 'package:hyend/controllers/ecommerceCartController.dart';
// import 'package:hyend/controllers/ecommerceStoreController.dart';

// import 'package:hyend/controllers/theme_controller.dart';
// import 'package:hyend/models/productModel.dart';
// import 'package:hyend/pages/adminDashboard.dart';
// import 'package:hyend/pages/flyToCart.dart';
// import 'package:hyend/pages/profile.dart';
// import 'package:hyend/userAuth/authController.dart';
// import 'package:hyend/userAuth/authpages.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'ecommerce_routes.dart';

// /// Now a StatefulWidget so the search TextEditingController is owned by
// /// this page's State and disposed with it. This fixes the
// /// "TextEditingController was used after being disposed" error, which
// /// happened because the controller lived in the store controller (which
// /// GetX can dispose/recreate) while this page kept using it.
// class EcommerceHomePage extends StatefulWidget {
//   const EcommerceHomePage({super.key});

//   @override
//   State<EcommerceHomePage> createState() => _EcommerceHomePageState();
// }

// class _EcommerceHomePageState extends State<EcommerceHomePage> {
//   late final ThemeController themeCtrl;

//   /// Current light/dark palette (reading it inside an Obx makes the widget
//   /// rebuild when the theme is switched from the profile page).
//   _HP get p => _HP(themeCtrl.isDarkMode.value);

//   // Resolved on every use instead of cached in initState. A cached reference
//   // goes stale if GetX ever deletes and recreates a controller, which left this
//   // page talking to a different instance than the pages it opens.
//   EcommerceLiveNavController get nav => Get.find<EcommerceLiveNavController>();
//   AuthController get authCtrl => Get.find<AuthController>();
//   EcommerceStoreController get storeCtrl =>
//       Get.find<EcommerceStoreController>();
//   EcommerceCartController get cartCtrl => Get.find<EcommerceCartController>();

//   // Support contact used by the Support sheet — change to your real details.
//   static const _supportEmail = 'contact@afiasplendid.co.site';

//   static const Color _bfGold = Color(0xFFF5B301);
//   static const Color _bfRed = Color(0xFFE5484D);

//   late final TextEditingController _searchCtrl;

//   final ScrollController _scroll = ScrollController();
//   Worker? _resetWorker;
//   Timer? _searchDebounce;

//   /// Target of the fly-to-cart animation (the cart icon in the app bar).
//   final GlobalKey<CartFlyTargetState> _cartFlyKey =
//       GlobalKey<CartFlyTargetState>();

//   @override
//   void initState() {
//     super.initState();
//     themeCtrl = Get.find<ThemeController>();
//     // Registered in AppBinding already; this is only a safety net.
//     Get.put(EcommerceLiveNavController(), permanent: true);

//     // Listens to the Black Friday switch for this customer (permanent).
//     BlackFridayController.ensure();

//     // Local controller, seeded with any existing search text.
//     _searchCtrl = TextEditingController(text: storeCtrl.searchText.value);

//     _scroll.addListener(_onScroll);

//     // New search / category → start again from the top.
//     _resetWorker = ever(storeCtrl.pageResetTick, (_) {
//       if (_scroll.hasClients) _scroll.jumpTo(0);
//     });
//   }

//   @override
//   void dispose() {
//     _searchDebounce?.cancel();
//     _resetWorker?.dispose();
//     _scroll.dispose();
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   /// Load the next 8 products shortly before the user reaches the bottom.
//   void _onScroll() {
//     if (!_scroll.hasClients) return;
//     final pos = _scroll.position;
//     if (pos.pixels >= pos.maxScrollExtent - 700) {
//       storeCtrl.loadMore();
//     }
//   }

//   /// On tall/wide screens 8 cards may not fill the viewport (nothing to
//   /// scroll) — keep loading until there is something to scroll.
//   void _fillIfShort() {
//     if (!mounted || !_scroll.hasClients) return;
//     if (_scroll.position.maxScrollExtent <= 0 && storeCtrl.hasMore.value) {
//       storeCtrl.loadMore();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     int crossAxisCount = 2;
//     if (width >= 1400) {
//       crossAxisCount = 6;
//     } else if (width >= 1100) {
//       crossAxisCount = 5;
//     } else if (width >= 800) {
//       crossAxisCount = 4;
//     } else if (width >= 600) {
//       crossAxisCount = 3;
//     }

//     return Obx(() {
//       final p = this.p;

//       return Scaffold(
//         backgroundColor: p.bg,
//         appBar: _appBar(),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 // STATIC: search + categories stay pinned while products scroll
//                 _searchAndCategories(),

//                 // SCROLLING: only the product cards move
//                 Expanded(
//                   child: Obx(() {
//                     final products = storeCtrl.visibleProducts;
//                     final hasMore = storeCtrl.hasMore.value;

//                     WidgetsBinding.instance.addPostFrameCallback(
//                       (_) => _fillIfShort(),
//                     );

//                     // Read here so the whole grid rebuilds when the admin
//                     // switches Black Friday on/off.
//                     final blackFriday = BlackFridayState.active.value;
//                     final maxOff = blackFriday
//                         ? _maxDiscount(storeCtrl.products)
//                         : 0.0;

//                     return CustomScrollView(
//                       controller: _scroll,
//                       cacheExtent: 500,
//                       physics: const BouncingScrollPhysics(),
//                       slivers: [
//                         if (blackFriday && maxOff > 0)
//                           SliverToBoxAdapter(child: _blackFridayBanner(maxOff)),
//                         if (products.isEmpty)
//                           SliverToBoxAdapter(child: _emptyState())
//                         else
//                           SliverPadding(
//                             padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//                             sliver: SliverGrid(
//                               delegate: SliverChildBuilderDelegate(
//                                 (_, index) {
//                                   final item = products[index];
//                                   return KeyedSubtree(
//                                     key: ValueKey(item.id),
//                                     child: _productCard(item),
//                                   );
//                                 },
//                                 childCount: products.length,
//                                 addAutomaticKeepAlives: false,
//                               ),
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: crossAxisCount,
//                                     crossAxisSpacing: 12,
//                                     mainAxisSpacing: 12,
//                                     childAspectRatio: .72,
//                                   ),
//                             ),
//                           ),
//                         if (products.isNotEmpty && hasMore)
//                           SliverToBoxAdapter(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 20),
//                               child: Center(
//                                 child: SizedBox(
//                                   width: 22,
//                                   height: 22,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2.2,
//                                     color: p.muted,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         SliverToBoxAdapter(child: _poweredBy()),
//                       ],
//                     );
//                   }),
//                 ),
//               ],
//             ),

//             // FLOATING BOTTOM BAR (hidden while the keyboard is open)
//             _floatingBottomBar(),
//           ],
//         ),
//       );
//     });
//   }

//   // ───────────────────────── APP BAR ─────────────────────────

//   PreferredSizeWidget _appBar() {
//     return AppBar(
//       backgroundColor: p.surface,
//       surfaceTintColor: Colors.transparent,
//       shadowColor: p.border,
//       systemOverlayStyle: p.isDark
//           ? SystemUiOverlayStyle.light
//           : SystemUiOverlayStyle.dark,
//       elevation: 0,
//       scrolledUnderElevation: 0.5,
//       toolbarHeight: 68,
//       titleSpacing: 16,
//       title: Row(
//         children: [
//           // Square logo with rounded corners
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: p.border),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(11),
//               child: Image.asset(
//                 'assets/images/HyEnd.png',
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) =>
//                     Icon(Icons.storefront, color: p.text),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "HyEnd",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.8,
//                     fontSize: 18,
//                     color: p.text,
//                   ),
//                 ),
//                 Text(
//                   "Wholesale beyond Borders.",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                     color: p.muted,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         Obx(() {
//           if (!authCtrl.isAuthenticated) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 16),
//               child: FilledButton.icon(
//                 style: FilledButton.styleFrom(
//                   backgroundColor: p.accent,
//                   foregroundColor: p.onAccent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () => Get.to(() => EarnLogin()),
//                 // ?.then((_) => statusCtrl.startProductLikesListener()),
//                 icon: const Icon(Icons.login, size: 18),
//                 label: const Text(
//                   "Login",
//                   style: TextStyle(fontWeight: FontWeight.w700),
//                 ),
//               ),
//             );
//           }

//           return Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _appBarAction(
//                 icon: Icons.receipt_long_outlined,
//                 label: "Orders",
//                 onTap: () => nav.goTo(EcommerceLiveRoutes.orders),
//               ),
//               _appBarAction(
//                 icon: Icons.shopping_cart_outlined,
//                 label: "Cart",
//                 badge: cartCtrl.cartCount,
//                 flyKey: _cartFlyKey,
//                 onTap: () => nav.goTo(EcommerceLiveRoutes.cart),
//               ),
//             ],
//           );
//         }),
//         Obx(() {
//           if (!authCtrl.isAdmin.value) return const SizedBox.shrink();

//           return _appBarAction(
//             icon: Icons.admin_panel_settings_outlined,
//             label: "Admin",
//             onTap: () => Get.to(() => EcommerceAdminDashboardPage()),
//           );
//         }),
//         const SizedBox(width: 8),
//       ],
//     );
//   }

//   /// Icon with a small text label underneath so users instantly know
//   /// what each button does.
//   Widget _appBarAction({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     int badge = 0,
//     GlobalKey<CartFlyTargetState>? flyKey,
//   }) {
//     return Tooltip(
//       message: label,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               flyKey == null
//                   ? _iconWithBadge(icon, badge)
//                   : CartFlyTarget(
//                       key: flyKey,
//                       child: _iconWithBadge(icon, badge),
//                     ),
//               const SizedBox(height: 3),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10.5,
//                   fontWeight: FontWeight.w600,
//                   color: p.text,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _iconWithBadge(IconData icon, int badge) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Icon(icon, size: 24, color: p.text),
//         if (badge > 0)
//           Positioned(
//             right: -8,
//             top: -6,
//             child: Container(
//               constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: p.surface, width: 1.5),
//               ),
//               child: Text(
//                 badge > 99 ? "99+" : badge.toString(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 9,
//                   fontWeight: FontWeight.bold,
//                   height: 1.1,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   /// Plays the Temu-style "jump into the cart" animation for [product].
//   void _flyToCart(BuildContext from, ProductModel product) {
//     Uint8List? bytes;
//     if (product.images.isNotEmpty) {
//       try {
//         bytes = base64Decode(product.images.first);
//       } catch (_) {}
//     }

//     FlyToCart.launch(
//       from: from,
//       to: _cartFlyKey,
//       trailColor: Colors.red,
//       flyer: FlyToCart.thumbnail(
//         bytes: bytes,
//         background: p.imageBg,
//         ring: p.surface,
//         iconColor: p.text,
//       ),
//     );
//   }

//   // ───────────────────────── SEARCH + CATEGORIES (merged, static) ─────────────────────────

//   Widget _searchAndCategories() {
//     return Container(
//       decoration: BoxDecoration(
//         color: p.surface,
//         borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
//         boxShadow: [
//           BoxShadow(
//             color: p.shadowSoft,
//             blurRadius: 14,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(16, 4, 0, 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Search
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: SizedBox(
//               height: 46,
//               child: TextField(
//                 controller: _searchCtrl,
//                 textInputAction: TextInputAction.search,
//                 onChanged: (value) {
//                   storeCtrl.searchText.value = value;
//                   _searchDebounce?.cancel();
//                   _searchDebounce = Timer(
//                     const Duration(milliseconds: 250),
//                     () => storeCtrl.filterProducts(),
//                   );
//                 },
//                 style: TextStyle(fontSize: 14, color: p.text),
//                 cursorColor: p.accent,
//                 decoration: InputDecoration(
//                   hintText: "Search by name, category or price",
//                   hintStyle: TextStyle(color: p.hint, fontSize: 13.5),
//                   prefixIcon: Icon(Icons.search, color: p.muted, size: 22),
//                   suffixIcon: ValueListenableBuilder<TextEditingValue>(
//                     valueListenable: _searchCtrl,
//                     builder: (_, value, __) => value.text.isEmpty
//                         ? const SizedBox.shrink()
//                         : IconButton(
//                             icon: Icon(Icons.close, size: 18, color: p.muted),
//                             onPressed: () {
//                               _searchDebounce?.cancel();
//                               _searchCtrl.clear();
//                               storeCtrl.searchText.value = '';
//                               storeCtrl.filterProducts();
//                             },
//                           ),
//                   ),
//                   filled: true,
//                   fillColor: p.tile,
//                   contentPadding: EdgeInsets.zero,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide(color: p.accent, width: 1.2),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),

//           // Categories (horizontal chips, Temu-style)
//           SizedBox(
//             height: 34,
//             child: Obx(() {
//               final cats = storeCtrl.categories;
//               final selected = storeCtrl.selectedCategory.value;

//               return ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.only(right: 16),
//                 itemCount: cats.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//                 itemBuilder: (_, i) {
//                   final category = cats[i];
//                   final isSelected = category == selected;

//                   return GestureDetector(
//                     onTap: () {
//                       storeCtrl.selectedCategory.value = category;
//                       storeCtrl.filterProducts();
//                     },
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: isSelected ? p.accent : p.tile,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         category,
//                         style: TextStyle(
//                           fontSize: 12.5,
//                           fontWeight: FontWeight.w600,
//                           color: isSelected ? p.onAccent : p.textSoft,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   // ───────────────────────── FLOATING BOTTOM BAR ─────────────────────────

//   Widget _floatingBottomBar() {
//     final mq = MediaQuery.of(context);
//     if (mq.viewInsets.bottom > 0) return const SizedBox.shrink();

//     return Positioned(
//       left: 0,
//       right: 0,
//       bottom: 16 + mq.padding.bottom,
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 440),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//               decoration: BoxDecoration(
//                 color: p.bar,
//                 borderRadius: BorderRadius.circular(28),
//                 border: Border.all(color: p.barBorder),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.28),
//                     blurRadius: 24,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   _barItem(Icons.policy_outlined, "Policy", _openPrivacyPolicy),
//                   _barItem(Icons.info_outline_rounded, "About Us", _showAbout),
//                   _barItem(
//                     Icons.support_agent_rounded,
//                     "Support",
//                     _showSupport,
//                   ),
//                   _barItem(
//                     Icons.person_outline_rounded,
//                     "Profile",
//                     _openProfile,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _barItem(IconData icon, String label, VoidCallback onTap) {
//     return Expanded(
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 6),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 22, color: Colors.white),
//               const SizedBox(height: 3),
//               Text(
//                 label,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 10.5,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _openProfile() {
//     final uid = authCtrl.currentUser?.uid;
//     if (uid == null) {
//       Get.snackbar(
//         'Login Required',
//         'Please login first',
//         backgroundColor: p.snackBg,
//         colorText: p.snackText,
//       );
//       return;
//     }
//     Get.to(() => const ProfileScreen());
//   }

//   void _showSheet({
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
//         decoration: BoxDecoration(
//           color: p.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
//         ),
//         child: SafeArea(
//           top: false,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: p.handle,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//                 Row(
//                   children: [
//                     Icon(icon, color: p.text),
//                     const SizedBox(width: 10),
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         color: p.text,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//                 ...children,
//               ],
//             ),
//           ),
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }

//   Widget _sheetText(String text) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: Text(
//       text,
//       style: TextStyle(fontSize: 13, height: 1.55, color: p.textSoft),
//     ),
//   );

//   static const _privacyPolicyUrl =
//       'https://docs.google.com/document/d/e/2PACX-1vRP7WWyLc3rxRJH8LoTYw7zCGqanOflXOI0qv_hVID1dYPSgzy9iiD0eKOyNC8PyeiEu9Mi9mmVJ4h5/pub';

//   /// Opens the Privacy Policy in the browser.
//   Future<void> _openPrivacyPolicy() async {
//     var opened = false;

//     try {
//       opened = await launchUrl(
//         Uri.parse(_privacyPolicyUrl),
//         mode: LaunchMode.externalApplication,
//       );
//     } catch (_) {
//       opened = false;
//     }

//     if (!opened) {
//       Get.snackbar(
//         'Privacy Policy',
//         'Could not open the link. Please try again.',
//         backgroundColor: p.snackBg,
//         colorText: p.snackText,
//       );
//     }
//   }

//   void _showAbout() => _showSheet(
//     title: "About Us",
//     icon: Icons.info_outline_rounded,
//     children: [
//       _sheetText(
//         "HyEnd — Wholesale Beyond Borders. We connect you directly to manufacturers, helping you access quality products at competitive prices.",
//       ),
//       Text(
//         "Powered by AFIA SPLENDID LTD",
//         style: TextStyle(
//           fontStyle: FontStyle.italic,
//           fontSize: 12,
//           color: p.muted,
//         ),
//       ),
//     ],
//   );

//   void _showSupport() => _showSheet(
//     title: "Support",
//     icon: Icons.support_agent_rounded,
//     children: [
//       _sheetText(
//         "Need help with an order or your account? Reach out and we'll get back to you.",
//       ),
//       SizedBox(
//         width: double.infinity,
//         child: FilledButton.icon(
//           style: FilledButton.styleFrom(
//             backgroundColor: p.accent,
//             foregroundColor: p.onAccent,
//             minimumSize: const Size.fromHeight(48),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//           ),
//           onPressed: () =>
//               launchUrl(Uri(scheme: 'mailto', path: _supportEmail)),
//           icon: const Icon(Icons.email_outlined, size: 18),
//           label: Text(_supportEmail),
//         ),
//       ),
//     ],
//   );

//   // ───────────────────────── POWERED BY ─────────────────────────

//   Widget _poweredBy() {
//     return Padding(
//       // extra bottom space so the floating bar never covers it
//       padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
//       child: Center(
//         child: Text(
//           "Powered by AFIA SPLENDID LTD",
//           style: TextStyle(
//             fontStyle: FontStyle.italic,
//             fontSize: 11.5,
//             color: p.hint,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _emptyState() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 60),
//       child: Column(
//         children: [
//           Icon(Icons.search_off_rounded, size: 48, color: p.faint),
//           const SizedBox(height: 12),
//           Text(
//             "No products found",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: p.text,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             "Try a different search or category",
//             style: TextStyle(color: p.muted),
//           ),
//         ],
//       ),
//     );
//   }

//   // ───────────────────────── PRODUCT CARD ─────────────────────────

//   String _formatPrice(num price) {
//     final fixed = price.toStringAsFixed(2);
//     final parts = fixed.split('.');
//     final whole = parts[0].replaceAllMapped(
//       RegExp(r'\B(?=(\d{3})+(?!\d))'),
//       (_) => ',',
//     );
//     return "₦$whole.${parts[1]}";
//   }

//   // ───────────────────────── BLACK FRIDAY ─────────────────────────

//   double _maxDiscount(Iterable<ProductModel> products) => products.fold(
//     0.0,
//     (max, p) => p.blackFridayPercent > max ? p.blackFridayPercent : max,
//   );

//   String _pct(double v) =>
//       v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

//   Widget _bfBadge(ProductModel product) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//       decoration: BoxDecoration(
//         color: _bfGold,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         '-${_pct(product.blackFridayPercent)}%',
//         style: const TextStyle(
//           color: Colors.black,
//           fontSize: 11,
//           fontWeight: FontWeight.w900,
//         ),
//       ),
//     );
//   }

//   Widget _blackFridayBanner(double maxOff) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF2A2005), Color(0xFF0B0B0C)],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: _bfGold.withOpacity(0.65)),
//           boxShadow: [
//             BoxShadow(
//               color: _bfGold.withOpacity(0.22),
//               blurRadius: 22,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: _bfGold,
//                 borderRadius: BorderRadius.circular(13),
//               ),
//               child: const Icon(
//                 Icons.local_offer_rounded,
//                 color: Colors.black,
//                 size: 21,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'BLACK FRIDAY IS LIVE',
//                     style: TextStyle(
//                       color: _bfGold,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   SizedBox(height: 3),
//                   Text(
//                     'Prices shown are already reduced',
//                     style: TextStyle(color: Colors.white70, fontSize: 10),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               decoration: BoxDecoration(
//                 color: _bfGold,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'UP TO ${_pct(maxOff)}% OFF',
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 8,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _productCard(ProductModel product) {
//     return Container(
//       decoration: BoxDecoration(
//         color: p.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: p.isDark ? Border.all(color: p.border) : null,
//         boxShadow: [
//           BoxShadow(
//             color: p.shadowCard,
//             blurRadius: 18,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(20),
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: () {
//             final uid = authCtrl.currentUser?.uid;

//             if (uid == null) {
//               Get.snackbar(
//                 'Login Required',
//                 'Please login first',
//                 //snackPosition: SnackPosition.BOTTOM,
//                 backgroundColor: p.snackBg,
//                 colorText: p.snackText,
//               );
//               return;
//             }

//             storeCtrl.selectProduct(product);
//             // The product also travels WITH the route, so the details page
//             // never depends on which controller instance holds the selection.
//             nav.goTo(EcommerceLiveRoutes.productDetails, arguments: product);
//           },
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // IMAGE — BoxFit.contain so the whole product is always visible
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(6),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Stack(
//                       fit: StackFit.expand,
//                       children: [
//                         Container(
//                           color: p.imageBg,
//                           child: product.images.isEmpty
//                               ? Center(
//                                   child: Icon(
//                                     Icons.image_outlined,
//                                     size: 40,
//                                     color: p.faint,
//                                   ),
//                                 )
//                               : _ProductImage(
//                                   productId: product.id.toString(),
//                                   base64: product.images.first,
//                                   faint: p.faint,
//                                 ),
//                         ),

//                         if (product.isOnBlackFriday)
//                           Positioned(top: 6, left: 6, child: _bfBadge(product)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // DETAILS — smaller text, name + price share one column
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(12, 2, 8, 10),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             product.name,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                               color: p.text,
//                             ),
//                           ),
//                           const SizedBox(height: 3),
//                           FittedBox(
//                             fit: BoxFit.scaleDown,
//                             alignment: Alignment.centerLeft,
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   _formatPrice(product.price),
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w800,
//                                     color: product.isOnBlackFriday
//                                         ? _bfRed
//                                         : p.text,
//                                   ),
//                                 ),
//                                 if (product.isOnBlackFriday) ...[
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     _formatPrice(product.regularPrice),
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: p.muted,
//                                       decoration: TextDecoration.lineThrough,
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Tooltip(
//                       message: 'Add ${cartCtrl.minOrderFor(product)} to cart',
//                       child: Material(
//                         color: p.accent,
//                         borderRadius: BorderRadius.circular(11),
//                         child: Builder(
//                           builder: (btnCtx) => InkWell(
//                             borderRadius: BorderRadius.circular(11),
//                             onTap: () => cartCtrl.addToCart(
//                               product,
//                               onAdded: () => _flyToCart(btnCtx, product),
//                             ),
//                             child: SizedBox(
//                               width: 34,
//                               height: 34,
//                               child: Icon(
//                                 Icons.add_shopping_cart_rounded,
//                                 size: 16,
//                                 color: p.onAccent,
//                               ),
//                             ),
//                           ),
//                         ),
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
// // PALETTE  (matches the profile page palette)
// //==================================================

// class _HP {
//   const _HP(this.isDark);

//   final bool isDark;

//   Color get bg => isDark ? const Color(0xFF0E0E10) : const Color(0xFFF7F7F8);
//   Color get surface => isDark ? const Color(0xFF1A1A1D) : Colors.white;
//   Color get border =>
//       isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE9E9EC);
//   Color get tile => isDark ? const Color(0xFF26262A) : const Color(0xFFF3F3F5);
//   Color get imageBg =>
//       isDark ? const Color(0xFF26262A) : const Color(0xFFF4F4F6);
//   Color get text => isDark ? Colors.white : const Color(0xFF111111);
//   Color get textSoft => isDark ? const Color(0xFFD4D4DA) : Colors.black87;
//   Color get muted => isDark ? const Color(0xFF9A9AA2) : Colors.black54;
//   Color get hint => isDark ? const Color(0xFF6E6E76) : Colors.black45;
//   Color get faint => isDark ? const Color(0xFF4A4A52) : Colors.black26;
//   Color get handle => isDark ? const Color(0xFF3A3A40) : Colors.black12;

//   // buttons, selected chips, add-to-cart
//   Color get accent => isDark ? Colors.white : const Color(0xFF111111);
//   Color get onAccent => isDark ? const Color(0xFF0B0B0C) : Colors.white;

//   // floating bottom bar
//   Color get bar => isDark ? const Color(0xFF232327) : const Color(0xFF111111);
//   Color get barBorder => isDark ? const Color(0xFF3A3A40) : Colors.white12;

//   // like button bubble on product images
//   Color get likeBg =>
//       isDark ? const Color(0xEB2A2A2E) : Colors.white.withOpacity(0.92);

//   // snackbars
//   Color get snackBg => isDark ? const Color(0xFF2A2A2E) : Colors.black;
//   Color get snackText => Colors.white;

//   Color get shadowSoft =>
//       isDark ? const Color(0x66000000) : const Color(0x0D000000);
//   Color get shadowCard =>
//       isDark ? const Color(0x66000000) : const Color(0x12000000);
// }

// //==================================================
// // LIGHTWEIGHT PRODUCT IMAGE
// //==================================================

// /// Small LRU cache of decoded base64 bytes. Without this, base64Decode ran on
// /// every rebuild AND handed Image.memory a brand-new byte list each time, so
// /// Flutter re-decoded the picture constantly (main cause of lag + memory).
// class _ImageBytesCache {
//   static const int _max = 40;
//   static final LinkedHashMap<String, Uint8List> _map =
//       LinkedHashMap<String, Uint8List>();

//   static Uint8List? get(String key, String b64) {
//     final hit = _map.remove(key);
//     if (hit != null) {
//       _map[key] = hit; // mark as most recently used
//       return hit;
//     }
//     try {
//       final bytes = base64Decode(b64);
//       _map[key] = bytes;
//       if (_map.length > _max) _map.remove(_map.keys.first);
//       return bytes;
//     } catch (_) {
//       return null;
//     }
//   }
// }

// class _ProductImage extends StatefulWidget {
//   const _ProductImage({
//     required this.productId,
//     required this.base64,
//     required this.faint,
//   });

//   final String productId;
//   final String base64;
//   final Color faint;

//   @override
//   State<_ProductImage> createState() => _ProductImageState();
// }

// class _ProductImageState extends State<_ProductImage> {
//   Uint8List? _bytes;

//   String get _key =>
//       '${widget.productId}:${widget.base64.length}:${widget.base64.hashCode}';

//   @override
//   void initState() {
//     super.initState();
//     _bytes = _ImageBytesCache.get(_key, widget.base64);
//   }

//   @override
//   void didUpdateWidget(covariant _ProductImage old) {
//     super.didUpdateWidget(old);
//     if (old.productId != widget.productId || old.base64 != widget.base64) {
//       _bytes = _ImageBytesCache.get(_key, widget.base64);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bytes = _bytes;
//     if (bytes == null) {
//       return Center(
//         child: Icon(Icons.broken_image_outlined, color: widget.faint),
//       );
//     }

//     return Image.memory(
//       bytes,
//       fit: BoxFit.contain,
//       // Decode at card size instead of full resolution → far less RAM.
//       cacheWidth: 400,
//       filterQuality: FilterQuality.low,
//       gaplessPlayback: true,
//       frameBuilder: (context, child, frame, wasSync) {
//         if (wasSync) return child;
//         return AnimatedOpacity(
//           opacity: frame == null ? 0 : 1,
//           duration: const Duration(milliseconds: 220),
//           curve: Curves.easeOut,
//           child: child,
//         );
//       },
//       errorBuilder: (_, __, ___) =>
//           Center(child: Icon(Icons.broken_image_outlined, color: widget.faint)),
//     );
//   }
// }

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/blackFridayController.dart';
import 'package:hyend/controllers/ecommerceCartController.dart';
import 'package:hyend/controllers/ecommerceStoreController.dart';

import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/models/productModel.dart';
import 'package:hyend/pages/adminDashboard.dart';
import 'package:hyend/pages/flyToCart.dart';
import 'package:hyend/pages/profile.dart';
import 'package:hyend/userAuth/authController.dart';
import 'package:hyend/userAuth/authpages.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ecommerce_routes.dart';

/// Now a StatefulWidget so the search TextEditingController is owned by
/// this page's State and disposed with it. This fixes the
/// "TextEditingController was used after being disposed" error, which
/// happened because the controller lived in the store controller (which
/// GetX can dispose/recreate) while this page kept using it.
class EcommerceHomePage extends StatefulWidget {
  const EcommerceHomePage({super.key});

  @override
  State<EcommerceHomePage> createState() => _EcommerceHomePageState();
}

class _EcommerceHomePageState extends State<EcommerceHomePage> {
  late final ThemeController themeCtrl;

  /// Current light/dark palette (reading it inside an Obx makes the widget
  /// rebuild when the theme is switched from the profile page).
  _HP get p => _HP(themeCtrl.isDarkMode.value);

  // Resolved on every use instead of cached in initState. A cached reference
  // goes stale if GetX ever deletes and recreates a controller, which left this
  // page talking to a different instance than the pages it opens.
  EcommerceLiveNavController get nav => Get.find<EcommerceLiveNavController>();
  AuthController get authCtrl => Get.find<AuthController>();
  EcommerceStoreController get storeCtrl =>
      Get.find<EcommerceStoreController>();
  EcommerceCartController get cartCtrl => Get.find<EcommerceCartController>();

  // Support contact used by the Support sheet — change to your real details.
  static const _supportEmail = 'contact@afiasplendid.co.site';
  static const _supportCompany = 'AFIA SPLENDID LTD';

  /// Company line, shown as typed and used for the phone call.
  static const _supportPhoneDisplay = '0903 032 3601';
  static const _supportPhoneDial = '+2349030323601';

  /// WhatsApp number in international format (no + or spaces): 0903... -> 234903...
  static const _supportWhatsApp = '2349030323601';

  static const Color _bfGold = Color(0xFFF5B301);
  static const Color _bfRed = Color(0xFFE5484D);

  late final TextEditingController _searchCtrl;

  final ScrollController _scroll = ScrollController();
  Worker? _resetWorker;
  Timer? _searchDebounce;

  /// Target of the fly-to-cart animation (the cart icon in the app bar).
  final GlobalKey<CartFlyTargetState> _cartFlyKey =
      GlobalKey<CartFlyTargetState>();

  @override
  void initState() {
    super.initState();
    themeCtrl = Get.find<ThemeController>();
    // Registered in AppBinding already; this is only a safety net.
    Get.put(EcommerceLiveNavController(), permanent: true);

    // Listens to the Black Friday switch for this customer (permanent).
    BlackFridayController.ensure();

    // Local controller, seeded with any existing search text.
    _searchCtrl = TextEditingController(text: storeCtrl.searchText.value);

    _scroll.addListener(_onScroll);

    // New search / category → start again from the top.
    _resetWorker = ever(storeCtrl.pageResetTick, (_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _resetWorker?.dispose();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Load the next 8 products shortly before the user reaches the bottom.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 700) {
      storeCtrl.loadMore();
    }
  }

  /// On tall/wide screens 8 cards may not fill the viewport (nothing to
  /// scroll) — keep loading until there is something to scroll.
  void _fillIfShort() {
    if (!mounted || !_scroll.hasClients) return;
    if (_scroll.position.maxScrollExtent <= 0 && storeCtrl.hasMore.value) {
      storeCtrl.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (width >= 1400) {
      crossAxisCount = 6;
    } else if (width >= 1100) {
      crossAxisCount = 5;
    } else if (width >= 800) {
      crossAxisCount = 4;
    } else if (width >= 600) {
      crossAxisCount = 3;
    }

    return Obx(() {
      final p = this.p;

      return Scaffold(
        backgroundColor: p.bg,
        appBar: _appBar(),
        body: Stack(
          children: [
            Column(
              children: [
                // STATIC: search + categories stay pinned while products scroll
                _searchAndCategories(),

                // SCROLLING: only the product cards move
                Expanded(
                  child: Obx(() {
                    final products = storeCtrl.visibleProducts;
                    final hasMore = storeCtrl.hasMore.value;

                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _fillIfShort(),
                    );

                    // Read here so the whole grid rebuilds when the admin
                    // switches Black Friday on/off.
                    final blackFriday = BlackFridayState.active.value;
                    final maxOff = blackFriday
                        ? _maxDiscount(storeCtrl.products)
                        : 0.0;

                    return CustomScrollView(
                      controller: _scroll,
                      cacheExtent: 500,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        if (blackFriday && maxOff > 0)
                          SliverToBoxAdapter(child: _blackFridayBanner(maxOff)),
                        if (products.isEmpty)
                          SliverToBoxAdapter(child: _emptyState())
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (_, index) {
                                  final item = products[index];
                                  return KeyedSubtree(
                                    key: ValueKey(item.id),
                                    child: _productCard(item),
                                  );
                                },
                                childCount: products.length,
                                addAutomaticKeepAlives: false,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: .72,
                                  ),
                            ),
                          ),
                        if (products.isNotEmpty && hasMore)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: p.muted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SliverToBoxAdapter(child: _poweredBy()),
                      ],
                    );
                  }),
                ),
              ],
            ),

            // FLOATING BOTTOM BAR (hidden while the keyboard is open)
            _floatingBottomBar(),
          ],
        ),
      );
    });
  }

  // ───────────────────────── APP BAR ─────────────────────────

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: p.border,
      systemOverlayStyle: p.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      toolbarHeight: 68,
      titleSpacing: 16,
      title: Row(
        children: [
          // Square logo with rounded corners
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                'assets/images/HyEnd.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.storefront, color: p.text),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "HyEnd",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    fontSize: 18,
                    color: p.text,
                  ),
                ),
                Text(
                  "Wholesale beyond Borders.",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: p.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          if (!authCtrl.isAuthenticated) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: p.onAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.to(() => EarnLogin()),
                // ?.then((_) => statusCtrl.startProductLikesListener()),
                icon: const Icon(Icons.login, size: 18),
                label: const Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _appBarAction(
                icon: Icons.receipt_long_outlined,
                label: "Orders",
                onTap: () => nav.goTo(EcommerceLiveRoutes.orders),
              ),
              _appBarAction(
                icon: Icons.shopping_cart_outlined,
                label: "Cart",
                badge: cartCtrl.cartCount,
                flyKey: _cartFlyKey,
                onTap: () => nav.goTo(EcommerceLiveRoutes.cart),
              ),
            ],
          );
        }),
        Obx(() {
          if (!authCtrl.isAdmin.value) return const SizedBox.shrink();

          return _appBarAction(
            icon: Icons.admin_panel_settings_outlined,
            label: "Admin",
            onTap: () => Get.to(() => EcommerceAdminDashboardPage()),
          );
        }),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Icon with a small text label underneath so users instantly know
  /// what each button does.
  Widget _appBarAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
    GlobalKey<CartFlyTargetState>? flyKey,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              flyKey == null
                  ? _iconWithBadge(icon, badge)
                  : CartFlyTarget(
                      key: flyKey,
                      child: _iconWithBadge(icon, badge),
                    ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconWithBadge(IconData icon, int badge) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 24, color: p.text),
        if (badge > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.surface, width: 1.5),
              ),
              child: Text(
                badge > 99 ? "99+" : badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Plays the Temu-style "jump into the cart" animation for [product].
  void _flyToCart(BuildContext from, ProductModel product) {
    Uint8List? bytes;
    if (product.images.isNotEmpty) {
      try {
        bytes = base64Decode(product.images.first);
      } catch (_) {}
    }

    FlyToCart.launch(
      from: from,
      to: _cartFlyKey,
      trailColor: Colors.red,
      flyer: FlyToCart.thumbnail(
        bytes: bytes,
        background: p.imageBg,
        ring: p.surface,
        iconColor: p.text,
      ),
    );
  }

  // ───────────────────────── SEARCH + CATEGORIES (merged, static) ─────────────────────────

  Widget _searchAndCategories() {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: p.shadowSoft,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              height: 46,
              child: TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  storeCtrl.searchText.value = value;
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 250),
                    () => storeCtrl.filterProducts(),
                  );
                },
                style: TextStyle(fontSize: 14, color: p.text),
                cursorColor: p.accent,
                decoration: InputDecoration(
                  hintText: "Search by name, category or price",
                  hintStyle: TextStyle(color: p.hint, fontSize: 13.5),
                  prefixIcon: Icon(Icons.search, color: p.muted, size: 22),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchCtrl,
                    builder: (_, value, __) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: Icon(Icons.close, size: 18, color: p.muted),
                            onPressed: () {
                              _searchDebounce?.cancel();
                              _searchCtrl.clear();
                              storeCtrl.searchText.value = '';
                              storeCtrl.filterProducts();
                            },
                          ),
                  ),
                  filled: true,
                  fillColor: p.tile,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: p.accent, width: 1.2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Categories (horizontal chips, Temu-style)
          SizedBox(
            height: 34,
            child: Obx(() {
              final cats = storeCtrl.categories;
              final selected = storeCtrl.selectedCategory.value;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(right: 16),
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final category = cats[i];
                  final isSelected = category == selected;

                  return GestureDetector(
                    onTap: () {
                      storeCtrl.selectedCategory.value = category;
                      storeCtrl.filterProducts();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? p.accent : p.tile,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? p.onAccent : p.textSoft,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── FLOATING BOTTOM BAR ─────────────────────────

  Widget _floatingBottomBar() {
    final mq = MediaQuery.of(context);
    if (mq.viewInsets.bottom > 0) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 16 + mq.padding.bottom,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: p.bar,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: p.barBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _barItem(Icons.policy_outlined, "Policies", _showPolicies),
                  _barItem(Icons.info_outline_rounded, "About Us", _showAbout),
                  _barItem(
                    Icons.support_agent_rounded,
                    "Support",
                    _showSupport,
                  ),
                  _barItem(
                    Icons.person_outline_rounded,
                    "Profile",
                    _openProfile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _barItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: Colors.white),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProfile() {
    final uid = authCtrl.currentUser?.uid;
    if (uid == null) {
      Get.snackbar(
        'Login Required',
        'Please login first',
        backgroundColor: p.snackBg,
        colorText: p.snackText,
      );
      return;
    }
    Get.to(() => const ProfileScreen());
  }

  void _showSheet({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.handle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(icon, color: p.text),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: p.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...children,
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _sheetText(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: TextStyle(fontSize: 13, height: 1.55, color: p.textSoft),
    ),
  );

  // ───────────────────────── POLICIES ─────────────────────────

  /// ╔══════════════════════════════════════════════════════════════════╗
  /// ║  >>> PUT YOUR 8 GOOGLE DOCS LINKS HERE <<<                       ║
  /// ║                                                                  ║
  /// ║  Publish each policy from Google Docs (File > Share > Publish    ║
  /// ║  to web), copy the link, and paste it in the matching `url:`     ║
  /// ║  below. Each entry is marked  "LINK n of 8".                     ║
  /// ║  Leave a url as '' and the app shows "coming soon" for it.       ║
  /// ╚══════════════════════════════════════════════════════════════════╝
  static const List<_PolicyItem> _policies = [
    // ── Legal & Privacy ──
    _PolicyItem(
      group: 'Legal & Privacy',
      title: 'Privacy Policy',
      subtitle: 'How we collect, use and protect your data',
      icon: Icons.privacy_tip_outlined,
      // LINK 1 of 8: Privacy Policy (already filled in)
      url: 'https://docs.google.com/document/d/e/2PACX-1vRPzsVCM0QAn4V6Uoms60yldLi-4x5CYxYmas59oQ7rGiEbUdxwL_WOx_lBfB_oXOqZYvmQ7djbZhLp/pub',
    ),
    _PolicyItem(
      group: 'Legal & Privacy',
      title: 'Terms & Conditions',
      subtitle: 'The terms of using HyEnd and buying from us',
      icon: Icons.gavel_rounded,
      // LINK 2 of 8: Terms and Conditions of Sale
      url: 'https://docs.google.com/document/d/e/2PACX-1vTTKkwoDO9R-eGHC-7AaR-vxLS06g7K8YVwaisEc1zXV1qw-zSRUlg_52w7UYzLFfcL8IX324gplZzN/pub',
    ),
    _PolicyItem(
      group: 'Legal & Privacy',
      title: 'Account Deletion & Data',
      subtitle: 'Delete your account or request your data',
      icon: Icons.manage_accounts_outlined,
      // LINK 3 of 8: Account Deletion and Data Request Policy
      url: 'https://docs.google.com/document/d/e/2PACX-1vSXzrG-4RsO2zcSdAAyVQSOWePMvTuFCkpYc-Rxn_m5b1MQ_tO4mwO8JbXY5Ylr9C5r25F0tQRzvstZ/pub',
    ),

    // ── Orders & Delivery ──
    _PolicyItem(
      group: 'Orders & Delivery',
      title: 'Order, Payment & Cancellation',
      subtitle: 'How orders are confirmed, paid and tracked',
      icon: Icons.receipt_long_outlined,
      // LINK 4 of 8: Order, Payment and Cancellation Policy
      url: 'https://docs.google.com/document/d/e/2PACX-1vTntf8x8z3szmavlKUdfpRZBc0dIxKBFjPuNZseYS0JZOrrRFizNQLQQz_FU-NeqxWRg3GZHe9QrmmJ/pub',
    ),
    _PolicyItem(
      group: 'Orders & Delivery',
      title: 'Shipping, Clearing & Service Fee',
      subtitle: 'What the Service Fee covers and delivery times',
      icon: Icons.local_shipping_outlined,
      // LINK 5 of 8: Shipping, Clearing and Service Fee Policy
      url: 'https://docs.google.com/document/d/e/2PACX-1vSKDrPEsEiiUzLKZbHF16ufY4d-QInZ6IuCv2i_uwQHPFZvMGBf1cFGJd252QT_WH-7xUU9ztg_IkO7/pub',
    ),
    _PolicyItem(
      group: 'Orders & Delivery',
      title: 'Return & Refund',
      subtitle: 'Damaged, defective or missing goods',
      icon: Icons.assignment_return_outlined,
      // LINK 6 of 8: Return and Refund Policy
      url: 'https://docs.google.com/document/d/e/2PACX-1vQZPcQIfs19cWRQs4K_36pFodvHvH1yd6cL4dIfTC1Xm6B-wJIgfnoDTxOugEKiPLBCiysb_9Gyog_q/pub',
    ),

    // ── Trust & Support ──
    _PolicyItem(
      group: 'Trust & Support',
      title: 'Restricted Goods & Compliance',
      subtitle: 'What we do not sell, and how we stay compliant',
      icon: Icons.verified_user_outlined,
      // LINK 7 of 8: Restricted Goods and Compliance Policy
      url: 'https://docs.google.com/document/d/e/2PACX-1vTux0vaOSH1FqngsutZ8OgT1xVbvuSmQJomjfREiK6c5ePw79Z02SSrL7HRpzFSgYkj5cN8Ktl5P_r0/pub',
    ),
    _PolicyItem(
      group: 'Trust & Support',
      title: 'Complaints & Disputes',
      subtitle: 'How to raise a complaint and get it resolved',
      icon: Icons.forum_outlined,
      // LINK 8 of 8: Complaints and Dispute Resolution Policy
      url: 'https://docs.google.com/document/d/e/2PACX-1vR4c1m-ogTdagiinZAtlgGm-b-_8k3-9Bh_i65HQtboQij6M8vFMbT7hj5T9SshQRLvBA0Dl53yx1Z2/pub',
    ),
  ];

  /// Opens the premium "Policies" pop-up: blurred background, soft
  /// scale-and-fade entrance, and the list of all policies.
  void _showPolicies() {
    HapticFeedback.selectionClick();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close policies',
      barrierColor: Colors.black.withOpacity(0.28),
      transitionDuration: const Duration(milliseconds: 340),
      pageBuilder: (ctx, _, __) => _policiesDialog(ctx),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        // Background blur grows in with the animation.
        return AnimatedBuilder(
          animation: curved,
          builder: (_, __) => BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 14 * curved.value,
              sigmaY: 14 * curved.value,
            ),
            child: FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _policiesDialog(BuildContext ctx) {
    final mq = MediaQuery.of(ctx);

    // List rows, with a small section label whenever the group changes.
    final rows = <Widget>[];
    String? lastGroup;
    for (final item in _policies) {
      if (item.group != lastGroup) {
        lastGroup = item.group;
        rows.add(
          Padding(
            padding: EdgeInsets.fromLTRB(22, rows.isEmpty ? 16 : 20, 22, 8),
            child: Text(
              item.group.toUpperCase(),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: p.hint,
              ),
            ),
          ),
        );
      }
      rows.add(_policyRow(ctx, item));
    }

    return SafeArea(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 460,
              maxHeight: mq.size.height * 0.84,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: p.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.38),
                      blurRadius: 44,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── header ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 14, 16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: p.accent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.policy_outlined,
                              size: 22,
                              color: p.onAccent,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Policies',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    color: p.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'HyEnd · Wholesale Beyond Borders',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: p.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: p.muted,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: p.tile,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: p.border),

                    // ── policy list ──
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 8),
                        physics: const BouncingScrollPhysics(),
                        children: rows,
                      ),
                    ),

                    // ── footer ──
                    Divider(height: 1, color: p.border),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 13,
                            color: p.hint,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Policies open in your browser · Powered by AFIA SPLENDID LTD',
                              style: TextStyle(
                                fontSize: 8,
                                color: p.hint,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _policyRow(BuildContext ctx, _PolicyItem item) {
    return InkWell(
      onTap: () => _openPolicy(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: p.tile,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 19, color: p.text),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.3,
                      color: p.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.north_east_rounded, size: 17, color: p.faint),
          ],
        ),
      ),
    );
  }

  /// Opens one policy link in the browser.
  Future<void> _openPolicy(_PolicyItem item) async {
    HapticFeedback.selectionClick();

    final link = item.url.trim();

    if (link.isEmpty) {
      Get.snackbar(
        item.title,
        'This policy will be available soon.',
        backgroundColor: p.snackBg,
        colorText: p.snackText,
      );
      return;
    }

    var opened = false;

    try {
      opened = await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      Get.snackbar(
        item.title,
        'Could not open the link. Please try again.',
        backgroundColor: p.snackBg,
        colorText: p.snackText,
      );
    }
  }

  void _showAbout() => _showSheet(
    title: "About Us",
    icon: Icons.info_outline_rounded,
    children: [
      _sheetText(
        "HyEnd — Wholesale Beyond Borders. We connect you directly to manufacturers, "
        "helping you access quality products at competitive wholesale prices. ",
      ),
      _sheetText(
        "When you buy in bulk, each item costs less. That is why order totals "
        "on HyEnd can look high: you are buying many units at wholesale prices.",
      ),

      const SizedBox(height: 6),
      Text(
        "HOW IT WORKS",
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: p.hint,
        ),
      ),
      const SizedBox(height: 12),

      for (final step in const [
        [
          "1",
          "Pick your products",
          "Add what you need to your cart, in the quantities you want.",
        ],
        [
          "2",
          "Place your order",
          "Enter your delivery details and send your order to us on WhatsApp.",
        ],
        [
          "3",
          "We confirm",
          "We check stock and tell you the full cost, including the Service Fee.",
        ],
        [
          "4",
          "Pay and track",
          "Pay the full amount to our official company account. Your order is "
              "then activated and you can follow it on the Orders page.",
        ],
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  step[0],
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: p.onAccent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step[1],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step[2],
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.45,
                        color: p.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 4, bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.tile,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.public_rounded, size: 17, color: p.text),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "What is the Service Fee? It covers shipping, customs clearing "
                "and other handling costs, so your goods travel safely from "
                "the supplier to you.",
                style: TextStyle(fontSize: 10, height: 1.45, color: p.muted),
              ),
            ),
          ],
        ),
      ),

      Text(
        "Powered by AFIA SPLENDID LTD",
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 12,
          color: p.muted,
        ),
      ),
    ],
  );

  // ───────────────────────── SUPPORT ─────────────────────────

  /// Support sheet: WhatsApp, phone call and email, one tap each.
  void _showSupport() => _showSheet(
    title: "Support",
    icon: Icons.support_agent_rounded,
    children: [
      _sheetText(
        "Need help with an order or your account? Reach out and we'll get back to you.",
      ),

      // Official company badge
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: p.tile,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.border),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_rounded, size: 16, color: p.text),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$_supportCompany · Official support',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: p.text,
                ),
              ),
            ),
          ],
        ),
      ),

      // WhatsApp (primary)
      _supportTile(
        icon: Icons.chat_rounded,
        iconBg: const Color(0xFF25D366),
        iconColor: Colors.white,
        title: 'Chat on WhatsApp',
        subtitle: _supportPhoneDisplay,
        highlight: true,
        onTap: _openWhatsAppSupport,
      ),

      // Phone call
      _supportTile(
        icon: Icons.call_rounded,
        iconBg: p.accent,
        iconColor: p.onAccent,
        title: 'Call us',
        subtitle: _supportPhoneDisplay,
        onTap: _callSupport,
      ),

      // Email
      _supportTile(
        icon: Icons.email_outlined,
        iconBg: p.tile,
        iconColor: p.text,
        title: 'Send an email',
        subtitle: _supportEmail,
        onTap: _emailSupport,
      ),

      const SizedBox(height: 4),
      Row(
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: p.hint),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Calls and visits: 24 hours, Monday to Saturday. '
              'Orders are accepted any day, any time.',
              style: TextStyle(fontSize: 9, height: 1.35, color: p.hint),
            ),
          ),
        ],
      ),
    ],
  );

  /// One premium contact row: icon badge, title, detail and an arrow.
  Widget _supportTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    const green = Color(0xFF25D366);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlight ? green.withOpacity(0.10) : p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: highlight ? green.withOpacity(0.45) : p.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 21, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: p.muted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.north_east_rounded, size: 17, color: p.faint),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openWhatsAppSupport() => _launchSupport(
    Uri.parse(
      'https://wa.me/$_supportWhatsApp?text=${Uri.encodeComponent("Hello HyEnd, I need help with ")}',
    ),
    'WhatsApp',
  );

  Future<void> _callSupport() =>
      _launchSupport(Uri(scheme: 'tel', path: _supportPhoneDial), 'Phone');

  Future<void> _emailSupport() =>
      _launchSupport(Uri(scheme: 'mailto', path: _supportEmail), 'Email');

  Future<void> _launchSupport(Uri uri, String label) async {
    var opened = false;

    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      Get.snackbar(
        label,
        'Could not open $label. Please try again.',
        backgroundColor: p.snackBg,
        colorText: p.snackText,
      );
    }
  }

  // ───────────────────────── POWERED BY ─────────────────────────

  Widget _poweredBy() {
    return Padding(
      // extra bottom space so the floating bar never covers it
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
      child: Center(
        child: Text(
          "Powered by AFIA SPLENDID LTD",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 11.5,
            color: p.hint,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: p.faint),
          const SizedBox(height: 12),
          Text(
            "No products found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Try a different search or category",
            style: TextStyle(color: p.muted),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── PRODUCT CARD ─────────────────────────

  String _formatPrice(num price) {
    final fixed = price.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return "₦$whole.${parts[1]}";
  }

  // ───────────────────────── BLACK FRIDAY ─────────────────────────

  double _maxDiscount(Iterable<ProductModel> products) => products.fold(
    0.0,
    (max, p) => p.blackFridayPercent > max ? p.blackFridayPercent : max,
  );

  String _pct(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  Widget _bfBadge(ProductModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _bfGold,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-${_pct(product.blackFridayPercent)}%',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _blackFridayBanner(double maxOff) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2005), Color(0xFF0B0B0C)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _bfGold.withOpacity(0.65)),
          boxShadow: [
            BoxShadow(
              color: _bfGold.withOpacity(0.22),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _bfGold,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.black,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BLACK FRIDAY IS LIVE',
                    style: TextStyle(
                      color: _bfGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Prices shown are already reduced',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _bfGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'UP TO ${_pct(maxOff)}% OFF',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: p.isDark ? Border.all(color: p.border) : null,
        boxShadow: [
          BoxShadow(
            color: p.shadowCard,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final uid = authCtrl.currentUser?.uid;

            if (uid == null) {
              Get.snackbar(
                'Login Required',
                'Please login first',
                //snackPosition: SnackPosition.BOTTOM,
                backgroundColor: p.snackBg,
                colorText: p.snackText,
              );
              return;
            }

            storeCtrl.selectProduct(product);
            // The product also travels WITH the route, so the details page
            // never depends on which controller instance holds the selection.
            nav.goTo(EcommerceLiveRoutes.productDetails, arguments: product);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE — BoxFit.contain so the whole product is always visible
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: p.imageBg,
                          child: product.images.isEmpty
                              ? Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: p.faint,
                                  ),
                                )
                              : _ProductImage(
                                  productId: product.id.toString(),
                                  base64: product.images.first,
                                  faint: p.faint,
                                ),
                        ),

                        if (product.isOnBlackFriday)
                          Positioned(top: 6, left: 6, child: _bfBadge(product)),
                      ],
                    ),
                  ),
                ),
              ),

              // DETAILS — smaller text, name + price share one column
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: p.text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatPrice(product.price),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: product.isOnBlackFriday
                                        ? _bfRed
                                        : p.text,
                                  ),
                                ),
                                if (product.isOnBlackFriday) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatPrice(product.regularPrice),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: p.muted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Add ${cartCtrl.minOrderFor(product)} to cart',
                      child: Material(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(11),
                        child: Builder(
                          builder: (btnCtx) => InkWell(
                            borderRadius: BorderRadius.circular(11),
                            onTap: () => cartCtrl.addToCart(
                              product,
                              onAdded: () => _flyToCart(btnCtx, product),
                            ),
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 16,
                                color: p.onAccent,
                              ),
                            ),
                          ),
                        ),
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
// POLICY LINK ITEM
//==================================================

/// One row in the Policies pop-up. Edit the `url` of each item inside
/// `_policies` (in _EcommerceHomePageState) to point to its Google Doc.
class _PolicyItem {
  const _PolicyItem({
    required this.group,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.url,
  });

  final String group;
  final String title;
  final String subtitle;
  final IconData icon;
  final String url;
}

//==================================================
// PALETTE  (matches the profile page palette)
//==================================================

class _HP {
  const _HP(this.isDark);

  final bool isDark;

  Color get bg => isDark ? const Color(0xFF0E0E10) : const Color(0xFFF7F7F8);
  Color get surface => isDark ? const Color(0xFF1A1A1D) : Colors.white;
  Color get border =>
      isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE9E9EC);
  Color get tile => isDark ? const Color(0xFF26262A) : const Color(0xFFF3F3F5);
  Color get imageBg =>
      isDark ? const Color(0xFF26262A) : const Color(0xFFF4F4F6);
  Color get text => isDark ? Colors.white : const Color(0xFF111111);
  Color get textSoft => isDark ? const Color(0xFFD4D4DA) : Colors.black87;
  Color get muted => isDark ? const Color(0xFF9A9AA2) : Colors.black54;
  Color get hint => isDark ? const Color(0xFF6E6E76) : Colors.black45;
  Color get faint => isDark ? const Color(0xFF4A4A52) : Colors.black26;
  Color get handle => isDark ? const Color(0xFF3A3A40) : Colors.black12;

  // buttons, selected chips, add-to-cart
  Color get accent => isDark ? Colors.white : const Color(0xFF111111);
  Color get onAccent => isDark ? const Color(0xFF0B0B0C) : Colors.white;

  // floating bottom bar
  Color get bar => isDark ? const Color(0xFF232327) : const Color(0xFF111111);
  Color get barBorder => isDark ? const Color(0xFF3A3A40) : Colors.white12;

  // like button bubble on product images
  Color get likeBg =>
      isDark ? const Color(0xEB2A2A2E) : Colors.white.withOpacity(0.92);

  // snackbars
  Color get snackBg => isDark ? const Color(0xFF2A2A2E) : Colors.black;
  Color get snackText => Colors.white;

  Color get shadowSoft =>
      isDark ? const Color(0x66000000) : const Color(0x0D000000);
  Color get shadowCard =>
      isDark ? const Color(0x66000000) : const Color(0x12000000);
}

//==================================================
// LIGHTWEIGHT PRODUCT IMAGE
//==================================================

/// Small LRU cache of decoded base64 bytes. Without this, base64Decode ran on
/// every rebuild AND handed Image.memory a brand-new byte list each time, so
/// Flutter re-decoded the picture constantly (main cause of lag + memory).
class _ImageBytesCache {
  static const int _max = 40;
  static final LinkedHashMap<String, Uint8List> _map =
      LinkedHashMap<String, Uint8List>();

  static Uint8List? get(String key, String b64) {
    final hit = _map.remove(key);
    if (hit != null) {
      _map[key] = hit; // mark as most recently used
      return hit;
    }
    try {
      final bytes = base64Decode(b64);
      _map[key] = bytes;
      if (_map.length > _max) _map.remove(_map.keys.first);
      return bytes;
    } catch (_) {
      return null;
    }
  }
}

class _ProductImage extends StatefulWidget {
  const _ProductImage({
    required this.productId,
    required this.base64,
    required this.faint,
  });

  final String productId;
  final String base64;
  final Color faint;

  @override
  State<_ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<_ProductImage> {
  Uint8List? _bytes;

  String get _key =>
      '${widget.productId}:${widget.base64.length}:${widget.base64.hashCode}';

  @override
  void initState() {
    super.initState();
    _bytes = _ImageBytesCache.get(_key, widget.base64);
  }

  @override
  void didUpdateWidget(covariant _ProductImage old) {
    super.didUpdateWidget(old);
    if (old.productId != widget.productId || old.base64 != widget.base64) {
      _bytes = _ImageBytesCache.get(_key, widget.base64);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null) {
      return Center(
        child: Icon(Icons.broken_image_outlined, color: widget.faint),
      );
    }

    return Image.memory(
      bytes,
      fit: BoxFit.contain,
      // Decode at card size instead of full resolution → far less RAM.
      cacheWidth: 400,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSync) {
        if (wasSync) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (_, __, ___) =>
          Center(child: Icon(Icons.broken_image_outlined, color: widget.faint)),
    );
  }
}
