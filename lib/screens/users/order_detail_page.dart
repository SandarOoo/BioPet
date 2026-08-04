import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/order_service.dart';
import 'user_shop_theme.dart';

class OrderDetailPage extends StatefulWidget {
  final String? orderId;
  final Product? product;

  const OrderDetailPage({
    super.key,
    this.orderId,
    this.product,
  }) : assert(
  orderId != null || product != null,
  'Either orderId or product must be provided',
  );

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderService orderService = OrderService();

  int quantity = 1;
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  bool loading = false;
  bool loadingOrder = false;
  String? loadError;

  String paymentMethod = 'Cash on Delivery';

  Map<String, dynamic>? createdOrder;
  Product? product;

  bool get isViewingExisting => widget.orderId != null;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      product = widget.product;
    } else if (widget.orderId != null) {
      _loadExistingOrder();
    }
  }

  Future<void> _loadExistingOrder() async {
    setState(() {
      loadingOrder = true;
      loadError = null;
    });

    try {
      final result = await orderService.getOrderDetail(widget.orderId!);

      if (!mounted) return;

      final items = result['items'] as List? ?? [];
      final firstItem = items.isNotEmpty ? items.first : null;

      setState(() {
        createdOrder = result;
        if (firstItem != null) {
          product = Product(
            id: firstItem['productId']?.toString() ?? '',
            name: firstItem['name']?.toString() ?? '',
            image: firstItem['image']?.toString() ?? '',
            price: (firstItem['price'] ?? 0).toDouble(),
            category: '',
            description: '',
            stock: 9999,
            ownerName: '',
            shopName: '',
          );
        }

        quantity = firstItem != null
            ? ((firstItem['quantity'] ?? 1) as num).toInt()
            : 1;

        final shipping = result['shippingAddress'] ?? {};
        phoneController.text = shipping['phone']?.toString() ?? '';
        addressController.text = shipping['address']?.toString() ?? '';

        paymentMethod =
            result['paymentMethod']?.toString() ?? 'Cash on Delivery';
        loadingOrder = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadError = e.toString().replaceFirst('Exception: ', '');
        loadingOrder = false;
      });
    }
  }

  double get subtotal => (product?.price ?? 0) * quantity;
  double get deliveryFee => 3000;
  double get total => subtotal + deliveryFee;

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> placeOrder() async {
    if (product == null) {
      _showMessage('Product information is not available');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _showMessage('Please enter your phone number');
      return;
    }

    if (addressController.text.trim().isEmpty) {
      _showMessage('Please enter your delivery address');
      return;
    }

    if (quantity <= 0) {
      _showMessage('Invalid quantity');
      return;
    }

    setState(() => loading = true);

    try {
      final result = await orderService.createOrder(
        items: [
          {
            'productId': product!.id,
            'name': product!.name,
            'image': product!.image,
            'price': product!.price,
            'quantity': quantity,
          },
        ],
        name: phoneController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        paymentMethod: paymentMethod,
      );

      if (!mounted) return;

      setState(() {
        createdOrder = Map<String, dynamic>.from(result['order'] ?? result);
        loading = false;
      });

      _showMessage('Order placed successfully');
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
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
      appBar: UserShopTheme.appBar('Order Details'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loadingOrder) {
      return const Center(
        child: CircularProgressIndicator(color: UserShopTheme.emerald),
      );
    }

    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: UserShopTheme.card(color: UserShopTheme.cream),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: UserShopTheme.danger,
                  size: 48,
                ),
                const SizedBox(height: 14),
                Text(
                  loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: UserShopTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _loadExistingOrder,
                  style: UserShopTheme.primaryButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (product == null) {
      return const Center(
        child: Text(
          'Product not found',
          style: TextStyle(color: UserShopTheme.textSecondary),
        ),
      );
    }

    final readOnly = isViewingExisting;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _orderHeader(),
          const SizedBox(height: 24),
          _sectionTitle(Icons.pets_outlined, 'Product Details'),
          const SizedBox(height: 12),
          _productCard(readOnly: readOnly),
          const SizedBox(height: 24),
          _sectionTitle(Icons.location_on_outlined, 'Delivery Information'),
          const SizedBox(height: 12),
          _deliveryCard(readOnly: readOnly),
          const SizedBox(height: 24),
          _sectionTitle(Icons.payments_outlined, 'Payment Information'),
          const SizedBox(height: 12),
          _paymentCard(readOnly: readOnly),
          const SizedBox(height: 24),
          _sectionTitle(Icons.receipt_long_outlined, 'Price Details'),
          const SizedBox(height: 12),
          _priceCard(),
          if (!readOnly) ...[
            const SizedBox(height: 28),
            _actionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: (loading || createdOrder != null)
                  ? null
                  : () => Navigator.pop(context),
              style: UserShopTheme.outlineButton(),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: (loading || createdOrder != null) ? null : placeOrder,
              style: UserShopTheme.primaryButton(),
              child: loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                createdOrder != null ? 'Order Placed' : 'Place Order',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _orderHeader() {
    final status = createdOrder?['status']?.toString() ?? 'Pending';
    final orderNumber =
        createdOrder?['orderNumber'] ?? createdOrder?['_id'] ?? 'New Order';

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (createdOrder != null)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
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
          const SizedBox(height: 18),
          Text(
            createdOrder != null ? '#$orderNumber' : 'New Order',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            createdOrder != null
                ? (isViewingExisting
                ? 'Your order information and current status.'
                : 'Your order was placed successfully.')
                : 'Review the details below before placing your order.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard({required bool readOnly}) {
    final p = product!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: UserShopTheme.card(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  color: UserShopTheme.cream,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: p.image.isNotEmpty
                      ? Image.network(
                    p.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.pets_rounded,
                      size: 44,
                      color: UserShopTheme.emerald,
                    ),
                  )
                      : const Icon(
                    Icons.pets_rounded,
                    size: 44,
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
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: UserShopTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${p.price.toStringAsFixed(0)} MMK',
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: UserShopTheme.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quantity',
                style: TextStyle(
                  color: UserShopTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              readOnly
                  ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: UserShopTheme.mintSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    color: UserShopTheme.emerald,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
                  : Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: UserShopTheme.mintSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: UserShopTheme.border),
                ),
                child: Row(
                  children: [
                    _quantityButton(
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
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _quantityButton(
                      icon: Icons.add_rounded,
                      enabled: quantity < p.stock,
                      onPressed: () => setState(() => quantity++),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: enabled ? onPressed : null,
        style: IconButton.styleFrom(
          backgroundColor: UserShopTheme.surface,
          foregroundColor: UserShopTheme.emerald,
        ),
        icon: Icon(icon, size: 19),
      ),
    );
  }

  Widget _deliveryCard({required bool readOnly}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: UserShopTheme.card(),
      child: Column(
        children: [
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            enabled: !readOnly && createdOrder == null,
            decoration: UserShopTheme.input(
              label: 'Phone Number',
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: addressController,
            maxLines: 3,
            enabled: !readOnly && createdOrder == null,
            decoration: UserShopTheme.input(
              label: 'Delivery Address',
              icon: Icons.location_on_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard({required bool readOnly}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: UserShopTheme.card(),
      child: DropdownButtonFormField<String>(
        value: paymentMethod,
        decoration: UserShopTheme.input(
          label: 'Payment Method',
          icon: Icons.account_balance_wallet_outlined,
        ),
        dropdownColor: UserShopTheme.surface,
        iconEnabledColor: UserShopTheme.emerald,
        items: const [
          DropdownMenuItem(
            value: 'Cash on Delivery',
            child: Text('Cash on Delivery'),
          ),
          DropdownMenuItem(value: 'KBZPay', child: Text('KBZPay')),
          DropdownMenuItem(value: 'WavePay', child: Text('WavePay')),
        ],
        onChanged: (readOnly || createdOrder != null)
            ? null
            : (value) {
          if (value != null) setState(() => paymentMethod = value);
        },
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
          _priceRow('Delivery', '${deliveryFee.toStringAsFixed(0)} MMK'),
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
}
