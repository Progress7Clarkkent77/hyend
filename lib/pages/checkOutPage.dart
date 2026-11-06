import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/ecommerceCartController.dart';
import 'package:hyend/controllers/orderController.dart';
import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/models/productModel.dart';
import 'package:hyend/pages/ecommerce_routes.dart';
import 'package:hyend/pages/storeUi.dart';
import 'package:hyend/userAuth/authController.dart';

import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// HyEnd's WhatsApp number (09030323601) in international format.
  static const String _whatsappNumber = '2349030323601';

  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  final AuthController authCtrl = Get.find();
  final EcommerceCartController cartCtrl = Get.find();
  final OrderController orderCtrl = Get.find();

  // ThemeController is created at login; fall back safely on cold start.
  final ThemeController themeCtrl = Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : Get.put(ThemeController());

  /// "Save these details for next time" toggle.
  final RxBool remember = true.obs;

  final RxBool loadingSaved = true.obs;
  final RxBool hasSaved = false.obs;

  /// Drives the page scroll and the "scroll for more" cue.
  final ScrollController _scroll = ScrollController();
  late final AnimationController _hintPulse;
  final RxBool showScrollHint = false.obs;

  @override
  void initState() {
    super.initState();
    _hintPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _scroll.addListener(_updateScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());

    _loadSaved();
  }

  @override
  void dispose() {
    _scroll.removeListener(_updateScrollHint);
    _scroll.dispose();
    _hintPulse.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  //==================================================
  // SCROLL CUE
  //==================================================

  /// Shown only while there is more content below the fold.
  void _updateScrollHint() {
    if (!mounted || !_scroll.hasClients) return;

    final pos = _scroll.position;
    final hasMore =
        pos.maxScrollExtent > 48 && pos.pixels < pos.maxScrollExtent - 72;

    if (showScrollHint.value != hasMore) showScrollHint.value = hasMore;
  }

  Future<void> _scrollDown() async {
    if (!_scroll.hasClients) return;

    HapticFeedback.selectionClick();

    final pos = _scroll.position;
    final target = (pos.pixels + pos.viewportDimension * 0.85).clamp(
      0.0,
      pos.maxScrollExtent,
    );

    await _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  //==================================================
  // SAVED DETAILS
  //==================================================

  Future<void> _loadSaved() async {
    final saved = await orderCtrl.loadSavedShipping();

    if (!mounted) return;

    if (saved != null) {
      // Never overwrite something the user has already started typing.
      if (phoneCtrl.text.trim().isEmpty) phoneCtrl.text = saved['phone'] ?? '';
      if (addressCtrl.text.trim().isEmpty) {
        addressCtrl.text = saved['address'] ?? '';
      }
      hasSaved.value = true;
    }

    loadingSaved.value = false;
  }

  Future<void> _clearSaved() async {
    await orderCtrl.clearSavedShipping();

    phoneCtrl.clear();
    addressCtrl.clear();
    hasSaved.value = false;

    Get.snackbar(
      'Removed',
      'Your saved delivery details were deleted.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(14),
    );
  }

  //==================================================
  // VALIDATION & SUBMIT
  //==================================================

  String? _validatePhone(String? value) {
    final raw = (value ?? '').replaceAll(RegExp(r'[\s\-()]'), '');

    if (raw.isEmpty) return 'Enter your phone number';

    // 0803..., +234803..., 234803...
    if (!RegExp(r'^(\+?234|0)[789][01]\d{8}$').hasMatch(raw)) {
      return 'Enter a valid Nigerian phone number';
    }

    return null;
  }

  String? _validateAddress(String? value) {
    if ((value ?? '').trim().length < 10) {
      return 'Enter a complete delivery address';
    }

    return null;
  }

  //==================================================
  // PLACE ORDER (WHATSAPP)
  //==================================================

  String _buildWhatsAppMessage(String orderId) {
    final items = cartCtrl.cartItems.toList();
    final email = authCtrl.currentUser?.email ?? '';

    final b = StringBuffer()
      ..writeln(
        'Hello HyEnd (AFIA SPLENDID LTD), I would like to place an order.',
      )
      ..writeln()
      ..writeln('*Order ID: #${shortOrderId(orderId)}*')
      ..writeln()
      ..writeln('*Items:*');

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      b
        ..writeln(
          '${i + 1}. ${item.product.name}'
          '${item.hasColor ? ' (${item.colorName})' : ''}',
        )
        ..writeln(
          '   ${item.quantity} x ${formatNaira(item.product.price)} '
          '= ${formatNaira(item.total)}',
        );
    }

    final fee = cartCtrl.deliveryFee;

    b
      ..writeln()
      ..writeln('Subtotal: ${formatNaira(cartCtrl.subtotal)}')
      ..writeln(
        'Service fee (${cartCtrl.deliveryZone.value.label}): '
        '${fee > 0 ? formatNaira(fee) : 'Free'}',
      )
      ..writeln('*Total: ${formatNaira(cartCtrl.grandTotal)}*')
      ..writeln()
      ..writeln('*Delivery address:*')
      ..writeln(addressCtrl.text.trim())
      ..writeln()
      ..writeln('Phone: ${phoneCtrl.text.trim()}')
      ..writeln('Account email: $email')
      ..writeln()
      ..write('Please confirm availability and delivery. Thank you!');

    return b.toString();
  }

  Future<void> _placeOrder() async {
    if (orderCtrl.isPlacingOrder.value) return;

    if (cartCtrl.cartItems.isEmpty) {
      Get.snackbar('Cart empty', 'Add items to your cart first');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    // Build the message BEFORE the cart is cleared.
    // The order id is only known after saving, so save first, then build.
    final orderId = await orderCtrl.createWhatsAppOrder(
      phone: phoneCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      rememberShipping: remember.value,
    );

    if (orderId == null) return;

    final message = _buildWhatsAppMessage(orderId);

    // The order is saved, so the cart can be emptied.
    unawaited(cartCtrl.clearCart());

    await _showOrderSentDialog(orderId: orderId, message: message);
  }

  Future<void> _openWhatsApp(String message) async {
    final uri = Uri.parse(
      'https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}',
    );

    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      // Fallback: copy the order so it can be pasted into any chat.
      await Clipboard.setData(ClipboardData(text: message));
      Get.snackbar(
        'Could not open WhatsApp',
        'Your order details were copied. Send them to 09030323601.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
      );
    }
  }

  /// Premium "order placed" notice. The WhatsApp button is a fresh tap, so
  /// browsers never block it as a popup.
  Future<void> _showOrderSentDialog({
    required String orderId,
    required String message,
  }) async {
    final p = StorePalette(themeCtrl.isDarkMode.value);
    final email = authCtrl.currentUser?.email ?? 'your email';
    const whatsappGreen = Color(0xFF25D366);

    Widget step(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: p.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: p.muted, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );

    await Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: p.surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.6, end: 1),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    builder: (_, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: StorePalette.success.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 44,
                        color: StorePalette.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Order placed with HyEnd',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Powered by AFIA SPLENDID LTD',
                    style: TextStyle(
                      color: p.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: p.tile,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: p.border),
                    ),
                    child: Text(
                      'Order #${shortOrderId(orderId)}',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  step(
                    Icons.chat_rounded,
                    'Tap the button below to send your order straight to HyEnd on WhatsApp.',
                  ),
                  step(
                    Icons.handshake_outlined,
                    'We will confirm availability and agree the details with you there.',
                  ),
                  step(
                    Icons.local_shipping_outlined,
                    'Once agreed, your order appears in My Orders under $email so you can track it.',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openWhatsApp(message),
                      icon: const Icon(Icons.chat_rounded, size: 20),
                      label: const Text('Send order on WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: whatsappGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                            Get.offAllNamed(EcommerceLiveRoutes.home);
                          },
                          child: Text(
                            'Continue shopping',
                            style: TextStyle(
                              color: p.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                            Get.offNamed(EcommerceLiveRoutes.orders);
                          },
                          child: Text(
                            'My orders',
                            style: TextStyle(
                              color: p.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  //==================================================
  // BUILD
  //==================================================

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Obx(() {
      final p = StorePalette(themeCtrl.isDarkMode.value);
      final isEmpty = cartCtrl.cartItems.isEmpty;
      final placing = orderCtrl.isPlacingOrder.value;

      // While an order is processing the user cannot leave the page.
      return PopScope(
        canPop: !placing,
        child: Stack(
          children: [
            _scaffold(p, isEmpty, isDesktop),
            if (placing) _processingOverlay(p),
          ],
        ),
      );
    });
  }

  Widget _processingOverlay(StorePalette p) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: const Color(0x66000000),
            alignment: Alignment.center,
            child: Material(
              color: p.surface,
              elevation: 8,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => Text(
                        orderCtrl.processingMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Please do not close this page',
                      style: TextStyle(color: p.muted, fontSize: 12),
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

  Widget _scaffold(StorePalette p, bool isEmpty, bool isDesktop) {
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
              'Checkout',
              style: TextStyle(
                color: p.text,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Place your order with HyEnd on WhatsApp',
              style: TextStyle(color: p.muted, fontSize: 10),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (isEmpty || isDesktop) ? null : _bottomBar(p),
      body: isEmpty
          ? _emptyState(p)
          : Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: NotificationListener<ScrollMetricsNotification>(
                      onNotification: (_) {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _updateScrollHint(),
                        );
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _scroll,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 6, child: _deliveryCard(p)),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      children: [
                                        _summaryCard(p, withButton: true),
                                        const SizedBox(height: 18),
                                        _whatsappCard(p),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _deliveryCard(p),
                                  const SizedBox(height: 18),
                                  _summaryCard(p, withButton: false),
                                  const SizedBox(height: 18),
                                  _whatsappCard(p),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                _scrollHint(p),
              ],
            ),
    );
  }

  //==================================================
  // SCROLL HINT OVERLAY
  //==================================================

  /// A soft fade plus a gently bobbing pill that tells the user there is
  /// more below. Tap it, or simply swipe up, to continue.
  Widget _scrollHint(StorePalette p) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Obx(() {
        final visible = showScrollHint.value;

        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.only(top: 46, bottom: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.bg.withOpacity(0), p.bg.withOpacity(0.96)],
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: _hintPulse,
                builder: (_, child) {
                  final t = Curves.easeInOut.transform(_hintPulse.value);
                  return Transform.translate(
                    offset: Offset(0, -4 + (t * 8)),
                    child: child,
                  );
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _scrollDown,
                  onVerticalDragUpdate: (d) {
                    // Dragging up on the cue scrolls the page along with it.
                    if (d.delta.dy < 0 && _scroll.hasClients) {
                      _scroll.jumpTo(
                        (_scroll.offset - d.delta.dy).clamp(
                          0.0,
                          _scroll.position.maxScrollExtent,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 9, 12, 9),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: p.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 22,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Scroll to see everything',
                          style: TextStyle(
                            color: p.text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: p.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_double_arrow_down_rounded,
                            size: 15,
                            color: p.onAccent,
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
      }),
    );
  }

  //==================================================
  // EMPTY
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
              'Nothing to check out',
              style: TextStyle(
                color: p.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your cart is empty.',
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
              child: const Text('Back to store'),
            ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // DELIVERY FORM
  //==================================================

  String _feeText(double fee) => fee > 0 ? formatNaira(fee) : 'Free';

  Widget _deliveryCard(StorePalette p) {
    final email = authCtrl.currentUser?.email ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: p.border),
        boxShadow: p.shadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 21,
                    color: p.onAccent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Delivery details',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (loadingSaved.value) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: p.text,
                  backgroundColor: p.tile,
                ),
              ),
            ],
            if (hasSaved.value) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                decoration: BoxDecoration(
                  color: StorePalette.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: StorePalette.success,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'We filled in your saved details.',
                        style: TextStyle(
                          color: StorePalette.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearSaved,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: StorePalette.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            _label('Email', p),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: p.tile,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.mail_outline_rounded, size: 20, color: p.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.lock_outline_rounded, size: 16, color: p.muted),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _label('Phone number', p),
            const SizedBox(height: 8),
            TextFormField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]')),
              ],
              validator: _validatePhone,
              style: TextStyle(color: p.text, fontWeight: FontWeight.w600),
              decoration: _decoration(
                p,
                hint: '0803 123 4567',
                icon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 20),
            _label('Delivery address', p),
            const SizedBox(height: 8),
            TextFormField(
              controller: addressCtrl,
              minLines: 3,
              maxLines: 4,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.newline,
              autofillHints: const [AutofillHints.fullStreetAddress],
              validator: _validateAddress,
              style: TextStyle(color: p.text, fontWeight: FontWeight.w600),
              decoration: _decoration(
                p,
                hint: 'House number, street, area, city and state',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => remember.value = !remember.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Switch.adaptive(
                      value: remember.value,
                      activeColor: p.accent,
                      onChanged: (v) => remember.value = v,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save for next time',
                            style: TextStyle(
                              color: p.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Skip typing these details on your next order.',
                            style: TextStyle(color: p.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, StorePalette p) {
    return Text(
      text,
      style: TextStyle(
        color: p.text,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _decoration(
    StorePalette p, {
    required String hint,
    required IconData icon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: p.muted, fontWeight: FontWeight.w400),
      prefixIcon: Icon(icon, size: 20, color: p.muted),
      filled: true,
      fillColor: p.tile,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(p.text, 1.5),
      errorBorder: border(StorePalette.danger),
      focusedErrorBorder: border(StorePalette.danger, 1.5),
      errorStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  //==================================================
  // SUMMARY
  //==================================================

  Widget _summaryCard(StorePalette p, {required bool withButton}) {
    final items = cartCtrl.cartItems.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: p.border),
        boxShadow: p.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order summary',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(EcommerceLiveRoutes.cart),
                child: Text(
                  'Edit cart',
                  style: TextStyle(
                    color: p.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items) ...[
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: p.tile,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Base64Image(
                    data: item.image,
                    placeholder: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: p.muted,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.quantity} × ${formatNaira(item.product.price)}'
                        '${item.hasColor ? ' · ${item.colorName}' : ''}',
                        style: TextStyle(color: p.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formatNaira(item.total),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          Divider(height: 24, color: p.border),
          _row(p, 'Subtotal', formatNaira(cartCtrl.subtotal)),
          const SizedBox(height: 12),
          _row(
            p,
            'Service fee (${cartCtrl.deliveryZone.value.shortLabel})',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.public_rounded, size: 16, color: p.text),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Service fee covers shipping, customs clearing and '
                    'other handling charges for your bulk order.',
                    style: TextStyle(
                      color: p.muted,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
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
          if (withButton) ...[const SizedBox(height: 22), _checkoutActions(p)],
        ],
      ),
    );
  }

  //==================================================
  // WHATSAPP ORDER PROCESS CARD
  //==================================================

  /// Its own container: explains how orders are processed and confirmed.
  Widget _whatsappCard(StorePalette p) {
    const green = Color(0xFF25D366);

    Widget stepRow(int n, String title, String subtitle, {bool last = false}) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: green.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$n',
                    style: const TextStyle(
                      color: green,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: p.border,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: p.muted,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: green.withOpacity(0.35)),
        boxShadow: p.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  size: 21,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How your order works',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Wholesale Beyond Borders · confirmed via WhatsApp',
                      style: TextStyle(color: p.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          stepRow(
            1,
            'Place your order',
            'Fill in your delivery details and tap Place order.',
          ),
          stepRow(
            2,
            'Send it on WhatsApp',
            'Your bulk order summary is prepared and sent to HyEnd in one tap.',
          ),
          stepRow(
            3,
            'We confirm with you',
            'We confirm availability and the full cost, agree payment, then arrange shipping and clearing.',
            last: true,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.tile,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: p.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Orders are processed and confirmed via WhatsApp. '
                    'Online payment is not available due to the high value '
                    'of wholesale orders.',
                    style: TextStyle(
                      color: p.muted,
                      fontSize: 11.5,
                      height: 1.4,
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
            fontSize: emphasized ? 18 : 14.5,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
            letterSpacing: emphasized ? -0.5 : 0,
          ),
        ),
      ],
    );
  }

  //==================================================
  // PAY BUTTON / BOTTOM BAR
  //==================================================

  Widget _checkoutActions(StorePalette p) {
    final placing = orderCtrl.isPlacingOrder.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: placing ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: const Size.fromHeight(56),
              backgroundColor: p.accent,
              foregroundColor: p.onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Place order via WhatsApp'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Powered by AFIA SPLENDID LTD',
          style: TextStyle(
            color: p.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
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
      child: SafeArea(top: false, child: _checkoutActions(p)),
    );
  }
}
