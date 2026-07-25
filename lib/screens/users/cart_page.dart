import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import 'checkout_page.dart';

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
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: items.isEmpty
          ? const Center(
        child: Text("Your cart is empty", style: TextStyle(fontSize: 18)),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
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
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                priceRow("Subtotal", subtotal),
                priceRow("Delivery Fee", items.isEmpty ? 0 : deliveryFee),
                const Divider(),
                priceRow("Total", total, bold: true),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: items.isEmpty
                        ? null
                        : () {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Proceed Checkout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget priceRow(String title, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "${value.toStringAsFixed(0)} MMK",
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.green : Colors.black,
            ),
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: image.isNotEmpty
                ? Image.network(
              image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 60),
            )
                : const Icon(Icons.pets, size: 60),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "${price.toStringAsFixed(0)} MMK",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onRemoveQuantity,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(quantity.toString()),
                    IconButton(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }
}