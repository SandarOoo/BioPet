
import 'package:flutter/material.dart';

import '../../services/business_service.dart';

class EditSellerProfileScreen
extends StatefulWidget {
final Map<String, dynamic>? user;

const EditSellerProfileScreen({
super.key,
required this.user,
});

@override
State<EditSellerProfileScreen>
createState() =>
_EditSellerProfileScreenState();
}

class _EditSellerProfileScreenState
extends State<EditSellerProfileScreen> {

// ============================================================
// CONTROLLERS
// ============================================================

late TextEditingController
businessNameController;

late TextEditingController
addressController;

late TextEditingController
descriptionController;

late TextEditingController
phoneController;

String selectedBusinessType =
'pet_shop';

bool isSaving = false;

final BusinessService
businessService =
BusinessService();

// ============================================================
// INIT
// ============================================================

@override
void initState() {
super.initState();

final profile =
widget.user?['businessProfile'];

final businessProfile =
profile is Map
? Map<String, dynamic>.from(
profile,
)
    : <String, dynamic>{};

businessNameController =
TextEditingController(
text:
businessProfile[
'businessName']
    ?.toString() ??
'',
);

addressController =
TextEditingController(
text:
businessProfile[
'address']
    ?.toString() ??
'',
);

descriptionController =
TextEditingController(
text:
businessProfile[
'description']
    ?.toString() ??
'',
);

phoneController =
TextEditingController(
text:
widget.user?['phone']
    ?.toString() ??
'',
);

final type =
businessProfile[
'businessType']
    ?.toString();

if (type != null &&
[
'pet_shop',
'vet_clinic',
'grooming',
'other',
].contains(type)) {
selectedBusinessType =
type;
}
}

// ============================================================
// DISPOSE
// ============================================================

@override
void dispose() {
businessNameController
    .dispose();

addressController
    .dispose();

descriptionController
    .dispose();

phoneController
    .dispose();

super.dispose();
}

// ============================================================
// SAVE PROFILE
// ============================================================

Future<void> saveProfile() async {
// ------------------------------------------
// VALIDATION
// ------------------------------------------

if (businessNameController.text
    .trim()
    .isEmpty) {
showMessage(
'Please enter your business name.',
);

return;
}

if (addressController.text
    .trim()
    .isEmpty) {
showMessage(
'Please enter your business address.',
);

return;
}

// ------------------------------------------
// START LOADING
// ------------------------------------------

setState(() {
isSaving = true;
});

try {
// ----------------------------------------
// UPDATE API
// ----------------------------------------

await businessService
    .updateBusinessProfile(
businessName:
businessNameController
    .text
    .trim(),

businessType:
selectedBusinessType,

address:
addressController
    .text
    .trim(),

description:
descriptionController
    .text
    .trim(),

phone:
phoneController
    .text
    .trim(),
);

if (!mounted) {
return;
}

// ----------------------------------------
// SUCCESS
// ----------------------------------------

ScaffoldMessenger.of(
context,
).showSnackBar(
const SnackBar(
content: Text(
'Profile updated successfully.',
),

backgroundColor:
Colors.green,
),
);

// ----------------------------------------
// RETURN TRUE
// ----------------------------------------

Navigator.pop(
context,
true,
);

} catch (e) {
if (!mounted) {
return;
}

showMessage(
e.toString()
    .replaceFirst(
'Exception: ',
'',
),
);

} finally {
if (mounted) {
setState(() {
isSaving = false;
});
}
}
}

// ============================================================
// SHOW MESSAGE
// ============================================================

void showMessage(
String message,
) {
ScaffoldMessenger.of(
context,
).showSnackBar(
SnackBar(
content:
Text(message),

backgroundColor:
Colors.red,
),
);
}

// ============================================================
// BUSINESS TYPE LABEL
// ============================================================

String getBusinessTypeLabel(
String type,
) {
switch (type) {
case 'pet_shop':
return 'Pet Shop';

case 'vet_clinic':
return 'Veterinary Clinic';

case 'grooming':
return 'Pet Grooming';

case 'other':
return 'Other';

default:
return type;
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
backgroundColor:
const Color(0xffF6FAF7),

appBar: AppBar(
backgroundColor:
const Color(0xffF6FAF7),

elevation: 0,

title: const Text(
'Edit Seller Profile',

style: TextStyle(
fontWeight:
FontWeight.bold,
),
),

centerTitle: true,
),

body:
SingleChildScrollView(
padding:
const EdgeInsets.all(
16,
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [

// ==================================================
// BUSINESS NAME
// ==================================================

_buildLabel(
'Business Name',
),

const SizedBox(
height: 8,
),

TextField(
controller:
businessNameController,

decoration:
_inputDecoration(
hint:
'Enter business name',

icon:
Icons.store_outlined,
),
),

const SizedBox(
height: 20,
),

// ==================================================
// BUSINESS TYPE
// ==================================================

_buildLabel(
'Business Type',
),

const SizedBox(
height: 8,
),

DropdownButtonFormField<
String>(
value:
selectedBusinessType,

decoration:
_inputDecoration(
hint:
'Select business type',

icon:
Icons.category_outlined,
),

items: const [
DropdownMenuItem(
value:
'pet_shop',

child:
Text(
'Pet Shop',
),
),

DropdownMenuItem(
value:
'vet_clinic',

child:
Text(
'Veterinary Clinic',
),
),

DropdownMenuItem(
value:
'grooming',

child:
Text(
'Pet Grooming',
),
),

DropdownMenuItem(
value:
'other',

child:
Text(
'Other',
),
),
],

onChanged:
(value) {
if (value !=
null) {
setState(() {
selectedBusinessType =
value;
});
}
},
),

const SizedBox(
height: 20,
),

// ==================================================
// PHONE
// ==================================================

_buildLabel(
'Phone Number',
),

const SizedBox(
height: 8,
),

TextField(
controller:
phoneController,

keyboardType:
TextInputType.phone,

decoration:
_inputDecoration(
hint:
'Enter phone number',

icon:
Icons.phone_outlined,
),
),

const SizedBox(
height: 20,
),

// ==================================================
// ADDRESS
// ==================================================

_buildLabel(
'Business Address',
),

const SizedBox(
height: 8,
),

TextField(
controller:
addressController,

maxLines: 2,

decoration:
_inputDecoration(
hint:
'Enter business address',

icon:
Icons
    .location_on_outlined,
),
),

const SizedBox(
height: 20,
),

// ==================================================
// DESCRIPTION
// ==================================================

_buildLabel(
'Business Description',
),

const SizedBox(
height: 8,
),

TextField(
controller:
descriptionController,

maxLines: 5,

decoration:
_inputDecoration(
hint:
'Tell customers about your business',

icon:
Icons
    .description_outlined,
),
),

const SizedBox(
height: 30,
),

// ==================================================
// SAVE BUTTON
// ==================================================

SizedBox(
width:
double.infinity,

height: 54,

child:
ElevatedButton(
onPressed:
isSaving
? null
    : saveProfile,

style:
ElevatedButton
    .styleFrom(
backgroundColor:
Colors.green
    .shade700,

foregroundColor:
Colors.white,

disabledBackgroundColor:
Colors.grey,

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
14,
),
),
),

child:
isSaving
? const SizedBox(
width: 24,
height: 24,

child:
CircularProgressIndicator(
strokeWidth:
2,

color:
Colors.white,
),
)
    : const Text(
'Save Changes',

style:
TextStyle(
fontSize:
16,

fontWeight:
FontWeight
    .bold,
),
),
),
),

const SizedBox(
height: 20,
),
],
),
),
);
}

// ============================================================
// LABEL
// ============================================================

Widget _buildLabel(
String text,
) {
return Text(
text,

style:
const TextStyle(
fontSize: 15,

fontWeight:
FontWeight.bold,
),
);
}

// ============================================================
// INPUT DECORATION
// ============================================================

InputDecoration _inputDecoration({
required String hint,
required IconData icon,
}) {
return InputDecoration(
hintText: hint,

prefixIcon:
Icon(icon),

filled: true,

fillColor:
Colors.white,

border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
14,
),

borderSide:
BorderSide.none,
),

enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
14,
),

borderSide:
BorderSide(
color:
Colors.grey.shade200,
),
),

focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
14,
),

borderSide:
BorderSide(
color:
Colors.green.shade700,

width: 1.5,
),
),

contentPadding:
const EdgeInsets
    .symmetric(
horizontal: 16,
vertical: 16,
),
);
}
}
