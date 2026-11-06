class OrderItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String image;

  /// Colour the customer chose (empty for products without colours).
  final String colorName;
  final String colorHex;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.image,
    this.colorName = '',
    this.colorHex = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'image': image,
      'colorName': colorName,
      'colorHex': colorHex,
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
    );
  }
}
