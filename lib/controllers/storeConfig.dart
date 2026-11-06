/// Central configuration for the single-store (proprietary) setup.
///
/// Suggested location: lib/live/config/storeConfig.dart
class StoreConfig {
  StoreConfig._();

  /// The one account that is treated as the store administrator.
  static const String adminEmail = 'progressclarkkent@gmail.com';

  // Firestore collections (top-level, no organization nesting).
  static const String productsCollection = 'products1';
  static const String ordersCollection = 'orders1';
  static const String cartsCollection = 'carts1';
  static const String cartItemsCollection = 'items1';

  /// One document per user (id = uid) holding their saved phone and address.
  static const String shippingCollection = 'shipping_profiles1';

  /// Platform markup applied on top of the price the admin enters.
  static const double platformFeeRate = 0.05;

  /// Firestore documents are limited to 1 MiB. Images are stored as base64,
  /// so keep the combined payload safely below that limit.
  static const int maxImagePayloadBytes = 900 * 1024;

  static bool isAdminEmail(String? email) =>
      email != null && email.trim().toLowerCase() == adminEmail;
}
