
import 'package:flutter/material.dart';

import 'edit_seller_profile_screen.dart';

class SellerProfileScreen extends StatelessWidget {
final Map<String, dynamic>? user;
final Future<void> Function()? onRefresh;

const SellerProfileScreen({
super.key,
required this.user,
this.onRefresh,
});

// ============================================================
// BUSINESS PROFILE
// ============================================================

Map<String, dynamic> get businessProfile {
final profile = user?['businessProfile'];

if (profile is Map) {
return Map<String, dynamic>.from(profile);
}

return {};
}

// ============================================================
// USER INFO
// ============================================================

String get ownerName {
final value = user?['name']?.toString();

if (value != null && value.isNotEmpty) {
return value;
}

return 'Business Owner';
}

String get email {
return user?['email']?.toString() ?? '';
}

String get phone {
return user?['phone']?.toString() ?? '';
}

// ============================================================
// BUSINESS INFO
// ============================================================

String get businessName {
final value =
businessProfile['businessName']?.toString();

if (value != null && value.isNotEmpty) {
return value;
}

return 'My Pet Business';
}

String get businessType {
final value =
businessProfile['businessType']?.toString();

if (value == null || value.isEmpty) {
return 'Pet Business';
}

switch (value) {
case 'pet_shop':
return 'Pet Shop';

case 'vet_clinic':
return 'Veterinary Clinic';

case 'grooming':
return 'Pet Grooming';

case 'other':
return 'Pet Business';

default:
return value
    .replaceAll('_', ' ')
    .split(' ')
    .map(
(word) => word.isEmpty
? ''
    : word[0].toUpperCase() +
word.substring(1),
)
    .join(' ');
}
}

String get address {
final value =
businessProfile['address']?.toString();

if (value != null && value.isNotEmpty) {
return value;
}

return 'Business location not set';
}

String get description {
final value =
businessProfile['description']?.toString();

if (value != null && value.isNotEmpty) {
return value;
}

return 'No business description available.';
}

String get verificationStatus {
return businessProfile[
'verificationStatus']
    ?.toString() ??
'draft';
}

bool get agreementAccepted {
return businessProfile[
'agreementAccepted'] ==
true;
}

double? get latitude {
final value =
businessProfile['latitude'];

if (value is num) {
return value.toDouble();
}

return double.tryParse(
value?.toString() ?? '',
);
}

double? get longitude {
final value =
businessProfile['longitude'];

if (value is num) {
return value.toDouble();
}

return double.tryParse(
value?.toString() ?? '',
);
}

// ============================================================
// STATUS COLOR
// ============================================================

Color get statusColor {
switch (verificationStatus) {
case 'approved':
return Colors.green;

case 'pending':
return Colors.orange;

case 'rejected':
return Colors.red;

default:
return Colors.grey;
}
}

// ============================================================
// STATUS TEXT
// ============================================================

String get statusText {
switch (verificationStatus) {
case 'approved':
return 'Approved';

case 'pending':
return 'Pending Review';

case 'rejected':
return 'Rejected';

default:
return 'Draft';
}
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xffF6FAF7),

appBar: AppBar(
elevation: 0,

backgroundColor:
const Color(0xffF6FAF7),

title: const Text(
'My Seller Profile',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),

centerTitle: true,

actions: [
IconButton(
onPressed: () {
// TODO:
// Open Edit Seller Profile Screen
},
icon: const Icon(
Icons.edit_outlined,
),
),
],
),

body: RefreshIndicator(
onRefresh: () async {
if (onRefresh != null) {
await onRefresh!();
}
},

child: SingleChildScrollView(
physics:
const AlwaysScrollableScrollPhysics(),

padding:
const EdgeInsets.fromLTRB(
16,
10,
16,
30,
),

child: Column(
children: [

// ==================================================
// PROFILE HEADER
// ==================================================

Container(
width: double.infinity,

padding:
const EdgeInsets.all(24),

decoration:
BoxDecoration(
color: Colors.white,

borderRadius:
BorderRadius.circular(
24,
),

boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.04),

blurRadius: 12,

offset:
const Offset(0, 5),
),
],
),

child: Column(
children: [

// PROFILE ICON
Container(
width: 90,
height: 90,

decoration:
BoxDecoration(
color:
Colors.green
    .shade50,

shape:
BoxShape.circle,
),

child: Icon(
Icons.store_rounded,

size: 48,

color:
Colors.green
    .shade700,
),
),

const SizedBox(
height: 16,
),

// BUSINESS NAME
Text(
businessName,

textAlign:
TextAlign.center,

style:
const TextStyle(
fontSize: 24,

fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 6,
),

// BUSINESS TYPE
Text(
businessType,

style:
TextStyle(
color:
Colors.grey
    .shade600,

fontSize: 15,
),
),

const SizedBox(
height: 16,
),

// STATUS
Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 16,
vertical: 8,
),

decoration:
BoxDecoration(
color: statusColor
    .withOpacity(
0.1,
),

borderRadius:
BorderRadius
    .circular(
20,
),
),

child: Row(
mainAxisSize:
MainAxisSize.min,

children: [
Icon(
verificationStatus ==
'approved'
? Icons
    .verified
    : Icons
    .info_outline,

size: 18,

color:
statusColor,
),

const SizedBox(
width: 7,
),

Text(
statusText,

style:
TextStyle(
color:
statusColor,

fontWeight:
FontWeight
    .bold,
),
),
],
),
),
],
),
),

const SizedBox(
height: 16,
),

// ==================================================
// BUSINESS INFORMATION
// ==================================================

_buildSection(
title:
'Business Information',

icon:
Icons.store_outlined,

children: [

_buildInfoRow(
icon:
Icons.storefront_outlined,

title:
'Business Name',

value:
businessName,
),

_buildInfoRow(
icon:
Icons.category_outlined,

title:
'Business Type',

value:
businessType,
),

_buildInfoRow(
icon:
Icons.location_on_outlined,

title:
'Address',

value:
address,
),

_buildInfoRow(
icon:
Icons.description_outlined,

title:
'Description',

value:
description,
),
],
),

const SizedBox(
height: 16,
),

// ==================================================
// OWNER INFORMATION
// ==================================================

_buildSection(
title:
'Owner Information',

icon:
Icons.person_outline,

children: [

_buildInfoRow(
icon:
Icons.person_outline,

title:
'Owner Name',

value:
ownerName,
),

_buildInfoRow(
icon:
Icons.email_outlined,

title:
'Email',

value:
email.isEmpty
? 'Not available'
    : email,
),

_buildInfoRow(
icon:
Icons.phone_outlined,

title:
'Phone',

value:
phone.isEmpty
? 'Not available'
    : phone,
),
],
),

const SizedBox(
height: 16,
),

// ==================================================
// VERIFICATION
// ==================================================

_buildSection(
title:
'Verification',

icon:
Icons.verified_user_outlined,

children: [

_buildInfoRow(
icon:
Icons.fact_check_outlined,

title:
'Application Status',

value:
statusText,
),

_buildInfoRow(
icon:
Icons
    .assignment_turned_in_outlined,

title:
'Agreement',

value:
agreementAccepted
? 'Accepted'
    : 'Not Accepted',
),
],
),

const SizedBox(
height: 16,
),

// ==================================================
// LOCATION COORDINATES
// ==================================================

_buildSection(
title:
'Business Location',

icon:
Icons.map_outlined,

children: [

_buildInfoRow(
icon:
Icons
    .location_searching,

title:
'Latitude',

value:
latitude
    ?.toString() ??
'Not set',
),

_buildInfoRow(
icon:
Icons
    .location_searching,

title:
'Longitude',

value:
longitude
    ?.toString() ??
'Not set',
),
],
),

const SizedBox(
height: 20,
),

// ==================================================
// EDIT PROFILE BUTTON
// ==================================================

SizedBox(
width:
double.infinity,

height: 52,

child:
ElevatedButton.icon(
  onPressed: () async {
    final updated =
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditSellerProfileScreen(
              user: user,
            ),
      ),
    );

    if (updated == true &&
        onRefresh != null) {
      await onRefresh!();
    }
  },

icon:
const Icon(
Icons.edit_outlined,
),

label:
const Text(
'Edit Business Profile',
),

style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.green
    .shade700,

foregroundColor:
Colors.white,

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
14,
),
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

// ============================================================
// SECTION
// ============================================================

Widget _buildSection({
required String title,
required IconData icon,
required List<Widget> children,
}) {
return Container(
width: double.infinity,

padding:
const EdgeInsets.all(20),

decoration:
BoxDecoration(
color: Colors.white,

borderRadius:
BorderRadius.circular(
20,
),

boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.03),

blurRadius: 10,

offset:
const Offset(0, 4),
),
],
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Row(
children: [
Icon(
icon,

color:
Colors.green.shade700,
),

const SizedBox(
width: 8,
),

Text(
title,

style:
const TextStyle(
fontSize: 18,

fontWeight:
FontWeight.bold,
),
),
],
),

const SizedBox(
height: 16,
),

...children,
],
),
);
}

// ============================================================
// INFO ROW
// ============================================================

Widget _buildInfoRow({
required IconData icon,
required String title,
required String value,
}) {
return Padding(
padding:
const EdgeInsets.only(
bottom: 16,
),

child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Icon(
icon,

size: 21,

color:
Colors.grey.shade600,
),

const SizedBox(
width: 12,
),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [

Text(
title,

style:
TextStyle(
fontSize: 12,

color:
Colors.grey.shade600,
),
),

const SizedBox(
height: 4,
),

Text(
value,

style:
const TextStyle(
fontSize: 15,

fontWeight:
FontWeight.w500,

height: 1.4,
),
),
],
),
),
],
),
);
}
}
