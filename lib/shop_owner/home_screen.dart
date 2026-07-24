import 'package:flutter/material.dart';
//import 'package:biopet_shop/screens/order_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bio Pet Seiler Center'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('View Shop'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Edit Shop'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop header
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/100',
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Happy Pet Shop',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Thaton, Myanmar'),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ★ 4.8'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Overview stats
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard('25 Products', Icons.inventory),
                _buildStatCard('18 Orders', Icons.shopping_bag),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard('320,000 Total Revenue', Icons.attach_money),
                _buildStatCard('4.8 Shop Rating', Icons.star),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Orders
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRecentOrderCard(
              context,
              orderId: '#1023',
              customer: 'Chit Snow Oo',
              amount: '28,000 MMK',
              status: 'May Thu', // status? using as note
            ),
            _buildRecentOrderCard(
              context,
              orderId: '#1022',
              customer: 'Zin Mar Aung',
              amount: '15,000 MMK',
              status: '9,500 MMK', // note
            ),
            const SizedBox(height: 24),

            // Products quick view
            const Text(
              'Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatusChip('Pending', '10 mins ago'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusChip('Completed', '1 hour ago'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Orders tabs quick view
            const Text(
              'Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Pending')),
                Chip(label: Text('Processing')),
                Chip(label: Text('Completed')),
                Chip(label: Text('Cancelled')),
              ],
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to add new product
                },
                child: const Text('Add New Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard(
      BuildContext context, {
        required String orderId,
        required String customer,
        required String amount,
        required String status,
      }) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: Text('$orderId - $customer'),
        subtitle: Text(amount),
        trailing: Text(status),
        onTap: () {
          Navigator.pushNamed(context, '/order-details');
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, String time) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(time, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}