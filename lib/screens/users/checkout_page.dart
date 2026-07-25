import 'package:flutter/material.dart';
import 'payment_page.dart';
import '../../services/cart_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;

  const CheckoutPage({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String deliveryType = "Standard Delivery";

  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    noteController.dispose();
    super.dispose();
  }

  double get currentDeliveryFee =>
      deliveryType == "Express Delivery" ? widget.deliveryFee + 2000 : widget.deliveryFee;

  double get total => widget.subtotal + currentDeliveryFee;

  void _continueToPayment() {
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your phone number")),
      );
      return;
    }

    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your delivery address")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          items: widget.items,
          subtotal: widget.subtotal,
          deliveryFee: currentDeliveryFee,
          total: total,
          phone: phoneController.text.trim(),
          address: addressController.text.trim(),
          note: noteController.text.trim(),
          deliveryType: deliveryType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
            sectionTitle("Delivery Address"),
            const SizedBox(height: 10),
            addressCard(),
            const SizedBox(height: 25),
            sectionTitle("Delivery Option"),
            const SizedBox(height: 10),
            deliveryOption("Standard Delivery", "2-3 Days"),
            deliveryOption("Express Delivery", "1 Day (+2,000 MMK)"),
            const SizedBox(height: 25),
            sectionTitle("Order Note"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Write note for seller",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 25),
            sectionTitle("Order Summary"),
            const SizedBox(height: 10),
            summaryCard(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _continueToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  "Continue Payment",
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold));
  }

  Widget addressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Phone Number",
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: "Delivery Address",
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget deliveryOption(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: RadioListTile(
        value: title,
        groupValue: deliveryType,
        onChanged: (value) {
          setState(() => deliveryType = value.toString());
        },
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        activeColor: Colors.orange,
      ),
    );
  }

  Widget summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          ...widget.items.map(
                (item) => summaryRow(
              "${item.product.name} x${item.quantity}",
              "${item.lineTotal.toStringAsFixed(0)} MMK",
            ),
          ),
          const Divider(),
          summaryRow("Subtotal", "${widget.subtotal.toStringAsFixed(0)} MMK"),
          summaryRow("Delivery Fee", "${currentDeliveryFee.toStringAsFixed(0)} MMK"),
          const Divider(),
          summaryRow("Total", "${total.toStringAsFixed(0)} MMK", bold: true),
        ],
      ),
    );
  }

  Widget summaryRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}