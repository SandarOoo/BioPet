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
    final productTitle = _orderProductTitle(items);
    final headerImage = items.isNotEmpty ? _itemImage(items.first) : '';
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
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: headerImage.isNotEmpty
                          ? Image.network(
                        headerImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.pets_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      )
                          : const Icon(
                        Icons.pets_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRODUCT NAME',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          productTitle,
                          maxLines: 2,
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
    final itemMap = _asMap(item);
    final name = _itemName(item);
    final image = _itemImage(item);
    final quantity = _asInt(itemMap['quantity'], fallback: 1);
    final productMap = _asMap(itemMap['product']);
    final price = _asDouble(
      itemMap['price'] ?? productMap['price'],
    );
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
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        color: UserShopTheme.emerald,
                        strokeWidth: 2.2,
                      ),
                    ),
                  );
                },
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

  String _orderProductTitle(List items) {
    if (items.isEmpty) return 'Product';

    final firstName = _itemName(items.first);
    if (items.length == 1) return firstName;

    return '$firstName + ${items.length - 1} more';
  }

  String _itemName(dynamic item) {
    final itemMap = _asMap(item);
    final productMap = _asMap(itemMap['product']);

    return _firstText([
      itemMap['name'],
      itemMap['productName'],
      productMap['name'],
      productMap['productName'],
    ], fallback: 'Product');
  }

  String _itemImage(dynamic item) {
    final itemMap = _asMap(item);
    final productMap = _asMap(itemMap['product']);

    return _firstImage([
      itemMap['image'],
      itemMap['imageUrl'],
      itemMap['images'],
      productMap['image'],
      productMap['imageUrl'],
      productMap['images'],
    ]);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _firstText(List<dynamic> values, {required String fallback}) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text != 'null') return text;
    }
    return fallback;
  }

  String _firstImage(List<dynamic> values) {
    for (final value in values) {
      if (value is List && value.isNotEmpty) {
        final first = value.first;
        if (first is Map) {
          final map = Map<String, dynamic>.from(first);
          final nested = _firstText(
            [map['url'], map['secure_url'], map['image']],
            fallback: '',
          );
          if (nested.isNotEmpty) return nested;
        }

        final text = first?.toString().trim() ?? '';
        if (text.isNotEmpty && text != 'null') return text;
      }

      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        final nested = _firstText(
          [map['url'], map['secure_url'], map['image']],
          fallback: '',
        );
        if (nested.isNotEmpty) return nested;
      }

      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text != 'null') return text;
    }

    return '';
  }

  int _asInt(dynamic value, {required int fallback}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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
