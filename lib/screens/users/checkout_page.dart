import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import 'payment_page.dart';
import 'user_shop_theme.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;

  const CheckoutPage({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String deliveryType = 'Standard Delivery';

  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    noteController.dispose();
    super.dispose();
  }

  double get currentDeliveryFee => deliveryType == 'Express Delivery'
      ? widget.deliveryFee + 2000
      : widget.deliveryFee;

  double get total => widget.subtotal + currentDeliveryFee;

  void _continueToPayment() {
    if (phoneController.text.trim().isEmpty) {
      _showMessage('Please enter your phone number');
      return;
    }

    if (addressController.text.trim().isEmpty) {
      _showMessage('Please enter your delivery address');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          items: widget.items,
          subtotal: widget.subtotal,
          deliveryFee: currentDeliveryFee,
          total: total,
          phone: phoneController.text.trim(),
          address: addressController.text.trim(),
          note: noteController.text.trim(),
          deliveryType: deliveryType,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: UserShopTheme.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UserShopTheme.background,
      appBar: UserShopTheme.appBar('Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          UserShopTheme.pagePadding,
          12,
          UserShopTheme.pagePadding,
          28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.location_on_outlined, 'Delivery Address'),
            const SizedBox(height: 12),
            _addressCard(),
            const SizedBox(height: 24),
            _sectionTitle(Icons.local_shipping_outlined, 'Delivery Option'),
            const SizedBox(height: 12),
            _deliveryOption(
              title: 'Standard Delivery',
              subtitle: 'Arrives in 2–3 days',
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 10),
            _deliveryOption(
              title: 'Express Delivery',
              subtitle: 'Arrives in 1 day · +2,000 MMK',
              icon: Icons.bolt_rounded,
            ),
            const SizedBox(height: 24),
            _sectionTitle(Icons.edit_note_rounded, 'Order Note'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: UserShopTheme.card(),
              child: TextField(
                controller: noteController,
                maxLines: 3,
                decoration: UserShopTheme.input(
                  label: 'Note for seller',
                  hint: 'Colour, size, delivery instructions…',
                  icon: Icons.chat_bubble_outline_rounded,
                ).copyWith(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(Icons.receipt_long_outlined, 'Order Summary'),
            const SizedBox(height: 12),
            _summaryCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _continueToPayment,
                style: UserShopTheme.primaryButton(),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text(
                  'Continue to Payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: UserShopTheme.mintSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: UserShopTheme.emerald, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: UserShopTheme.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _addressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: UserShopTheme.card(),
      child: Column(
        children: [
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: UserShopTheme.input(
              label: 'Phone Number',
              hint: '09xxxxxxxxx',
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: addressController,
            maxLines: 2,
            decoration: UserShopTheme.input(
              label: 'Delivery Address',
              hint: 'Street, township and city',
              icon: Icons.location_on_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryOption({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = deliveryType == title;

    return InkWell(
      onTap: () => setState(() => deliveryType = title),
      borderRadius: BorderRadius.circular(UserShopTheme.cardRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: UserShopTheme.selectedCard(selected: selected),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? UserShopTheme.mint
                    : UserShopTheme.cream,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: UserShopTheme.emerald),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: UserShopTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: UserShopTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: title,
              groupValue: deliveryType,
              activeColor: UserShopTheme.emerald,
              onChanged: (value) {
                if (value != null) setState(() => deliveryType = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: UserShopTheme.card(color: UserShopTheme.cream),
      child: Column(
        children: [
          ...widget.items.map(
                (item) => _summaryRow(
              '${item.product.name} × ${item.quantity}',
              '${item.lineTotal.toStringAsFixed(0)} MMK',
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: UserShopTheme.border),
          ),
          _summaryRow(
            'Subtotal',
            '${widget.subtotal.toStringAsFixed(0)} MMK',
          ),
          _summaryRow(
            'Delivery Fee',
            '${currentDeliveryFee.toStringAsFixed(0)} MMK',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: UserShopTheme.border),
          ),
          _summaryRow(
            'Total',
            '${total.toStringAsFixed(0)} MMK',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: bold
                    ? UserShopTheme.textPrimary
                    : UserShopTheme.textSecondary,
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: bold
                  ? UserShopTheme.emerald
                  : UserShopTheme.textPrimary,
              fontSize: bold ? 18 : 14,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
