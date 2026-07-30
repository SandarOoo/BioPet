import 'package:flutter/material.dart';

import '../../models/business_order.dart';
import '../../services/api_service.dart';
import '../../services/business_service.dart';

import 'add_product_screen.dart';
import 'seller_products_screen.dart';
import 'seller_orders_screen.dart';

class BusinessDashboard extends StatefulWidget {
  const BusinessDashboard({
    super.key,
  });

  @override
  State<BusinessDashboard> createState() =>
      _BusinessDashboardState();
}

class _BusinessDashboardState
    extends State<BusinessDashboard> {
  // ============================================================
  // STATE
  // ============================================================

  int currentIndex = 0;

  Map<String, dynamic>? currentUser;

  List<dynamic> products = [];

  List<BusinessOrder> orders = [];

  bool loadingUser = true;
  bool loadingProducts = true;
  bool loadingOrders = true;

  String? ordersError;

  final BusinessService businessService =
  BusinessService();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadDashboardData();
  }

  // ============================================================
  // LOAD ALL DASHBOARD DATA
  // ============================================================

  Future<void> loadDashboardData() async {
    await Future.wait([
      loadCurrentUser(),
      loadProducts(),
      loadOrders(),
    ]);
  }

  // ============================================================
  // LOAD CURRENT USER
  // ============================================================

  Future<void> loadCurrentUser() async {
    try {
      final response =
      await ApiService.getCurrentUser();

      if (!mounted) return;

      Map<String, dynamic>? user;

      if (response != null &&
          response['user'] != null &&
          response['user'] is Map) {
        user = Map<String, dynamic>.from(
          response['user'],
        );
      } else if (response != null) {
        user = Map<String, dynamic>.from(
          response,
        );
      }

      setState(() {
        currentUser = user;
        loadingUser = false;
      });

      debugPrint(
        'CURRENT USER LOADED',
      );

      debugPrint(
        'BUSINESS NAME: $businessName',
      );

      debugPrint(
        'BUSINESS TYPE: $businessType',
      );
    } catch (e) {
      debugPrint(
        'LOAD CURRENT USER ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        loadingUser = false;
      });
    }
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> loadProducts() async {
    try {
      final result =
      await businessService.getProducts();

      if (!mounted) return;

      setState(() {
        products = result;
        loadingProducts = false;
      });

      debugPrint(
        'PRODUCTS COUNT: ${products.length}',
      );
    } catch (e) {
      debugPrint(
        'LOAD PRODUCTS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        loadingProducts = false;
      });
    }
  }

  // ============================================================
  // LOAD BUSINESS ORDERS
  // ============================================================

  Future<void> loadOrders() async {
    if (mounted) {
      setState(() {
        loadingOrders = true;
        ordersError = null;
      });
    }

    try {
      debugPrint(
        '========================================',
      );

      debugPrint(
        'LOADING BUSINESS ORDERS',
      );

      final result =
      await businessService.getBusinessOrders();

      debugPrint(
        'ORDERS API COUNT: ${result.length}',
      );

      final List<BusinessOrder> parsedOrders = [];

      for (final item in result) {
        try {
          if (item is! Map) {
            debugPrint(
              'INVALID ORDER ITEM',
            );

            continue;
          }

          final orderJson =
          Map<String, dynamic>.from(item);

          debugPrint(
            '----------------------------------------',
          );

          debugPrint(
            'ORDER ID: '
                '${orderJson['_id'] ?? ''}',
          );

          debugPrint(
            'ORDER NUMBER: '
                '${orderJson['orderNumber'] ?? ''}',
          );

          debugPrint(
            'ORDER STATUS: '
                '${orderJson['status'] ?? ''}',
          );

          final businessOrder =
          BusinessOrder.fromJson(
            orderJson,
          );

          debugPrint(
            'PARSED ORDER ID: '
                '${businessOrder.id}',
          );

          debugPrint(
            'PARSED ORDER NUMBER: '
                '${businessOrder.orderNumber}',
          );

          debugPrint(
            'PARSED ORDER STATUS: '
                '${businessOrder.status}',
          );

          parsedOrders.add(
            businessOrder,
          );
        } catch (e, stackTrace) {
          debugPrint(
            'PARSE ORDER ERROR: $e',
          );

          debugPrint(
            'STACK: $stackTrace',
          );
        }
      }

      if (!mounted) return;

      setState(() {
        orders = parsedOrders;
        loadingOrders = false;
        ordersError = null;
      });

      debugPrint(
        '========================================',
      );

      debugPrint(
        'BUSINESS ORDERS LOADED',
      );

      debugPrint(
        'TOTAL PARSED ORDERS: ${orders.length}',
      );

      debugPrint(
        '========================================',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'LOAD BUSINESS ORDERS ERROR: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      if (!mounted) return;

      setState(() {
        loadingOrders = false;
        ordersError = e.toString();
      });
    }
  }

  // ============================================================
  // USER DATA HELPERS
  // ============================================================

  String get ownerName {
    final name =
    currentUser?['name']?.toString();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'Business Owner';
  }

  String get email {
    return currentUser?['email']
        ?.toString() ??
        '';
  }

  Map<String, dynamic>
  get businessProfile {
    final profile =
    currentUser?['businessProfile'];

    if (profile is Map) {
      return Map<String, dynamic>.from(
        profile,
      );
    }

    return {};
  }

  String get businessName {
    final name =
    businessProfile['businessName']
        ?.toString();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'My Pet Business';
  }

  String get businessType {
    final type =
    businessProfile['businessType']
        ?.toString();

    if (type == null || type.isEmpty) {
      return 'Pet Business';
    }

    return formatBusinessType(type);
  }

  String get businessAddress {
    final address =
    businessProfile['address']
        ?.toString();

    if (address != null &&
        address.isNotEmpty) {
      return address;
    }

    return 'Business location not set';
  }

  String formatBusinessType(
      String type) {
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
              : word[0]
              .toUpperCase() +
              word.substring(1),
        )
            .join(' ');
    }
  }

  // ============================================================
  // RECENT ORDERS
  // ============================================================

  List<BusinessOrder>
  get recentOrders {
    if (orders.length <= 5) {
      return orders;
    }

    return orders.take(5).toList();
  }

  // ============================================================
  // OPEN ADD PRODUCT
  // ============================================================

  Future<void> openAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const AddProductScreen(),
      ),
    );

    await loadProducts();
  }

  // ============================================================
  // OPEN ALL ORDERS
  // ============================================================

  void openOrders() {
    setState(() {
      currentIndex = 2;
    });

    loadOrders();
  }

  // ============================================================
  // PAGES
  // ============================================================

  List<Widget> get pages {
    return [
      // ========================================================
      // PAGE 0 - DASHBOARD
      // ========================================================

      DashboardHome(
        businessName: businessName,
        businessType: businessType,
        businessAddress:
        businessAddress,
        ownerName: ownerName,
        email: email,
        productCount:
        products.length,
        orderCount: orders.length,
        recentOrders:
        recentOrders,
        loadingProducts:
        loadingProducts,
        loadingOrders:
        loadingOrders,
        onAddProduct:
        openAddProduct,
        onViewOrders:
        openOrders,
        onRefresh:
        loadDashboardData,
      ),

      // ========================================================
      // PAGE 1 - PRODUCTS
      // ========================================================

      const SellerProductsScreen(),

      // ========================================================
      // PAGE 2 - ORDERS
      // ========================================================

      SellerOrdersScreen(
        orders: orders,
        isLoading:
        loadingOrders,
        error: ordersError,
        onRefresh:
        loadOrders,
      ),

      // ========================================================
      // PAGE 3 - PROFILE
      // ========================================================

      // SellerProfileScreen(),
    ];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      body: loadingUser
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar:
      NavigationBar(
        selectedIndex:
        currentIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            currentIndex = index;
          });

          // Dashboard
          if (index == 0) {
            loadDashboardData();
          }

          // Products
          if (index == 1) {
            loadProducts();
          }

          // Orders
          if (index == 2) {
            loadOrders();
          }
        },

        indicatorColor:
        Colors.green.shade100,

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons
                  .dashboard_outlined,
            ),
            selectedIcon:
            Icon(
              Icons.dashboard,
            ),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(
              Icons
                  .inventory_2_outlined,
            ),
            selectedIcon:
            Icon(
              Icons.inventory_2,
            ),
            label: 'Products',
          ),

          NavigationDestination(
            icon: Icon(
              Icons
                  .shopping_bag_outlined,
            ),
            selectedIcon:
            Icon(
              Icons.shopping_bag,
            ),
            label: 'Orders',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon:
            Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// DASHBOARD HOME
// ==================================================================

class DashboardHome
    extends StatelessWidget {
  final String businessName;
  final String businessType;
  final String businessAddress;
  final String ownerName;
  final String email;

  final int productCount;
  final int orderCount;

  final List<BusinessOrder>
  recentOrders;

  final bool loadingProducts;
  final bool loadingOrders;

  final VoidCallback onAddProduct;

  final VoidCallback onViewOrders;

  final Future<void> Function()
  onRefresh;

  const DashboardHome({
    super.key,
    required this.businessName,
    required this.businessType,
    required this.businessAddress,
    required this.ownerName,
    required this.email,
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
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xffF6FAF7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        const Color(0xffF6FAF7),

        title: const Text(
          'Seller Center',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons
                  .notifications_none_rounded,
            ),
          ),

          const SizedBox(
            width: 8,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: onRefresh,

        child:
        SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            30,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // ==================================================
              // WELCOME
              // ==================================================

              Text(
                'Welcome back, '
                    '$ownerName 👋',

                style:
                const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              const Text(
                'Manage your business',

                style:
                TextStyle(
                  fontSize: 25,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // BUSINESS CARD
              // ==================================================

              Container(
                width:
                double.infinity,

                padding:
                const EdgeInsets.all(
                  20,
                ),

                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    colors: [
                      Colors.green
                          .shade800,
                      Colors.green
                          .shade600,
                    ],
                    begin:
                    Alignment.topLeft,
                    end: Alignment
                        .bottomRight,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    24,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.green
                          .withOpacity(
                        0.25,
                      ),
                      blurRadius: 18,
                      offset:
                      const Offset(
                        0,
                        8,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,

                          decoration:
                          BoxDecoration(
                            color:
                            Colors.white,
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),
                          ),

                          child:
                          const Icon(
                            Icons
                                .store_rounded,
                            color:
                            Colors.green,
                            size: 32,
                          ),
                        ),

                        const SizedBox(
                          width: 15,
                        ),

                        Expanded(
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [
                              Text(
                                businessName,

                                maxLines: 1,

                                overflow:
                                TextOverflow
                                    .ellipsis,

                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 21,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                businessType,

                                style:
                                const TextStyle(
                                  color:
                                  Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),

                      decoration:
                      BoxDecoration(
                        color: Colors.white
                            .withOpacity(
                          0.12,
                        ),

                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,
                            color:
                            Colors.white,
                            size: 20,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child: Text(
                              businessAddress,

                              maxLines: 2,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // OVERVIEW
              // ==================================================

              const Text(
                'Business Overview',

                style:
                TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              GridView.count(
                crossAxisCount: 2,

                crossAxisSpacing: 12,

                mainAxisSpacing: 12,

                childAspectRatio: 1.35,

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                children: [
                  DashboardStatCard(
                    icon: Icons
                        .inventory_2_outlined,
                    title: 'Products',
                    value:
                    loadingProducts
                        ? '...'
                        : productCount
                        .toString(),
                    iconColor:
                    Colors.green,
                  ),

                  DashboardStatCard(
                    icon: Icons
                        .shopping_bag_outlined,
                    title: 'Orders',
                    value:
                    loadingOrders
                        ? '...'
                        : orderCount
                        .toString(),
                    iconColor:
                    Colors.blue,
                  ),

                  const DashboardStatCard(
                    icon: Icons
                        .payments_outlined,
                    title: 'Revenue',
                    value: '0 MMK',
                    iconColor:
                    Colors.orange,
                  ),

                  const DashboardStatCard(
                    icon:
                    Icons.star_outline,
                    title: 'Rating',
                    value: '0.0',
                    iconColor:
                    Colors.amber,
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // QUICK ACTIONS
              // ==================================================

              const Text(
                'Quick Actions',

                style:
                TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                    QuickActionCard(
                      icon: Icons
                          .add_box_outlined,
                      title:
                      'Add Product',
                      subtitle:
                      'Create new product',
                      onTap:
                      onAddProduct,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                    QuickActionCard(
                      icon: Icons
                          .inventory_2_outlined,
                      title:
                      'My Products',
                      subtitle:
                      'Manage products',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // RECENT ORDERS HEADER
              // ==================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

                children: [
                  const Text(
                    'Recent Orders',

                    style:
                    TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed:
                    onViewOrders,

                    child:
                    const Text(
                      'View All',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // ORDERS
              // ==================================================

              if (loadingOrders)
                const Center(
                  child: Padding(
                    padding:
                    EdgeInsets.all(
                      30,
                    ),
                    child:
                    CircularProgressIndicator(),
                  ),
                )
              else if (recentOrders
                  .isEmpty)
                const EmptyOrdersCard()
              else
                Column(
                  children:
                  recentOrders
                      .map(
                        (
                        order,
                        ) =>
                        RecentOrderCard(
                          order:
                          order,
                        ),
                  )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// STAT CARD
// ==================================================================

class DashboardStatCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(
      BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(16),

      decoration:
      BoxDecoration(
        color: Colors.white,

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
            blurRadius: 10,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Container(
            width: 42,
            height: 42,

            decoration:
            BoxDecoration(
              color: iconColor
                  .withOpacity(
                0.1,
              ),

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            value,

            style:
            const TextStyle(
              fontSize: 19,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            title,

            style:
            const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// QUICK ACTION CARD
// ==================================================================

class QuickActionCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius:
      BorderRadius.circular(
        18,
      ),

      child: Container(
        padding:
        const EdgeInsets.all(16),

        decoration:
        BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(
            18,
          ),

          border: Border.all(
            color: Colors.green
                .shade100,
          ),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Icon(
              icon,
              color: Colors.green,
              size: 30,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              title,

              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              subtitle,

              style:
              const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// RECENT ORDER CARD
// ==================================================================

class RecentOrderCard
    extends StatelessWidget {
  final BusinessOrder order;

  const RecentOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(
      BuildContext context) {
    return Container(
      width:
      double.infinity,

      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
      const EdgeInsets.all(16),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 15,
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
            height: 12,
          ),

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
                  order.customer.name,
                ),
              ),

              Text(
                '${order.totalAmount.toStringAsFixed(0)} MMK',

                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

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
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ORDER STATUS BADGE
// ==================================================================

class OrderStatusBadge
    extends StatelessWidget {
  final String status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(
      BuildContext context) {
    Color color;

    switch (
    status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;

      case 'confirmed':
        color = Colors.blue;
        break;

      case 'processing':
        color = Colors.indigo;
        break;

      case 'shipped':
        color = Colors.purple;
        break;

      case 'delivered':
      case 'completed':
        color = Colors.green;
        break;

      case 'cancelled':
      case 'canceled':
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
        color: color.withOpacity(
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
          color: color,
          fontSize: 10,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }
}

// ==================================================================
// EMPTY ORDERS
// ==================================================================

class EmptyOrdersCard
    extends StatelessWidget {
  const EmptyOrdersCard({
    super.key,
  });

  @override
  Widget build(
      BuildContext context) {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(28),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),

      child: Column(
        children: [
          Icon(
            Icons
                .shopping_bag_outlined,
            size: 48,
            color:
            Colors.grey.shade400,
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'No orders yet',

            style:
            TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'Your recent customer orders will appear here.',

            textAlign:
            TextAlign.center,

            style:
            TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}