import 'package:flutter/material.dart';
import 'order_success_page.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: const Text("Order Summary", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Products"),
            const SizedBox(height: 10),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: productCard(item),
            )),
            const SizedBox(height: 15),
            sectionTitle("Delivery Information"),
            const SizedBox(height: 10),
            infoCard(["Phone: $phone", "Address: $address"]),
            const SizedBox(height: 25),
            sectionTitle("Payment Method"),
            const SizedBox(height: 10),
            infoCard(["Payment: $paymentMethod", "Status: ${order['status'] ?? 'Pending'}"]),
            const SizedBox(height: 25),
            sectionTitle("Price Details"),
            const SizedBox(height: 10),
            priceCard(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => OrderSuccessPage(order: order)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Done",
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) =>
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));

  Widget productCard(dynamic item) {
    final name = item['name']?.toString() ?? 'Product';
    final image = item['image']?.toString() ?? '';
    final quantity = item['quantity']?.toString() ?? '1';
    final price = (item['price'] ?? 0).toDouble();
    final lineTotal = price * (item['quantity'] ?? 1);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: image.isNotEmpty
                ? Image.network(image, width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 60))
                : const Icon(Icons.pets, size: 60),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Quantity: $quantity"),
                const SizedBox(height: 5),
                Text("${lineTotal.toStringAsFixed(0)} MMK",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard(List<String> data) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data
            .map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(e, style: const TextStyle(fontSize: 15))))
            .toList(),
      ),
    );
  }

  Widget priceCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          priceRow("Subtotal", "${subtotal.toStringAsFixed(0)} MMK"),
          priceRow("Delivery Fee", "${deliveryFee.toStringAsFixed(0)} MMK"),
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
          Text(value,
              style: TextStyle(
                  color: bold ? Colors.green : Colors.black,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}