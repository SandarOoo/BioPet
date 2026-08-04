import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import 'checkout_page.dart';
import 'user_shop_theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService cartService = CartService();

  double deliveryFee = 3000;

  @override
  Widget build(BuildContext context) {
    final items = cartService.items;
    final subtotal = cartService.subtotal;
    final total = subtotal + (items.isEmpty ? 0 : deliveryFee);

    return Scaffold(
      backgroundColor: UserShopTheme.background,
      appBar: UserShopTheme.appBar('My Cart'),
      body: items.isEmpty
          ? _EmptyCart(onContinue: () => Navigator.maybePop(context))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                UserShopTheme.pagePadding,
                12,
                UserShopTheme.pagePadding,
                20,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return CartItemCard(
                  name: item.product.name,
                  image: item.product.image,
                  price: item.product.price,
                  quantity: item.quantity,
                  onAdd: () {
                    setState(() => cartService.increment(item.product.id));
                  },
                  onRemoveQuantity: () {
                    setState(() => cartService.decrement(item.product.id));
                  },
                  onDelete: () {
                    setState(() => cartService.remove(item.product.id));
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              color: UserShopTheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: const Border(
                top: BorderSide(color: UserShopTheme.border),
              ),
              boxShadow: UserShopTheme.softShadow,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  _priceRow('Subtotal', subtotal),
                  _priceRow('Delivery Fee', deliveryFee),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Divider(color: UserShopTheme.border),
                  ),
                  _priceRow('Total', total, bold: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              items: items,
                              subtotal: subtotal,
                              deliveryFee: deliveryFee,
                            ),
                          ),
                        );
                      },
                      style: UserShopTheme.primaryButton(),
                      icon: const Icon(Icons.lock_outline_rounded),
                      label: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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
    );
  }

  Widget _priceRow(String title, double value, {bool bold = false}) {
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
              fontSize: bold ? 17 : 15,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} MMK',
            style: TextStyle(
              fontSize: bold ? 19 : 15,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              color: bold
                  ? UserShopTheme.emerald
                  : UserShopTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onContinue;

  const _EmptyCart({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: const BoxDecoration(
                color: UserShopTheme.mintSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 54,
                color: UserShopTheme.emerald,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: UserShopTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your favourite pet products and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: UserShopTheme.textSecondary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 190,
              child: OutlinedButton(
                onPressed: onContinue,
                style: UserShopTheme.outlineButton(),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final String name;
  final String image;
  final double price;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemoveQuantity;
  final VoidCallback onDelete;

  const CartItemCard({
    super.key,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.onAdd,
    required this.onRemoveQuantity,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: UserShopTheme.card(),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: UserShopTheme.cream,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
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
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${price.toStringAsFixed(0)} MMK',
                  style: const TextStyle(
                    color: UserShopTheme.emerald,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove_rounded,
                      onPressed: onRemoveQuantity,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 38),
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(
                          color: UserShopTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add_rounded,
                      onPressed: onAdd,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: onDelete,
            style: IconButton.styleFrom(
              backgroundColor: UserShopTheme.danger.withOpacity(0.10),
            ),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: UserShopTheme.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: UserShopTheme.mintSoft,
          foregroundColor: UserShopTheme.emerald,
        ),
        icon: Icon(icon, size: 19),
      ),
    );
  }
}
