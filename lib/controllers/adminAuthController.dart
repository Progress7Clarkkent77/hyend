import 'package:get/get.dart';
import 'package:hyend/controllers/storeConfig.dart';
import 'package:hyend/pages/adminDashboard.dart';
import 'package:hyend/userAuth/authController.dart';

/// Handles admin access for the store.
///
/// Admin access is granted to the single account defined in
/// [StoreConfig.adminEmail]. The user signs in through the normal
/// [AuthController]; this controller only re-verifies the password
/// before opening the admin dashboard.
class AdminAuthController extends GetxController {
  final AuthController authCtrl = Get.find<AuthController>();

  final RxBool isLoading = false.obs;

  /// True when the currently signed-in user is the store admin.
  bool get isAdmin => StoreConfig.isAdminEmail(authCtrl.currentUser?.email);

  Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    if (isLoading.value) return;

    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      Get.snackbar('Missing Fields', 'Email and password are required');
      return;
    }

    try {
      isLoading.value = true;

      final user = authCtrl.currentUser;

      if (user == null) {
        Get.snackbar('Authentication', 'Please login first');
        return;
      }

      if (!StoreConfig.isAdminEmail(cleanEmail) || !isAdmin) {
        Get.snackbar('Access Denied', 'Admin permission required');
        return;
      }

      final valid = await authCtrl.verifyPassword(cleanEmail, cleanPassword);

      if (!valid) {
        Get.snackbar('Access Denied', 'Invalid password');
        return;
      }

      Get.off(() => EcommerceAdminDashboardPage());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
