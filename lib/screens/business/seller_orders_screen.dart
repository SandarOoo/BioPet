import 'package:flutter/material.dart';

import '../../models/business_order.dart';
import '../../services/order_service.dart';

class SellerOrdersScreen extends StatefulWidget {
  final List<BusinessOrder> orders;

  final bool isLoading;

  final String? error;

  final Future<void> Function() onRefresh;

  const SellerOrdersScreen({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  @override
  State<SellerOrdersScreen> createState() =>
      _SellerOrdersScreenState();
}

class _SellerOrdersScreenState
    extends State<SellerOrdersScreen> {
  final OrderService orderService =
  OrderService();

  String? updatingOrderId;

  // =====================================================
  // UPDATE ORDER STATUS
  // =====================================================

  Future<void> updateStatus({
    required BusinessOrder order,
    required String status,
  }) async {
    if (updatingOrderId != null) {
      return;
    }

    setState(() {
      updatingOrderId = order.id;
    });

    try {
      await orderService.updateOrderStatus(
        orderId: order.id,
        status: status,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Order status updated to $status',
          ),
        ),
      );

      await widget.onRefresh();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update order: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          updatingOrderId = null;
        });
      }
    }
  }

  // =====================================================
  // STATUS BUTTON
  // =====================================================

  Widget buildStatusButtons(
      BusinessOrder order,
      ) {
    final status =
    order.status.toLowerCase();

    final isUpdating =
        updatingOrderId == order.id;

    // ---------------------------------------------------
    // PENDING
    // ---------------------------------------------------

    if (status == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isUpdating
              ? null
              : () {
            updateStatus(
              order: order,
              status: 'Confirmed',
            );
          },
          icon: isUpdating
              ? const SizedBox(
            width: 18,
            height: 18,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons.check_circle_outline,
          ),
          label: Text(
            isUpdating
                ? 'Updating...'
                : 'Confirm Order',
          ),
          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            Colors.green,
            foregroundColor:
            Colors.white,
            padding:
            const EdgeInsets.symmetric(
              vertical: 13,
            ),
          ),
        ),
      );
    }

    // ---------------------------------------------------
    // CONFIRMED
    // ---------------------------------------------------

    if (status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isUpdating
              ? null
              : () {
            updateStatus(
              order: order,
              status: 'Processing',
            );
          },
          icon: const Icon(
            Icons.inventory_2_outlined,
          ),
          label: const Text(
            'Start Processing',
          ),
          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            Colors.blue,
            foregroundColor:
            Colors.white,
            padding:
            const EdgeInsets.symmetric(
              vertical: 13,
            ),
          ),
        ),
      );
    }

    // ---------------------------------------------------
    // PROCESSING
    // ---------------------------------------------------

    if (status == 'processing') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isUpdating
              ? null
              : () {
            updateStatus(
              order: order,
              status: 'Shipped',
            );
          },
          icon: const Icon(
            Icons.local_shipping_outlined,
          ),
          label: const Text(
            'Mark as Shipped',
          ),
          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            Colors.deepPurple,
            foregroundColor:
            Colors.white,
            padding:
            const EdgeInsets.symmetric(
              vertical: 13,
            ),
          ),
        ),
      );
    }

    // ---------------------------------------------------
    // SHIPPED
    // ---------------------------------------------------

    if (status == 'shipped') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isUpdating
              ? null
              : () {
            updateStatus(
              order: order,
              status: 'Delivered',
            );
          },
          icon: const Icon(
            Icons.done_all,
          ),
          label: const Text(
            'Mark as Delivered',
          ),
          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            Colors.green,
            foregroundColor:
            Colors.white,
            padding:
            const EdgeInsets.symmetric(
              vertical: 13,
            ),
          ),
        ),
      );
    }

    // ---------------------------------------------------
    // DELIVERED / COMPLETED
    // ---------------------------------------------------

    if (status == 'delivered' ||
        status == 'completed') {
      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(12),
        decoration:
        BoxDecoration(
          color:
          Colors.green.shade50,
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color:
              Colors.green.shade700,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              'Order Completed',
              style: TextStyle(
                color:
                Colors.green.shade700,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // ---------------------------------------------------
    // CANCELLED
    // ---------------------------------------------------

    if (status == 'cancelled' ||
        status == 'canceled') {
      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(12),
        decoration:
        BoxDecoration(
          color:
          Colors.red.shade50,
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel,
              color:
              Colors.red.shade700,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              'Order Cancelled',
              style: TextStyle(
                color:
                Colors.red.shade700,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xffF6FAF7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        const Color(0xffF6FAF7),

        title: const Text(
          'Business Orders',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
            widget.onRefresh,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh:
        widget.onRefresh,

        child:
        _buildBody(),
      ),
    );
  }

  // =====================================================
  // BUILD BODY
  // =====================================================

  Widget _buildBody() {
    if (widget.isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (widget.error != null) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height: 400,

            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    const Icon(
                      Icons
                          .error_outline,
                      size: 60,
                      color:
                      Colors.red,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Text(
                      widget.error!,
                      textAlign:
                      TextAlign.center,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton.icon(
                      onPressed:
                      widget.onRefresh,
                      icon:
                      const Icon(
                        Icons.refresh,
                      ),
                      label:
                      const Text(
                        'Try Again',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.orders.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height: 400,

            child: Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,

                children: [
                  Icon(
                    Icons
                        .shopping_bag_outlined,
                    size: 70,
                    color: Colors
                        .grey
                        .shade400,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'No orders yet',
                    style:
                    TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'Customer orders will appear here.',
                    style:
                    TextStyle(
                      color: Colors
                          .grey
                          .shade600,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  OutlinedButton.icon(
                    onPressed:
                    widget.onRefresh,
                    icon:
                    const Icon(
                      Icons.refresh,
                    ),
                    label:
                    const Text(
                      'Refresh',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics:
      const AlwaysScrollableScrollPhysics(),

      padding:
      const EdgeInsets.all(
        16,
      ),

      itemCount:
      widget.orders.length,

      itemBuilder:
          (
          context,
          index,
          ) {
        final order =
        widget.orders[index];

        return BusinessOrderCard(
          order:
          order,

          statusButton:
          buildStatusButtons(
            order,
          ),
        );
      },
    );
  }
}

// ================================================================
// BUSINESS ORDER CARD
// ================================================================

class BusinessOrderCard
    extends StatelessWidget {
  final BusinessOrder order;

  final Widget statusButton;

  const BusinessOrderCard({
    super.key,
    required this.order,
    required this.statusButton,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 16,
      ),

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.05,
            ),

            blurRadius:
            10,

            offset:
            const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          // =================================================
          // ORDER NUMBER + STATUS
          // =================================================

          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,

                  style:
                  const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              OrderStatusBadge(
                status:
                order.status,
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          // =================================================
          // CUSTOMER
          // =================================================

          Row(
            children: [
              const Icon(
                Icons
                    .person_outline,
                size: 20,
                color:
                Colors.grey,
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: Text(
                  order.customer
                      .name,

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // =================================================
          // PHONE
          // =================================================

          if (order.customer
              .phone
              .isNotEmpty) ...[
            const SizedBox(
              height: 8,
            ),

            Row(
              children: [
                const Icon(
                  Icons
                      .phone_outlined,
                  size: 20,
                  color:
                  Colors.grey,
                ),

                const SizedBox(
                  width: 8,
                ),

                Text(
                  order.customer
                      .phone,
                ),
              ],
            ),
          ],

          const SizedBox(
            height: 12,
          ),

          // =================================================
          // ITEMS + TOTAL
          // =================================================

          Row(
            children: [
              const Icon(
                Icons
                    .inventory_2_outlined,
                size: 20,
                color:
                Colors.grey,
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                '${order.items.length} item(s)',
              ),

              const Spacer(),

              Text(
                '${order.totalAmount.toStringAsFixed(0)} MMK',

                style:
                const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Colors.green,
                ),
              ),
            ],
          ),

          // =================================================
          // ADDRESS
          // =================================================

          if (order.shippingAddress
              .address
              .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),

            Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                const Icon(
                  Icons
                      .location_on_outlined,
                  size: 20,
                  color:
                  Colors.grey,
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Text(
                    order.shippingAddress
                        .address,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(
            height: 16,
          ),

          // =================================================
          // STATUS ACTION BUTTON
          // =================================================

          statusButton,
        ],
      ),
    );
  }
}

// ================================================================
// ORDER STATUS BADGE
// ================================================================

class OrderStatusBadge
    extends StatelessWidget {
  final String status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    Color color;

    switch (
    status.toLowerCase()) {
      case 'pending':
        color =
            Colors.orange;
        break;

      case 'confirmed':
        color =
            Colors.blue;
        break;

      case 'processing':
        color =
            Colors.indigo;
        break;

      case 'shipped':
        color =
            Colors.purple;
        break;

      case 'delivered':
      case 'completed':
        color =
            Colors.green;
        break;

      case 'cancelled':
      case 'canceled':
        color =
            Colors.red;
        break;

      default:
        color =
            Colors.grey;
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
        status.toUpperCase(),

        style:
        TextStyle(
          color:
          color,
          fontSize:
          10,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }
}