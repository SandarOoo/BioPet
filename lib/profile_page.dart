import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Happy Pet Shop', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Pet Supplies Store • Rating 4.8 ⭐'),
            SizedBox(height: 16),
            Text('Phone: 09 123 456 789'),
            Text('Email: happypet@gmail.com'),
            Text('Address: Thaton, Mon State'),
            Text('Business Hours: 9:00 AM - 8:00 PM'),
          ],
        ),
      ),
    );
  }
}
