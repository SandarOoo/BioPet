import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pending products
          const Text('Pending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildProductItem('Royal Canin Dog Food', '25,000 MMK', 'Stock: 50'),
          _buildProductItem('Cat Toy', '8,000 MMK', 'Stock: 30'),
          const SizedBox(height: 24),

          // Completed products
          const Text('Completed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildProductItem('Pet Leash', '6,000 MMK', 'Stock: 25'),
          _buildProductItem('Pet Shampoo', '12,000 MMK', 'Stock: 40'),
          _buildProductItem('Soft Pet Bed', '35,000 MMK', 'Stock: 10'),
        ],
      ),
    );
  }

  Widget _buildProductItem(String name, String price, String stock) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.pets),
        title: Text(name),
        subtitle: Text('$price | $stock'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}