import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// FLY-TO-CART  (Temu-style "add to cart" animation)
///
/// 1. Wrap your cart icon (icon + badge) in a [CartFlyTarget] and give it a
///    `GlobalKey<CartFlyTargetState>`.
/// 2. When an item is added, call
///    `FlyToCart.launch(from: buttonContext, to: thatKey, flyer: ...)`.
///
/// A round product thumbnail pops off the button, flies along a curved path
/// (with a soft trail) into the cart icon, shrinking as it goes. When it
/// lands the cart icon does a springy bounce + a haptic tick.
/// ─────────────────────────────────────────────────────────────────────────

//==================================================
// TARGET (the cart icon)
//==================================================

class CartFlyTarget extends StatefulWidget {
  const CartFlyTarget({super.key, required this.child});

  final Widget child;

  @override
  State<CartFlyTarget> createState() => CartFlyTargetState();
}

class CartFlyTargetState extends State<CartFlyTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.45,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.45,
        end: 0.86,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.86,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 40,
    ),
  ]).animate(_c);

  /// Springy "received it!" bounce.
  void bump() {
    if (mounted) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}

//==================================================
// LAUNCHER
//==================================================

class FlyToCart {
  FlyToCart._();

  /// Round product thumbnail used as the flying object.
  static Widget thumbnail({
    Uint8List? bytes,
    required Color background,
    required Color ring,
    required Color iconColor,
  }) {
    final hasImage = bytes != null && bytes.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: Border.all(color: ring, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: hasImage
            ? Image.memory(
                bytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shopping_bag_rounded,
                  color: iconColor,
                  size: 22,
                ),
              )
            : Icon(Icons.shopping_bag_rounded, color: iconColor, size: 22),
      ),
    );
  }

  /// Flies [flyer] from the centre of [from] to the centre of the cart icon.
  /// Silently does nothing if either end is not on screen.
  static void launch({
    required BuildContext from,
    required GlobalKey<CartFlyTargetState> to,
    required Widget flyer,
    Color trailColor = const Color(0xFFFF6A00),
    double size = 58,
  }) {
    if (!from.mounted) return;

    final overlay = Overlay.maybeOf(from, rootOverlay: true);
    final fromBox = from.findRenderObject();
    final toBox = to.currentContext?.findRenderObject();
    final overlayBox = overlay?.context.findRenderObject();

    if (overlay == null ||
        fromBox is! RenderBox ||
        toBox is! RenderBox ||
        overlayBox is! RenderBox ||
        !fromBox.attached ||
        !toBox.attached ||
        !fromBox.hasSize ||
        !toBox.hasSize) {
      return;
    }

    Offset centre(RenderBox b) =>
        overlayBox.globalToLocal(b.localToGlobal(b.size.center(Offset.zero)));

    final start = centre(fromBox);
    final end = centre(toBox);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyingThumb(
        start: start,
        end: end,
        size: size,
        flyer: flyer,
        trailColor: trailColor,
        onLand: () => to.currentState?.bump(),
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
    HapticFeedback.lightImpact();
  }
}

//==================================================
// THE FLYING OBJECT
//==================================================

class _FlyingThumb extends StatefulWidget {
  const _FlyingThumb({
    required this.start,
    required this.end,
    required this.size,
    required this.flyer,
    required this.trailColor,
    required this.onLand,
    required this.onDone,
  });

  final Offset start;
  final Offset end;
  final double size;
  final Widget flyer;
  final Color trailColor;
  final VoidCallback onLand;
  final VoidCallback onDone;

  @override
  State<_FlyingThumb> createState() => _FlyingThumbState();
}

class _FlyingThumbState extends State<_FlyingThumb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 880),
  );

  bool _landed = false;

  @override
  void initState() {
    super.initState();

    _c.addListener(() {
      if (!_landed && _c.value >= 0.9) {
        _landed = true;
        HapticFeedback.selectionClick();
        widget.onLand();
      }
    });

    _c.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Quadratic bezier: lifts up first, then sweeps across into the cart.
  Offset _pointAt(double u) {
    final p0 = widget.start;
    final p2 = widget.end;
    final p1 = Offset(p0.dx + (p2.dx - p0.dx) * 0.2, p2.dy);

    final a = (1 - u) * (1 - u);
    final b = 2 * (1 - u) * u;
    final c = u * u;

    return Offset(
      a * p0.dx + b * p1.dx + c * p2.dx,
      a * p0.dy + b * p1.dy + c * p2.dy,
    );
  }

  double _scaleAt(double t) {
    // quick pop-in, then shrink as it nears the cart
    if (t < 0.14) {
      return 0.6 + 0.4 * Curves.easeOutBack.transform(t / 0.14);
    }
    final k = Curves.easeInCubic.transform((t - 0.14) / 0.86);
    return 1.0 - 0.74 * k;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value;
          final eased = Curves.easeInOutCubic.transform(t);
          final pos = _pointAt(eased);

          // fade out only in the last moments, as it "enters" the cart
          final opacity = t < 0.88
              ? 1.0
              : (1 - (t - 0.88) / 0.12).clamp(0.0, 1.0);

          final children = <Widget>[];

          // soft trail dots
          for (var i = 3; i >= 1; i--) {
            final tt = t - i * 0.045;
            if (tt <= 0) continue;

            final tp = _pointAt(Curves.easeInOutCubic.transform(tt));
            final d = size * (0.30 - i * 0.06);

            children.add(
              Positioned(
                left: tp.dx - d / 2,
                top: tp.dy - d / 2,
                width: d,
                height: d,
                child: Opacity(
                  opacity: (0.55 - i * 0.14).clamp(0.0, 1.0) * opacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.trailColor,
                    ),
                  ),
                ),
              ),
            );
          }

          children.add(
            Positioned(
              left: pos.dx - size / 2,
              top: pos.dy - size / 2,
              width: size,
              height: size,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(scale: _scaleAt(t), child: widget.flyer),
              ),
            ),
          );

          return Stack(clipBehavior: Clip.none, children: children);
        },
      ),
    );
  }
}
