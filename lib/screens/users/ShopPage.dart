import 'package:flutter/material.dart';

import '../../models/product.dart';
import 'package:biopet/models/product.dart';
import 'package:biopet/services/business_service.dart';


class ShopPage extends StatefulWidget {

  const ShopPage({
    super.key,
  });


  @override
  State<ShopPage> createState() =>
      _ShopPageState();

}



class _ShopPageState
    extends State<ShopPage> {


  final BusinessService service =
  BusinessService();


  final TextEditingController
  searchController =
  TextEditingController();


  List<Product> allProducts = [];

  List<Product> filteredProducts = [];


  bool loading = true;

  String? error;


  String selectedCategory =
      "All";



  final List<Map<String, String>>
  categories = [

    {
      'icon': '🐶',
      'label': 'Dog'
    },

    {
      'icon': '🐱',
      'label': 'Cat'
    },

    {
      'icon': '🍖',
      'label': 'Food'
    },

    {
      'icon': '🧸',
      'label': 'Toys'
    },

    {
      'icon': '🧴',
      'label': 'Care'
    },

    {
      'icon': '🦴',
      'label': 'Accessories'
    },

  ];



  @override
  void initState() {

    super.initState();

    loadProducts();


    searchController
        .addListener(
      filterProducts,
    );

  }



  @override
  void dispose() {

    searchController.dispose();

    super.dispose();

  }



  Future<void>
  loadProducts() async {


    setState(() {

      loading = true;

      error = null;

    });


    try {


      final products =
      await service
          .getShopProducts();


      setState(() {

        allProducts = products;

        filteredProducts =
            products;

        loading = false;

      });


    } catch (e) {


      setState(() {

        loading = false;

        error = e.toString();

      });

    }

  }



  void filterProducts() {


    final search =
    searchController.text
        .toLowerCase()
        .trim();


    setState(() {


      filteredProducts =
          allProducts.where(
                (product) {


              final matchesSearch =

                  product.name
                      .toLowerCase()
                      .contains(search) ||

                      product.category
                          .toLowerCase()
                          .contains(search);


              final matchesCategory =

                  selectedCategory ==
                      "All" ||

                      product.category
                          .toLowerCase() ==
                          selectedCategory
                              .toLowerCase();


              return matchesSearch &&
                  matchesCategory;

            },

          ).toList();

    });

  }



  void selectCategory(
      String category
      ) {


    setState(() {

      selectedCategory =
          category;

    });


    filterProducts();

  }



  @override
  Widget build(
      BuildContext context
      ) {


    return Scaffold(

      backgroundColor:
      const Color(0xffF7F8FA),


      appBar: AppBar(

        backgroundColor:
        Colors.white,

        elevation: 0,


        title: const Text(

          "BioPet Shop",

          style: TextStyle(

            color: Colors.black,

            fontWeight:
            FontWeight.bold,

          ),

        ),


        actions: [

          IconButton(

            onPressed: () {},

            icon: const Icon(

              Icons
                  .favorite_border,

              color: Colors.black,

            ),

          ),


          IconButton(

            onPressed: () {},

            icon: const Icon(

              Icons
                  .shopping_cart_outlined,

              color: Colors.black,

            ),

          ),

        ],

      ),



      body: RefreshIndicator(

        onRefresh:
        loadProducts,


        child: SingleChildScrollView(

          physics:
          const AlwaysScrollableScrollPhysics(),


          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,


            children: [


              _searchBar(),


              _banner(),


              const SizedBox(
                  height: 25),


              _categoryHeader(),


              _categoryList(),


              const SizedBox(
                  height: 25),


              _productHeader(),


              const SizedBox(
                  height: 10),


              _productBody(),


              const SizedBox(
                  height: 30),

            ],

          ),

        ),

      ),



      bottomNavigationBar:

      BottomNavigationBar(

        currentIndex: 2,

        selectedItemColor:
        const Color(0xff6C63FF),

        unselectedItemColor:
        Colors.grey,

        type:
        BottomNavigationBarType
            .fixed,


        items: const [

          BottomNavigationBarItem(

            icon:
            Icon(
                Icons.home_outlined),

            label:
            "Home",

          ),

          BottomNavigationBarItem(

            icon:
            Icon(
                Icons.pets_outlined),

            label:
            "AI",

          ),

          BottomNavigationBarItem(

            icon:
            Icon(
                Icons.storefront),

            label:
            "Shop",

          ),

          BottomNavigationBarItem(

            icon:
            Icon(
                Icons.receipt_long_outlined),

            label:
            "Orders",

          ),

          BottomNavigationBarItem(

            icon:
            Icon(
                Icons.person_outline),

            label:
            "Profile",

          ),

        ],

      ),

    );

  }






  Widget _searchBar() {


    return Padding(

      padding:
      const EdgeInsets.all(16),


      child: Container(

        padding:
        const EdgeInsets.symmetric(
            horizontal: 16),


        decoration:
        BoxDecoration(

          color:
          Colors.white,

          borderRadius:
          BorderRadius.circular(14),

        ),


        child: Row(

          children: [

            const Icon(
                Icons.search,
                color: Colors.grey),


            const SizedBox(
                width: 10),


            Expanded(

              child: TextField(

                controller:
                searchController,


                decoration:
                const InputDecoration(

                  hintText:
                  "Search products...",

                  border:
                  InputBorder.none,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }






  Widget _banner() {


    return Padding(

      padding:
      const EdgeInsets.symmetric(
          horizontal: 16),


      child: Container(

        height: 150,

        width:
        double.infinity,


        padding:
        const EdgeInsets.all(20),


        decoration:
        BoxDecoration(

          borderRadius:
          BorderRadius.circular(20),


          gradient:
          const LinearGradient(

            colors: [

              Color(0xff6C63FF),

              Color(0xff8E7CFF),

            ],

          ),

        ),


        child: const Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [

            Text(

              "Special Offer",

              style: TextStyle(

                color:
                Colors.white,

                fontSize:
                16,

              ),

            ),


            SizedBox(
                height: 5),


            Text(

              "20% OFF",

              style: TextStyle(

                color:
                Colors.white,

                fontSize:
                30,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            Text(

              "Pet Food & Accessories",

              style: TextStyle(

                color:
                Colors.white70,

              ),

            ),

          ],

        ),

      ),

    );

  }






  Widget _categoryHeader() {


    return Padding(

      padding:
      const EdgeInsets.symmetric(
          horizontal: 16),


      child: Row(

        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,


        children: [

          const Text(

            "Categories",

            style: TextStyle(

              fontSize:
              19,

              fontWeight:
              FontWeight.bold,

            ),

          ),


          TextButton(

            onPressed: () {

              selectCategory("All");

            },


            child:
            const Text("All"),

          ),

        ],

      ),

    );

  }






  Widget _categoryList() {


    return SizedBox(

      height: 90,


      child: ListView.builder(

        scrollDirection:
        Axis.horizontal,


        padding:
        const EdgeInsets.symmetric(
            horizontal: 12),


        itemCount:
        categories.length,


        itemBuilder:
            (context, index) {


          final category =
          categories[index];


          final label =
          category['label']!;


          final selected =
              selectedCategory ==
                  label;


          return GestureDetector(

            onTap: () {

              selectCategory(
                  label);

            },


            child: Padding(

              padding:
              const EdgeInsets.symmetric(
                  horizontal: 5),


              child: Column(

                children: [

                  Container(

                    width: 60,

                    height: 60,


                    decoration:
                    BoxDecoration(

                      color: selected

                          ? const Color(
                          0xff6C63FF)

                          : Colors.white,


                      borderRadius:
                      BorderRadius
                          .circular(
                          18),

                    ),


                    child: Center(

                      child: Text(

                        category[
                        'icon']!,

                        style:
                        const TextStyle(
                            fontSize:
                            27),

                      ),

                    ),

                  ),


                  const SizedBox(
                      height: 5),


                  Text(

                    label,

                    style:
                    TextStyle(

                      fontSize:
                      12,

                      fontWeight:
                      selected
                          ? FontWeight
                          .bold
                          : FontWeight
                          .normal,

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

      padding:
      const EdgeInsets.symmetric(
          horizontal: 16),


      child: Row(

        mainAxisAlignment:
        MainAxisAlignment
            .spaceBetween,


        children: [

          const Text(

            "Popular Products",

            style: TextStyle(

              fontSize:
              19,

              fontWeight:
              FontWeight.bold,

            ),

          ),


          Text(

            "${filteredProducts.length} products",

            style: const TextStyle(

              color:
              Colors.grey,

            ),

          ),

        ],

      ),

    );

  }






  Widget _productBody() {


    if (loading) {

      return const Padding(

        padding:
        EdgeInsets.all(50),


        child: Center(

          child:
          CircularProgressIndicator(),

        ),

      );

    }



    if (error != null) {

      return Padding(

        padding:
        const EdgeInsets.all(30),


        child: Center(

          child: Column(

            children: [

              const Icon(

                Icons.error_outline,

                size: 60,

                color: Colors.red,

              ),


              const SizedBox(
                  height: 10),


              Text(
                  error!),


              const SizedBox(
                  height: 15),


              ElevatedButton(

                onPressed:
                loadProducts,


                child:
                const Text(
                    "Retry"),

              ),

            ],

          ),

        ),

      );

    }



    if (filteredProducts.isEmpty) {

      return const Padding(

        padding:
        EdgeInsets.all(50),


        child: Center(

          child: Column(

            children: [

              Icon(

                Icons
                    .inventory_2_outlined,

                size: 60,

                color: Colors.grey,

              ),


              SizedBox(
                  height: 10),


              Text(

                "No products found",

                style: TextStyle(

                  fontSize: 17,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),

            ],

          ),

        ),

      );

    }



    return Padding(

      padding:
      const EdgeInsets.all(16),


      child: GridView.builder(

        shrinkWrap: true,


        physics:
        const NeverScrollableScrollPhysics(),


        itemCount:
        filteredProducts.length,


        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount:
          2,


          crossAxisSpacing:
          14,


          mainAxisSpacing:
          14,


          childAspectRatio:
          0.62,

        ),


        itemBuilder:
            (context, index) {


          return _productCard(

              filteredProducts[
              index]);

        },

      ),

    );

  }






  Widget _productCard(
      Product product
      ) {


    return Container(

      decoration:
      BoxDecoration(

        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(
            20),

      ),


      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,


        children: [


          Expanded(

            child: ClipRRect(

              borderRadius:
              const BorderRadius.vertical(

                top:
                Radius.circular(
                    20),

              ),


              child:

              product.image
                  .isEmpty


                  ?

              const Center(

                child:
                Icon(
                    Icons
                        .image_not_supported),

              )


                  :

              Image.network(

                product.image,


                width:
                double.infinity,


                fit:
                BoxFit.cover,


                errorBuilder:
                    (
                    context,
                    error,
                    stackTrace
                    ) {

                  return const Center(

                    child:
                    Icon(
                        Icons
                            .broken_image),

                  );

                },

              ),

            ),

          ),



          Padding(

            padding:
            const EdgeInsets.all(
                12),


            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment
                  .start,


              children: [


                Text(

                  product.name,


                  maxLines:
                  2,


                  overflow:
                  TextOverflow
                      .ellipsis,


                  style:
                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),



                const SizedBox(
                    height: 5),



                Text(

                  product.category,


                  style:
                  const TextStyle(

                    color:
                    Colors.grey,

                    fontSize:
                    12,

                  ),

                ),



                const SizedBox(
                    height: 5),



                Text(

                  "${product.price.toStringAsFixed(0)} MMK",


                  style:
                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    fontSize:
                    16,

                    color:
                    Color(
                        0xff6C63FF),

                  ),

                ),



                const SizedBox(
                    height: 5),



                Text(

                  "Stock: ${product.stock}",


                  style:
                  TextStyle(

                    color:
                    product.stock > 0

                        ? Colors.green

                        : Colors.red,

                    fontSize:
                    12,

                  ),

                ),



                const SizedBox(
                    height: 8),



                SizedBox(

                  width:
                  double.infinity,


                  child:
                  ElevatedButton(

                    onPressed:

                    product.stock > 0

                        ? () {

                      // TODO:
                      // Add cart logic

                    }

                        : null,


                    style:
                    ElevatedButton
                        .styleFrom(

                      backgroundColor:
                      const Color(
                          0xff6C63FF),

                      foregroundColor:
                      Colors.white,

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius
                            .circular(
                            12),

                      ),

                    ),


                    child:

                    Text(

                      product.stock > 0

                          ? "Add to Cart"

                          : "Out of Stock",

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