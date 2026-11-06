import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/adminDashboardController.dart';
import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/pages/ecommerce_routes.dart';
import 'package:hyend/userAuth/authController.dart';

class EcommerceAdminDashboardPage extends StatelessWidget {
  EcommerceAdminDashboardPage({super.key});

  // Registered lazily in AppBinding (main.dart).
  final EcommerceAdminDashboardController dashboardCtrl =
      Get.find<EcommerceAdminDashboardController>();

  final AuthController authCtrl = Get.find<AuthController>();

  // ThemeController is created at login; fall back safely when the admin
  // reopens the app while already signed in.
  final ThemeController themeCtrl = Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : Get.put(ThemeController());

  static const String _logoAsset = 'assets/images/RealStore Logo.png';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = _Palette(themeCtrl.isDarkMode.value);
      final loading = dashboardCtrl.isLoading.value;

      final stats = <_Stat>[
        _Stat(
          'Revenue',
          loading
              ? '—'
              : dashboardCtrl.formatAmount(dashboardCtrl.revenue.value),
          Icons.payments_outlined,
        ),
        _Stat(
          'Orders',
          loading ? '—' : '${dashboardCtrl.orderCount.value}',
          Icons.receipt_long_outlined,
        ),
        _Stat(
          'Products',
          loading ? '—' : '${dashboardCtrl.productCount.value}',
          Icons.inventory_2_outlined,
        ),
        _Stat(
          'Customers',
          loading ? '—' : '${dashboardCtrl.customerCount.value}',
          Icons.people_outline,
        ),
      ];

      return Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: p.textPrimary,
          centerTitle: false,
          title: Text(
            'Dashboard',
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: dashboardCtrl.startRealtimeListeners,
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: 'View store',
              onPressed: () => Get.offAllNamed(EcommerceLiveRoutes.home),
              icon: const Icon(Icons.storefront_outlined),
            ),
            const SizedBox(width: 8),
          ],
          bottom: loading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: p.textPrimary,
                    backgroundColor: Colors.transparent,
                  ),
                )
              : null,
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final statColumns = w >= 900 ? 4 : 2;
                final actionColumns = w >= 900 ? 3 : (w >= 640 ? 2 : 1);

                return RefreshIndicator(
                  color: p.textPrimary,
                  onRefresh: dashboardCtrl.loadDashboard,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      _header(p),
                      const SizedBox(height: 28),
                      _sectionTitle('Overview', p),
                      const SizedBox(height: 14),
                      _statsGrid(stats, statColumns, p),
                      const SizedBox(height: 32),
                      _sectionTitle('Management', p),
                      const SizedBox(height: 14),
                      _actionsGrid(actionColumns, p),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  //==================================================
  // LOGO (rounded square)
  //==================================================

  Widget _logo({required double size, required double radius}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0x33FFFFFF), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1.5),
        child: Image.asset(
          _logoAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.storefront_rounded, color: Colors.black),
        ),
      ),
    );
  }

  //==================================================
  // HEADER
  //==================================================

  Widget _header(_Palette p) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : (hour < 17 ? 'Good afternoon' : 'Good evening');

    final email = authCtrl.currentUser?.email ?? '';

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
              _logo(size: 64, radius: 18),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Color(0xB3FFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'RealStore Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(
                leading: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                  ),
                ),
                label: 'Live data',
              ),
              if (email.isNotEmpty)
                _pill(
                  leading: const Icon(
                    Icons.verified_user_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                  label: email,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill({required Widget leading, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // SECTION TITLE
  //==================================================

  Widget _sectionTitle(String text, _Palette p) {
    return Text(
      text,
      style: TextStyle(
        color: p.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }

  //==================================================
  // STATS
  //==================================================

  Widget _statsGrid(List<_Stat> stats, int columns, _Palette p) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 124,
      ),
      itemBuilder: (_, i) => _statCard(stats[i], p),
    );
  }

  Widget _statCard(_Stat stat, _Palette p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.border),
        boxShadow: p.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: p.tile,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, size: 15, color: p.textPrimary),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              stat.value,
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.title,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // MANAGEMENT ACTIONS
  //==================================================

  Widget _actionsGrid(int columns, _Palette p) {
    final actions = <_Action>[
      _Action(
        'Manage Products',
        'Edit, hide or remove listings',
        Icons.shopping_bag_outlined,
        EcommerceLiveRoutes.manageProducts,
      ),
      _Action(
        'Manage Orders',
        'Track and update deliveries',
        Icons.local_shipping_outlined,
        EcommerceLiveRoutes.manageOrders,
      ),
      _Action(
        'Upload Products',
        'Add new items to your store',
        Icons.add_photo_alternate_outlined,
        EcommerceLiveRoutes.uploadProducts,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 92,
      ),
      itemBuilder: (_, i) => _actionTile(actions[i], p),
    );
  }

  Widget _actionTile(_Action action, _Palette p) {
    return Material(
      color: p.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: p.border),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(action.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action.icon, color: p.onAccent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      action.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: p.textMuted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: p.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==================================================
// SUPPORTING TYPES
//==================================================

class _Stat {
  const _Stat(this.title, this.value, this.icon);

  final String title;
  final String value;
  final IconData icon;
}

class _Action {
  const _Action(this.title, this.subtitle, this.icon, this.route);

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

class _Palette {
  _Palette(this.isDark);

  final bool isDark;

  Color get background =>
      isDark ? const Color(0xFF0E0E10) : const Color(0xFFF6F6F7);

  Color get surface => isDark ? const Color(0xFF1A1A1D) : Colors.white;

  Color get border =>
      isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE9E9EC);

  Color get tile => isDark ? const Color(0xFF26262A) : const Color(0xFFF1F1F3);

  Color get textPrimary => isDark ? Colors.white : const Color(0xFF0B0B0C);

  Color get textMuted =>
      isDark ? const Color(0xFF9A9AA2) : const Color(0xFF6B6B73);

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
