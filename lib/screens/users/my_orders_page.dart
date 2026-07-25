import 'package:flutter/material.dart';
import 'order_detail_page.dart';


class MyOrdersPage extends StatefulWidget {

  const MyOrdersPage({super.key});


  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();

}



class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {



  late TabController tabController;



  @override
  void initState() {

    super.initState();

    tabController =
        TabController(
          length: 4,
          vsync: this,
        );

  }



  @override
  void dispose(){

    tabController.dispose();

    super.dispose();

  }







  final List<String> statuses = [

    "Pending",
    "Shipping",
    "Delivered",
    "Cancelled"

  ];







  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
      const Color(0xffF7F7F7),





      appBar: AppBar(


        title:
        const Text(

          "My Orders",

          style:
          TextStyle(

            color:Colors.black,

            fontWeight:
            FontWeight.bold,

          ),

        ),



        centerTitle:true,



        backgroundColor:
        Colors.white,



        elevation:0,



        iconTheme:
        const IconThemeData(

          color:Colors.black,

        ),




        bottom:
        TabBar(


          controller:
          tabController,


          isScrollable:true,


          labelColor:
          Colors.orange,


          unselectedLabelColor:
          Colors.grey,


          indicatorColor:
          Colors.orange,



          tabs:
          statuses.map(

                  (e)=>

                  Tab(

                    text:e,

                  )

          ).toList(),


        ),



      ),






      body:

      TabBarView(


        controller:
        tabController,


        children:

        statuses.map(

                (status)=>

                orderList(status)

        ).toList(),


      ),




    );


  }









  Widget orderList(String status){



    return ListView(

      padding:
      const EdgeInsets.all(16),



      children:[


        orderCard(status),


        orderCard(status),



      ],


    );


  }









  Widget orderCard(String status){



    return Container(


      margin:
      const EdgeInsets.only(

        bottom:15,

      ),



      padding:
      const EdgeInsets.all(15),



      decoration:
      BoxDecoration(

        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(20),


      ),




      child:
      Column(


        crossAxisAlignment:
        CrossAxisAlignment.start,



        children:[





          Row(


            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,



            children:[



              const Text(

                "Order #BP20260001",

                style:
                TextStyle(

                  fontWeight:
                  FontWeight.bold,

                  fontSize:16,

                ),

              ),





              statusBadge(status),




            ],


          ),






          const SizedBox(height:15),






          Row(

            children:[



              ClipRRect(

                borderRadius:
                BorderRadius.circular(12),


                child:
                Image.network(

                  "https://images.unsplash.com/photo-1589924691995-400dc9ecc119",


                  height:70,

                  width:70,


                  fit:
                  BoxFit.cover,


                  errorBuilder:
                      (_,__,___){

                    return const Icon(
                      Icons.pets,
                      size:50,
                    );

                  },


                ),

              ),





              const SizedBox(width:15),





              const Expanded(

                child:
                Column(


                  crossAxisAlignment:
                  CrossAxisAlignment.start,



                  children:[



                    Text(

                      "Royal Canin Puppy Food",

                      style:
                      TextStyle(

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),




                    SizedBox(height:8),




                    Text(

                      "Quantity: 2",

                    ),




                    SizedBox(height:5),





                    Text(

                      "93,000 MMK",

                      style:
                      TextStyle(

                        color:
                        Colors.green,


                        fontWeight:
                        FontWeight.bold,

                      ),

                    )




                  ],



                ),



              )



            ],



          ),







          const SizedBox(height:15),





          SizedBox(

            width:
            double.infinity,


            height:
            45,



            child:
            OutlinedButton(


              onPressed:(){


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:
                        (context)=>

                    const OrderDetailPage(),

                  ),

                );


              },



              style:
              OutlinedButton.styleFrom(


                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(12),

                ),


              ),



              child:
              const Text(

                "View Details",

              ),



            ),


          )




        ],



      ),


    );


  }









  Widget statusBadge(String status){


    Color color;



    if(status=="Delivered"){

      color=Colors.green;

    }

    else if(status=="Shipping"){

      color=Colors.blue;

    }

    else if(status=="Cancelled"){

      color=Colors.red;

    }

    else{

      color=Colors.orange;

    }




    return Container(


      padding:
      const EdgeInsets.symmetric(

        horizontal:10,

        vertical:5,

      ),



      decoration:
      BoxDecoration(


        color:
        color.withOpacity(0.15),


        borderRadius:
        BorderRadius.circular(20),


      ),



      child:
      Text(


        status,


        style:
        TextStyle(


          color:
          color,


          fontWeight:
          FontWeight.bold,

        ),


      ),


    );


  }




}