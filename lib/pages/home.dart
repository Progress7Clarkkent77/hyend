import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/theme/app_theme.dart';
import 'package:hyend/widgets/hyend_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final themeCtrl = Get.find<ThemeController>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Top bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
                    child: Row(
                      children: [
                        const HyEndLogo(size: 36),
                        const SizedBox(width: 12),
                        Text(
                          'HYEND',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                            color: p.text,
                          ),
                        ),
                        const Spacer(),
                        Obx(
                          () => IconButton(
                            onPressed: () {
                              final isDark = !themeCtrl.isDarkMode.value;
                              themeCtrl.isDarkMode.value = isDark;
                              Get.changeThemeMode(
                                isDark ? ThemeMode.dark : ThemeMode.light,
                              );
                            },
                            icon: Icon(
                              themeCtrl.isDarkMode.value
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              color: p.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Hero ──
                SliverToBoxAdapter(
                  child: _Reveal(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1B2747), AppColors.navy],
                        ),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Eyebrow(
                            'INTERNATIONAL WHOLESALE SOURCING',
                            color: AppColors.goldSoft,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Wholesale\nBeyond Borders.',
                            style: TextStyle(
                              fontSize: 36,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'HyEnd connects Nigerian buyers with international suppliers through consolidated import shipments, so you can source wholesale without travelling abroad.',
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.6,
                              color: Colors.white.withOpacity(0.78),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── The Problem ──
                _section(
                  p,
                  eyebrow: 'THE PROBLEM',
                  title: 'Importing is hard to navigate',
                  intro: 'Many Nigerian entrepreneurs want to buy wholesale products internationally but face real barriers. They may not know:',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _Chip('Reliable overseas suppliers'),
                      _Chip('How to negotiate wholesale'),
                      _Chip('How international shipping works'),
                      _Chip('How customs clearance works'),
                      _Chip('How to calculate landed cost'),
                      _Chip('How to consolidate shipments'),
                      _Chip('How to manage logistics'),
                    ],
                  ),
                  footer: 'Travelling abroad to source products is also expensive and out of reach for many small businesses.',
                ),

                // ── The Solution ──
                _section(
                  p,
                  eyebrow: 'THE SOLUTION',
                  title: 'One platform. The whole import journey.',
                  intro: 'HyEnd is an international wholesale sourcing and import-consolidation platform. Customers discover wholesale products, reserve quantities and take part in consolidated import shipments, without personally handling the entire sourcing process.',
                ),

                // ── How it works ──
                _section(
                  p,
                  eyebrow: 'HOW IT WORKS',
                  title: 'From supplier to your doorstep',
                  child: const _Timeline(
                    steps: [
                      'International Supplier',
                      'HyEnd',
                      'Product / Import Slot',
                      'Multiple Nigerian Buyers',
                      'Consolidated Shipment',
                      'Nigeria',
                      'Customs Clearance',
                      'Enugu / Customer Delivery',
                    ],
                  ),
                ),

                // ── Example ──
                _section(
                  p,
                  eyebrow: 'EXAMPLE',
                  title: 'Shared shipments, shared opportunity',
                  intro: 'A Chinese supplier has a product at wholesale quantity. Instead of one entrepreneur buying the entire shipment, HyEnd organises an import opportunity where multiple buyers reserve quantities.',
                  child: const _ShipmentExample(),
                  footer: 'Once the shipment reaches the required commercial threshold, the logistics process begins.',
                ),

                // ── Transparency ──
                _section(
                  p,
                  eyebrow: 'TRANSPARENCY',
                  title: 'Know your costs before you commit',
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.6,
                    children: const [
                      _CostTile(Icons.sell_outlined, 'Product price'),
                      _CostTile(
                        Icons.directions_boat_outlined,
                        'Shipping cost',
                      ),
                      _CostTile(
                        Icons.receipt_long_outlined,
                        'Import-related costs',
                      ),
                      _CostTile(
                        Icons.local_shipping_outlined,
                        'Local logistics',
                      ),
                      _CostTile(
                        Icons.workspace_premium_outlined,
                        'HyEnd service fee',
                      ),
                      _CostTile(Icons.calculate_outlined, 'Est. landed cost'),
                    ],
                  ),
                  footer: 'Plus live shipment status, so you always know where your goods are.',
                ),

                // ── Trust layer ──
                _section(
                  p,
                  eyebrow: 'TRUST LAYER',
                  title: 'More than products on an app',
                  intro: 'HyEnd\'s long-term value is a structured system built on:',
                  child: Column(
                    children: const [
                      _TrustRow(
                        Icons.verified_outlined,
                        'Supplier verification',
                      ),
                      _TrustRow(Icons.fact_check_outlined, 'Product screening'),
                      _TrustRow(Icons.route_outlined, 'Logistics'),
                      _TrustRow(
                        Icons.assignment_turned_in_outlined,
                        'Import coordination',
                      ),
                      _TrustRow(Icons.shopping_bag_outlined, 'Customer orders'),
                    ],
                  ),
                ),

                // ── Vision ──
                SliverToBoxAdapter(
                  child: _Reveal(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 36, 20, 0),
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: p.card,
                        border: Border.all(color: p.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Eyebrow('OUR VISION'),
                          const SizedBox(height: 12),
                          Text(
                            'To make international wholesale sourcing accessible to businesses and individuals across Africa, without requiring them to travel abroad.',
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Launch status ──
                SliverToBoxAdapter(
                  child: _Reveal(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withOpacity(0.18),
                            AppColors.gold.withOpacity(0.06),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.rocket_launch_outlined,
                            color: AppColors.gold,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Full platform launching soon',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: p.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'We are working on our supplier network, logistics partners and on-the-ground operations to bring you the complete HyEnd experience.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: p.subtext,
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

                // ── Footer ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 40),
                    child: Column(
                      children: [
                        const HyEndLogo(size: 40),
                        const SizedBox(height: 14),
                        Text(
                          'HyEnd',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                            color: p.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Wholesale Beyond Borders.',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: p.subtext,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'POWERED BY',
                          style: TextStyle(
                            fontSize: 9.5,
                            letterSpacing: 3,
                            color: p.subtext,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'AFIA SPLENDID LTD',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reusable section block.
  Widget _section(
    _Palette p, {
    required String eyebrow,
    required String title,
    String? intro,
    Widget? child,
    String? footer,
  }) {
    return SliverToBoxAdapter(
      child: _Reveal(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Eyebrow(eyebrow),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: p.text,
                ),
              ),
              if (intro != null) ...[
                const SizedBox(height: 12),
                Text(
                  intro,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.65,
                    color: p.subtext,
                  ),
                ),
              ],
              if (child != null) ...[const SizedBox(height: 20), child],
              if (footer != null) ...[
                const SizedBox(height: 16),
                Text(
                  footer,
                  style: TextStyle(fontSize: 14, height: 1.6, color: p.subtext),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── helpers ─────────────────────────

class _Palette {
  final Color text, subtext, card, border;
  _Palette(this.text, this.subtext, this.card, this.border);

  static _Palette of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? _Palette(
            Colors.white,
            Colors.white.withOpacity(0.68),
            AppColors.navyLight,
            Colors.white.withOpacity(0.08),
          )
        : _Palette(
            AppColors.navy,
            AppColors.navy.withOpacity(0.65),
            Colors.white,
            AppColors.navy.withOpacity(0.08),
          );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  final Color color;
  const _Eyebrow(this.text, {this.color = AppColors.gold});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 3,
      color: color,
    ),
  );
}

/// Gentle fade + rise when a section first builds.
class _Reveal extends StatelessWidget {
  final Widget child;
  const _Reveal({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: p.border),
      ),
      child: Text(label, style: TextStyle(fontSize: 12.5, color: p.text)),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<String> steps;
  const _Timeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return Column(
      children: List.generate(steps.length, (i) {
        final last = i == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 34,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: last ? AppColors.gold : Colors.transparent,
                        border: Border.all(color: AppColors.gold, width: 1.5),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: last ? AppColors.navy : AppColors.gold,
                        ),
                      ),
                    ),
                    if (!last)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: AppColors.gold.withOpacity(0.35),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 22),
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ShipmentExample extends StatelessWidget {
  const _ShipmentExample();

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    const total = 500;
    const rows = [
      ['Customer A', 50],
      ['Customer B', 100],
      ['Customer C', 75],
      ['Customer D', 25],
      ['Others (remaining capacity)', 250],
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Shipment capacity',
                style: TextStyle(fontSize: 13, color: p.subtext),
              ),
              const Spacer(),
              Text(
                '$total units',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...rows.map((r) {
            final units = r[1] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        r[0] as String,
                        style: TextStyle(fontSize: 13, color: p.text),
                      ),
                      const Spacer(),
                      Text(
                        '$units',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: units / total),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 7,
                        backgroundColor: p.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CostTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CostTile(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.gold),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
        ],
      ),
    );
  }
}
