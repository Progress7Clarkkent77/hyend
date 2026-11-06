import 'dart:ui' show Color;

import 'package:hyend/models/productModel.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  /// Chosen colour (empty for products without colours).
  final String colorName;
  final String colorHex;

  /// Image that shows the chosen colour.
  final int imageIndex;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.colorName = '',
    this.colorHex = '',
    this.imageIndex = 0,
  });

  bool get hasColor => colorName.isNotEmpty;

  /// "RRGGBB", or '' when there is no colour.
  String get colorKey => colorHex.replaceAll('#', '').toUpperCase();

  Color get color =>
      Color(int.tryParse('FF$colorKey', radix: 16) ?? 0xFF000000);

  /// Unique id of this cart line (same product in two colours = two lines).
  /// Also used as the Firestore document id.
  String get lineId => lineIdFor(product.id, colorKey);

  static String lineIdFor(String productId, String colorKey) =>
      colorKey.isEmpty ? productId : '${productId}_$colorKey';

  /// The image to show for this line (the one matching the chosen colour).
  String get image {
    if (product.images.isEmpty) return '';
    final i = imageIndex.clamp(0, product.images.length - 1);
    return product.images[i];
  }

  double get total => product.price * quantity;
}
