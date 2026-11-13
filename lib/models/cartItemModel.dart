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

  /// Size / weight / length the customer picked (empty when the product
  /// does not offer that choice). [product] still holds every option.
  final String size;
  final String weight;
  final String length;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.colorName = '',
    this.colorHex = '',
    this.imageIndex = 0,
    this.size = '',
    this.weight = '',
    this.length = '',
  });

  bool get hasSize => size.isNotEmpty;
  bool get hasWeight => weight.isNotEmpty;
  bool get hasLength => length.isNotEmpty;

  /// At least one of size / weight / length was chosen.
  bool get hasSpecs => hasSize || hasWeight || hasLength;

  /// e.g. "Size: XL  •  Weight: 2 kg  •  Length: 120 cm" (only what is set).
  String get specsLabel => [
    if (hasSize) 'Size: $size',
    if (hasWeight) 'Weight: $weight',
    if (hasLength) 'Length: $length',
  ].join('  •  ');

  bool get hasColor => colorName.isNotEmpty;

  /// "RRGGBB", or '' when there is no colour.
  String get colorKey => colorHex.replaceAll('#', '').toUpperCase();

  Color get color =>
      Color(int.tryParse('FF$colorKey', radix: 16) ?? 0xFF000000);

  /// Unique id of this cart line (same product in two colours, or two sizes,
  /// = two lines). Also used as the Firestore document id.
  String get lineId => lineIdFor(
    product.id,
    colorKey,
    size: size,
    weight: weight,
    length: length,
  );

  static String _slug(String value) =>
      value.trim().replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');

  /// Lines without a size / weight / length keep the exact id they always
  /// had, so carts saved before this feature still match their documents.
  static String lineIdFor(
    String productId,
    String colorKey, {
    String size = '',
    String weight = '',
    String length = '',
  }) {
    final parts = <String>[
      if (colorKey.isNotEmpty) colorKey,
      if (size.isNotEmpty) 's-${_slug(size)}',
      if (weight.isNotEmpty) 'w-${_slug(weight)}',
      if (length.isNotEmpty) 'l-${_slug(length)}',
    ];

    return parts.isEmpty ? productId : '${productId}_${parts.join('_')}';
  }

  /// The image to show for this line (the one matching the chosen colour).
  String get image {
    if (product.images.isEmpty) return '';
    final i = imageIndex.clamp(0, product.images.length - 1);
    return product.images[i];
  }

  double get total => product.price * quantity;
}
