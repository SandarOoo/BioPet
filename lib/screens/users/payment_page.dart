import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import 'order_summary_page.dart';
import 'user_shop_theme.dart';

class PaymentPage extends StatefulWidget {
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String phone;
  final String address;
  final String note;
  final String deliveryType;

  const PaymentPage({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.phone,
    required this.address,
    required this.note,
    required this.deliveryType,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final OrderService orderService = OrderService();

  String selectedPayment = 'KBZ_PAY';
  bool loading = false;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'KBZPay',
      'value': 'KBZ_PAY',
      'icon': Icons.account_balance_wallet_outlined,
      'color': const Color(0xFF2563EB),
      'subtitle': 'Pay securely with KBZPay',
    },
    {
      'name': 'Wave Pay',
      'value': 'WAVE_PAY',
      'icon': Icons.phone_android_rounded,
      'color': const Color(0xFFF59E0B),
      'subtitle': 'Pay from your Wave account',
    },
    {
      'name': 'AYA Pay',
      'value': 'AYA_PAY',
      'icon': Icons.account_balance_wallet_outlined,
      'color': const Color(0xFF16A34A),
      'subtitle': 'Pay securely with AYA Pay',
    },
    {
      'name': 'Cash On Delivery',
      'value': 'COD',
      'icon': Icons.local_shipping_outlined,
      'color': const Color(0xFF8B5E3C),
      'subtitle': 'Pay when the order arrives',
    },
  ];

  Future<void> _confirmPayment() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final currentUser = await ApiService.getCurrentUser();
      debugPrint('CURRENT USER RESPONSE => $currentUser');

      if (currentUser == null) {
        throw Exception('User information not found. Please login again.');
      }

      final userData = currentUser['user'] ?? currentUser;
      final customerName = userData['name']?.toString() ?? '';

      if (customerName.isEmpty) {
        throw Exception('Customer name not found.');
      }

      final items = widget.items.map((item) {
        return {
          'product': item.product.id,
          'quantity': item.quantity,
        };
      }).toList();

      final result = await orderService.createOrder(
        items: items,
        name: customerName,
        phone: widget.phone,
        address: widget.address,
        paymentMethod: selectedPayment,
      );

      if (!mounted) return;

      CartService().clear();

      final order = Map<String, dynamic>.from(result['order'] ?? result);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSummaryPage(
            order: order,
            subtotal: widget.subtotal,
            deliveryFee: widget.deliveryFee,
            total: widget.total,
            paymentMethod: selectedPayment,
            phone: widget.phone,
            address: widget.address,
          ),
        ),
      );
    } catch (e) {
      debugPrint('CONFIRM PAYMENT ERROR => $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: UserShopTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UserShopTheme.background,
      appBar: UserShopTheme.appBar('Payment'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [UserShopTheme.mintSoft, UserShopTheme.cream],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: UserShopTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: UserShopTheme.emerald,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure payment',
                          style: TextStyle(
                            color: UserShopTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose the payment method you prefer.',
                          style: TextStyle(
                            color: UserShopTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Select Payment Method',
              style: TextStyle(
                color: UserShopTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final payment = paymentMethods[index];
                  return _paymentCard(
                    name: payment['name'] as String,
                    value: payment['value'] as String,
                    icon: payment['icon'] as IconData,
                    color: payment['color'] as Color,
                    subtitle: payment['subtitle'] as String,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: UserShopTheme.card(color: UserShopTheme.cream),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                color: UserShopTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Including delivery',
                              style: TextStyle(
                                color: UserShopTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${widget.total.toStringAsFixed(0)} MMK',
                          style: const TextStyle(
                            color: UserShopTheme.emerald,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : _confirmPayment,
                        style: UserShopTheme.primaryButton(),
                        icon: loading
                            ? const SizedBox.shrink()
                            : const Icon(Icons.verified_user_outlined),
                        label: loading
                            ? const SizedBox(
                          height: 21,
                          width: 21,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Confirm Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard({
    required String name,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    final selected = selectedPayment == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: InkWell(
        onTap: loading ? null : () => setState(() => selectedPayment = value),
        borderRadius: BorderRadius.circular(UserShopTheme.cardRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: UserShopTheme.selectedCard(selected: selected),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: UserShopTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: UserShopTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: selectedPayment,
                activeColor: UserShopTheme.emerald,
                onChanged: loading
                    ? null
                    : (newValue) {
                  if (newValue != null) {
                    setState(() => selectedPayment = newValue);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
