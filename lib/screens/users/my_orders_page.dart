import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import 'order_detail_page.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({
    super.key,
  });

  @override
  State<MyOrdersPage> createState() =>
      _MyOrdersPageState();
}

class _MyOrdersPageState
    extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {

  late TabController tabController;

  final OrderService orderService =
  OrderService();

  List<dynamic> orders = [];

  bool loading = true;

  String? error;

  final List<String> statuses = [
    "Pending",
    "Shipping",
    "Delivered",
    "Cancelled",
  ];

  @override
  void initState() {
    super.initState();

    tabController =
        TabController(
          length: 4,
          vsync: this,
        );

    loadOrders();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> loadOrders() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final data =
      await orderService
          .getMyOrders();

      setState(() {
        orders = data;
        loading = false;
      });

    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  List<dynamic> filteredOrders(
      String status) {

    return orders.where((order) {
      final orderStatus =
          order['status']
              ?.toString() ??
              '';

      return orderStatus ==
          status;
    }).toList();
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xffF7F7F7),

      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(
            color: Colors.black,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        centerTitle: true,

        backgroundColor:
        Colors.white,

        elevation: 0,

        iconTheme:
        const IconThemeData(
          color: Colors.black,
        ),

        bottom: TabBar(
          controller:
          tabController,

          isScrollable: true,

          labelColor:
          Colors.orange,

          unselectedLabelColor:
          Colors.grey,

          indicatorColor:
          Colors.orange,

          tabs: statuses.map(
                (e) {
              return Tab(
                text: e,
              );
            },
          ).toList(),
        ),
      ),

      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : error != null
          ? Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Text(error!),

            const SizedBox(
              height: 15,
            ),

            ElevatedButton(
              onPressed:
              loadOrders,
              child:
              const Text(
                "Retry",
              ),
            ),
          ],
        ),
      )

          : TabBarView(
        controller:
        tabController,

        children:
        statuses.map(
              (status) {
            return orderList(
              status,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget orderList(
      String status) {

    final filtered =
    filteredOrders(status);

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "No orders found",
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
      loadOrders,

      child: ListView.builder(
        padding:
        const EdgeInsets.all(16),

        itemCount:
        filtered.length,

        itemBuilder:
            (context, index) {

          return orderCard(
            filtered[index],
          );
        },
      ),
    );
  }

  Widget orderCard(
      Map<String, dynamic> order) {

    final items =
        order['items']
        as List? ??
            [];

    final firstItem =
    items.isNotEmpty
        ? items.first
        : {};

    final image =
        firstItem['image']
            ?.toString() ??
            '';

    final name =
        firstItem['name']
            ?.toString() ??
            'Product';

    final quantity =
        firstItem['quantity']
            ?.toString() ??
            '1';

    final total =
        order['totalAmount']
            ?.toString() ??
            '0';

    final orderNumber =
        order['orderNumber']
            ?.toString() ??
            '';

    final status =
        order['status']
            ?.toString() ??
            'Pending';

    final orderId =
        order['_id']
            ?.toString() ??
            '';

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 15,
      ),

      padding:
      const EdgeInsets.all(15),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

            children: [

              Text(
                "Order #$orderNumber",

                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,

                  fontSize: 16,
                ),
              ),

              statusBadge(
                status,
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Row(
            children: [

              ClipRRect(
                borderRadius:
                BorderRadius.circular(
                  12,
                ),

                child:
                image.isNotEmpty
                    ? Image.network(
                  image,

                  height: 70,

                  width: 70,

                  fit:
                  BoxFit.cover,

                  errorBuilder:
                      (_, __, ___) {
                    return const Icon(
                      Icons.pets,
                      size: 50,
                    );
                  },
                )
                    : const Icon(
                  Icons.pets,
                  size: 50,
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Text(
                      name,

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      "Quantity: $quantity",
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      "$total MMK",

                      style:
                      const TextStyle(
                        color:
                        Colors.green,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          SizedBox(
            width:
            double.infinity,

            height: 45,

            child:
            OutlinedButton(
              onPressed: () async {

                final result =
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailPage(orderId: order['_id']),
                  ),
                );

                if (result == true) {
                  loadOrders();
                }
              },

              style:
              OutlinedButton.styleFrom(
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
              ),

              child:
              const Text(
                "View Details",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statusBadge(
      String status) {

    Color color;

    if (status ==
        "Delivered") {
      color = Colors.green;
    } else if (status ==
        "Shipping") {
      color = Colors.blue;
    } else if (status ==
        "Cancelled") {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration:
      BoxDecoration(
        color:
        color.withOpacity(
          0.15,
        ),

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: Text(
        status,

        style: TextStyle(
          color: color,

          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }
}