import 'package:flutter/material.dart';

import 'add_product_screen.dart';
import 'seller_products_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_profile_screen.dart';


class BusinessDashboard extends StatefulWidget {

  const BusinessDashboard({
    super.key
  });


  @override
  State<BusinessDashboard> createState()
  => _BusinessDashboardState();

}



class _BusinessDashboardState
    extends State<BusinessDashboard>{


  int currentIndex = 0;



  final pages = [

    const DashboardHome(),

    const SellerProductsScreen(),

    // const SellerOrdersScreen(),
    //
    // const SellerProfileScreen(),

  ];



  @override
  Widget build(BuildContext context){


    return Scaffold(


      body: pages[currentIndex],



      bottomNavigationBar:
      BottomNavigationBar(

        currentIndex: currentIndex,


        selectedItemColor:
        Colors.green,


        unselectedItemColor:
        Colors.grey,


        onTap:(index){

          setState(() {

            currentIndex=index;

          });

        },


        items:[


          const BottomNavigationBarItem(

              icon:Icon(Icons.dashboard),

              label:"Dashboard"

          ),


          const BottomNavigationBarItem(

              icon:Icon(Icons.inventory),

              label:"Products"

          ),


          const BottomNavigationBarItem(

              icon:Icon(Icons.shopping_cart),

              label:"Orders"

          ),



          const BottomNavigationBarItem(

              icon:Icon(Icons.person),

              label:"Profile"

          ),


        ],


      ),


    );


  }


}






class DashboardHome extends StatelessWidget {


  const DashboardHome({
    super.key
  });



  @override
  Widget build(BuildContext context){


    return Scaffold(


        backgroundColor:
        const Color(0xfff5faf5),



        appBar: AppBar(

          title:
          const Text(
              "Bio Pet Seller Center"
          ),

          actions:[

            IconButton(
                onPressed:(){},
                icon:
                const Icon(Icons.notifications)
            )

          ],

        ),



        body: SingleChildScrollView(


            padding:
            const EdgeInsets.all(16),



            child:Column(


                crossAxisAlignment:
                CrossAxisAlignment.start,


                children:[



// SHOP CARD

                  Container(

                      padding:
                      const EdgeInsets.all(18),


                      decoration:
                      BoxDecoration(

                        color:
                        Colors.green.shade700,

                        borderRadius:
                        BorderRadius.circular(18),

                      ),


                      child:Row(

                          children:[


                            const CircleAvatar(
                              radius:35,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.store,
                                size:40,
                                color: Colors.green,
                              ),
                            ),


                            const SizedBox(width:15),



                            Column(

                                crossAxisAlignment:
                                CrossAxisAlignment.start,


                                children:[


                                  const Text(

                                      "Happy Pet Shop",

                                      style:TextStyle(

                                          color:Colors.white,

                                          fontSize:20,

                                          fontWeight:
                                          FontWeight.bold

                                      )

                                  ),


                                  const Text(

                                      "Pet Supplies Store",

                                      style:TextStyle(

                                          color:Colors.white70

                                      )

                                  ),


                                  Row(

                                      children:[

                                        const Icon(
                                            Icons.star,
                                            color:Colors.yellow,
                                            size:18
                                        ),

                                        const Text(
                                          " 4.8",
                                          style:TextStyle(
                                              color:Colors.white
                                          ),
                                        )

                                      ]

                                  )

                                ]

                            )

                          ]

                      )

                  ),



                  const SizedBox(height:25),




                  const Text(

                      "Overview",

                      style:TextStyle(

                          fontSize:20,

                          fontWeight:FontWeight.bold

                      )

                  ),



                  const SizedBox(height:15),



                  GridView.count(


                    crossAxisCount:2,

                    shrinkWrap:true,

                    physics:
                    const NeverScrollableScrollPhysics(),



                    children:[


                      statCard(
                          "25",
                          "Products",
                          Icons.inventory
                      ),


                      statCard(
                          "18",
                          "Orders",
                          Icons.shopping_bag
                      ),


                      statCard(
                          "320,000",
                          "Revenue",
                          Icons.money
                      ),


                      statCard(
                          "4.8",
                          "Rating",
                          Icons.star
                      ),


                    ],


                  ),



                  const SizedBox(height:20),



                  Text(

                      "Recent Orders",

                      style:
                      TextStyle(

                          fontSize:20,

                          fontWeight:
                          FontWeight.bold

                      )

                  ),



                  const SizedBox(height:10),
                  const SizedBox(height:20),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddProductScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Product"),
                  ),



                  orderCard(
                      "#1023",
                      "Chit Snow Oo",
                      "28,000 MMK",
                      "Pending"
                  ),


                  orderCard(
                      "#1022",
                      "Zin Mar Aung",
                      "15,000 MMK",
                      "Completed"
                  ),


                ]


            )


        )


    );


  }



  Widget statCard(
      String value,
      String title,
      IconData icon
      ){

    return Card(

        child:Column(

            mainAxisAlignment:
            MainAxisAlignment.center,


            children:[

              Icon(
                  icon,
                  color:Colors.green
              ),


              Text(

                  value,

                  style:
                  const TextStyle(

                      fontSize:22,

                      fontWeight:
                      FontWeight.bold

                  )

              ),


              Text(title)

            ]


        )


    );


  }




  Widget orderCard(
      String id,
      String name,
      String price,
      String status
      ){

    return Card(

        child:ListTile(

          title:Text(
              "$id - $name"
          ),


          subtitle:Text(price),


          trailing:
          Text(
            status,
            style:
            const TextStyle(
                color:Colors.green
            ),
          ),


        )


    );

  }




}