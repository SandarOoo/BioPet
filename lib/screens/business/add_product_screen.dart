
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/business_service.dart';

class AddProductScreen extends StatefulWidget {
const AddProductScreen({super.key});

@override
State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
static const Color _emerald = Color(0xFF065F46);
static const Color _mint = Color(0xFFA7F3D0);
static const Color _cream = Color(0xFFFFF8E7);
static const Color _ink = Color(0xFF102A24);
static const Color _page = Color(0xFFF7FAF6);

final TextEditingController nameController =
TextEditingController();

final TextEditingController priceController =
TextEditingController();

final TextEditingController stockController =
TextEditingController();

final TextEditingController descriptionController =
TextEditingController();

final BusinessService service = BusinessService();

final ImagePicker _imagePicker = ImagePicker();

String category = 'Food';

bool loading = false;

// Keep the selected XFile only for preview/name.
XFile? _productImage;

// IMPORTANT:
// Store image bytes immediately after picking.
// This prevents PathNotFoundException caused by
// temporary cache files being deleted.
Uint8List? _productImageBytes;

@override
void dispose() {
nameController.dispose();
priceController.dispose();
stockController.dispose();
descriptionController.dispose();
super.dispose();
}

// ============================================================
// PICK PRODUCT IMAGE
// ============================================================

Future<void> _pickProductImage() async {
try {
final XFile? image = await _imagePicker.pickImage(
source: ImageSource.gallery,
imageQuality: 80,
maxWidth: 1200,
);

if (image == null) {
return;
}

// Read bytes IMMEDIATELY.
// Do not wait until addProduct().
final Uint8List bytes = await image.readAsBytes();

if (bytes.isEmpty) {
if (mounted) {
_showMessage(
'Selected image is empty.',
isError: true,
);
}
return;
}

if (!mounted) {
return;
}

setState(() {
_productImage = image;
_productImageBytes = bytes;
});

debugPrint(
'PRODUCT IMAGE SELECTED',
);

debugPrint(
'Image name: ${image.name}',
);

debugPrint(
'Image bytes: ${bytes.length}',
);

debugPrint(
'Image path: ${image.path}',
);
} catch (error) {
debugPrint(
'PICK PRODUCT IMAGE ERROR: $error',
);

if (mounted) {
_showMessage(
'Unable to select image: $error',
isError: true,
);
}
}
}

// ============================================================
// REMOVE PRODUCT IMAGE
// ============================================================

void _removeProductImage() {
if (loading) {
return;
}

setState(() {
_productImage = null;
_productImageBytes = null;
});
}

// ============================================================
// ADD PRODUCT
// ============================================================

Future<void> addProduct() async {
FocusScope.of(context).unfocus();

final String name =
nameController.text.trim();

final double? price =
double.tryParse(
priceController.text.trim(),
);

final int stock =
int.tryParse(
stockController.text.trim(),
) ??
0;

// ============================================================
// VALIDATION
// ============================================================

if (name.isEmpty) {
_showMessage(
'Please enter a product name.',
isError: true,
);
return;
}

if (price == null || price <= 0) {
_showMessage(
'Please enter a valid product price.',
isError: true,
);
return;
}

if (stock < 0) {
_showMessage(
'Stock cannot be negative.',
isError: true,
);
return;
}

// ============================================================
// IMAGE REQUIRED
// ============================================================

if (_productImage == null ||
_productImageBytes == null ||
_productImageBytes!.isEmpty) {
_showMessage(
'Please select a product image.',
isError: true,
);
return;
}

if (loading) {
return;
}

setState(() {
loading = true;
});

try {
debugPrint(
'ADDING PRODUCT...',
);

debugPrint(
'Product name: $name',
);

debugPrint(
'Category: $category',
);

debugPrint(
'Price: $price',
);

debugPrint(
'Stock: $stock',
);

debugPrint(
'Image name: ${_productImage!.name}',
);

debugPrint(
'Image bytes: ${_productImageBytes!.length}',
);

// ============================================================
// IMPORTANT
//
// Send image BYTES instead of temporary file PATH.
//
// Your BusinessService needs:
//
// Uint8List imageBytes
//
// instead of:
//
// XFile image
// ============================================================

final bool success =
await service.addProduct(
name: name,
category: category,
price: price,
stock: stock,
description:
descriptionController.text.trim(),
imageBytes: _productImageBytes!,
imageFileName:
_productImage!.name,
);

if (!mounted) {
return;
}

if (success) {
_showMessage(
'Product added successfully.',
);

Navigator.pop(
context,
true,
);
} else {
_showMessage(
'Unable to add the product. Please try again.',
isError: true,
);
}
} catch (error) {
debugPrint(
'ADD PRODUCT ERROR: $error',
);

if (mounted) {
_showMessage(
'Unable to add product: $error',
isError: true,
);
}
} finally {
if (mounted) {
setState(() {
loading = false;
});
}
}
}

// ============================================================
// MESSAGE
// ============================================================

void _showMessage(
String message, {
bool isError = false,
}) {
if (!mounted) {
return;
}

ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
content: Text(message),
behavior:
SnackBarBehavior.floating,
backgroundColor:
isError
? Colors.red.shade700
    : _ink,
),
);
}

// ============================================================
// INPUT DECORATION
// ============================================================

InputDecoration _decoration({
required String label,
required IconData icon,
String? hint,
String? prefixText,
}) {
return InputDecoration(
labelText: label,
hintText: hint,
prefixText: prefixText,
prefixIcon: Icon(
icon,
color: _emerald,
),
filled: true,
fillColor: Colors.white,
labelStyle: const TextStyle(
color: Color(0xFF55706A),
),
enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(18),
borderSide:
const BorderSide(
color: Color(0xFFDDE9E3),
),
),
focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(18),
borderSide:
const BorderSide(
color: _emerald,
width: 1.6,
),
),
errorBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(18),
borderSide:
const BorderSide(
color: Colors.redAccent,
),
),
contentPadding:
const EdgeInsets.symmetric(
horizontal: 16,
vertical: 18,
),
);
}

// ============================================================
// PRODUCT IMAGE PICKER
// ============================================================

Widget _buildProductImagePicker() {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Product image *',
style: TextStyle(
color: _ink,
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(height: 10),

GestureDetector(
onTap: loading
? null
    : _pickProductImage,
child: Container(
width: double.infinity,
height: 220,
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color:
_productImageBytes != null
? _emerald
    : const Color(
0xFFDDE9E3,
),
width:
_productImageBytes != null
? 1.6
    : 1,
),
),
child:
_productImageBytes == null
? _buildEmptyImagePicker()
    : _buildSelectedImage(),
),
),
],
);
}

// ============================================================
// EMPTY IMAGE PICKER
// ============================================================

Widget _buildEmptyImagePicker() {
return Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Container(
width: 60,
height: 60,
decoration:
BoxDecoration(
color:
_mint.withOpacity(0.35),
shape: BoxShape.circle,
),
child: const Icon(
Icons
    .add_photo_alternate_outlined,
color: _emerald,
size: 32,
),
),

const SizedBox(height: 12),

const Text(
'Add product image',
style: TextStyle(
color: _ink,
fontSize: 15,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(height: 5),

const Text(
'Tap to select an image from gallery',
style: TextStyle(
color:
Color(0xFF6C7E77),
fontSize: 12,
),
),
],
);
}

// ============================================================
// SELECTED IMAGE
// ============================================================

Widget _buildSelectedImage() {
return ClipRRect(
borderRadius:
BorderRadius.circular(19),
child: Stack(
fit: StackFit.expand,
children: [
// IMPORTANT:
// Use Image.memory instead of Image.file.
// This uses the bytes already loaded into memory.
Image.memory(
_productImageBytes!,
fit: BoxFit.cover,
gaplessPlayback: true,
),

// Dark overlay
Positioned(
left: 0,
right: 0,
bottom: 0,
child: Container(
padding:
const EdgeInsets.symmetric(
horizontal: 14,
vertical: 10,
),
color:
Colors.black.withOpacity(
0.55,
),
child: Text(
_productImage?.name ??
'Product image selected',
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color: Colors.white,
fontSize: 13,
fontWeight:
FontWeight.w700,
),
),
),
),

// Remove button
Positioned(
top: 10,
right: 10,
child: Container(
decoration:
BoxDecoration(
color:
Colors.black.withOpacity(
0.6,
),
shape:
BoxShape.circle,
),
child: IconButton(
onPressed: loading
? null
    : _removeProductImage,
icon: const Icon(
Icons.close_rounded,
color: Colors.white,
),
),
),
),
],
),
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(
BuildContext context,
) {
return Scaffold(
backgroundColor: _page,

appBar: AppBar(
backgroundColor: _page,
surfaceTintColor: _page,
elevation: 0,
title: const Text(
'Add Product',
style: TextStyle(
color: _ink,
fontWeight:
FontWeight.w800,
),
),
),

body: SafeArea(
child:
SingleChildScrollView(
padding:
const EdgeInsets.fromLTRB(
18,
8,
18,
32,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ==================================================
// HEADER
// ==================================================

Container(
width: double.infinity,
padding:
const EdgeInsets.all(22),
decoration:
BoxDecoration(
gradient:
const LinearGradient(
colors: [
_emerald,
Color(0xFF0B7A5B),
],
begin:
Alignment.topLeft,
end:
Alignment.bottomRight,
),
borderRadius:
BorderRadius.circular(
26,
),
boxShadow: [
BoxShadow(
color:
_emerald.withOpacity(
0.20,
),
blurRadius: 24,
offset:
const Offset(
0,
12,
),
),
],
),
child: Row(
children: [
Container(
width: 72,
height: 72,
decoration:
BoxDecoration(
color: _cream,
borderRadius:
BorderRadius
    .circular(
22,
),
),
child:
const Icon(
Icons
    .add_photo_alternate_rounded,
color: _emerald,
size: 36,
),
),

const SizedBox(
width: 16,
),

const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
'Create a new listing',
style:
TextStyle(
color:
Colors.white,
fontSize: 20,
fontWeight:
FontWeight
    .w800,
),
),
SizedBox(
height: 6,
),
Text(
'Add clear details so pet owners can find the right product.',
style:
TextStyle(
color:
Color(
0xFFD9FFF1,
),
height: 1.35,
),
),
],
),
),
],
),
),

const SizedBox(
height: 24,
),

// ==================================================
// PRODUCT INFORMATION
// ==================================================

const Text(
'Product information',
style: TextStyle(
color: _ink,
fontSize: 18,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(
height: 14,
),

_buildProductImagePicker(),

const SizedBox(
height: 18,
),

// NAME
TextField(
controller:
nameController,
textInputAction:
TextInputAction.next,
decoration:
_decoration(
label:
'Product name *',
hint:
'Example: Premium Cat Food',
icon: Icons
    .inventory_2_outlined,
),
),

const SizedBox(
height: 14,
),

// CATEGORY
DropdownButtonFormField<
String>(
value: category,
isExpanded: true,
icon:
const Icon(
Icons
    .keyboard_arrow_down_rounded,
),
items: const [
'Food',
'Medicine',
'Toy',
'Accessory',
]
    .map(
(
item,
) =>
DropdownMenuItem<
String>(
value: item,
child:
Text(item),
),
)
    .toList(),
onChanged: loading
? null
    : (
value,
) {
if (value !=
null) {
setState(
() =>
category =
value,
);
}
},
decoration:
_decoration(
label:
'Category',
icon: Icons
    .category_outlined,
),
),

const SizedBox(
height: 14,
),

// PRICE + STOCK
Row(
children: [
Expanded(
child:
TextField(
controller:
priceController,
keyboardType:
const TextInputType
    .numberWithOptions(
decimal: true,
),
textInputAction:
TextInputAction
    .next,
decoration:
_decoration(
label:
'Price *',
icon: Icons
    .payments_outlined,
prefixText:
'MMK ',
),
),
),

const SizedBox(
width: 12,
),

Expanded(
child:
TextField(
controller:
stockController,
keyboardType:
TextInputType
    .number,
textInputAction:
TextInputAction
    .next,
decoration:
_decoration(
label:
'Stock',
icon: Icons
    .layers_outlined,
),
),
),
],
),

const SizedBox(
height: 14,
),

// DESCRIPTION
TextField(
controller:
descriptionController,
minLines: 4,
maxLines: 6,
textInputAction:
TextInputAction
    .newline,
decoration:
_decoration(
label:
'Description',
hint:
'Size, ingredients, usage or other useful details',
icon: Icons
    .notes_rounded,
),
),

const SizedBox(
height: 18,
),

// TIP
Container(
padding:
const EdgeInsets
    .all(14),
decoration:
BoxDecoration(
color:
_mint.withOpacity(
0.38,
),
borderRadius:
BorderRadius.circular(
18,
),
border: Border.all(
color: _mint,
),
),
child: const Row(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Icon(
Icons
    .lightbulb_outline_rounded,
color: _emerald,
),
SizedBox(
width: 10,
),
Expanded(
child: Text(
'Use a clear product image and short product name. Keep stock updated to avoid cancelled orders.',
style:
TextStyle(
color: _ink,
height: 1.4,
),
),
),
],
),
),

const SizedBox(
height: 24,
),

// ADD BUTTON
SizedBox(
width:
double.infinity,
height: 56,
child:
ElevatedButton.icon(
onPressed: loading
? null
    : addProduct,
style:
ElevatedButton.styleFrom(
backgroundColor:
_emerald,
foregroundColor:
Colors.white,
disabledBackgroundColor:
_emerald.withOpacity(
0.45,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
18,
),
),
elevation: 0,
),
icon: loading
? const SizedBox(
width: 20,
height: 20,
child:
CircularProgressIndicator(
strokeWidth:
2.2,
color:
Colors.white,
),
)
    : const Icon(
Icons.add_rounded,
),
label: Text(
loading
? 'Adding product...'
    : 'Add Product',
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),
),
),
],
),
),
),
);
}
}
