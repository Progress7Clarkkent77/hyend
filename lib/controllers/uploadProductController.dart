import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/storeConfig.dart';
import 'package:image_picker/image_picker.dart';

//==================================================
// COLOUR TAG (one per product image)
//==================================================

class ImageColorTag {
  const ImageColorTag({required this.name, required this.value});

  /// Display name shown to customers, e.g. "Navy Blue".
  final String name;

  /// ARGB value, e.g. 0xFF1E88E5.
  final int value;

  Color get color => Color(value);

  /// "#RRGGBB" — what is stored in Firestore.
  String get hex =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  Map<String, dynamic> toMap() => {'name': name, 'hex': hex};
}

/// Quick-pick colours shown in the colour sheet.
const List<ImageColorTag> kColorPresets = [
  ImageColorTag(name: 'Black', value: 0xFF111111),
  ImageColorTag(name: 'White', value: 0xFFFFFFFF),
  ImageColorTag(name: 'Grey', value: 0xFF9E9E9E),
  ImageColorTag(name: 'Silver', value: 0xFFC0C0C0),
  ImageColorTag(name: 'Red', value: 0xFFE53935),
  ImageColorTag(name: 'Maroon', value: 0xFF7B1E2B),
  ImageColorTag(name: 'Pink', value: 0xFFEC407A),
  ImageColorTag(name: 'Orange', value: 0xFFFB8C00),
  ImageColorTag(name: 'Yellow', value: 0xFFFDD835),
  ImageColorTag(name: 'Gold', value: 0xFFD4AF37),
  ImageColorTag(name: 'Green', value: 0xFF43A047),
  ImageColorTag(name: 'Teal', value: 0xFF00897B),
  ImageColorTag(name: 'Blue', value: 0xFF1E88E5),
  ImageColorTag(name: 'Navy', value: 0xFF0D2A57),
  ImageColorTag(name: 'Purple', value: 0xFF8E24AA),
  ImageColorTag(name: 'Brown', value: 0xFF6D4C41),
  ImageColorTag(name: 'Beige', value: 0xFFE8D8C0),
  ImageColorTag(name: 'Lavender', value: 0xFFB57EDC),
  ImageColorTag(name: 'Cyan', value: 0xFF00ACC1),
  ImageColorTag(name: 'Lime', value: 0xFF7CB342),
  ImageColorTag(name: 'Coral', value: 0xFFFF7043),
  ImageColorTag(name: 'Turquoise', value: 0xFF26A69A),
  ImageColorTag(name: 'Indigo', value: 0xFF3F2A6D),
  //ImageColorTag(name: 'Lavender', value: 0xFFB57EDC),
  // ImageColorTag(name: 'Cyan', value: 0xFF00ACC1),
  //ImageColorTag(name: 'Lime', value: 0xFF7CB342),
  //ImageColorTag(name: 'Coral', value: 0xFFFF7043),
];

class UploadProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  static const int maxImages = 10;

  final RxBool isLoading = false.obs;

  //==================================================
  // FORM CONTROLLERS
  //==================================================

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();

  /// Delivery inside Enugu State.
  final TextEditingController deliveryFeeEnuguCtrl = TextEditingController();

  /// Delivery to any other state.
  final TextEditingController deliveryFeeOutsideCtrl = TextEditingController();

  //==================================================
  // IMAGES
  //==================================================

  /// Used for preview in the UI.
  final RxList<Uint8List> selectedImages = <Uint8List>[].obs;

  /// Stored in Firestore.
  final RxList<String> imageBase64List = <String>[].obs;

  /// Colour of each image — same order/length as [selectedImages].
  /// null means the admin has not chosen one yet.
  final RxList<ImageColorTag?> selectedColors = <ImageColorTag?>[].obs;

  //==================================================
  // CATEGORY
  //==================================================

  final RxList<String> categories = <String>[
    'Electronics',
    'Fashion',
    'Beauty',
    'Groceries',
    'Phones & A..',
    'Computers',
    'Home & Kitchen',
    'Books',
    'Foods',
    'Sports',
    'Automobile',
  ].obs;

  final RxString selectedCategory = ''.obs;

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    deliveryFeeEnuguCtrl.dispose();
    deliveryFeeOutsideCtrl.dispose();
    super.onClose();
  }

  //==================================================
  // IMAGES
  //==================================================

  /// Adds the chosen images to the ones already picked.
  /// Returns how many new images were added.
  Future<int> pickImages() async {
    try {
      final remaining = maxImages - selectedImages.length;

      if (remaining <= 0) {
        Get.snackbar('Images', 'You can add up to $maxImages images.');
        return 0;
      }

      final files = await _picker.pickMultiImage(imageQuality: 80);

      if (files.isEmpty) return 0;

      final chosen = files.take(remaining).toList();

      if (files.length > remaining) {
        Get.snackbar(
          'Images',
          'Only the first $remaining image(s) were added (max $maxImages).',
        );
      }

      final previews = <Uint8List>[];
      final encoded = <String>[];
      var totalBytes = 0;

      for (final file in chosen) {
        final bytes = await file.readAsBytes();
        totalBytes += bytes.length;
        previews.add(bytes);
        encoded.add(base64Encode(bytes));
      }

      // base64 inflates size by ~33%; guard the 1 MiB document limit
      // across the images already added plus the new ones.
      final existing = imageBase64List.fold<int>(0, (sum, e) => sum + e.length);
      final incoming = encoded.fold<int>(0, (sum, e) => sum + e.length);

      if (existing + incoming > StoreConfig.maxImagePayloadBytes) {
        Get.snackbar(
          'Images Too Large',
          'The new images total ${(totalBytes / 1024).round()} KB. '
              'Please choose fewer or smaller images.',
        );
        return 0;
      }

      selectedImages.addAll(previews);
      imageBase64List.addAll(encoded);
      selectedColors.addAll(List<ImageColorTag?>.filled(previews.length, null));

      return previews.length;
    } catch (e) {
      Get.snackbar('Images', e.toString());
      return 0;
    }
  }

  void setImageColor(int index, ImageColorTag tag) {
    if (index < 0 || index >= selectedColors.length) return;
    selectedColors[index] = tag;
  }

  void removeImage(int index) {
    if (index < 0 || index >= selectedImages.length) return;

    selectedImages.removeAt(index);
    imageBase64List.removeAt(index);
    selectedColors.removeAt(index);
  }

  //==================================================
  // VALIDATION
  //==================================================

  bool _validFee(String text) {
    if (text.isEmpty) return true; // empty = free delivery
    final v = double.tryParse(text);
    return v != null && v >= 0;
  }

  bool validateForm() {
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Product', 'Product name required');
      return false;
    }

    if (selectedCategory.value.isEmpty) {
      Get.snackbar('Category', 'Please select a category');
      return false;
    }

    final price = double.tryParse(priceCtrl.text.trim());

    if (priceCtrl.text.trim().isEmpty) {
      Get.snackbar('Price', 'Enter product price');
      return false;
    }

    if (price == null || price <= 0) {
      Get.snackbar('Price', 'Invalid price');
      return false;
    }

    // every image needs a colour so customers can choose by colour
    for (var i = 0; i < selectedColors.length; i++) {
      if (selectedColors[i] == null) {
        Get.snackbar('Image colour', 'Choose a colour for image ${i + 1}');
        return false;
      }
    }

    if (!_validFee(deliveryFeeEnuguCtrl.text.trim())) {
      Get.snackbar('Delivery Fee', 'Invalid delivery fee within Enugu State');
      return false;
    }

    if (!_validFee(deliveryFeeOutsideCtrl.text.trim())) {
      Get.snackbar('Delivery Fee', 'Invalid delivery fee outside Enugu State');
      return false;
    }

    final stockText = stockCtrl.text.trim();
    if (stockText.isNotEmpty && (int.tryParse(stockText) ?? -1) < 0) {
      Get.snackbar('Stock', 'Invalid stock quantity');
      return false;
    }

    return true;
  }

  //==================================================
  // UPLOAD
  //==================================================

  Future<void> uploadProduct() async {
    if (isLoading.value || !validateForm()) return;

    try {
      isLoading.value = true;

      final originalPrice = double.parse(priceCtrl.text.trim());
      final platformFee = originalPrice * StoreConfig.platformFeeRate;
      final sellingPrice = originalPrice + platformFee;

      final feeEnugu = double.tryParse(deliveryFeeEnuguCtrl.text.trim()) ?? 0;
      final feeOutside =
          double.tryParse(deliveryFeeOutsideCtrl.text.trim()) ?? 0;

      await _firestore.collection(StoreConfig.productsCollection).add({
        // Product info
        'name': nameCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'category': selectedCategory.value,

        // Pricing
        'price': sellingPrice,
        'originalPrice': originalPrice,
        'platformFee': platformFee,

        // Delivery (two zones)
        'deliveryFeeEnugu': feeEnugu,
        'deliveryFeeOutside': feeOutside,
        // legacy single fee — kept so existing screens keep working
        'deliveryFee': feeEnugu,

        // Stock
        'stock': int.tryParse(stockCtrl.text.trim()) ?? 0,

        // Images + the colour of each image (same order)
        'images': imageBase64List.toList(),
        'imageColors': selectedColors.map((c) => c!.toMap()).toList(),

        // Status
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      clearForm();

      Get.snackbar('Success', 'Product uploaded successfully');
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    nameCtrl.clear();
    descriptionCtrl.clear();
    priceCtrl.clear();
    stockCtrl.clear();
    deliveryFeeEnuguCtrl.clear();
    deliveryFeeOutsideCtrl.clear();

    selectedImages.clear();
    imageBase64List.clear();
    selectedColors.clear();

    selectedCategory.value = '';
  }
}
