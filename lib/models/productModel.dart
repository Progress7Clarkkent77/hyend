import 'dart:ui' show Color;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

//==================================================
// BLACK FRIDAY (global switch)
//==================================================

/// Shared on/off flag. [ProductModel.price] reads it, so every screen that
/// shows a price inside an Obx updates the moment the switch flips.
class BlackFridayState {
  BlackFridayState._();

  static final RxBool active = false.obs;
}

//==================================================
// DELIVERY ZONE
//==================================================

enum DeliveryZone { enugu, outside }

extension DeliveryZoneX on DeliveryZone {
  /// Value stored in Firestore ('enugu' / 'outside').
  String get key => name;

  String get label =>
      this == DeliveryZone.enugu ? 'Within Enugu State' : 'Outside Enugu State';

  String get shortLabel =>
      this == DeliveryZone.enugu ? 'Within Enugu' : 'Outside Enugu';

  static DeliveryZone fromKey(String? key) =>
      key == 'outside' ? DeliveryZone.outside : DeliveryZone.enugu;
}

//==================================================
// COLOUR (one per image)
//==================================================

class ProductColor {
  const ProductColor({required this.name, required this.hex});

  final String name;

  /// "#RRGGBB"
  final String hex;

  /// "RRGGBB" upper-case — used to compare colours and build cart line ids.
  String get key => hex.replaceAll('#', '').toUpperCase();

  Color get color => Color(int.tryParse('FF$key', radix: 16) ?? 0xFF000000);

  factory ProductColor.fromMap(Map<String, dynamic> map) {
    final hex = (map['hex'] ?? '#000000').toString();
    return ProductColor(
      name: (map['name'] ?? '').toString(),
      hex: '#${hex.replaceAll('#', '').toUpperCase()}',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'hex': hex};
}

/// A distinct colour of a product and the images that show it.
class ColorOption {
  const ColorOption({required this.color, required this.imageIndexes});

  final ProductColor color;
  final List<int> imageIndexes;

  /// First image that shows this colour.
  int get imageIndex => imageIndexes.first;
}

//==================================================
// PRODUCT
//==================================================

class ProductModel {
  final String id;
  final String name;
  final String description;
  final List<String> images;

  /// Colour of each image — same order as [images]. May be empty for
  /// products uploaded before colours existed.
  final List<ProductColor> imageColors;

  final String category;

  /// Normal price (what is stored in Firestore as `price`).
  final double regularPrice;

  /// Seller price before the platform fee (null on older products).
  final double? originalPrice;

  /// Black Friday discount, 0–90 (%). Only applied while the switch is on.
  final double blackFridayPercent;

  /// Legacy single delivery fee.
  final double deliveryFee;

  /// Delivery fee to an address inside Enugu State.
  final double deliveryFeeEnugu;

  /// Delivery fee to an address outside Enugu State.
  final double deliveryFeeOutside;

  final int stock;

  /// Smallest quantity a customer may put in the cart (1 = no minimum).
  /// E.g. 10 means 1–9 units can't be added.
  final int minOrderQuantity;

  /// Choices the customer picks from, entered as free text so they suit any
  /// product, e.g. sizes ["S", "M", "L"], weights ["1 kg", "2 kg"], lengths
  /// ["120 cm"]. Empty list = not offered.
  final List<String> sizes;
  final List<String> weights;
  final List<String> lengths;

  final bool isActive;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.category,
    required double price,
    this.originalPrice,
    this.blackFridayPercent = 0,
    required this.deliveryFee,
    required this.stock,
    this.minOrderQuantity = 1,
    this.sizes = const [],
    this.weights = const [],
    this.lengths = const [],
    required this.isActive,
    this.createdAt,
    this.imageColors = const [],
    double? deliveryFeeEnugu,
    double? deliveryFeeOutside,
  }) : regularPrice = price,
       deliveryFeeEnugu = deliveryFeeEnugu ?? deliveryFee,
       deliveryFeeOutside = deliveryFeeOutside ?? deliveryFee;

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    final legacyFee = (data['deliveryFee'] ?? 0).toDouble();

    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      imageColors: (data['imageColors'] as List? ?? [])
          .map((e) => ProductColor.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      blackFridayPercent: (data['blackFridayPercent'] ?? 0).toDouble(),
      deliveryFee: legacyFee,
      // Older products only have one fee, so both zones fall back to it.
      deliveryFeeEnugu: (data['deliveryFeeEnugu'] ?? legacyFee).toDouble(),
      deliveryFeeOutside: (data['deliveryFeeOutside'] ?? legacyFee).toDouble(),
      stock: data['stock'] ?? 0,
      // older products have no minimum, so they default to 1
      minOrderQuantity: _readMinOrder(data['minOrderQuantity']),
      // products saved before multiple options only have a single text value
      sizes: _readOptions(data['sizes'], data['size']),
      weights: _readOptions(data['weights'], data['weight']),
      lengths: _readOptions(data['lengths'], data['length']),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static List<String> _readOptions(dynamic list, dynamic legacy) {
    final out = <String>[];

    void add(String raw) {
      final s = raw.trim();
      if (s.isEmpty) return;
      if (out.any((o) => o.toLowerCase() == s.toLowerCase())) return;
      out.add(s);
    }

    if (list is List) {
      for (final e in list) {
        add(e.toString());
      }
    }

    if (out.isEmpty) add((legacy ?? '').toString());

    return out;
  }

  /// Most options one product can offer per group, and the longest option.
  static const int maxOptions = 20;
  static const int maxOptionLength = 40;

  /// Adds the comma-separated [raw] text ("S, M, L") to [target], skipping
  /// duplicates. Returns an error message, or null when it worked. Nothing is
  /// added when there is an error.
  static String? addOptions(List<String> target, String raw) {
    final parts = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final toAdd = <String>[];

    for (final part in parts) {
      if (part.length > maxOptionLength) {
        return 'Each option must be $maxOptionLength characters or fewer';
      }

      final exists =
          target.any((o) => o.toLowerCase() == part.toLowerCase()) ||
          toAdd.any((o) => o.toLowerCase() == part.toLowerCase());

      if (!exists) toAdd.add(part);
    }

    if (target.length + toAdd.length > maxOptions) {
      return 'You can add up to $maxOptions options';
    }

    target.addAll(toAdd);
    return null;
  }

  /// Copy of this product narrowed to the choice the customer made, so the
  /// cart, checkout and orders show "Size: XL" instead of every size.
  ProductModel withSelection({String? size, String? weight, String? length}) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      images: images,
      category: category,
      price: regularPrice,
      originalPrice: originalPrice,
      blackFridayPercent: blackFridayPercent,
      deliveryFee: deliveryFee,
      stock: stock,
      minOrderQuantity: minOrderQuantity,
      sizes: size == null ? sizes : [size],
      weights: weight == null ? weights : [weight],
      lengths: length == null ? lengths : [length],
      isActive: isActive,
      createdAt: createdAt,
      imageColors: imageColors,
      deliveryFeeEnugu: deliveryFeeEnugu,
      deliveryFeeOutside: deliveryFeeOutside,
    );
  }

  static int _readMinOrder(dynamic value) {
    final n = (value as num?)?.toInt() ?? 1;
    return n < 1 ? 1 : n;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'images': images,
      'imageColors': imageColors.map((c) => c.toMap()).toList(),
      // always the NORMAL price — never the discounted one
      'price': regularPrice,
      'originalPrice': originalPrice,
      'blackFridayPercent': blackFridayPercent,
      'deliveryFee': deliveryFee,
      'deliveryFeeEnugu': deliveryFeeEnugu,
      'deliveryFeeOutside': deliveryFeeOutside,
      'stock': stock,
      'minOrderQuantity': minOrderQuantity,
      'sizes': sizes,
      'weights': weights,
      'lengths': lengths,
      // single-text copies, kept so older screens keep working
      'size': size,
      'weight': weight,
      'length': length,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  //--------------------------------------------------
  // PRICE (normal / Black Friday)
  //--------------------------------------------------

  /// This product has a Black Friday discount set (applies only when the
  /// global switch is on).
  bool get hasBlackFridayDiscount => blackFridayPercent > 0;

  /// True while Black Friday is live AND this product is discounted.
  bool get isOnBlackFriday =>
      BlackFridayState.active.value && hasBlackFridayDiscount;

  /// Price the customer pays right now. Used by the cart, checkout and
  /// orders, so switching Black Friday off restores every price at once.
  double get price => isOnBlackFriday
      ? (regularPrice * (1 - blackFridayPercent / 100)).roundToDouble()
      : regularPrice;

  /// Amount saved per unit while Black Friday is live.
  double get savings => regularPrice - price;

  //--------------------------------------------------
  // MINIMUM ORDER QUANTITY
  //--------------------------------------------------

  /// This product has a minimum quantity above 1.
  bool get hasMinOrder => minOrderQuantity > 1;

  /// Quantity to use when the customer adds the product for the first time.
  int get startingQuantity => minOrderQuantity;

  /// Whether [quantity] is allowed in the cart for this product.
  bool meetsMinOrder(int quantity) => quantity >= minOrderQuantity;

  /// Message to show when a quantity below the minimum is attempted.
  String get minOrderMessage =>
      'Minimum order for this product is $minOrderQuantity units.';

  //--------------------------------------------------
  // SIZE / WEIGHT / LENGTH
  //--------------------------------------------------

  /// All options as one text, e.g. "S, M, L" (the chosen one after
  /// [withSelection]).
  String get size => sizes.join(', ');
  String get weight => weights.join(', ');
  String get length => lengths.join(', ');

  bool get hasSize => sizes.isNotEmpty;
  bool get hasWeight => weights.isNotEmpty;
  bool get hasLength => lengths.isNotEmpty;

  /// At least one of size / weight / length is set.
  bool get hasSpecs => hasSize || hasWeight || hasLength;

  /// e.g. "Size: XL  •  Weight: 2 kg  •  Length: 120 cm" (only what is set).
  String get specsLabel => [
    if (hasSize) 'Size: $size',
    if (hasWeight) 'Weight: $weight',
    if (hasLength) 'Length: $length',
  ].join('  •  ');

  //--------------------------------------------------
  // DELIVERY
  //--------------------------------------------------

  double deliveryFeeFor(DeliveryZone zone) =>
      zone == DeliveryZone.enugu ? deliveryFeeEnugu : deliveryFeeOutside;

  //--------------------------------------------------
  // COLOURS
  //--------------------------------------------------

  bool get hasColors => images.isNotEmpty && imageColors.isNotEmpty;

  ProductColor? colorAt(int imageIndex) =>
      (imageIndex >= 0 && imageIndex < imageColors.length)
      ? imageColors[imageIndex]
      : null;

  /// Distinct colours in the order they first appear, each with the images
  /// that show it.
  List<ColorOption> get colorOptions {
    final order = <String>[];
    final colors = <String, ProductColor>{};
    final indexes = <String, List<int>>{};

    for (var i = 0; i < images.length && i < imageColors.length; i++) {
      final c = imageColors[i];
      if (!colors.containsKey(c.key)) {
        order.add(c.key);
        colors[c.key] = c;
      }
      (indexes[c.key] ??= []).add(i);
    }

    return [
      for (final k in order)
        ColorOption(color: colors[k]!, imageIndexes: indexes[k]!),
    ];
  }
}
