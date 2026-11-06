import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/theme_controller.dart';

/// Shared light / dark palette. Same colours as the private `_P` class in
/// profile.dart, plus the extras the admin pages need (status colours,
/// input fields, buttons, sheets, dialogs).
///
/// Usage: inside an `Obx`, call `final p = AppPalette.current();`
/// It reads `ThemeController.isDarkMode`, so the page rebuilds the moment
/// the user flips the switch on the profile page.
class AppPalette {
  const AppPalette(this.isDark);

  final bool isDark;

  factory AppPalette.current() {
    final dark = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>().isDarkMode.value
        : false;
    return AppPalette(dark);
  }

  //==================================================
  // CORE COLOURS (identical to profile.dart)
  //==================================================

  Color get bg => isDark ? const Color(0xFF0E0E10) : const Color(0xFFF6F6F7);
  Color get surface => isDark ? const Color(0xFF1A1A1D) : Colors.white;
  Color get border =>
      isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE9E9EC);
  Color get tile => isDark ? const Color(0xFF26262A) : const Color(0xFFF1F1F3);
  Color get text => isDark ? Colors.white : const Color(0xFF0B0B0C);
  Color get muted => isDark ? const Color(0xFF9A9AA2) : const Color(0xFF6B6B73);
  Color get accent => isDark ? Colors.white : const Color(0xFF0B0B0C);
  Color get onAccent => isDark ? const Color(0xFF0B0B0C) : Colors.white;

  /// Slightly stronger than [border]; used on input fields and outlined buttons.
  Color get borderStrong =>
      isDark ? const Color(0xFF3A3A40) : const Color(0xFFD4D4D9);

  //==================================================
  // STATUS COLOURS
  //==================================================

  Color get danger => const Color(0xFFE5484D);
  Color get success =>
      isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A);
  Color get warning =>
      isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
  Color get info => isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

  Color get gold => const Color(0xFFF5B301);

  /// Gold that stays readable as text on both backgrounds.
  Color get goldText =>
      isDark ? const Color(0xFFF5B301) : const Color(0xFF9A6B00);

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

  //==================================================
  // SYSTEM BARS
  //==================================================

  SystemUiOverlayStyle get overlay =>
      (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent);

  //==================================================
  // BUILDING BLOCKS
  //==================================================

  PreferredSizeWidget appBar(String title, {List<Widget>? actions}) {
    return AppBar(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: overlay,
      iconTheme: IconThemeData(color: text),
      actionsIconTheme: IconThemeData(color: text),
      title: Text(
        title,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions,
    );
  }

  /// Text style for anything typed into a TextField / shown in a dropdown.
  TextStyle get fieldStyle => TextStyle(color: text, fontSize: 15);

  InputDecoration input(
    String? label, {
    String? hint,
    String? prefix,
    String? suffix,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? counterText,
    Color? fill,
    double radius = 16,
  }) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: c, width: w),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      suffixText: suffix,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: counterText,
      filled: true,
      fillColor: fill ?? surface,
      labelStyle: TextStyle(color: muted),
      floatingLabelStyle: TextStyle(color: text),
      hintStyle: TextStyle(color: muted),
      prefixStyle: TextStyle(color: text),
      suffixStyle: TextStyle(color: muted),
      prefixIconColor: muted,
      suffixIconColor: muted,
      border: b(borderStrong),
      enabledBorder: b(borderStrong),
      focusedBorder: b(text, 1.6),
      errorBorder: b(danger),
      focusedErrorBorder: b(danger, 1.6),
    );
  }

  BoxDecoration cardDecoration({double radius = 22, Color? borderColor}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? border),
      boxShadow: shadow,
    );
  }

  BoxDecoration get sheetDecoration => BoxDecoration(
    color: surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
  );

  Widget get sheetHandle => Center(
    child: Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: borderStrong,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );

  ButtonStyle primaryButton({double radius = 16}) => ElevatedButton.styleFrom(
    elevation: 0,
    backgroundColor: accent,
    foregroundColor: onAccent,
    disabledBackgroundColor: tile,
    disabledForegroundColor: muted,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );

  ButtonStyle outlinedButton({
    double radius = 14,
    EdgeInsetsGeometry? padding,
  }) => OutlinedButton.styleFrom(
    foregroundColor: text,
    padding: padding,
    side: BorderSide(color: borderStrong),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );

  //==================================================
  // SNACKBAR + CONFIRM DIALOG (shown above the page, so they need their own
  // explicit colours)
  //==================================================

  static void snack(String title, String message) {
    final p = AppPalette.current();

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

  static Future<bool> confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final p = AppPalette.current();

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
              backgroundColor: destructive ? p.danger : p.accent,
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
}
