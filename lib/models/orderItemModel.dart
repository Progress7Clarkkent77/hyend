class OrderItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String image;

  /// Colour the customer chose (empty for products without colours).
  final String colorName;
  final String colorHex;

  /// Size, weight and length of the product at the time of ordering
  /// (empty when the product has none, or for older orders).
  final String size;
  final String weight;
  final String length;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.image,
    this.colorName = '',
    this.colorHex = '',
    this.size = '',
    this.weight = '',
    this.length = '',
  });

  /// At least one of size / weight / length is set.
  bool get hasSpecs =>
      size.isNotEmpty || weight.isNotEmpty || length.isNotEmpty;

  /// e.g. "Size: XL  •  Weight: 2 kg  •  Length: 120 cm" (only what is set).
  String get specsLabel => [
    if (size.isNotEmpty) 'Size: $size',
    if (weight.isNotEmpty) 'Weight: $weight',
    if (length.isNotEmpty) 'Length: $length',
  ].join('  •  ');

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'image': image,
      'colorName': colorName,
      'colorHex': colorHex,
      'size': size,
      'weight': weight,
      'length': length,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      image: map['image'] ?? '',
      colorName: map['colorName'] ?? '',
      colorHex: map['colorHex'] ?? '',
      size: (map['size'] ?? '').toString(),
      weight: (map['weight'] ?? '').toString(),
      length: (map['length'] ?? '').toString(),
    );
  }
}
