import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/ecommerceCartController.dart';
import 'package:hyend/controllers/orderController.dart';

import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/controllers/verified_controller.dart';
import 'package:hyend/pages/avatar_screen.dart';
import 'package:hyend/pages/ecommerce_routes.dart';
import 'package:hyend/userAuth/account_controller.dart';
import 'package:hyend/userAuth/authController.dart';

import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final ThemeController themeCtrl = Get.find();
  final AccountController accountCtrl = Get.find();
  final VerifiedController verifiedCtrl = Get.find();
  final AuthController authCtrl = Get.find();
  final OrderController orderCtrl = Get.find();
  final EcommerceCartController cartCtrl = Get.find();

  final RxString referCode = ''.obs;
  final RxBool referLoading = true.obs;

  static const Color _danger = Color(0xFFE5484D);

  static const String _privacyPolicyUrl =
      'https://docs.google.com/document/d/e/2PACX-1vRP7WWyLc3rxRJH8LoTYw7zCGqanOflXOI0qv_hVID1dYPSgzy9iiD0eKOyNC8PyeiEu9Mi9mmVJ4h5/pub';

  static const String _refundPolicyUrl =
      'https://docs.google.com/document/d/e/2PACX-1vTpFax5hQ4WDMkpi-JlQbiajUhpJqexXYs45rLgjxjPhsSaRMnxJ39tvfcfBT4UX_9212fnz73r3HPV/pub';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadReferCode();
  }

  //==================================================
  // DATA
  //==================================================

  Future<void> _loadReferCode() async {
    final uid = authCtrl.currentUser?.uid;

    if (uid == null) {
      referLoading.value = false;
      return;
    }

    try {
      referCode.value = await authCtrl.ensureReferCode(uid);
    } catch (_) {
      _snack(
        'Error',
        'Could not load your referral code. Pull to refresh and try again.',
      );
    } finally {
      referLoading.value = false;
    }
  }

  Future<void> _refresh() async {
    accountCtrl.fetchUserInfo();
    await _loadReferCode();
  }

  //==================================================
  // THEME
  //==================================================

  Future<void> _setTheme(bool dark) async {
    if (themeCtrl.isDarkMode.value == dark) return;

    HapticFeedback.selectionClick();

    // Apply instantly so the UI doesn't wait on the network
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);

    try {
      // Controller updates isDarkMode and saves to Firestore
      if (dark) {
        await themeCtrl.setDark();
      } else {
        await themeCtrl.setLight();
      }
    } catch (_) {
      // Save failed, so roll back to the previous theme
      themeCtrl.isDarkMode.value = !dark;
      Get.changeThemeMode(dark ? ThemeMode.light : ThemeMode.dark);
      _snack('Error', 'Could not save your theme. Please try again.');
    }
  }

  //==================================================
  // FEEDBACK & DIALOGS
  //==================================================

  Future<void> _openLink(String url, String title) async {
    var opened = false;

    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      _snack(title, 'Could not open the link. Please try again.');
    }
  }

  void _snack(String title, String message) {
    final p = _P(themeCtrl.isDarkMode.value);

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

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final p = _P(themeCtrl.isDarkMode.value);

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
        ),
        content: Text(
          message,
          style: TextStyle(color: p.muted, height: 1.5, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: p.muted)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: destructive ? _danger : p.accent,
              foregroundColor: destructive ? Colors.white : p.onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _logout() async {
    final ok = await _confirm(
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log out',
    );

    if (!ok) return;

    final p = _P(themeCtrl.isDarkMode.value);

    Get.dialog(
      AlertDialog(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: p.text),
            ),
            const SizedBox(width: 18),
            Text('Logging out...', style: TextStyle(color: p.text)),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      await authCtrl.logout();
      if (Get.isDialogOpen ?? false) Get.back();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _snack('Logout failed', e.toString());
    }
  }

  Future<void> _deleteAccount() async {
    final ok = await _confirm(
      title: 'Delete account',
      message:
          'This will permanently delete your account and all associated '
          'data. This action cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (!ok) return;

    try {
      await accountCtrl.deleteAccount();
    } catch (_) {
      _snack('Error', 'Could not delete account. Please try again.');
    }
  }

  //==================================================
  // BUILD
  //==================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final p = _P(themeCtrl.isDarkMode.value);
      final isAdmin = authCtrl.isAdmin.value;

      return Scaffold(
        backgroundColor: p.bg,
        appBar: AppBar(
          backgroundColor: p.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: p.text),
          title: Text(
            'Profile',
            style: TextStyle(
              color: p.text,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: p.text,
          onRefresh: _refresh,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                children: [
                  _header(p, isAdmin),
                  const SizedBox(height: 28),
                  _label('Account', p),
                  const SizedBox(height: 12),
                  _group(p, [
                    if (isAdmin)
                      _tile(
                        p,
                        icon: Icons.dashboard_customize_outlined,
                        title: 'Admin dashboard',
                        subtitle: 'Products, orders and store overview',
                        onTap: () => Get.toNamed(EcommerceLiveRoutes.admin),
                      ),
                    _tile(
                      p,
                      icon: Icons.receipt_long_outlined,
                      title: 'My orders',
                      subtitle: 'Track and review your purchases',
                      onTap: () => Get.toNamed(EcommerceLiveRoutes.orders),
                    ),
                    _tile(
                      p,
                      icon: Icons.face_retouching_natural_outlined,
                      title: 'Change avatar',
                      subtitle: 'Pick a look that suits you',
                      onTap: () => Get.to(() => const AvatarSelectionScreen()),
                    ),
                  ]),
                  const SizedBox(height: 28),
                  _label('Appearance', p),
                  const SizedBox(height: 12),
                  _appearanceCard(p),
                  const SizedBox(height: 28),
                  _label('Security', p),
                  const SizedBox(height: 12),
                  _group(p, [
                    _tile(
                      p,
                      icon: Icons.logout_rounded,
                      title: 'Log out',
                      subtitle: 'Sign out of this device',
                      onTap: _logout,
                    ),
                    _tile(
                      p,
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete account',
                      subtitle: 'Permanently remove your account',
                      destructive: true,
                      onTap: _deleteAccount,
                    ),
                  ]),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'HyEnd',
                      style: TextStyle(
                        color: p.muted,
                        fontSize: 12,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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

  Widget _header(_P p, bool isAdmin) {
    final name = accountCtrl.userName.value;
    final email = accountCtrl.userEmail.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: p.headerGradient,
        ),
        border: p.isDark ? Border.all(color: p.border) : null,
        boxShadow: p.isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
      ),
      child: Column(
        children: [
          _avatar(name),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name.isEmpty ? 'Your name' : name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              if (verifiedCtrl.isVerified.value) ...[
                const SizedBox(width: 8),
                Image.asset(
                  'assets/images/verified.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.verified,
                    color: Colors.lightBlueAccent,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            email,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13.5),
          ),
          const SizedBox(height: 20),
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x1FFFFFFF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Store Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _headerStat('Orders', '${orderCtrl.orders.length}'),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: const Color(0x33FFFFFF),
                  ),
                  Expanded(
                    child: _headerStat('In cart', '${cartCtrl.cartCount}'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
        ),
      ],
    );
  }

  Widget _avatar(String name) {
    final avatar = accountCtrl.avatarName.value;
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    Widget fallback() => Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 34,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Hero(
          tag: 'profile_avatar',
          child: Container(
            width: 104,
            height: 104,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0x55FFFFFF)],
              ),
            ),
            child: ClipOval(
              child: Container(
                color: Colors.white,
                child: avatar.isEmpty
                    ? fallback()
                    : Image.asset(
                        'assets/images/$avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => fallback(),
                      ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: -2,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: Color(0xFF0B0B0C), width: 2),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Get.to(() => const AvatarSelectionScreen()),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.edit, size: 15, color: Color(0xFF0B0B0C)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //==================================================
  // SECTIONS
  //==================================================

  Widget _label(String text, _P p) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: p.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _group(_P p, List<Widget> tiles) {
    final children = <Widget>[];

    for (var i = 0; i < tiles.length; i++) {
      children.add(tiles[i]);
      if (i != tiles.length - 1) {
        children.add(Divider(height: 1, indent: 72, color: p.border));
      }
    }

    return Material(
      color: p.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: p.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile(
    _P p, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color = destructive ? _danger : p.text;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: destructive ? const Color(0x1FE5484D) : p.tile,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 21, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.muted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.muted),
          ],
        ),
      ),
    );
  }

  //==================================================
  // APPEARANCE
  //==================================================

  Widget _appearanceCard(_P p) {
    final isDark = p.isDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.border),
        boxShadow: p.shadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: p.tile,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween<double>(begin: 0.75, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    key: ValueKey(isDark),
                    size: 21,
                    color: p.text,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDark ? 'Dark mode is on' : 'Light mode is on',
                      style: TextStyle(color: p.muted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _themeSwitch(p),
        ],
      ),
    );
  }

  Widget _themeSwitch(_P p) {
    final isDark = p.isDark;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.tile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // sliding thumb
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _themeOption(
                p,
                icon: Icons.light_mode_rounded,
                label: 'Light',
                selected: !isDark,
                onTap: () => _setTheme(false),
              ),
              _themeOption(
                p,
                icon: Icons.dark_mode_rounded,
                label: 'Dark',
                selected: isDark,
                onTap: () => _setTheme(true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _themeOption(
    _P p, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected ? p.onAccent : p.muted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: color,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //==================================================
  // REFERRAL
  //==================================================
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

  List<Color> get headerGradient => isDark
      ? const [Color(0xFF2A2A2F), Color(0xFF17171A)]
      : const [Color(0xFF0B0B0C), Color(0xFF2C2C30)];

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
