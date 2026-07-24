import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order #1023'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'May 20, 2024 - 10:30 AM',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // Customer info
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Chit Snow Oo',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('09 123 456 789'),
                    Text('Thaton, Mon State'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Order items
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  _OrderItemRow('Royal Canin Dog Food', '25,000 MMK', 'Stock: 50'),
                  _OrderItemRow('Cat Toy', '8,000 MMK', 'Stock: 30'),
                  _OrderItemRow('Pet Leash', '6,000 MMK', 'Stock: 25'),
                  _OrderItemRow('Pet Shampoo', '12,000 MMK', 'Stock: 40'),
                  _OrderItemRow('Soft Pet Bed', '35,000 MMK', 'Stock: 10'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final String name;
  final String price;
  final String stock;
  const _OrderItemRow(this.name, this.price, this.stock);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text('$price | $stock'),
        leading: const Icon(Icons.circle, size: 12),
      ),
    );
  }
}