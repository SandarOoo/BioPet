import 'package:flutter/material.dart';

import '../../models/business_order.dart';
import '../../services/api_service.dart';
import '../../services/business_service.dart';

import 'add_product_screen.dart';
import 'seller_products_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_profile_screen.dart';

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
  int currentIndex = 0;

  Map<String, dynamic>? currentUser;

  List<dynamic> products = [];

  List<BusinessOrder> _orders = [];

  String? _ordersError;

  bool loadingUser = true;
  bool loadingProducts = true;
  bool _isLoadingOrders = false;

  final BusinessService businessService =
  BusinessService();

  @override
  void initState() {
    super.initState();

    loadDashboardData();

    _loadBusinessOrders();
  }

  // ============================================================
  // LOAD ALL DASHBOARD DATA
  // ============================================================

  Future<void> loadDashboardData() async {
    await Future.wait([
      loadCurrentUser(),
      loadProducts(),
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

      setState(() {
        if (response?['user'] != null) {
          currentUser =
          Map<String, dynamic>.from(
            response!['user'],
          );
        } else {
          currentUser = response;
        }

        loadingUser = false;
      });
    } catch (e) {
      debugPrint(
        "LOAD CURRENT USER ERROR: $e",
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
    } catch (e) {
      debugPrint(
        "LOAD PRODUCTS ERROR: $e",
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

  Future<void> _loadBusinessOrders() async {
    if (mounted) {
      setState(() {
        _isLoadingOrders = true;
        _ordersError = null;
      });
    }

    try {
      final orders =
      await businessService
          .getBusinessOrders();

      if (!mounted) return;

      setState(() {
        _orders = orders;

        _isLoadingOrders = false;
      });

      debugPrint(
        "BUSINESS ORDERS COUNT: "
            "${orders.length}",
      );

      for (final order in orders) {
        debugPrint(
          "ORDER: ${order.orderNumber}",
        );

        debugPrint(
          "CUSTOMER: "
              "${order.customer.name}",
        );

        debugPrint(
          "STATUS: ${order.status}",
        );

        debugPrint(
          "TOTAL: "
              "${order.totalAmount}",
        );
      }
    } catch (e) {
      debugPrint(
        "BUSINESS ORDERS ERROR: $e",
      );

      if (!mounted) return;

      setState(() {
        _isLoadingOrders = false;

        _ordersError = e.toString();
      });
    }
  }

  // ============================================================
  // USER DATA HELPERS
  // ============================================================

  String get ownerName {
    return currentUser?['name']
        ?.toString() ??
        'Business Owner';
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

    if (profile
    is Map<String, dynamic>) {
      return profile;
    }

    return {};
  }

  String get businessName {
    final name =
    businessProfile[
    'businessName']
        ?.toString();

    if (name != null &&
        name.isNotEmpty) {
      return name;
    }

    return 'My Pet Business';
  }

  String get businessType {
    final type =
    businessProfile[
    'businessType']
        ?.toString();

    if (type == null ||
        type.isEmpty) {
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
      String type,
      ) {
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
              (word) =>
          word.isEmpty
              ? ''
              : word[0]
              .toUpperCase() +
              word.substring(1),
        )
            .join(' ');
    }
  }

  // ============================================================
  // ADD PRODUCT
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
  // NAVIGATION PAGES
  // ============================================================

  List<Widget> get pages {
    return [
      DashboardHome(
        businessName:
        businessName,
        businessType:
        businessType,
        businessAddress:
        businessAddress,
        ownerName:
        ownerName,
        email:
        email,
        productCount:
        products.length,
        orderCount:
        _orders.length,
        recentOrders:
        _orders,
        loadingProducts:
        loadingProducts,
        loadingOrders:
        _isLoadingOrders,
        onAddProduct:
        openAddProduct,
        onRefreshOrders:
        _loadBusinessOrders,
      ),

      const SellerProductsScreen(),

      // SellerOrdersScreen(
      //   orders: _orders,
      //   isLoading:
      //   _isLoadingOrders,
      //   error:
      //   _ordersError,
      //   onRefresh:
      //   _loadBusinessOrders,
      // ),

      // const SellerProfileScreen(),
    ];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
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

      bottomNavigationBar:
      NavigationBar(
        selectedIndex:
        currentIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            currentIndex =
                index;
          });
        },

        indicatorColor:
        Colors.green.shade100,

        destinations:
        const [
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

// ================================================================
// DASHBOARD HOME
// ================================================================

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

  final Future<void> Function()
  onRefreshOrders;

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

    required this.onRefreshOrders,
  });

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
        onRefresh:
        onRefreshOrders,

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
            CrossAxisAlignment
                .start,

            children: [

              // =================================================
              // WELCOME
              // =================================================

              Text(
                'Welcome back, '
                    '$ownerName 👋',

                style:
                const TextStyle(
                  fontSize: 16,
                  color:
                  Colors.grey,
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

              // =================================================
              // BUSINESS CARD
              // =================================================

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

                    end:
                    Alignment
                        .bottomRight,
                  ),

                  borderRadius:
                  BorderRadius
                      .circular(
                    24,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .green
                          .withOpacity(
                        0.25,
                      ),

                      blurRadius:
                      18,

                      offset:
                      const Offset(
                        0,
                        8,
                      ),
                    ),
                  ],
                ),

                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

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

                                maxLines:
                                1,

                                overflow:
                                TextOverflow
                                    .ellipsis,

                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,

                                  fontSize:
                                  21,

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

                                  fontSize:
                                  14,
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
                        color: Colors
                            .white
                            .withOpacity(
                          0.12,
                        ),

                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                      ),

                      child:
                      Row(
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
                            child:
                            Text(
                              businessAddress,

                              maxLines:
                              2,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              const TextStyle(
                                color:
                                Colors.white,

                                fontSize:
                                13,
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

              // =================================================
              // OVERVIEW
              // =================================================

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

                crossAxisSpacing:
                12,

                mainAxisSpacing:
                12,

                childAspectRatio:
                1.35,

                shrinkWrap:
                true,

                physics:
                const NeverScrollableScrollPhysics(),

                children: [

                  DashboardStatCard(
                    icon: Icons
                        .inventory_2_outlined,

                    title:
                    'Products',

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

                    title:
                    'Orders',

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

                    title:
                    'Revenue',

                    value:
                    '0 MMK',

                    iconColor:
                    Colors.orange,
                  ),

                  const DashboardStatCard(
                    icon: Icons
                        .star_outline,

                    title:
                    'Rating',

                    value:
                    '0.0',

                    iconColor:
                    Colors.amber,
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              // =================================================
              // QUICK ACTION
              // =================================================

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

              // =================================================
              // RECENT ORDERS
              // =================================================

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
                    onPressed: () {},

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

              _buildRecentOrders(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECENT ORDERS WIDGET
  // ============================================================

  Widget _buildRecentOrders() {
    if (loadingOrders) {
      return const Center(
        child:
        Padding(
          padding:
          EdgeInsets.all(
            30,
          ),

          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (recentOrders.isEmpty) {
      return const EmptyOrdersCard();
    }

    final orders =
    recentOrders
        .take(3)
        .toList();

    return Column(
      children:
      orders.map(
            (order) {
          return _RecentOrderCard(
            order: order,
          );
        },
      ).toList(),
    );
  }
}

// ================================================================
// RECENT ORDER CARD
// ================================================================

class _RecentOrderCard
    extends StatelessWidget {
  final BusinessOrder order;

  const _RecentOrderCard({
    required this.order,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      elevation: 1,

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),

      child:
      Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),

        child:
        Row(
          children: [

            Container(
              width: 48,
              height: 48,

              decoration:
              BoxDecoration(
                color:
                Colors.green
                    .shade50,

                borderRadius:
                BorderRadius
                    .circular(
                  14,
                ),
              ),

              child:
              Icon(
                Icons
                    .shopping_bag_outlined,

                color:
                Colors.green
                    .shade700,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Text(
                    order.orderNumber,

                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    order.customer
                        .name,

                    style:
                    const TextStyle(
                      color:
                      Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    '${order.totalAmount} MMK',

                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            _StatusBadge(
              status:
              order.status,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// STATUS BADGE
// ================================================================

class _StatusBadge
    extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets
          .symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.grey.shade100,

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child:
      Text(
        status,

        style:
        const TextStyle(
          fontSize: 11,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }
}

// ================================================================
// STAT CARD
// ================================================================

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
      BuildContext context,
      ) {
    return Container(
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

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        mainAxisAlignment:
        MainAxisAlignment
            .center,

        children: [

          Container(
            width: 42,
            height: 42,

            decoration:
            BoxDecoration(
              color:
              iconColor
                  .withOpacity(
                0.1,
              ),

              borderRadius:
              BorderRadius
                  .circular(
                12,
              ),
            ),

            child:
            Icon(
              icon,

              color:
              iconColor,
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
              color:
              Colors.grey,

              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// QUICK ACTION
// ================================================================

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
      BuildContext context,
      ) {
    return InkWell(
      onTap:
      onTap,

      borderRadius:
      BorderRadius.circular(
        18,
      ),

      child:
      Container(
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

          border:
          Border.all(
            color:
            Colors.green.shade100,
          ),
        ),

        child:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [

            Icon(
              icon,

              color:
              Colors.green,

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

                fontSize:
                15,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              subtitle,

              style:
              const TextStyle(
                color:
                Colors.grey,

                fontSize:
                12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// EMPTY ORDERS
// ================================================================

class EmptyOrdersCard
    extends StatelessWidget {
  const EmptyOrdersCard({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        28,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border:
        Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),

      child:
      Column(
        children: [

          Icon(
            Icons
                .shopping_bag_outlined,

            size:
            48,

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
              fontSize:
              16,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'Your recent customer orders '
                'will appear here.',

            textAlign:
            TextAlign.center,

            style:
            TextStyle(
              color:
              Colors.grey.shade600,

              fontSize:
              13,
            ),
          ),
        ],
      ),
    );
  }
}