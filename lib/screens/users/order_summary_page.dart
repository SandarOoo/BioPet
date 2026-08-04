import 'package:flutter/material.dart';

import 'order_success_page.dart';
import 'user_shop_theme.dart';

class OrderSummaryPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String phone;
  final String address;

  const OrderSummaryPage({
    super.key,
    required this.order,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List? ?? [];
    final orderNumber =
        order['orderNumber']?.toString() ?? order['_id']?.toString() ?? 'N/A';
    final status = order['status']?.toString() ?? 'Pending';

    return Scaffold(
      backgroundColor: UserShopTheme.background,
      appBar: UserShopTheme.appBar('Order Summary'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [UserShopTheme.emerald, UserShopTheme.emeraldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: UserShopTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ORDER NUMBER',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#$orderNumber',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: UserShopTheme.mint,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: UserShopTheme.emeraldDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(Icons.pets_outlined, 'Products'),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: UserShopTheme.card(),
                child: const Text(
                  'No product details available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: UserShopTheme.textSecondary),
                ),
              )
            else
              ...items.map(
                    (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _productCard(item),
                ),
              ),
            const SizedBox(height: 12),
            _sectionTitle(Icons.location_on_outlined, 'Delivery Information'),
            const SizedBox(height: 12),
            _infoCard(
              rows: [
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: phone,
                ),
                _InfoRow(
                  icon: Icons.home_outlined,
                  label: 'Address',
                  value: address,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle(Icons.payments_outlined, 'Payment Method'),
            const SizedBox(height: 12),
            _infoCard(
              rows: [
                _InfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Payment',
                  value: _paymentLabel(paymentMethod),
                ),
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Status',
                  value: status,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle(Icons.calculate_outlined, 'Price Details'),
            const SizedBox(height: 12),
            _priceCard(),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderSuccessPage(order: order),
                    ),
                  );
                },
                style: UserShopTheme.primaryButton(),
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentLabel(String value) {
    switch (value) {
      case 'KBZ_PAY':
        return 'KBZPay';
      case 'WAVE_PAY':
        return 'Wave Pay';
      case 'AYA_PAY':
        return 'AYA Pay';
      case 'COD':
        return 'Cash On Delivery';
      default:
        return value;
    }
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

  Widget _productCard(dynamic item) {
    final name = item['name']?.toString() ?? 'Product';
    final image = item['image']?.toString() ?? '';
    final quantity = ((item['quantity'] ?? 1) as num).toInt();
    final price = ((item['price'] ?? 0) as num).toDouble();
    final lineTotal = price * quantity;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: UserShopTheme.card(),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: UserShopTheme.cream,
              borderRadius: BorderRadius.circular(17),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: image.isNotEmpty
                  ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.pets_rounded,
                  size: 42,
                  color: UserShopTheme.emerald,
                ),
              )
                  : const Icon(
                Icons.pets_rounded,
                size: 42,
                color: UserShopTheme.emerald,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: UserShopTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Quantity: $quantity',
                  style: const TextStyle(
                    color: UserShopTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${lineTotal.toStringAsFixed(0)} MMK',
                  style: const TextStyle(
                    color: UserShopTheme.emerald,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required List<_InfoRow> rows}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: UserShopTheme.card(),
      child: Column(
        children: [
          for (int index = 0; index < rows.length; index++) ...[
            rows[index],
            if (index != rows.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: UserShopTheme.border, height: 1),
              ),
          ],
        ],
      ),
    );
  }

  Widget _priceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: UserShopTheme.card(color: UserShopTheme.cream),
      child: Column(
        children: [
          _priceRow('Subtotal', '${subtotal.toStringAsFixed(0)} MMK'),
          _priceRow('Delivery Fee', '${deliveryFee.toStringAsFixed(0)} MMK'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: UserShopTheme.border),
          ),
          _priceRow('Total', '${total.toStringAsFixed(0)} MMK', bold: true),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: bold
                  ? UserShopTheme.textPrimary
                  : UserShopTheme.textSecondary,
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: bold
                  ? UserShopTheme.emerald
                  : UserShopTheme.textPrimary,
              fontSize: bold ? 19 : 14,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: UserShopTheme.mintSoft,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: UserShopTheme.emerald, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: UserShopTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: UserShopTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
