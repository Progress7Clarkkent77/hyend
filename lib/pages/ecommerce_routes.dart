import 'package:get/get.dart';

/// Central list of named routes. Every route here that the app navigates to
/// must have a matching GetPage in main.dart.
class EcommerceLiveRoutes {
  EcommerceLiveRoutes._();

  // Public
  static const root = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const products = '/products';
  static const productDetails = '/product-details';
  static const categories = '/categories';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgotpassword';
  static const changePassword = '/change-password';
  static const terms = '/terms';

  // Signed-in customers
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const ordersdetails = '/ordersdetails';

  // Admin only
  static const admin = '/admin';
  static const adminLogin = '/admin-login';
  static const customers = '/customers';
  static const manageProducts = '/manage-products';
  static const manageOrders = '/manage-orders';
  static const uploadProducts = '/upload-products';
}

class EcommerceLiveNavController extends GetxController {
  void goTo(String route, {dynamic arguments}) =>
      Get.toNamed(route, arguments: arguments);
}
