import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyend/models/productModel.dart';

/// Two-option picker: "Within Enugu" / "Outside Enugu".
/// Colours are passed in so every page can use its own light/dark palette.
class DeliveryZoneSelector extends StatelessWidget {
  const DeliveryZoneSelector({
    super.key,
    required this.zone,
    required this.onChanged,
    required this.tile,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.text,
    required this.muted,
    this.enuguSubtitle,
    this.outsideSubtitle,
  });

  final DeliveryZone zone;
  final ValueChanged<DeliveryZone> onChanged;

  final Color tile;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color text;
  final Color muted;

  /// Optional line under each title (usually the delivery fee).
  final String? enuguSubtitle;
  final String? outsideSubtitle;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight gives both cards the same height without needing a
    // bounded parent (this widget sits inside scrolling pages).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _option(
              DeliveryZone.enugu,
              Icons.location_on_outlined,
              enuguSubtitle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _option(
              DeliveryZone.outside,
              Icons.public_rounded,
              outsideSubtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _option(DeliveryZone value, IconData icon, String? subtitle) {
    final selected = zone == value;
    final fg = selected ? onAccent : text;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (selected) return;
        HapticFeedback.selectionClick();
        onChanged(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? accent : tile,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? accent : border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: fg),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? onAccent : Colors.transparent,
                    border: Border.all(
                      color: selected ? onAccent : muted.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check_rounded, size: 13, color: accent)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value.shortLabel,
              style: TextStyle(
                color: fg,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: selected ? onAccent.withOpacity(0.75) : muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
