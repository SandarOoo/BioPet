import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {'id': '#1023', 'name': 'Chit Snow Oo', 'amount': '28,000 MMK', 'status': 'Pending'},
      {'id': '#1022', 'name': 'Zin Mar Aung', 'amount': '15,000 MMK', 'status': 'Completed'},
      {'id': '#1021', 'name': 'May Thu', 'amount': '9,500 MMK', 'status': 'Pending'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text('${order['id']} - ${order['name']}'),
            subtitle: Text(order['amount']!),
            trailing: Text(order['status']!, style: TextStyle(color: order['status'] == 'Completed' ? Colors.green : Colors.orange)),
          );
        },
      ),
    );
  }
}
