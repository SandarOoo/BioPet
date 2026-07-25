import 'package:flutter/material.dart';


class OrderDetailPage extends StatelessWidget {

  const OrderDetailPage({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      const Color(0xffF7F7F7),



      appBar: AppBar(

        title:
        const Text(

          "Order Details",

          style:
          TextStyle(

            color: Colors.black,

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

          color: Colors.black,

        ),


      ),






      body:
      SingleChildScrollView(


        padding:
        const EdgeInsets.all(16),



        child:
        Column(


          crossAxisAlignment:
          CrossAxisAlignment.start,



          children:[






            orderHeader(),





            const SizedBox(height:25),






            sectionTitle(
              "Order Status",
            ),



            const SizedBox(height:15),





            statusTimeline(),





            const SizedBox(height:25),






            sectionTitle(
              "Product Details",
            ),



            const SizedBox(height:10),






            productCard(),





            const SizedBox(height:25),






            sectionTitle(
              "Delivery Information",
            ),



            const SizedBox(height:10),





            infoCard([


              "Name: Chit Snow Oo",

              "Phone: 09xxxxxxxxx",

              "Address: Yangon, Myanmar",

            ]),






            const SizedBox(height:25),






            sectionTitle(
              "Payment Information",
            ),




            const SizedBox(height:10),





            infoCard([


              "Payment Method: KBZPay",

              "Payment Status: Paid",

            ]),





            const SizedBox(height:25),






            sectionTitle(
              "Price Details",
            ),



            const SizedBox(height:10),






            priceCard(),





            const SizedBox(height:30),







            Row(

              children:[





                Expanded(

                  child:
                  OutlinedButton(


                    onPressed:(){},


                    style:
                    OutlinedButton.styleFrom(

                      padding:
                      const EdgeInsets.all(15),


                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(15),

                      ),


                    ),



                    child:
                    const Text(

                      "Cancel Order",

                    ),



                  ),

                ),





                const SizedBox(width:15),





                Expanded(

                  child:
                  ElevatedButton(


                    onPressed:(){},


                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.orange,


                      padding:
                      const EdgeInsets.all(15),


                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(15),

                      ),


                    ),



                    child:
                    const Text(

                      "Buy Again",

                      style:
                      TextStyle(

                        color:
                        Colors.white,

                      ),

                    ),



                  ),

                )




              ],


            )





          ],


        ),


      ),


    );


  }









  Widget orderHeader(){


    return Container(

      padding:
      const EdgeInsets.all(18),


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



          const Text(

            "Order ID",

            style:
            TextStyle(

              color:
              Colors.grey,

            ),

          ),





          const SizedBox(height:5),





          const Text(

            "#BP20260001",

            style:
            TextStyle(

              fontSize:20,

              fontWeight:
              FontWeight.bold,

            ),

          ),





          const SizedBox(height:10),





          const Text(

            "Order Date: 24 July 2026",

          ),



        ],



      ),


    );


  }









  Widget statusTimeline(){



    List<String> steps=[

      "Order Placed",

      "Confirmed",

      "Packed",

      "Shipping",

      "Delivered",

    ];



    return Container(

      padding:
      const EdgeInsets.all(18),


      decoration:
      BoxDecoration(

        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(20),

      ),



      child:
      Column(

        children:

        List.generate(

          steps.length,


              (index){



            bool completed =
                index < 4;



            return Row(


              crossAxisAlignment:
              CrossAxisAlignment.start,



              children:[





                Column(

                  children:[



                    Icon(

                      completed

                          ? Icons.check_circle

                          : Icons.circle_outlined,


                      color:

                      completed

                          ? Colors.green

                          : Colors.grey,

                    ),




                    if(index != steps.length-1)

                      Container(

                        height:35,

                        width:2,

                        color:
                        Colors.grey.shade300,

                      )



                  ],

                ),






                const SizedBox(width:15),





                Padding(

                  padding:
                  const EdgeInsets.only(
                    top:5,
                  ),


                  child:
                  Text(

                    steps[index],

                    style:
                    TextStyle(

                      fontWeight:
                      completed

                          ? FontWeight.bold

                          : FontWeight.normal,

                    ),

                  ),

                )





              ],


            );

          },

        ),

      ),



    );

  }









  Widget productCard(){


    return Container(

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
      Row(


        children:[



          Container(

            height:80,

            width:80,


            decoration:
            BoxDecoration(

              borderRadius:
              BorderRadius.circular(15),


              color:
              Colors.orange.shade100,

            ),


            child:
            const Icon(

              Icons.pets,

              size:45,

              color:
              Colors.orange,

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

                    fontSize:16,

                  ),

                ),





                SizedBox(height:8),




                Text(

                  "Quantity: 2",

                ),





                SizedBox(height:5),




                Text(

                  "90,000 MMK",

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



    );


  }









  Widget infoCard(List<String> items){


    return Container(

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


        children:

        items.map(

              (e)=>Padding(

            padding:
            const EdgeInsets.symmetric(
              vertical:5,
            ),


            child:
            Text(e),


          ),

        ).toList(),


      ),


    );


  }









  Widget priceCard(){


    return Container(

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

        children:[



          priceRow(
            "Subtotal",
            "90,000 MMK",
          ),



          priceRow(
            "Delivery",
            "3,000 MMK",
          ),




          const Divider(),





          priceRow(
            "Total",
            "93,000 MMK",
            bold:true,
          )




        ],


      ),



    );


  }








  Widget priceRow(
      String title,
      String value,
      {
        bool bold=false,
      }
      ){


    return Padding(

      padding:
      const EdgeInsets.symmetric(
        vertical:8,
      ),


      child:
      Row(

        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,


        children:[



          Text(

            title,

            style:
            TextStyle(

              fontWeight:
              bold

                  ? FontWeight.bold

                  : FontWeight.normal,

            ),

          ),





          Text(

            value,

            style:
            TextStyle(

              color:
              bold

                  ? Colors.green

                  : Colors.black,


              fontWeight:
              bold

                  ? FontWeight.bold

                  : FontWeight.normal,

            ),


          )



        ],


      ),


    );


  }









  Widget sectionTitle(String title){


    return Text(

      title,

      style:
      const TextStyle(

        fontSize:20,

        fontWeight:
        FontWeight.bold,

      ),

    );


  }


}