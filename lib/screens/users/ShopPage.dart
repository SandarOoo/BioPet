import 'package:biopet/models/product.dart';
import 'package:biopet/screens/users/product_detail_page.dart';
import 'package:biopet/services/business_service.dart';
import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import 'cart_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  static const Color emerald = Color(0xFF065F46);
  static const Color darkEmerald = Color(0xFF064E3B);
  static const Color mint = Color(0xFFA7F3D0);
  static const Color lightMint = Color(0xFFECFDF5);
  static const Color cream = Color(0xFFFFF8E7);
  static const Color textColor = Color(0xFF12372A);
  static const Color mutedText = Color(0xFF6B7C74);

  final BusinessService service = BusinessService();
  final TextEditingController searchController = TextEditingController();

  List<Product> allProducts = [];
  List<Product> filteredProducts = [];

  bool loading = true;
  String? error;
  String selectedCategory = 'All';

  final List<Map<String, String>> categories = [
    {'icon': '🐶', 'label': 'Dog'},
    {'icon': '🐱', 'label': 'Cat'},
    {'icon': '🍖', 'label': 'Food'},
    {'icon': '🧸', 'label': 'Toys'},
    {'icon': '🧴', 'label': 'Care'},
    {'icon': '🦴', 'label': 'Accessories'},
  ];

  @override
  void initState() {
    super.initState();
    loadProducts();
    searchController.addListener(filterProducts);
  }

  @override
  void dispose() {
    searchController.removeListener(filterProducts);
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final products = await service.getShopProducts();
      if (!mounted) return;

      setState(() {
        allProducts = products;
        filteredProducts = products;
        loading = false;
      });

      filterProducts();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  void filterProducts() {
    final search = searchController.text.toLowerCase().trim();

    setState(() {
      filteredProducts = allProducts.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(search) ||
            product.category.toLowerCase().contains(search);

        final matchesCategory = selectedCategory == 'All' ||
            product.category.toLowerCase() == selectedCategory.toLowerCase();

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
    filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 18,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: lightMint,
              child: Icon(Icons.pets_rounded, color: emerald, size: 21),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BioPet Shop',
                  style: TextStyle(
                    color: darkEmerald,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Everything your pet needs',
                  style: TextStyle(
                    color: mutedText,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite_border_rounded, color: emerald),
          ),
          AnimatedBuilder(
            animation: CartService(),
            builder: (context, _) {
              final count = CartService().itemCount;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                      tooltip: 'Cart',
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: emerald,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 3,
                        top: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: darkEmerald,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cream, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 19,
                            minHeight: 19,
                          ),
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: emerald,
        backgroundColor: cream,
        onRefresh: loadProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchBar(),
              const SizedBox(height: 8),
              _categoryHeader(),
              const SizedBox(height: 10),
              _categoryList(),
              const SizedBox(height: 22),
              _productHeader(),
              const SizedBox(height: 4),
              _productBody(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: mint.withOpacity(0.85)),
          boxShadow: [
            BoxShadow(
              color: emerald.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          cursorColor: emerald,
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search food, toys, care products...',
            hintStyle: const TextStyle(color: mutedText, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: emerald),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              onPressed: searchController.clear,
              icon: const Icon(Icons.close_rounded, color: mutedText),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _categoryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Find products by pet needs',
                style: TextStyle(
                  color: mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => selectCategory('All'),
            style: TextButton.styleFrom(
              foregroundColor: emerald,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selectedCategory == 'All' ? 'All selected' : 'View all',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryList() {
    return SizedBox(
      height: 98,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final label = category['label']!;
          final selected = selectedCategory == label;

          return GestureDetector(
            onTap: () => selectCategory(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 76,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: selected ? emerald : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? emerald : mint.withOpacity(0.9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: emerald.withOpacity(selected ? 0.16 : 0.05),
                    blurRadius: selected ? 14 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withOpacity(0.18)
                          : lightMint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category['icon']!,
                      style: const TextStyle(fontSize: 23),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : textColor,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _productHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedCategory == 'All'
                    ? 'Popular Products'
                    : selectedCategory,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Carefully selected for your pets',
                style: TextStyle(
                  color: mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: lightMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${filteredProducts.length} items',
              style: const TextStyle(
                color: emerald,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productBody() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(56),
        child: Center(
          child: CircularProgressIndicator(color: emerald),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: mint),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 52,
                  color: emerald,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Could not load products',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: mutedText, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: loadProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: lightMint,
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 34,
                  color: emerald,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'No products found',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Try another search or category.',
                style: TextStyle(color: mutedText, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.61,
        ),
        itemBuilder: (context, index) {
          return _productCard(filteredProducts[index]);
        },
      ),
    );
  }

  Widget _productCard(Product product) {
    final inStock = product.stock > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: inStock
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            ),
          );
        }
            : null,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: mint.withOpacity(0.75)),
            boxShadow: [
              BoxShadow(
                color: emerald.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(21),
                        ),
                        child: Container(
                          color: lightMint,
                          child: product.image.isEmpty
                              ? const Center(
                            child: Icon(
                              Icons.pets_rounded,
                              size: 46,
                              color: emerald,
                            ),
                          )
                              : Image.network(
                            product.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 42,
                                  color: emerald,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: cream.withOpacity(0.93),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: darkEmerald,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            '${product.price.toStringAsFixed(0)} MMK',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: emerald,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 31,
                          height: 31,
                          decoration: BoxDecoration(
                            color: inStock ? emerald : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            inStock
                                ? Icons.add_shopping_cart_rounded
                                : Icons.block_rounded,
                            size: 17,
                            color: inStock ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: inStock ? const Color(0xFF10B981) : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            inStock ? 'In stock: ${product.stock}' : 'Out of stock',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: inStock ? mutedText : Colors.red.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
