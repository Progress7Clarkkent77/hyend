// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:hyend/controllers/uploadProductController.dart';

// class UploadProductsPage extends StatelessWidget {
//   UploadProductsPage({super.key});

//   final uploadCtrl = Get.put(UploadProductController());

//   static const Color _amber = Color(0xFFD97706);

//   //==================================================
//   // ACTIONS
//   //==================================================

//   /// Pick images, then ask for the colour of each new one in turn.
//   Future<void> _addImages() async {
//     final added = await uploadCtrl.pickImages();
//     if (added == 0) return;

//     final start = uploadCtrl.selectedImages.length - added;

//     for (var i = start; i < uploadCtrl.selectedImages.length; i++) {
//       final chosen = await _chooseColor(i);
//       if (!chosen) break; // dismissed — remaining images stay "unset"
//     }
//   }

//   Future<bool> _chooseColor(int index) async {
//     if (index < 0 || index >= uploadCtrl.selectedImages.length) return false;

//     final tag = await Get.bottomSheet<ImageColorTag>(
//       _ColorSheet(
//         image: uploadCtrl.selectedImages[index],
//         index: index,
//         total: uploadCtrl.selectedImages.length,
//         current: uploadCtrl.selectedColors[index],
//       ),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );

//     if (tag == null) return false;

//     uploadCtrl.setImageColor(index, tag);
//     return true;
//   }

//   //==================================================
//   // BUILD
//   //==================================================

//   InputDecoration _decoration(String label, {String? hint, String? prefix}) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       prefixText: prefix,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//     );
//   }

//   Widget _sectionLabel(String text, {String? subtitle}) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               text,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
//             ),
//             if (subtitle != null) ...[
//               const SizedBox(height: 2),
//               Text(
//                 subtitle,
//                 style: const TextStyle(fontSize: 12.5, color: Colors.black54),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Upload Product",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             _sectionLabel(
//               'Images & colours',
//               subtitle: 'Give every image its colour — customers will choose by colour.',
//             ),
//             Obx(() => _imagesArea()),
//             const SizedBox(height: 25),
//             TextField(
//               controller: uploadCtrl.nameCtrl,
//               decoration: _decoration("Product Name"),
//             ),
//             const SizedBox(height: 15),
//             Obx(
//               () => DropdownButtonFormField<String>(
//                 value: uploadCtrl.selectedCategory.value.isEmpty
//                     ? null
//                     : uploadCtrl.selectedCategory.value,
//                 decoration: _decoration("Category"),
//                 items: uploadCtrl.categories
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     uploadCtrl.selectedCategory.value = value;
//                   }
//                 },
//               ),
//             ),
//             const SizedBox(height: 15),
//             TextField(
//               controller: uploadCtrl.priceCtrl,
//               keyboardType: TextInputType.number,
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               decoration: _decoration("Price"),
//             ),
//             const SizedBox(height: 25),
//             _deliverySection(),
//             const SizedBox(height: 25),
//             TextField(
//               controller: uploadCtrl.stockCtrl,
//               keyboardType: TextInputType.number,
//               decoration: _decoration("Stock Quantity"),
//             ),
//             const SizedBox(height: 15),
//             TextField(
//               controller: uploadCtrl.descriptionCtrl,
//               maxLines: 2,
//               decoration: _decoration("Description"),
//             ),
//             const SizedBox(height: 25),
//             Obx(
//               () => SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                   ),
//                   onPressed: uploadCtrl.isLoading.value
//                       ? null
//                       : uploadCtrl.uploadProduct,
//                   child: uploadCtrl.isLoading.value
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                           "Upload Product",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   //==================================================
//   // IMAGES + COLOURS
//   //==================================================

//   Widget _imagesArea() {
//     final images = uploadCtrl.selectedImages;

//     if (images.isEmpty) {
//       return InkWell(
//         onTap: _addImages,
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           height: 180,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.cloud_upload_outlined, size: 40),
//                 SizedBox(height: 10),
//                 Text("Select Product Images"),
//                 SizedBox(height: 4),
//                 Text(
//                   "You'll choose a colour for each image",
//                   style: TextStyle(fontSize: 12, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     final missing = uploadCtrl.selectedColors.where((c) => c == null).length;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 200,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: images.length + 1,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               if (index == images.length) return _addMoreTile();
//               return _imageTile(index, images[index]);
//             },
//           ),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             Icon(
//               missing == 0 ? Icons.check_circle : Icons.info_outline,
//               size: 16,
//               color: missing == 0 ? const Color(0xFF16A34A) : _amber,
//             ),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Text(
//                 missing == 0
//                     ? 'All ${images.length} image(s) have a colour'
//                     : '$missing image(s) still need a colour — tap the image',
//                 style: TextStyle(
//                   fontSize: 12.5,
//                   fontWeight: FontWeight.w600,
//                   color: missing == 0 ? const Color(0xFF16A34A) : _amber,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _addMoreTile() {
//     return InkWell(
//       onTap: _addImages,
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         width: 120,
//         decoration: BoxDecoration(
//           color: const Color(0xFFF6F6F7),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: Colors.black12),
//         ),
//         child: const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.add_photo_alternate_outlined, size: 32),
//             SizedBox(height: 8),
//             Text(
//               'Add more',
//               style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _imageTile(int index, Uint8List bytes) {
//     final tag = uploadCtrl.selectedColors[index];

//     return GestureDetector(
//       onTap: () => _chooseColor(index),
//       child: Container(
//         width: 150,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color: tag == null ? _amber : Colors.black12,
//             width: tag == null ? 1.6 : 1,
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(17),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
//               // remove
//               Positioned(
//                 right: 6,
//                 top: 6,
//                 child: GestureDetector(
//                   onTap: () => uploadCtrl.removeImage(index),
//                   child: const CircleAvatar(
//                     radius: 13,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.close, size: 15, color: Colors.black87),
//                   ),
//                 ),
//               ),
//               // colour pill
//               Positioned(
//                 left: 8,
//                 right: 8,
//                 bottom: 8,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 7,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.95),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Color(0x26000000),
//                         blurRadius: 10,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       if (tag != null)
//                         Container(
//                           width: 16,
//                           height: 16,
//                           decoration: BoxDecoration(
//                             color: tag.color,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.black26),
//                           ),
//                         )
//                       else
//                         const Icon(
//                           Icons.palette_outlined,
//                           size: 16,
//                           color: _amber,
//                         ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           tag?.name ?? 'Set colour',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                             color: tag == null ? _amber : Colors.black87,
//                           ),
//                         ),
//                       ),
//                       const Icon(
//                         Icons.edit_outlined,
//                         size: 13,
//                         color: Colors.black45,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   //==================================================
//   // DELIVERY
//   //==================================================

//   Widget _deliverySection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F8F9),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.black12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionLabel(
//             'Delivery fees',
//             subtitle:
//                 'Customers choose where the order is going. '
//                 'Leave a field empty for free delivery.',
//           ),
//           Row(
//             children: [
//               const Icon(Icons.location_on_outlined, size: 18),
//               const SizedBox(width: 6),
//               const Text(
//                 'Within Enugu State',
//                 style: TextStyle(fontWeight: FontWeight.w700),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: uploadCtrl.deliveryFeeEnuguCtrl,
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             decoration: _decoration(
//               "Delivery fee (Enugu)",
//               prefix: '₦ ',
//             ).copyWith(filled: true, fillColor: Colors.white),
//           ),
//           const SizedBox(height: 18),
//           Row(
//             children: [
//               const Icon(Icons.public_rounded, size: 18),
//               const SizedBox(width: 6),
//               const Text(
//                 'Outside Enugu State',
//                 style: TextStyle(fontWeight: FontWeight.w700),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: uploadCtrl.deliveryFeeOutsideCtrl,
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             decoration: _decoration(
//               "Delivery fee (Outside Enugu)",
//               prefix: '₦ ',
//             ).copyWith(filled: true, fillColor: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
// }

// //==================================================
// // COLOUR SHEET
// //==================================================

// class _ColorSheet extends StatefulWidget {
//   const _ColorSheet({
//     required this.image,
//     required this.index,
//     required this.total,
//     required this.current,
//   });

//   final Uint8List image;
//   final int index;
//   final int total;
//   final ImageColorTag? current;

//   @override
//   State<_ColorSheet> createState() => _ColorSheetState();
// }

// class _ColorSheetState extends State<_ColorSheet> {
//   final TextEditingController _nameCtrl = TextEditingController();
//   final TextEditingController _hexCtrl = TextEditingController();

//   String? _error;

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _hexCtrl.dispose();
//     super.dispose();
//   }

//   Color? get _hexPreview {
//     final hex = _hexCtrl.text.trim().replaceAll('#', '');
//     if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
//     return Color(int.parse('FF$hex', radix: 16));
//   }

//   void _useCustom() {
//     final preview = _hexPreview;

//     if (preview == null) {
//       setState(() => _error = 'Enter a 6-digit colour code, e.g. 1E88E5');
//       return;
//     }

//     final hex = _hexCtrl.text.trim().replaceAll('#', '').toUpperCase();
//     final name = _nameCtrl.text.trim().isEmpty
//         ? '#$hex'
//         : _nameCtrl.text.trim();

//     Get.back(
//       result: ImageColorTag(name: name, value: preview.value),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selected = widget.current?.value;

//     return AnimatedPadding(
//       duration: const Duration(milliseconds: 150),
//       padding: MediaQuery.of(context).viewInsets,
//       child: Container(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.88,
//         ),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
//         ),
//         child: SafeArea(
//           top: false,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 42,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.black12,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//                 Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(14),
//                       child: Image.memory(
//                         widget.image,
//                         width: 58,
//                         height: 58,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Colour of image ${widget.index + 1} of ${widget.total}',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                           const SizedBox(height: 3),
//                           const Text(
//                             'Customers will pick this colour on the product page.',
//                             style: TextStyle(
//                               fontSize: 12.5,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Wrap(
//                   spacing: 12,
//                   runSpacing: 14,
//                   children: [
//                     for (final preset in kColorPresets)
//                       _swatch(preset, selected == preset.value),
//                   ],
//                 ),
//                 const SizedBox(height: 22),
//                 const Divider(height: 1),
//                 const SizedBox(height: 18),
//                 const Text(
//                   'Custom colour',
//                   style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _nameCtrl,
//                         textCapitalization: TextCapitalization.words,
//                         decoration: InputDecoration(
//                           labelText: 'Name',
//                           hintText: 'e.g. Wine Red',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     SizedBox(
//                       width: 140,
//                       child: TextField(
//                         controller: _hexCtrl,
//                         maxLength: 7,
//                         onChanged: (_) => setState(() => _error = null),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(
//                             RegExp(r'[0-9a-fA-F#]'),
//                           ),
//                         ],
//                         decoration: InputDecoration(
//                           labelText: 'Code',
//                           hintText: '1E88E5',
//                           counterText: '',
//                           prefixText: '#',
//                           suffixIcon: _hexPreview == null
//                               ? null
//                               : Padding(
//                                   padding: const EdgeInsets.all(12),
//                                   child: DecoratedBox(
//                                     decoration: BoxDecoration(
//                                       color: _hexPreview,
//                                       shape: BoxShape.circle,
//                                       border: Border.all(color: Colors.black26),
//                                     ),
//                                   ),
//                                 ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (_error != null) ...[
//                   const SizedBox(height: 8),
//                   Text(
//                     _error!,
//                     style: const TextStyle(
//                       color: Color(0xFFE5484D),
//                       fontSize: 12.5,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 14),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _useCustom,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text(
//                       'Use custom colour',
//                       style: TextStyle(fontWeight: FontWeight.w700),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _swatch(ImageColorTag preset, bool isSelected) {
//     final dark =
//         ThemeData.estimateBrightnessForColor(preset.color) == Brightness.dark;

//     return GestureDetector(
//       onTap: () => Get.back(result: preset),
//       child: SizedBox(
//         width: 60,
//         child: Column(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               width: 48,
//               height: 48,
//               padding: const EdgeInsets.all(3),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isSelected ? Colors.black : Colors.transparent,
//                   width: 2,
//                 ),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: preset.color,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.black12),
//                 ),
//                 child: isSelected
//                     ? Icon(
//                         Icons.check_rounded,
//                         size: 20,
//                         color: dark ? Colors.white : Colors.black,
//                       )
//                     : null,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               preset.name,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/uploadProductController.dart';
import 'package:hyend/pages/app_palette.dart';

class UploadProductsPage extends StatelessWidget {
  UploadProductsPage({super.key});

  final uploadCtrl = Get.put(UploadProductController());

  //==================================================
  // ACTIONS
  //==================================================

  /// Pick images, then ask for the colour of each new one in turn.
  Future<void> _addImages() async {
    final added = await uploadCtrl.pickImages();
    if (added == 0) return;

    final start = uploadCtrl.selectedImages.length - added;

    for (var i = start; i < uploadCtrl.selectedImages.length; i++) {
      final chosen = await _chooseColor(i);
      if (!chosen) break; // dismissed — remaining images stay "unset"
    }
  }

  Future<bool> _chooseColor(int index) async {
    if (index < 0 || index >= uploadCtrl.selectedImages.length) return false;

    final tag = await Get.bottomSheet<ImageColorTag>(
      _ColorSheet(
        image: uploadCtrl.selectedImages[index],
        index: index,
        total: uploadCtrl.selectedImages.length,
        current: uploadCtrl.selectedColors[index],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (tag == null) return false;

    uploadCtrl.setImageColor(index, tag);
    return true;
  }

  //==================================================
  // BUILD
  //==================================================

  Widget _sectionLabel(AppPalette p, String text, {String? subtitle}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: p.text,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12.5, color: p.muted)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = AppPalette.current();

      return Scaffold(
        backgroundColor: p.bg,
        appBar: p.appBar('Upload Product'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _sectionLabel(
                p,
                'Images & colours',
                subtitle: 'Give every image its colour — customers will choose by colour.',
              ),
              Obx(() => _imagesArea(p)),
              const SizedBox(height: 25),
              TextField(
                controller: uploadCtrl.nameCtrl,
                style: p.fieldStyle,
                cursorColor: p.text,
                decoration: p.input('Product Name'),
              ),
              const SizedBox(height: 15),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: uploadCtrl.selectedCategory.value.isEmpty
                      ? null
                      : uploadCtrl.selectedCategory.value,
                  dropdownColor: p.surface,
                  style: p.fieldStyle,
                  iconEnabledColor: p.muted,
                  decoration: p.input('Category'),
                  items: uploadCtrl.categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      uploadCtrl.selectedCategory.value = value;
                    }
                  },
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: uploadCtrl.priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: p.fieldStyle,
                cursorColor: p.text,
                decoration: p.input('Price'),
              ),
              const SizedBox(height: 25),
              _deliverySection(p),
              const SizedBox(height: 25),
              TextField(
                controller: uploadCtrl.stockCtrl,
                keyboardType: TextInputType.number,
                style: p.fieldStyle,
                cursorColor: p.text,
                decoration: p.input('Stock Quantity'),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: uploadCtrl.descriptionCtrl,
                maxLines: 2,
                style: p.fieldStyle,
                cursorColor: p.text,
                decoration: p.input('Description'),
              ),
              const SizedBox(height: 25),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: p.primaryButton(),
                    onPressed: uploadCtrl.isLoading.value
                        ? null
                        : uploadCtrl.uploadProduct,
                    child: uploadCtrl.isLoading.value
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: p.onAccent,
                            ),
                          )
                        : const Text(
                            'Upload Product',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //==================================================
  // IMAGES + COLOURS
  //==================================================

  Widget _imagesArea(AppPalette p) {
    final images = uploadCtrl.selectedImages;

    if (images.isEmpty) {
      return InkWell(
        onTap: _addImages,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(color: p.borderStrong),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 40, color: p.text),
                const SizedBox(height: 10),
                Text(
                  'Select Product Images',
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "You'll choose a colour for each image",
                  style: TextStyle(fontSize: 12, color: p.muted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final missing = uploadCtrl.selectedColors.where((c) => c == null).length;
    final statusColor = missing == 0 ? p.success : p.warning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              if (index == images.length) return _addMoreTile(p);
              return _imageTile(p, index, images[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              missing == 0 ? Icons.check_circle : Icons.info_outline,
              size: 16,
              color: statusColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                missing == 0
                    ? 'All ${images.length} image(s) have a colour'
                    : '$missing image(s) still need a colour — tap the image',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _addMoreTile(AppPalette p) {
    return InkWell(
      onTap: _addImages,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: p.tile,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 32, color: p.text),
            const SizedBox(height: 8),
            Text(
              'Add more',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageTile(AppPalette p, int index, Uint8List bytes) {
    final tag = uploadCtrl.selectedColors[index];

    return GestureDetector(
      onTap: () => _chooseColor(index),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: tag == null ? p.warning : p.border,
            width: tag == null ? 1.6 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
              // remove — sits on top of the photo, so it stays white in both themes
              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: () => uploadCtrl.removeImage(index),
                  child: const CircleAvatar(
                    radius: 13,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, size: 15, color: Colors.black87),
                  ),
                ),
              ),
              // colour pill
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (tag != null)
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: tag.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.borderStrong),
                          ),
                        )
                      else
                        Icon(
                          Icons.palette_outlined,
                          size: 16,
                          color: p.warning,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tag?.name ?? 'Set colour',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: tag == null ? p.warning : p.text,
                          ),
                        ),
                      ),
                      Icon(Icons.edit_outlined, size: 13, color: p.muted),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //==================================================
  // DELIVERY
  //==================================================

  Widget _deliverySection(AppPalette p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: p.cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(
            p,
            'Delivery fees',
            subtitle:
                'Customers choose where the order is going. '
                'Leave a field empty for free delivery.',
          ),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: p.text),
              const SizedBox(width: 6),
              Text(
                'Within Enugu State',
                style: TextStyle(fontWeight: FontWeight.w700, color: p.text),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: uploadCtrl.deliveryFeeEnuguCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: p.fieldStyle,
            cursorColor: p.text,
            decoration: p.input(
              'Delivery fee (Enugu)',
              prefix: '₦ ',
              fill: p.tile,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.public_rounded, size: 18, color: p.text),
              const SizedBox(width: 6),
              Text(
                'Outside Enugu State',
                style: TextStyle(fontWeight: FontWeight.w700, color: p.text),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: uploadCtrl.deliveryFeeOutsideCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: p.fieldStyle,
            cursorColor: p.text,
            decoration: p.input(
              'Delivery fee (Outside Enugu)',
              prefix: '₦ ',
              fill: p.tile,
            ),
          ),
        ],
      ),
    );
  }
}

//==================================================
// COLOUR SHEET
//==================================================

class _ColorSheet extends StatefulWidget {
  const _ColorSheet({
    required this.image,
    required this.index,
    required this.total,
    required this.current,
  });

  final Uint8List image;
  final int index;
  final int total;
  final ImageColorTag? current;

  @override
  State<_ColorSheet> createState() => _ColorSheetState();
}

class _ColorSheetState extends State<_ColorSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _hexCtrl = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hexCtrl.dispose();
    super.dispose();
  }

  Color? get _hexPreview {
    final hex = _hexCtrl.text.trim().replaceAll('#', '');
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _useCustom() {
    final preview = _hexPreview;

    if (preview == null) {
      setState(() => _error = 'Enter a 6-digit colour code, e.g. 1E88E5');
      return;
    }

    final hex = _hexCtrl.text.trim().replaceAll('#', '').toUpperCase();
    final name = _nameCtrl.text.trim().isEmpty
        ? '#$hex'
        : _nameCtrl.text.trim();

    Get.back(
      result: ImageColorTag(name: name, value: preview.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.current?.value;

    // The sheet is shown above the page, so it has to listen to the theme itself.
    return Obx(() {
      final p = AppPalette.current();

      return AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: p.sheetDecoration,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  p.sheetHandle,
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          widget.image,
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Colour of image ${widget.index + 1} of ${widget.total}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: p.text,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Customers will pick this colour on the product page.',
                              style: TextStyle(fontSize: 12.5, color: p.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 14,
                    children: [
                      for (final preset in kColorPresets)
                        _swatch(p, preset, selected == preset.value),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Divider(height: 1, color: p.border),
                  const SizedBox(height: 18),
                  Text(
                    'Custom colour',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          style: p.fieldStyle,
                          cursorColor: p.text,
                          decoration: p.input(
                            'Name',
                            hint: 'e.g. Wine Red',
                            radius: 14,
                            fill: p.tile,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: _hexCtrl,
                          maxLength: 7,
                          onChanged: (_) => setState(() => _error = null),
                          style: p.fieldStyle,
                          cursorColor: p.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9a-fA-F#]'),
                            ),
                          ],
                          decoration: p.input(
                            'Code',
                            hint: '1E88E5',
                            prefix: '#',
                            counterText: '',
                            radius: 14,
                            fill: p.tile,
                            suffixIcon: _hexPreview == null
                                ? null
                                : Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: _hexPreview,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: p.borderStrong,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: p.danger,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _useCustom,
                      style: p.primaryButton(radius: 14),
                      child: const Text(
                        'Use custom colour',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _swatch(AppPalette p, ImageColorTag preset, bool isSelected) {
    final dark =
        ThemeData.estimateBrightnessForColor(preset.color) == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.back(result: preset),
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? p.text : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: preset.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.borderStrong),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: dark ? Colors.white : Colors.black,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              preset.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: p.text,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
