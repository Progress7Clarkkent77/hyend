import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Shared UI helpers for the storefront pages (cart, orders, ...).
/// Suggested location: lib/live/pages/storeUi.dart

//==================================================
// PALETTE
//==================================================

class StorePalette {
  const StorePalette(this.isDark);

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

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFE5484D);
  static const Color info = Color(0xFF2563EB);

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

//==================================================
// FORMATTERS
//==================================================

/// 1234567.5 -> ₦1,234,567.50 ; 1500 -> ₦1,500
String formatNaira(num value) {
  final parts = value.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return parts[1] == '00' ? '₦$whole' : '₦$whole.${parts[1]}';
}

/// Safe short order reference, e.g. "A1B2C3D4".
String shortOrderId(String id) =>
    (id.length <= 8 ? id : id.substring(0, 8)).toUpperCase();

/// Delivery stages, in order. Mirrors ManageOrdersController.trackingLocations.
const List<String> kTrackingStages = [
  'Order Received',
  'Processing',
  'Packed',
  'Dispatched',
  'In Transit',
  'Arrived Local Hub',
  'Out For Delivery',
  'Delivered',
];

//==================================================
// BASE64 IMAGE (decodes once, not on every rebuild)
//==================================================

class Base64Image extends StatefulWidget {
  const Base64Image({
    super.key,
    required this.data,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  final String data;
  final Widget placeholder;
  final BoxFit fit;

  @override
  State<Base64Image> createState() => _Base64ImageState();
}

class _Base64ImageState extends State<Base64Image> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant Base64Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _decode();
  }

  void _decode() {
    if (widget.data.isEmpty) {
      _bytes = null;
      return;
    }

    try {
      _bytes = base64Decode(widget.data);
    } catch (_) {
      _bytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;

    if (bytes == null) return widget.placeholder;

    return Image.memory(
      bytes,
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => widget.placeholder,
    );
  }
}
