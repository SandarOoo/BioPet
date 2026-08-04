import 'package:flutter/material.dart';

import 'my_orders_page.dart';
import 'user_shop_theme.dart';

class OrderSuccessPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderSuccessPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderNumber =
        order['orderNumber']?.toString() ?? order['_id']?.toString() ?? 'N/A';
    final status = order['status']?.toString() ?? 'Pending';

    return Scaffold(
      backgroundColor: UserShopTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [UserShopTheme.mint, UserShopTheme.mintSoft],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: UserShopTheme.softShadow,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 72,
                        color: UserShopTheme.emerald,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Order Successful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: UserShopTheme.textPrimary,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your pet products have been ordered successfully. You can track the order at any time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: UserShopTheme.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: UserShopTheme.card(color: UserShopTheme.cream),
                      child: Column(
                        children: [
                          _orderInfo('Order ID', '#$orderNumber'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            child: Divider(
                              color: UserShopTheme.border,
                              height: 1,
                            ),
                          ),
                          _orderInfo('Estimated Delivery', '2 – 3 Days'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            child: Divider(
                              color: UserShopTheme.border,
                              height: 1,
                            ),
                          ),
                          _orderInfo('Payment Status', status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyOrdersPage(),
                            ),
                          );
                        },
                        style: UserShopTheme.primaryButton(),
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: const Text(
                          'Track Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.popUntil(
                          context,
                              (route) => route.isFirst,
                        ),
                        style: UserShopTheme.outlineButton(),
                        icon: const Icon(Icons.storefront_outlined),
                        label: const Text(
                          'Continue Shopping',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _orderInfo(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: UserShopTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: UserShopTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
