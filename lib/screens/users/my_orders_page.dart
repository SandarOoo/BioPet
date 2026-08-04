import 'package:flutter/material.dart';

import '../../services/order_service.dart';
import 'order_detail_page.dart';
import 'user_shop_theme.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final OrderService orderService = OrderService();

  List<dynamic> orders = [];
  bool loading = true;
  String? error;

  final List<String> statuses = [
    'Pending',
    'Shipping',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: statuses.length, vsync: this);
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

      final data = await orderService.getMyOrders();

      if (!mounted) return;
      setState(() {
        orders = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<dynamic> filteredOrders(String status) {
    return orders.where((order) {
      final orderStatus = order['status']?.toString() ?? '';
      return orderStatus == status;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UserShopTheme.background,
      appBar: UserShopTheme.appBar(
        'My Orders',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: UserShopTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: UserShopTheme.border),
            ),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: UserShopTheme.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800),
              unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w700),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: UserShopTheme.emerald,
                borderRadius: BorderRadius.circular(13),
              ),
              tabs: statuses.map((status) => Tab(text: status)).toList(),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: UserShopTheme.emerald),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: UserShopTheme.card(color: UserShopTheme.cream),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  color: UserShopTheme.danger,
                  size: 48,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Could not load orders',
                  style: TextStyle(
                    color: UserShopTheme.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: UserShopTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: loadOrders,
                  style: UserShopTheme.primaryButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return TabBarView(
      controller: tabController,
      children: statuses.map(_orderList).toList(),
    );
  }

  Widget _orderList(String status) {
    final filtered = filteredOrders(status);

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadOrders,
        color: UserShopTheme.emerald,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            _EmptyOrders(status: status),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadOrders,
      color: UserShopTheme.emerald,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final order = Map<String, dynamic>.from(filtered[index] as Map);
          return _orderCard(order);
        },
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final items = order['items'] as List? ?? [];
    final firstItem = items.isNotEmpty ? items.first as Map? : null;

    final image = firstItem?['image']?.toString() ?? '';
    final name = firstItem?['name']?.toString() ?? 'Product';
    final quantity = firstItem?['quantity']?.toString() ?? '1';
    final total = order['totalAmount']?.toString() ?? '0';
    final orderNumber = order['orderNumber']?.toString() ?? '';
    final status = order['status']?.toString() ?? 'Pending';
    final moreItems = items.length > 1 ? items.length - 1 : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: UserShopTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORDER NUMBER',
                      style: TextStyle(
                        color: UserShopTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '#$orderNumber',
                      style: const TextStyle(
                        color: UserShopTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: UserShopTheme.border, height: 1),
          ),
          Row(
            children: [
              Container(
                height: 78,
                width: 78,
                decoration: BoxDecoration(
                  color: UserShopTheme.cream,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: image.isNotEmpty
                      ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.pets_rounded,
                      size: 40,
                      color: UserShopTheme.emerald,
                    ),
                  )
                      : const Icon(
                    Icons.pets_rounded,
                    size: 40,
                    color: UserShopTheme.emerald,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: UserShopTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      moreItems > 0
                          ? 'Qty: $quantity  ·  +$moreItems more item${moreItems > 1 ? 's' : ''}'
                          : 'Quantity: $quantity',
                      style: const TextStyle(
                        color: UserShopTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$total MMK',
                      style: const TextStyle(
                        color: UserShopTheme.emerald,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailPage(
                      orderId: order['_id']?.toString(),
                    ),
                  ),
                );

                if (result == true) loadOrders();
              },
              style: UserShopTheme.outlineButton(
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
              icon: const Icon(Icons.visibility_outlined, size: 19),
              label: const Text(
                'View Details',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final String status;

  const _EmptyOrders({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: const BoxDecoration(
              color: UserShopTheme.mintSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 50,
              color: UserShopTheme.emerald,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'No $status orders',
            style: const TextStyle(
              color: UserShopTheme.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pull down to refresh your order list.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: UserShopTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case 'Delivered':
        color = UserShopTheme.emerald;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'Shipping':
        color = UserShopTheme.info;
        icon = Icons.local_shipping_outlined;
        break;
      case 'Cancelled':
        color = UserShopTheme.danger;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = UserShopTheme.warning;
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
