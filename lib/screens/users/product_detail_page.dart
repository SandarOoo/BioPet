import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/cart_service.dart';
import 'order_detail_page.dart';
import 'user_shop_theme.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final totalPrice = product.price * quantity;

    return Scaffold(
      backgroundColor: UserShopTheme.background,
      appBar: AppBar(
        backgroundColor: UserShopTheme.background,
        surfaceTintColor: UserShopTheme.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: UserShopTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: UserShopTheme.textPrimary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => setState(() => isFavorite = !isFavorite),
              style: IconButton.styleFrom(
                backgroundColor: isFavorite
                    ? UserShopTheme.danger.withOpacity(0.10)
                    : UserShopTheme.surface,
                side: const BorderSide(color: UserShopTheme.border),
              ),
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? UserShopTheme.danger
                    : UserShopTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              height: 310,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [UserShopTheme.cream, UserShopTheme.mintSoft],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: UserShopTheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: product.image.isNotEmpty
                    ? Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.pets_rounded,
                    size: 100,
                    color: UserShopTheme.emerald,
                  ),
                )
                    : const Icon(
                  Icons.pets_rounded,
                  size: 100,
                  color: UserShopTheme.emerald,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              decoration: BoxDecoration(
                color: UserShopTheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: const Border(
                  top: BorderSide(color: UserShopTheme.border),
                ),
                boxShadow: UserShopTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            color: UserShopTheme.textPrimary,
                            fontSize: 24,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StockBadge(inStock: product.stock > 0),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${product.price.toStringAsFixed(0)} MMK',
                    style: const TextStyle(
                      color: UserShopTheme.emerald,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoChip(
                        icon: Icons.category_outlined,
                        label: product.category,
                      ),
                      _InfoChip(
                        icon: Icons.inventory_2_outlined,
                        label: product.stock > 0
                            ? '${product.stock} available'
                            : 'Out of stock',
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionHeading('Description'),
                  const SizedBox(height: 10),
                  Text(
                    product.description.isEmpty
                        ? 'No description available for this product.'
                        : product.description,
                    style: const TextStyle(
                      color: UserShopTheme.textSecondary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionHeading('Quantity'),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: UserShopTheme.mintSoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: UserShopTheme.border),
                        ),
                        child: Row(
                          children: [
                            _QuantityIconButton(
                              icon: Icons.remove_rounded,
                              enabled: quantity > 1,
                              onPressed: () => setState(() => quantity--),
                            ),
                            SizedBox(
                              width: 42,
                              child: Text(
                                quantity.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: UserShopTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            _QuantityIconButton(
                              icon: Icons.add_rounded,
                              enabled: quantity < product.stock,
                              onPressed: () => setState(() => quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: product.stock > 0
                                ? () {
                              CartService().addProduct(
                                product,
                                quantity: quantity,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} added to cart',
                                  ),
                                  backgroundColor:
                                  UserShopTheme.textPrimary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                                : null,
                            style: UserShopTheme.outlineButton(),
                            icon: const Icon(Icons.add_shopping_cart_rounded),
                            label: const Text(
                              'Add to Cart',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: product.stock > 0
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailPage(product: product),
                                ),
                              );
                            }
                                : null,
                            style: UserShopTheme.primaryButton(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Buy Now',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '${totalPrice.toStringAsFixed(0)} MMK',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: UserShopTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: UserShopTheme.cream,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: UserShopTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: UserShopTheme.emerald, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: UserShopTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final bool inStock;

  const _StockBadge({required this.inStock});

  @override
  Widget build(BuildContext context) {
    final color = inStock ? UserShopTheme.emerald : UserShopTheme.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        inStock ? 'In stock' : 'Sold out',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _QuantityIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _QuantityIconButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: enabled ? onPressed : null,
        style: IconButton.styleFrom(
          backgroundColor: UserShopTheme.surface,
          foregroundColor: UserShopTheme.emerald,
          disabledForegroundColor: UserShopTheme.textSecondary.withOpacity(0.4),
        ),
        icon: Icon(icon, size: 19),
      ),
    );
  }
}
