import 'package:get/get.dart';

class StartupController extends GetxController {
  final RxBool isChecking = true.obs;

  /// Shows the onboarding screen briefly, then moves to the home page.
  /// (Theme is already loaded in main.dart, so nothing theme-related here.)
  Future<void> initializeApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 3200));
    } finally {
      isChecking.value = false;
      Get.offAllNamed('/home');
    }
  }
}
