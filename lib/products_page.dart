import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {'name': 'Royal Canin Dog Food', 'price': '25,000 MMK', 'stock': '50'},
      {'name': 'Cat Toy', 'price': '8,000 MMK', 'stock': '30'},
      {'name': 'Pet Leash', 'price': '6,000 MMK', 'stock': '25'},
      {'name': 'Pet Shampoo', 'price': '12,000 MMK', 'stock': '40'},
      {'name': 'Soft Pet Bed', 'price': '35,000 MMK', 'stock': '10'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];
          return ListTile(
            leading: const Icon(Icons.pets, color: Colors.green),
            title: Text(item['name']!),
            subtitle: Text('Price: ${item['price']} • Stock: ${item['stock']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
