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
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  static const Color _emerald = Color(0xFF065F46);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _cream = Color(0xFFFFF8E7);
  static const Color _ink = Color(0xFF102A24);
  static const Color _page = Color(0xFFF7FAF6);

  final OrderService orderService = OrderService();

  String? updatingOrderId;
  String selectedFilter = 'All';

  Future<void> updateStatus({
    required BusinessOrder order,
    required String status,
  }) async {
    if (updatingOrderId != null) return;

    setState(() => updatingOrderId = order.id);

    try {
      await orderService.updateOrderStatus(
        orderId: order.id,
        status: status,
      );

      if (!mounted) return;

      _showMessage('Order status updated to $status.');
      await widget.onRefresh();
    } catch (error) {
      if (mounted) {
        _showMessage('Failed to update order: $error', isError: true);
      }
    } finally {
      if (mounted) setState(() => updatingOrderId = null);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade700 : _ink,
      ),
    );
  }

  List<BusinessOrder> get filteredOrders {
    if (selectedFilter == 'All') return widget.orders;

    return widget.orders.where((order) {
      final status = order.status.toLowerCase();

      switch (selectedFilter) {
        case 'Pending':
          return status == 'pending';
        case 'Active':
          return status == 'confirmed' ||
              status == 'processing' ||
              status == 'shipped';
        case 'Completed':
          return status == 'delivered' ||
              status == 'completed' ||
              status == 'cancelled' ||
              status == 'canceled';
        default:
          return true;
      }
    }).toList();
  }

  Widget buildStatusAction(BusinessOrder order) {
    final status = order.status.toLowerCase();
    final isUpdating = updatingOrderId == order.id;

    if (status == 'pending') {
      return _OrderActionButton(
        label: isUpdating ? 'Updating...' : 'Confirm Order',
        icon: Icons.check_circle_outline_rounded,
        loading: isUpdating,
        onPressed: isUpdating
            ? null
            : () => updateStatus(order: order, status: 'Confirmed'),
      );
    }

    if (status == 'confirmed') {
      return _OrderActionButton(
        label: isUpdating ? 'Updating...' : 'Start Processing',
        icon: Icons.inventory_2_outlined,
        loading: isUpdating,
        onPressed: isUpdating
            ? null
            : () => updateStatus(order: order, status: 'Processing'),
      );
    }

    if (status == 'processing') {
      return _OrderActionButton(
        label: isUpdating ? 'Updating...' : 'Mark as Shipped',
        icon: Icons.local_shipping_outlined,
        loading: isUpdating,
        onPressed: isUpdating
            ? null
            : () => updateStatus(order: order, status: 'Shipped'),
      );
    }

    if (status == 'shipped') {
      return _OrderActionButton(
        label: isUpdating ? 'Updating...' : 'Mark as Delivered',
        icon: Icons.done_all_rounded,
        loading: isUpdating,
        onPressed: isUpdating
            ? null
            : () => updateStatus(order: order, status: 'Delivered'),
      );
    }

    if (status == 'delivered' || status == 'completed') {
      return const _FinalStatusBox(
        icon: Icons.check_circle_rounded,
        label: 'Order completed',
        background: Color(0xFFEAF7F1),
        foreground: _emerald,
      );
    }

    if (status == 'cancelled' || status == 'canceled') {
      return _FinalStatusBox(
        icon: Icons.cancel_rounded,
        label: 'Order cancelled',
        background: Colors.red.shade50,
        foreground: Colors.red.shade700,
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        surfaceTintColor: _page,
        elevation: 0,
        title: const Text(
          'Business Orders',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: widget.isLoading ? null : widget.onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: _ink),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: _emerald,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.isLoading && widget.orders.isEmpty) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 520,
            child: Center(
              child: CircularProgressIndicator(color: _emerald),
            ),
          ),
        ],
      );
    }

    if (widget.error != null && widget.orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 95),
          _OrdersEmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Orders could not be loaded',
            subtitle: 'Check your internet connection and try again.',
            buttonText: 'Try Again',
            onPressed: widget.onRefresh,
          ),
        ],
      );
    }

    if (widget.orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 80),
          _OrdersEmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'No orders yet',
            subtitle:
                'New customer orders will appear here as soon as they are placed.',
            buttonText: 'Refresh',
            onPressed: widget.onRefresh,
          ),
        ],
      );
    }

    final visibleOrders = filteredOrders;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
      children: [
        _OrdersSummary(orders: widget.orders),
        const SizedBox(height: 17),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Pending', 'Active', 'Completed']
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selectedFilter == filter,
                      onSelected: (_) => setState(() => selectedFilter = filter),
                      selectedColor: _emerald,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selectedFilter == filter ? Colors.white : _ink,
                        fontWeight: FontWeight.w800,
                      ),
                      side: const BorderSide(color: Color(0xFFDDE8E3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      showCheckmark: false,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 15),
        if (visibleOrders.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2ECE7)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.filter_alt_off_outlined,
                  color: _emerald,
                  size: 42,
                ),
                SizedBox(height: 12),
                Text(
                  'No orders in this category',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          ...visibleOrders.map(
            (order) => BusinessOrderCard(
              order: order,
              statusButton: buildStatusAction(order),
            ),
          ),
      ],
    );
  }
}

class _OrdersSummary extends StatelessWidget {
  final List<BusinessOrder> orders;

  const _OrdersSummary({required this.orders});

  @override
  Widget build(BuildContext context) {
    final pending = orders
        .where((order) => order.status.toLowerCase() == 'pending')
        .length;
    final active = orders.where((order) {
      final status = order.status.toLowerCase();
      return status == 'confirmed' ||
          status == 'processing' ||
          status == 'shipped';
    }).length;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF0B7A5B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF065F46).withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _SummaryNumber(label: 'Total', value: '${orders.length}'),
          Container(
            width: 1,
            height: 42,
            color: Colors.white.withOpacity(0.22),
          ),
          _SummaryNumber(label: 'Pending', value: '$pending'),
          Container(
            width: 1,
            height: 42,
            color: Colors.white.withOpacity(0.22),
          ),
          _SummaryNumber(label: 'Active', value: '$active'),
        ],
      ),
    );
  }

}

class _SummaryNumber extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryNumber({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final shownValue = value;

    return Expanded(
      child: Column(
        children: [
          Text(
            shownValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD9FFF1),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class BusinessOrderCard extends StatelessWidget {
  final BusinessOrder order;
  final Widget statusButton;

  const BusinessOrderCard({
    super.key,
    required this.order,
    required this.statusButton,
  });

  String _formatAmount(num amount) => '${amount.toStringAsFixed(0)} MMK';

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF065F46);
    const ink = Color(0xFF102A24);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2ECE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: emerald,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                        color: Color(0xFF6A7C76),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFE8EFEB)),
          ),
          _OrderDetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Customer',
            value: order.customer.name,
          ),
          if (order.customer.phone.isNotEmpty) ...[
            const SizedBox(height: 9),
            _OrderDetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: order.customer.phone,
            ),
          ],
          if (order.shippingAddress.address.isNotEmpty) ...[
            const SizedBox(height: 9),
            _OrderDetailRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: order.shippingAddress.address,
              multiline: true,
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F8F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Text(
                  'Order total',
                  style: TextStyle(
                    color: Color(0xFF60736E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatAmount(order.totalAmount),
                  style: const TextStyle(
                    color: emerald,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          statusButton,
        ],
      ),
    );
  }
}

class _OrderDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  const _OrderDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7A8D86)),
        const SizedBox(width: 9),
        SizedBox(
          width: 66,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A8D86),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF102A24),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;

  const _OrderActionButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF065F46),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF065F46).withOpacity(0.45),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _FinalStatusBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _FinalStatusBox({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: style.foreground,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.25,
        ),
      ),
    );
  }

  _StatusStyle _statusStyle(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return const _StatusStyle(
          background: Color(0xFFFFF3D6),
          foreground: Color(0xFF9A6500),
        );
      case 'confirmed':
        return const _StatusStyle(
          background: Color(0xFFE6F1FF),
          foreground: Color(0xFF1765A8),
        );
      case 'processing':
        return const _StatusStyle(
          background: Color(0xFFEDEBFF),
          foreground: Color(0xFF5041A8),
        );
      case 'shipped':
        return const _StatusStyle(
          background: Color(0xFFF3E8FF),
          foreground: Color(0xFF7A36A4),
        );
      case 'delivered':
      case 'completed':
        return const _StatusStyle(
          background: Color(0xFFE4F6EE),
          foreground: Color(0xFF065F46),
        );
      case 'cancelled':
      case 'canceled':
        return const _StatusStyle(
          background: Color(0xFFFFE9E9),
          foreground: Color(0xFFB3261E),
        );
      default:
        return const _StatusStyle(
          background: Color(0xFFF0F3F1),
          foreground: Color(0xFF60736E),
        );
    }
  }
}

class _StatusStyle {
  final Color background;
  final Color foreground;

  const _StatusStyle({
    required this.background,
    required this.foreground,
  });
}

class _OrdersEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final Future<void> Function() onPressed;

  const _OrdersEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8E7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF065F46), size: 50),
        ),
        const SizedBox(height: 22),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF102A24),
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF60736E),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF065F46),
            side: const BorderSide(color: Color(0xFF065F46)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(
            buttonText,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
