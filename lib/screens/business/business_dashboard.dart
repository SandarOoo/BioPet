import 'package:flutter/material.dart';

import '../../models/business_order.dart';
import '../../services/api_service.dart';
import '../../services/business_service.dart';
import 'add_product_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_products_screen.dart';
import 'seller_profile_screen.dart';

class BusinessDashboard extends StatefulWidget {
  const BusinessDashboard({super.key});

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  static const Color _emerald = Color(0xFF065F46);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _page = Color(0xFFF7FAF6);
  static const Color _ink = Color(0xFF102A24);

  int currentIndex = 0;

  Map<String, dynamic>? currentUser;
  List<dynamic> products = [];
  List<BusinessOrder> orders = [];

  bool loadingUser = true;
  bool loadingProducts = true;
  bool loadingOrders = true;
  String? ordersError;

  final BusinessService businessService = BusinessService();

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    await Future.wait([
      loadCurrentUser(),
      loadProducts(),
      loadOrders(),
    ]);
  }

  Future<void> loadCurrentUser() async {
    try {
      final response = await ApiService.getCurrentUser();

      if (!mounted) return;

      Map<String, dynamic>? user;
      if (response != null &&
          response['user'] != null &&
          response['user'] is Map) {
        user = Map<String, dynamic>.from(response['user']);
      } else if (response != null) {
        user = Map<String, dynamic>.from(response);
      }

      setState(() {
        currentUser = user;
        loadingUser = false;
      });
    } catch (error) {
      debugPrint('LOAD CURRENT USER ERROR: $error');
      if (mounted) setState(() => loadingUser = false);
    }
  }

  Future<void> loadProducts() async {
    try {
      final result = await businessService.getProducts();

      if (!mounted) return;
      setState(() {
        products = result;
        loadingProducts = false;
      });
    } catch (error) {
      debugPrint('LOAD PRODUCTS ERROR: $error');
      if (mounted) setState(() => loadingProducts = false);
    }
  }

  Future<void> loadOrders() async {
    if (mounted) {
      setState(() {
        loadingOrders = true;
        ordersError = null;
      });
    }

    try {
      final result = await businessService.getBusinessOrders();
      final parsedOrders = <BusinessOrder>[];

      for (final item in result) {
        try {
          if (item is Map) {
            parsedOrders.add(
              BusinessOrder.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        } catch (error) {
          debugPrint('PARSE ORDER ERROR: $error');
        }
      }

      if (!mounted) return;
      setState(() {
        orders = parsedOrders;
        loadingOrders = false;
        ordersError = null;
      });
    } catch (error) {
      debugPrint('LOAD BUSINESS ORDERS ERROR: $error');
      if (!mounted) return;
      setState(() {
        loadingOrders = false;
        ordersError = error.toString();
      });
    }
  }

  String get ownerName {
    final name = currentUser?['name']?.toString();
    return name != null && name.trim().isNotEmpty ? name : 'Business Owner';
  }

  String get email => currentUser?['email']?.toString() ?? '';

  Map<String, dynamic> get businessProfile {
    final profile = currentUser?['businessProfile'];
    return profile is Map ? Map<String, dynamic>.from(profile) : {};
  }

  String get businessName {
    final name = businessProfile['businessName']?.toString();
    return name != null && name.trim().isNotEmpty ? name : 'My Pet Business';
  }

  String get businessType {
    final type = businessProfile['businessType']?.toString();
    return type == null || type.isEmpty
        ? 'Pet Business'
        : formatBusinessType(type);
  }

  String get businessAddress {
    final address = businessProfile['address']?.toString();
    return address != null && address.trim().isNotEmpty
        ? address
        : 'Business location not set';
  }

  String formatBusinessType(String type) {
    switch (type) {
      case 'vet_clinic':
        return 'Veterinary Clinic';
      case 'pet_shop':
        return 'Pet Shop';
      case 'grooming':
        return 'Pet Grooming';
      case 'other':
        return 'Pet Business';
      default:
        return type
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) => word.isEmpty
                  ? ''
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }

  List<BusinessOrder> get recentOrders =>
      orders.length <= 4 ? orders : orders.take(4).toList();

  Future<void> openAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
    await loadProducts();
  }

  void openOrders() {
    setState(() => currentIndex = 2);
    loadOrders();
  }

  List<Widget> get pages => [
        DashboardHome(
          businessName: businessName,
          businessType: businessType,
          businessAddress: businessAddress,
          ownerName: ownerName,
          productCount: products.length,
          orderCount: orders.length,
          recentOrders: recentOrders,
          loadingProducts: loadingProducts,
          loadingOrders: loadingOrders,
          onAddProduct: openAddProduct,
          onViewOrders: openOrders,
          onRefresh: loadDashboardData,
        ),
        const SellerProductsScreen(),
        SellerOrdersScreen(
          orders: orders,
          isLoading: loadingOrders,
          error: ordersError,
          onRefresh: loadOrders,
        ),
        SellerProfileScreen(
          ownerName: ownerName,
          email: email,
          businessName: businessName,
          businessType: businessType,
          businessAddress: businessAddress,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      body: loadingUser
          ? const Center(
              child: CircularProgressIndicator(color: _emerald),
            )
          : IndexedStack(
              index: currentIndex,
              children: pages,
            ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: _mint.withOpacity(0.58),
          labelTextStyle: MaterialStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(MaterialState.selected)
                  ? _emerald
                  : const Color(0xFF71847D),
              fontSize: 11,
              fontWeight: states.contains(MaterialState.selected)
                  ? FontWeight.w900
                  : FontWeight.w700,
            ),
          ),
          iconTheme: MaterialStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(MaterialState.selected)
                  ? _emerald
                  : const Color(0xFF71847D),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          height: 70,
          elevation: 0,
          onDestinationSelected: (index) {
            setState(() => currentIndex = index);
            if (index == 0) loadDashboardData();
            if (index == 1) loadProducts();
            if (index == 2) loadOrders();
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  static const Color _emerald = Color(0xFF065F46);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _cream = Color(0xFFFFF8E7);
  static const Color _ink = Color(0xFF102A24);
  static const Color _page = Color(0xFFF7FAF6);

  final String businessName;
  final String businessType;
  final String businessAddress;
  final String ownerName;
  final int productCount;
  final int orderCount;
  final List<BusinessOrder> recentOrders;
  final bool loadingProducts;
  final bool loadingOrders;
  final VoidCallback onAddProduct;
  final VoidCallback onViewOrders;
  final Future<void> Function() onRefresh;

  const DashboardHome({
    super.key,
    required this.businessName,
    required this.businessType,
    required this.businessAddress,
    required this.ownerName,
    required this.productCount,
    required this.orderCount,
    required this.recentOrders,
    required this.loadingProducts,
    required this.loadingOrders,
    required this.onAddProduct,
    required this.onViewOrders,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        surfaceTintColor: _page,
        elevation: 0,
        title: const Text(
          'Seller Center',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2ECE7)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onRefresh,
              icon: const Icon(
                Icons.refresh_rounded,
                color: _emerald,
                size: 21,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: _emerald,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              'Welcome back, $ownerName',
              style: const TextStyle(
                color: Color(0xFF71847D),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your business',
              style: TextStyle(
                color: _ink,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 19),
            _BusinessHeroCard(
              businessName: businessName,
              businessType: businessType,
              businessAddress: businessAddress,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Products',
                    value: loadingProducts ? '—' : '$productCount',
                    accent: _emerald,
                    background: _mint.withOpacity(0.38),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Orders',
                    value: loadingOrders ? '—' : '$orderCount',
                    accent: const Color(0xFF9A6500),
                    background: _cream,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick actions',
              style: TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_business_rounded,
                    title: 'Add product',
                    subtitle: 'Create a new listing',
                    onTap: onAddProduct,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.receipt_long_rounded,
                    title: 'View orders',
                    subtitle: 'Manage customer orders',
                    onTap: onViewOrders,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent orders',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onViewOrders,
                  style: TextButton.styleFrom(foregroundColor: _emerald),
                  child: const Text(
                    'View all',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (loadingOrders)
              const _DashboardLoadingCard()
            else if (recentOrders.isEmpty)
              const _NoRecentOrders()
            else
              ...recentOrders.map(
                (order) => _RecentOrderCard(
                  order: order,
                  onTap: onViewOrders,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BusinessHeroCard extends StatelessWidget {
  final String businessName;
  final String businessType;
  final String businessAddress;

  const _BusinessHeroCard({
    required this.businessName,
    required this.businessType,
    required this.businessAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF0B7A5B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF065F46).withOpacity(0.22),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFF065F46),
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessType,
                      style: const TextStyle(
                        color: Color(0xFFD9FFF1),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Color(0xFFA7F3D0),
                      size: 17,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    businessAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color background;

  const _DashboardStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE2ECE7)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF102A24),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF71847D),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: const Color(0xFFE2ECE7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFFA7F3D0).withOpacity(0.40),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF065F46),
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF102A24),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                style: const TextStyle(
                  color: Color(0xFF71847D),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  final BusinessOrder order;
  final VoidCallback onTap;

  const _RecentOrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE2ECE7)),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFF065F46),
                  size: 22,
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
                        color: Color(0xFF102A24),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF71847D),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} MMK',
                    style: const TextStyle(
                      color: Color(0xFF065F46),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  OrderStatusBadge(status: order.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardLoadingCard extends StatelessWidget {
  const _DashboardLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE2ECE7)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF065F46),
          strokeWidth: 2.2,
        ),
      ),
    );
  }
}

class _NoRecentOrders extends StatelessWidget {
  const _NoRecentOrders();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE2ECE7)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFF065F46),
            size: 39,
          ),
          SizedBox(height: 10),
          Text(
            'No recent orders',
            style: TextStyle(
              color: Color(0xFF102A24),
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Customer orders will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF71847D)),
          ),
        ],
      ),
    );
  }
}
