import 'package:flutter/material.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({
    super.key,
  });

  @override
  State<SellerOrdersScreen> createState() =>
      _SellerOrdersScreenState();
}

class _SellerOrdersScreenState
    extends State<SellerOrdersScreen> {

  String selectedFilter = 'All';

  // ===========================================================
  // TEMPORARY ORDERS
  // Later this will come from your backend API
  // ===========================================================

  final List<Map<String, dynamic>> orders = [
    {
      'id': '#ORD-1001',
      'customer': {
        'name': 'Chit Snow Oo',
        'phone': '09 123456789',
      },
      'items': 2,
      'total': 28000,
      'status': 'Pending',
      'date': 'Today, 10:30 AM',
    },
    {
      'id': '#ORD-1002',
      'customer': {
        'name': 'Zin Mar Aung',
        'phone': '09 987654321',
      },
      'items': 1,
      'total': 15000,
      'status': 'Confirmed',
      'date': 'Yesterday',
    },
    {
      'id': '#ORD-1003',
      'customer': {
        'name': 'Aung Aung',
        'phone': '09 555555555',
      },
      'items': 3,
      'total': 45000,
      'status': 'Processing',
      'date': 'Jul 22, 2026',
    },
    {
      'id': '#ORD-1004',
      'customer': {
        'name': 'Su Su',
        'phone': '09 777777777',
      },
      'items': 1,
      'total': 12000,
      'status': 'Completed',
      'date': 'Jul 20, 2026',
    },
  ];

  // ===========================================================
  // FILTERED ORDERS
  // ===========================================================

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedFilter == 'All') {
      return orders;
    }

    return orders
        .where(
          (order) =>
      order['status'] == selectedFilter,
    )
        .toList();
  }

  // ===========================================================
  // CUSTOMER NAME
  // ===========================================================

  String getCustomerName(
      Map<String, dynamic> order) {

    final customer = order['customer'];

    if (customer is Map) {
      return customer['name']
          ?.toString() ??
          '';
    }

    return customer?.toString() ?? '';
  }

  // ===========================================================
  // CUSTOMER PHONE
  // ===========================================================

  String getCustomerPhone(
      Map<String, dynamic> order) {

    final customer = order['customer'];

    if (customer is Map) {
      return customer['phone']
          ?.toString() ??
          '';
    }

    return order['phone']
        ?.toString() ??
        '';
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xffF6FAF7),

      appBar: AppBar(

        backgroundColor:
        const Color(0xffF6FAF7),

        elevation: 0,

        title: const Text(
          'Orders',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(
            onPressed: () {

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content:
                  Text('Search coming soon'),
                ),
              );

            },
            icon: const Icon(
              Icons.search,
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),

        ],
      ),

      body: Column(
        children: [

          // =====================================================
          // SUMMARY
          // =====================================================

          Padding(
            padding:
            const EdgeInsets.all(16),

            child: Row(
              children: [

                Expanded(
                  child: _summaryCard(
                    'Pending',
                    orders
                        .where(
                          (e) =>
                      e['status'] ==
                          'Pending',
                    )
                        .length
                        .toString(),
                    Colors.orange,
                    Icons.pending_actions,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: _summaryCard(
                    'Processing',
                    orders
                        .where(
                          (e) =>
                      e['status'] ==
                          'Processing',
                    )
                        .length
                        .toString(),
                    Colors.blue,
                    Icons.local_shipping_outlined,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: _summaryCard(
                    'Completed',
                    orders
                        .where(
                          (e) =>
                      e['status'] ==
                          'Completed',
                    )
                        .length
                        .toString(),
                    Colors.green,
                    Icons.check_circle_outline,
                  ),
                ),

              ],
            ),
          ),

          // =====================================================
          // FILTER
          // =====================================================

          SizedBox(
            height: 45,

            child: ListView(
              scrollDirection:
              Axis.horizontal,

              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              children: [

                _filterButton('All'),

                _filterButton('Pending'),

                _filterButton('Confirmed'),

                _filterButton('Processing'),

                _filterButton('Completed'),

                _filterButton('Cancelled'),

              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // =====================================================
          // ORDER LIST
          // =====================================================

          Expanded(

            child:
            filteredOrders.isEmpty

                ? _emptyOrders()

                : ListView.builder(

              padding:
              const EdgeInsets.fromLTRB(
                16,
                5,
                16,
                30,
              ),

              itemCount:
              filteredOrders.length,

              itemBuilder:
                  (context, index) {

                final order =
                filteredOrders[index];

                return _orderCard(
                  order,
                );

              },
            ),
          ),

        ],
      ),
    );
  }

  // ===========================================================
  // SUMMARY CARD
  // ===========================================================

  Widget _summaryCard(
      String title,
      String value,
      Color color,
      IconData icon,
      ) {

    return Container(

      padding:
      const EdgeInsets.all(12),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.04,
            ),

            blurRadius: 8,

            offset:
            const Offset(0, 3),
          ),

        ],
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: color,
            size: 25,
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            value,

            style:
            const TextStyle(
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          Text(
            title,

            style:
            const TextStyle(
              fontSize: 11,
              color:
              Colors.grey,
            ),
          ),

        ],
      ),
    );
  }

  // ===========================================================
  // FILTER BUTTON
  // ===========================================================

  Widget _filterButton(
      String filter) {

    final selected =
        selectedFilter == filter;

    return Padding(

      padding:
      const EdgeInsets.only(
        right: 8,
      ),

      child: ChoiceChip(

        label:
        Text(filter),

        selected:
        selected,

        onSelected: (_) {

          setState(() {

            selectedFilter =
                filter;

          });

        },

        selectedColor:
        Colors.green.shade100,

        labelStyle:
        TextStyle(

          color: selected
              ? Colors.green.shade800
              : Colors.grey.shade700,

          fontWeight: selected
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  // ===========================================================
  // ORDER CARD
  // ===========================================================

  Widget _orderCard(
      Map<String, dynamic> order) {

    final customerName =
    getCustomerName(order);

    final phone =
    getCustomerPhone(order);

    return Card(

      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      elevation: 0,

      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(18),

        side:
        BorderSide(
          color:
          Colors.grey.shade200,
        ),
      ),

      child: InkWell(

        borderRadius:
        BorderRadius.circular(18),

        onTap: () {

          _showOrderDetails(
            order,
          );

        },

        child: Padding(

          padding:
          const EdgeInsets.all(16),

          child: Column(
            children: [

              // =================================================
              // ORDER HEADER
              // =================================================

              Row(
                children: [

                  Container(

                    width: 45,
                    height: 45,

                    decoration:
                    BoxDecoration(

                      color:
                      Colors.green
                          .withOpacity(
                        0.1,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        13,
                      ),
                    ),

                    child:
                    const Icon(
                      Icons
                          .shopping_bag_outlined,

                      color:
                      Colors.green,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          order['id']
                              ?.toString() ??
                              '',

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,

                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          order['date']
                              ?.toString() ??
                              '',

                          style:
                          const TextStyle(
                            color:
                            Colors.grey,

                            fontSize: 12,
                          ),
                        ),

                      ],
                    ),
                  ),

                  _statusBadge(
                    order['status']
                        ?.toString() ??
                        '',
                  ),

                ],
              ),

              const SizedBox(
                height: 15,
              ),

              const Divider(
                height: 1,
              ),

              const SizedBox(
                height: 15,
              ),

              // =================================================
              // CUSTOMER
              // =================================================

              Row(
                children: [

                  const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Colors.grey,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          customerName,

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),

                        Text(
                          phone,

                          style:
                          const TextStyle(
                            color:
                            Colors.grey,

                            fontSize: 12,
                          ),
                        ),

                      ],
                    ),
                  ),

                  Column(

                    crossAxisAlignment:
                    CrossAxisAlignment
                        .end,

                    children: [

                      Text(
                        '${order['total']} MMK',

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,

                          fontSize: 16,

                          color:
                          Colors.green,
                        ),
                      ),

                      Text(
                        '${order['items']} items',

                        style:
                        const TextStyle(
                          color:
                          Colors.grey,

                          fontSize: 12,
                        ),
                      ),

                    ],
                  ),

                ],
              ),

              const SizedBox(
                height: 15,
              ),

              // =================================================
              // ACTION BUTTON
              // =================================================

              _buildActionButton(
                order,
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // ACTION BUTTON
  // ===========================================================

  Widget _buildActionButton(
      Map<String, dynamic> order) {

    final status =
    order['status'];

    if (status == 'Pending') {

      return _actionButton(
        'Accept Order',
        Colors.green,
            () {

          _updateStatus(
            order,
            'Confirmed',
          );

        },
      );
    }

    if (status == 'Confirmed') {

      return _actionButton(
        'Start Processing',
        Colors.blue,
            () {

          _updateStatus(
            order,
            'Processing',
          );

        },
      );
    }

    if (status == 'Processing') {

      return _actionButton(
        'Mark Completed',
        Colors.green,
            () {

          _updateStatus(
            order,
            'Completed',
          );

        },
      );
    }

    return const SizedBox.shrink();
  }

  // ===========================================================
  // ACTION BUTTON UI
  // ===========================================================

  Widget _actionButton(
      String text,
      Color color,
      VoidCallback onPressed,
      ) {

    return SizedBox(

      width:
      double.infinity,

      child:
      ElevatedButton(

        onPressed:
        onPressed,

        style:
        ElevatedButton.styleFrom(

          backgroundColor:
          color,

          foregroundColor:
          Colors.white,

          padding:
          const EdgeInsets.symmetric(
            vertical: 13,
          ),

          shape:
          RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),
        ),

        child:
        Text(text),
      ),
    );
  }

  // ===========================================================
  // STATUS BADGE
  // ===========================================================

  Widget _statusBadge(
      String status) {

    Color color;

    switch (status) {

      case 'Pending':
        color = Colors.orange;
        break;

      case 'Confirmed':
        color = Colors.blue;
        break;

      case 'Processing':
        color = Colors.indigo;
        break;

      case 'Completed':
        color = Colors.green;
        break;

      case 'Cancelled':
        color = Colors.red;
        break;

      default:
        color = Colors.grey;
    }

    return Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration:
      BoxDecoration(

        color:
        color.withOpacity(
          0.1,
        ),

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: Text(

        status,

        style:
        TextStyle(

          color:
          color,

          fontSize: 11,

          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  // ===========================================================
  // ORDER DETAILS
  // ===========================================================

  void _showOrderDetails(
      Map<String, dynamic> order) {

    final customerName =
    getCustomerName(order);

    final phone =
    getCustomerPhone(order);

    showModalBottomSheet(

      context: context,

      isScrollControlled:
      true,

      backgroundColor:
      Colors.transparent,

      builder: (context) {

        return Container(

          padding:
          const EdgeInsets.all(20),

          decoration:
          const BoxDecoration(

            color:
            Colors.white,

            borderRadius:
            BorderRadius.vertical(
              top:
              Radius.circular(25),
            ),
          ),

          child: Column(

            mainAxisSize:
            MainAxisSize.min,

            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [

              Center(

                child: Container(

                  width: 45,
                  height: 5,

                  decoration:
                  BoxDecoration(

                    color:
                    Colors.grey.shade300,

                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(

                'Order Details',

                style:
                TextStyle(

                  fontSize: 22,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              _detailRow(
                'Order ID',
                order['id']
                    ?.toString() ??
                    '',
              ),

              _detailRow(
                'Customer',
                customerName,
              ),

              _detailRow(
                'Phone',
                phone,
              ),

              _detailRow(
                'Items',
                '${order['items']} items',
              ),

              _detailRow(
                'Total',
                '${order['total']} MMK',
              ),

              _detailRow(
                'Status',
                order['status']
                    ?.toString() ??
                    '',
              ),

              _detailRow(
                'Date',
                order['date']
                    ?.toString() ??
                    '',
              ),

              const SizedBox(
                height: 15,
              ),

              SizedBox(

                width:
                double.infinity,

                child:
                ElevatedButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );

                  },

                  child:
                  const Text(
                    'Close',
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

            ],
          ),
        );
      },
    );
  }

  // ===========================================================
  // DETAIL ROW
  // ===========================================================

  Widget _detailRow(
      String title,
      String value,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        children: [

          SizedBox(

            width: 90,

            child: Text(

              title,

              style:
              const TextStyle(
                color:
                Colors.grey,
              ),
            ),
          ),

          Expanded(

            child: Text(

              value,

              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

        ],
      ),
    );
  }

  // ===========================================================
  // UPDATE STATUS
  // ===========================================================

  void _updateStatus(
      Map<String, dynamic> order,
      String newStatus,
      ) {

    setState(() {

      order['status'] =
          newStatus;

    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(

        content: Text(
          'Order ${order['id']} updated to $newStatus',
        ),

        behavior:
        SnackBarBehavior
            .floating,
      ),
    );
  }

  // ===========================================================
  // EMPTY ORDERS
  // ===========================================================

  Widget _emptyOrders() {

    return Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(

            Icons
                .shopping_bag_outlined,

            size: 70,

            color:
            Colors.grey.shade400,
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(

            'No Orders Found',

            style:
            TextStyle(

              fontSize: 18,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(

            'Orders matching this filter will appear here.',

            textAlign:
            TextAlign.center,

            style:
            TextStyle(

              color:
              Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}