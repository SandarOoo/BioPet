
import 'dart:convert';
import 'dart:typed_data';

import 'package:biopet/models/product.dart';
import 'package:flutter/material.dart';

import '../../services/business_service.dart';
import 'add_product_screen.dart';

class SellerProductsScreen extends StatefulWidget {
const SellerProductsScreen({super.key});

@override
State<SellerProductsScreen> createState() =>
_SellerProductsScreenState();
}

class _SellerProductsScreenState
extends State<SellerProductsScreen> {
static const Color _emerald =
Color(0xFF065F46);

static const Color _mint =
Color(0xFFA7F3D0);

static const Color _cream =
Color(0xFFFFF8E7);

static const Color _ink =
Color(0xFF102A24);

static const Color _page =
Color(0xFFF7FAF6);

final BusinessService service =
BusinessService();

List<Product> products = [];

bool loading = true;

String? deletingId;

String? error;

@override
void initState() {
super.initState();
loadProducts();
}

// ============================================================
// LOAD PRODUCTS
// ============================================================

Future<void> loadProducts() async {
if (mounted) {
setState(() {
loading = true;
error = null;
});
}

try {
final result =
await service.getProducts();

if (!mounted) return;

setState(() {
products = result;
loading = false;
});
} catch (exception) {
debugPrint(
'LOAD PRODUCTS ERROR => $exception',
);

if (!mounted) return;

setState(() {
loading = false;
error = exception.toString();
});
}
}

// ============================================================
// OPEN ADD PRODUCT
// ============================================================

Future<void> openAddProduct() async {
await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (_) =>
const AddProductScreen(),
),
);

if (!mounted) return;

await loadProducts();
}

// ============================================================
// CONFIRM DELETE
// ============================================================

Future<void> confirmDelete(
Product product,
) async {
final confirmed =
await showModalBottomSheet<bool>(
context: context,
backgroundColor:
Colors.transparent,
builder: (context) {
return SafeArea(
child: Container(
margin:
const EdgeInsets.all(14),
padding:
const EdgeInsets.fromLTRB(
20,
14,
20,
20,
),
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(
26,
),
),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
Container(
width: 46,
height: 5,
decoration:
BoxDecoration(
color:
const Color(
0xFFD9E2DE,
),
borderRadius:
BorderRadius.circular(
99,
),
),
),

const SizedBox(
height: 20,
),

Container(
width: 62,
height: 62,
decoration:
BoxDecoration(
color:
Colors.red.shade50,
shape:
BoxShape.circle,
),
child: Icon(
Icons
    .delete_outline_rounded,
color:
Colors.red.shade700,
size: 31,
),
),

const SizedBox(
height: 15,
),

const Text(
'Delete product?',
style:
TextStyle(
color: _ink,
fontSize: 21,
fontWeight:
FontWeight.w900,
),
),

const SizedBox(
height: 7,
),

Text(
'“${product.name}” will be removed from your shop.',
textAlign:
TextAlign.center,
style:
const TextStyle(
color:
Color(0xFF60736E),
height: 1.4,
),
),

const SizedBox(
height: 22,
),

Row(
children: [
Expanded(
child:
OutlinedButton(
onPressed: () {
Navigator.pop(
context,
false,
);
},
style:
OutlinedButton
    .styleFrom(
foregroundColor:
_ink,
side:
const BorderSide(
color:
Color(
0xFFD8E3DE,
),
),
padding:
const EdgeInsets
    .symmetric(
vertical: 14,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
16,
),
),
),
child:
const Text(
'Cancel',
style:
TextStyle(
fontWeight:
FontWeight
    .w800,
),
),
),
),

const SizedBox(
width: 11,
),

Expanded(
child:
ElevatedButton(
onPressed: () {
Navigator.pop(
context,
true,
);
},
style:
ElevatedButton
    .styleFrom(
backgroundColor:
Colors.red
    .shade700,
foregroundColor:
Colors.white,
elevation: 0,
padding:
const EdgeInsets
    .symmetric(
vertical: 14,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
16,
),
),
),
child:
const Text(
'Delete',
style:
TextStyle(
fontWeight:
FontWeight
    .w800,
),
),
),
),
],
),
],
),
),
);
},
);

if (confirmed == true) {
await deleteProduct(
product.id,
);
}
}

// ============================================================
// DELETE PRODUCT
// ============================================================

Future<void> deleteProduct(
String id,
) async {
if (deletingId != null) return;

setState(() {
deletingId = id;
});

try {
final success =
await service.deleteProduct(
id,
);

if (!mounted) return;

if (success) {
_showMessage(
'Product deleted.',
);

await loadProducts();
} else {
_showMessage(
'Unable to delete the product.',
);
}
} catch (exception) {
if (mounted) {
_showMessage(
'Delete failed: $exception',
);
}
} finally {
if (mounted) {
setState(() {
deletingId = null;
});
}
}
}

// ============================================================
// MESSAGE
// ============================================================

void _showMessage(
String message,
) {
ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
content:
Text(message),
behavior:
SnackBarBehavior.floating,
backgroundColor:
_ink,
),
);
}

// ============================================================
// FORMAT PRICE
// ============================================================

String _formatPrice(
dynamic price,
) {
if (price is num) {
final whole =
price.toStringAsFixed(0);

return '$whole MMK';
}

return '$price MMK';
}

// ============================================================
// CATEGORY ICON
// ============================================================

IconData _categoryIcon(
String category,
) {
switch (
category.toLowerCase()) {
case 'food':
return Icons
    .restaurant_rounded;

case 'medicine':
return Icons
    .medication_outlined;

case 'toy':
return Icons
    .sports_baseball_outlined;

case 'accessory':
return Icons.pets_rounded;

default:
return Icons
    .inventory_2_outlined;
}
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
'My Products',
style:
TextStyle(
color: _ink,
fontWeight:
FontWeight.w800,
),
),

actions: [
IconButton(
tooltip: 'Refresh',
onPressed:
loading
? null
    : loadProducts,
icon:
const Icon(
Icons
    .refresh_rounded,
color: _ink,
),
),

const SizedBox(
width: 6,
),
],
),

floatingActionButton:
FloatingActionButton
    .extended(
onPressed:
openAddProduct,
backgroundColor:
_emerald,
foregroundColor:
Colors.white,
elevation: 5,

icon:
const Icon(
Icons.add_rounded,
),

label:
const Text(
'Add Product',
style:
TextStyle(
fontWeight:
FontWeight.w800,
),
),
),

body:
RefreshIndicator(
onRefresh:
loadProducts,
color: _emerald,
child:
_buildBody(),
),
);
}

// ============================================================
// BODY
// ============================================================

Widget _buildBody() {
// LOADING
if (loading &&
products.isEmpty) {
return ListView(
physics:
const AlwaysScrollableScrollPhysics(),
children: const [
SizedBox(
height: 520,
child:
Center(
child:
CircularProgressIndicator(
color: _emerald,
),
),
),
],
);
}

// ERROR
if (error != null &&
products.isEmpty) {
return ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding:
const EdgeInsets.all(22),
children: [
const SizedBox(
height: 100,
),

_EmptyState(
icon:
Icons.cloud_off_rounded,
title:
'Products could not be loaded',
subtitle:
'Check your connection and try again.',
buttonText:
'Try Again',
onPressed:
loadProducts,
),
],
);
}

// EMPTY
if (products.isEmpty) {
return ListView(
physics:
const AlwaysScrollableScrollPhysics(),
padding:
const EdgeInsets.all(22),
children: [
const SizedBox(
height: 80,
),

_EmptyState(
icon:
Icons
    .inventory_2_outlined,
title:
'No products yet',
subtitle:
'Add your first pet product and start building your shop catalogue.',
buttonText:
'Add First Product',
onPressed:
openAddProduct,
),
],
);
}

// PRODUCTS
return ListView(
physics:
const AlwaysScrollableScrollPhysics(),

padding:
const EdgeInsets.fromLTRB(
16,
6,
16,
100,
),

children: [
Container(
padding:
const EdgeInsets.all(
18,
),

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
24,
),
),

child: Row(
children: [
Container(
width: 55,
height: 55,

decoration:
BoxDecoration(
color: _cream,
borderRadius:
BorderRadius.circular(
18,
),
),

child:
const Icon(
Icons
    .inventory_rounded,
color:
_emerald,
size: 29,
),
),

const SizedBox(
width: 14,
),

Expanded(
child:
Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [
Text(
'${products.length} ${products.length == 1 ? 'product' : 'products'}',

style:
const TextStyle(
color:
Colors.white,
fontSize: 20,
fontWeight:
FontWeight
    .w900,
),
),

const SizedBox(
height: 3,
),

const Text(
'Keep prices and stock up to date.',
style:
TextStyle(
color:
Color(
0xFFD9FFF1,
),
),
),
],
),
),
],
),
),

const SizedBox(
height: 18,
),

...products.map(
(product) =>
_ProductCard(
product:
product,

icon:
_categoryIcon(
product.category,
),

formattedPrice:
_formatPrice(
product.price,
),

deleting:
deletingId ==
product.id,

onEdit: () {
_showMessage(
'Product editing can be connected in the next step.',
);
},

onDelete: () {
confirmDelete(
product,
);
},
),
),
],
);
}
}

// ============================================================
// PRODUCT CARD
// ============================================================

class _ProductCard
extends StatelessWidget {
final Product product;

final IconData icon;

final String formattedPrice;

final bool deleting;

final VoidCallback onEdit;

final VoidCallback onDelete;

const _ProductCard({
required this.product,
required this.icon,
required this.formattedPrice,
required this.deleting,
required this.onEdit,
required this.onDelete,
});

// ============================================================
// DECODE PRODUCT IMAGE
// ============================================================

Uint8List? _decodeProductImage() {
try {
final String image =
product.image;

if (image.isEmpty) {
return null;
}

String base64String =
image.trim();

// Example:
// data:image/jpeg;base64,/9j/4AAQ...
//
// Remove:
// data:image/jpeg;base64,

if (base64String
    .contains(',')) {
base64String =
base64String
    .split(',')
    .last;
}

return base64Decode(
base64String,
);
} catch (e) {
debugPrint(
'PRODUCT IMAGE DECODE ERROR => $e',
);

return null;
}
}

@override
Widget build(
BuildContext context,
) {
final bool inStock =
product.stock > 0;

final Uint8List?
imageBytes =
_decodeProductImage();

return Container(
margin:
const EdgeInsets.only(
bottom: 13,
),

padding:
const EdgeInsets.all(
15,
),

decoration:
BoxDecoration(
color: Colors.white,

borderRadius:
BorderRadius.circular(
21,
),

border:
Border.all(
color:
const Color(
0xFFE2ECE7,
),
),

boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(
0.035,
),
blurRadius: 14,
offset:
const Offset(
0,
7,
),
),
],
),

child: Row(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [
// ==================================================
// PRODUCT PHOTO
// ==================================================

ClipRRect(
borderRadius:
BorderRadius.circular(
19,
),

child:
SizedBox(
width: 78,
height: 78,

child:
imageBytes != null
? Image.memory(
imageBytes,

width: 78,
height: 78,

fit:
BoxFit.cover,

gaplessPlayback:
true,

errorBuilder:
(
context,
error,
stackTrace,
) {
return _buildFallbackIcon();
},
)
    : _buildFallbackIcon(),
),
),

const SizedBox(
width: 14,
),

// ==================================================
// PRODUCT DETAILS
// ==================================================

Expanded(
child:
Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [
Row(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [
Expanded(
child:
Text(
product.name,

maxLines: 2,

overflow:
TextOverflow
    .ellipsis,

style:
const TextStyle(
color:
Color(
0xFF102A24,
),
fontSize:
16,
fontWeight:
FontWeight
    .w900,
height:
1.25,
),
),
),

PopupMenuButton<
String>(
padding:
EdgeInsets.zero,

icon:
const Icon(
Icons
    .more_horiz_rounded,
),

onSelected:
(value) {
if (value ==
'edit') {
onEdit();
}

if (value ==
'delete') {
onDelete();
}
},

itemBuilder:
(context) =>
const [
PopupMenuItem(
value:
'edit',

child:
Row(
children: [
Icon(
Icons
    .edit_outlined,
size:
20,
),
SizedBox(
width:
10,
),
Text(
'Edit',
),
],
),
),

PopupMenuItem(
value:
'delete',

child:
Row(
children: [
Icon(
Icons
    .delete_outline_rounded,
color:
Colors.red,
size:
20,
),
SizedBox(
width:
10,
),
Text(
'Delete',
style:
TextStyle(
color:
Colors.red,
),
),
],
),
),
],
),
],
),

const SizedBox(
height: 5,
),

Wrap(
spacing: 7,
runSpacing: 7,

children: [
_SmallChip(
label:
product.category,

background:
const Color(
0xFFA7F3D0,
).withOpacity(
0.42,
),

foreground:
const Color(
0xFF065F46,
),
),

_SmallChip(
label: inStock
? 'Stock ${product.stock}'
    : 'Out of stock',

background:
inStock
? const Color(
0xFFEAF7F1,
)
    : Colors
    .red
    .shade50,

foreground:
inStock
? const Color(
0xFF065F46,
)
    : Colors
    .red
    .shade700,
),
],
),

const SizedBox(
height: 10,
),

Row(
children: [
Text(
formattedPrice,

style:
const TextStyle(
color:
Color(
0xFF065F46,
),
fontSize:
16,
fontWeight:
FontWeight
    .w900,
),
),

if (deleting) ...[
const Spacer(),

const SizedBox(
width: 17,
height: 17,

child:
CircularProgressIndicator(
strokeWidth:
2,

color:
Color(
0xFF065F46,
),
),
),
],
],
),
],
),
),
],
),
);
}

// ============================================================
// FALLBACK ICON
// ============================================================

Widget _buildFallbackIcon() {
return Container(
width: 78,
height: 78,

decoration:
const BoxDecoration(
gradient:
LinearGradient(
colors: [
Color(
0xFFA7F3D0,
),
Color(
0xFFFFF8E7,
),
],

begin:
Alignment.topLeft,

end:
Alignment.bottomRight,
),
),

child:
Icon(
icon,

color:
const Color(
0xFF065F46,
),

size: 31,
),
);
}
}

// ============================================================
// SMALL CHIP
// ============================================================

class _SmallChip
extends StatelessWidget {
final String label;

final Color background;

final Color foreground;

const _SmallChip({
required this.label,
required this.background,
required this.foreground,
});

@override
Widget build(
BuildContext context,
) {
return Container(
padding:
const EdgeInsets.symmetric(
horizontal: 9,
vertical: 5,
),

decoration:
BoxDecoration(
color: background,

borderRadius:
BorderRadius.circular(
99,
),
),

child:
Text(
label,

style:
TextStyle(
color: foreground,
fontSize: 11,
fontWeight:
FontWeight.w800,
),
),
);
}
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState
extends StatelessWidget {
final IconData icon;

final String title;

final String subtitle;

final String buttonText;

final VoidCallback onPressed;

const _EmptyState({
required this.icon,
required this.title,
required this.subtitle,
required this.buttonText,
required this.onPressed,
});

@override
Widget build(
BuildContext context,
) {
return Column(
children: [
Container(
width: 112,
height: 112,

decoration:
const BoxDecoration(
color:
Color(
0xFFFFF8E7,
),
shape:
BoxShape.circle,
),

child:
Icon(
icon,

color:
const Color(
0xFF065F46,
),

size: 50,
),
),

const SizedBox(
height: 22,
),

Text(
title,

textAlign:
TextAlign.center,

style:
const TextStyle(
color:
Color(
0xFF102A24,
),
fontSize:
21,
fontWeight:
FontWeight.w900,
),
),

const SizedBox(
height: 8,
),

Text(
subtitle,

textAlign:
TextAlign.center,

style:
const TextStyle(
color:
Color(
0xFF60736E,
),
height:
1.5,
),
),

const SizedBox(
height: 20,
),

OutlinedButton.icon(
onPressed:
onPressed,

style:
OutlinedButton
    .styleFrom(
foregroundColor:
const Color(
0xFF065F46,
),

side:
const BorderSide(
color:
Color(
0xFF065F46,
),
),

padding:
const EdgeInsets
    .symmetric(
horizontal:
18,
vertical:
13,
),

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
16,
),
),
),

icon:
const Icon(
Icons.add_rounded,
),

label:
Text(
buttonText,

style:
const TextStyle(
fontWeight:
FontWeight.w800,
),
),
),
],
);
}
}
