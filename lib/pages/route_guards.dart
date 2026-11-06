import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/pages/ecommerce_routes.dart';
import 'package:hyend/userAuth/authController.dart';

/// Requires a signed-in user; otherwise redirects to the login page.
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();

    return auth.isAuthenticated
        ? null
        : const RouteSettings(name: EcommerceLiveRoutes.login);
  }
}

/// Requires the store admin. Signed-out users go to login, signed-in
/// customers go back to the storefront.
///
/// UI-level protection only; Firestore security rules are what actually
/// stop non-admins from reading or writing admin data.
class AdminGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();

    if (!auth.isAuthenticated) {
      return const RouteSettings(name: EcommerceLiveRoutes.login);
    }

    return auth.isAdmin.value
        ? null
        : const RouteSettings(name: EcommerceLiveRoutes.home);
  }
}
