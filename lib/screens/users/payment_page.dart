import 'package:flutter/material.dart';
import 'order_summary_page.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../services/api_service.dart';

class PaymentPage extends StatefulWidget {
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String phone;
  final String address;
  final String note;
  final String deliveryType;

  const PaymentPage({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.phone,
    required this.address,
    required this.note,
    required this.deliveryType,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final OrderService orderService = OrderService();

  String selectedPayment = "KBZ_PAY";
  bool loading = false;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      "name": "KBZPay",
      "value": "KBZ_PAY",
      "icon": Icons.account_balance_wallet,
      "color": Colors.blue,
    },
    {
      "name": "Wave Pay",
      "value": "WAVE_PAY",
      "icon": Icons.phone_android,
      "color": Colors.orange,
    },
    {
      "name": "AYA Pay",
      "value": "AYA_PAY",
      "icon": Icons.account_balance_wallet,
      "color": Colors.green,
    },
    {
      "name": "Cash On Delivery",
      "value": "COD",
      "icon": Icons.local_shipping,
      "color": Colors.brown,
    },
  ];

  Future<void> _confirmPayment() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      // ==========================================
      // 1. GET CURRENT USER FROM BACKEND
      // ==========================================

      final currentUser =
      await ApiService.getCurrentUser();

      print("CURRENT USER RESPONSE => $currentUser");

      if (currentUser == null) {
        throw Exception(
          "User information not found. Please login again.",
        );
      }

      // ==========================================
      // 2. GET USER NAME
      // ==========================================

      final userData =
          currentUser['user'] ?? currentUser;

      final customerName =
          userData['name']?.toString() ?? '';

      print("CUSTOMER NAME => $customerName");

      if (customerName.isEmpty) {
        throw Exception(
          "Customer name not found.",
        );
      }

      // ==========================================
      // 3. PREPARE ITEMS
      // ==========================================

      final items = widget.items.map((item) {
        return {
          "product": item.product.id,
          "quantity": item.quantity,
        };
      }).toList();



      print("ORDER ITEMS => $items");

      // ==========================================
      // 4. CREATE ORDER
      // ==========================================

      final result =
      await orderService.createOrder(

        items: items,

        name: customerName,

        phone: widget.phone,

        address: widget.address,

        paymentMethod:
        selectedPayment,

      );

      print(
        "ORDER RESULT => $result",
      );

      if (!mounted) return;

      // ==========================================
      // 5. CLEAR CART
      // ==========================================

      CartService().clear();

      // ==========================================
      // 6. GET ORDER
      // ==========================================

      final order =
          result['order'] ?? result;

      // ==========================================
      // 7. GO TO SUMMARY
      // ==========================================

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
              OrderSummaryPage(

                order: order,

                subtotal:
                widget.subtotal,

                deliveryFee:
                widget.deliveryFee,

                total:
                widget.total,

                paymentMethod:
                selectedPayment,

                phone:
                widget.phone,

                address:
                widget.address,

              ),

        ),

      );

    } catch (e) {

      print(
        "CONFIRM PAYMENT ERROR => $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString()
                .replaceFirst(
              "Exception: ",
              "",
            ),
          ),
          backgroundColor:
          Colors.red,
        ),

      );

    } finally {

      if (mounted) {

        setState(() {
          loading = false;
        });

      }

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,

                itemBuilder: (context, index) {
                  final payment = paymentMethods[index];

                  return paymentCard(
                    payment["name"],
                    payment["value"],
                    payment["icon"],
                    payment["color"],
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "${widget.total.toStringAsFixed(0)} MMK",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed:
                      loading ? null : _confirmPayment,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),

                      child: loading
                          ? const SizedBox(
                        height: 20,
                        width: 20,

                        child:
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Confirm Payment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentCard(
      String name,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Material(
        color: Colors.transparent,

        borderRadius:
        BorderRadius.circular(18),

        child: RadioListTile<String>(
          value: value,

          groupValue:
          selectedPayment,

          onChanged:
          loading
              ? null
              : (value) {
            if (value == null) return;

            setState(() {
              selectedPayment = value;
            });
          },

          activeColor:
          Colors.orange,

          title: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                color.withOpacity(0.15),

                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const SizedBox(width: 15),

              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}