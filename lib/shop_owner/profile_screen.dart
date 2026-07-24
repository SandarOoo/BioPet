import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://via.placeholder.com/200',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Happy Pet Shop',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Pet Suppliers Store',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star, color: Colors.amber),
                Text(' ★ 4.8 (128 Reviews)'),
              ],
            ),
            const SizedBox(height: 24),

            // Shop info
            _buildInfoRow('Shop Name', 'Happy Pet Shop'),
            _buildInfoRow('Phone', '09 123 456 789'),
            _buildInfoRow('Email', 'happypet@gmail.com'),
            _buildInfoRow('Address', 'Thaton, Mon State'),
            _buildInfoRow('Business Hours', '9:00 AM - 8:00 PM'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}