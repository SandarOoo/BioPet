import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Processing'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrderList(status: 'Pending'),
          OrderList(status: 'Processing'),
          OrderList(status: 'Completed'),
          OrderList(status: 'Cancelled'),
        ],
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final String status;
  const OrderList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Dummy orders
    final List<Map<String, String>> orders = [
      {'id': '#1023', 'customer': 'Chit Snow Oo', 'amount': '28,000 MMK'},
      {'id': '#1022', 'customer': 'Zin Mar Aung', 'amount': '15,000 MMK'},
      {'id': '#1021', 'customer': 'Aung Aung', 'amount': '9,500 MMK'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: Text('${order['id']} - ${order['customer']}'),
            subtitle: Text(order['amount']!),
            trailing: Chip(label: Text(status)),
            onTap: () {
              Navigator.pushNamed(context, '/order-details');
            },
          ),
        );
      },
    );
  }
}