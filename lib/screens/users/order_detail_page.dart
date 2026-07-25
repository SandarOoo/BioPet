import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/order_service.dart';

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

  String paymentMethod = "Cash on Delivery";

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
        quantity = firstItem != null ? (firstItem['quantity'] ?? 1) as int : 1;

        final shipping = result['shippingAddress'] ?? {};
        phoneController.text = shipping['phone']?.toString() ?? '';
        addressController.text = shipping['address']?.toString() ?? '';

        paymentMethod = result['paymentMethod']?.toString() ?? 'Cash on Delivery';
        loadingOrder = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadError = e.toString().replaceFirst("Exception: ", "");
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
      _showMessage("Product information is not available");
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _showMessage("Please enter your phone number");
      return;
    }

    if (addressController.text.trim().isEmpty) {
      _showMessage("Please enter your delivery address");
      return;
    }

    if (quantity <= 0) {
      _showMessage("Invalid quantity");
      return;
    }

    setState(() => loading = true);

    try {
      final result = await orderService.createOrder(
        items: [
          {
            "productId": product!.id,
            "name": product!.name,
            "image": product!.image,
            "price": product!.price,
            "quantity": quantity,
          }
        ],
        name: phoneController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        paymentMethod: paymentMethod,
      );

      if (!mounted) return;

      setState(() {
        createdOrder = result['order'] ?? result;
        loading = false;
      });

      _showMessage("Order placed successfully");
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      _showMessage(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loadingOrder) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadExistingOrder, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (product == null) {
      return const Center(child: Text("Product not found"));
    }

    final readOnly = isViewingExisting;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          orderHeader(),
          const SizedBox(height: 25),
          sectionTitle("Product Details"),
          const SizedBox(height: 10),
          productCard(readOnly: readOnly),
          const SizedBox(height: 25),
          sectionTitle("Delivery Information"),
          const SizedBox(height: 10),
          deliveryCard(readOnly: readOnly),
          const SizedBox(height: 25),
          sectionTitle("Payment Information"),
          const SizedBox(height: 10),
          paymentCard(readOnly: readOnly),
          const SizedBox(height: 25),
          sectionTitle("Price Details"),
          const SizedBox(height: 10),
          priceCard(),
          const SizedBox(height: 30),
          if (!readOnly) _actionButtons(),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: (loading || createdOrder != null) ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Cancel Order"),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: (loading || createdOrder != null) ? null : placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: loading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : Text(
              createdOrder != null ? "Order Placed" : "Place Order",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget orderHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Information", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            createdOrder != null
                ? "#${createdOrder!['orderNumber'] ?? createdOrder!['_id']}"
                : "New Order",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            createdOrder != null
                ? (isViewingExisting
                ? "Status: ${createdOrder!['status'] ?? 'Pending'}"
                : "Order placed successfully")
                : "Review your order before placing",
          ),
        ],
      ),
    );
  }

  Widget productCard({required bool readOnly}) {
    final p = product!;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.orange.shade100,
                ),
                child: p.image.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    p.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.pets, size: 45, color: Colors.orange),
                  ),
                )
                    : const Icon(Icons.pets, size: 45, color: Colors.orange),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Price: ${p.price.toStringAsFixed(0)} MMK"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
              readOnly
                  ? Text(quantity.toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                  : Row(
                children: [
                  IconButton(
                    onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(quantity.toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed:
                    quantity < p.stock ? () => setState(() => quantity++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget deliveryCard({required bool readOnly}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            enabled: !readOnly && createdOrder == null,
            decoration: const InputDecoration(
              labelText: "Phone Number",
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: addressController,
            maxLines: 3,
            enabled: !readOnly && createdOrder == null,
            decoration: const InputDecoration(
              labelText: "Delivery Address",
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentCard({required bool readOnly}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonFormField<String>(
        value: paymentMethod,
        decoration: const InputDecoration(labelText: "Payment Method", border: OutlineInputBorder()),
        items: const [
          DropdownMenuItem(value: "Cash on Delivery", child: Text("Cash on Delivery")),
          DropdownMenuItem(value: "KBZPay", child: Text("KBZPay")),
          DropdownMenuItem(value: "WavePay", child: Text("WavePay")),
        ],
        onChanged: (readOnly || createdOrder != null)
            ? null
            : (value) {
          if (value != null) setState(() => paymentMethod = value);
        },
      ),
    );
  }

  Widget priceCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          priceRow("Subtotal", "${subtotal.toStringAsFixed(0)} MMK"),
          priceRow("Delivery", "${deliveryFee.toStringAsFixed(0)} MMK"),
          const Divider(),
          priceRow("Total", "${total.toStringAsFixed(0)} MMK", bold: true),
        ],
      ),
    );
  }

  Widget priceRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              color: bold ? Colors.green : Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }
}