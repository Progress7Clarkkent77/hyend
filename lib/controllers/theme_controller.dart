import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Stores the theme choice locally on the device. No login or cloud needed.
class ThemeController extends GetxController {
  static const _key = 'isDarkMode';
  final GetStorage _box = GetStorage();

  /// Light mode is the default.
  final RxBool isDarkMode = false.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read<bool>(_key) ?? false;
  }

  /// Only called by the user pressing the theme button.
  Future<void> toggle() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(themeMode);
    await _box.write(_key, isDarkMode.value);
  }
}
