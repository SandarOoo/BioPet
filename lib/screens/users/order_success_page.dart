import 'package:flutter/material.dart';
import 'my_orders_page.dart';


class OrderSuccessPage extends StatelessWidget {

  const OrderSuccessPage({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      const Color(0xffF7F7F7),



      body:
      Center(


        child:
        Padding(

          padding:
          const EdgeInsets.all(25),



          child:
          Column(


            mainAxisAlignment:
            MainAxisAlignment.center,



            children:[





              // Success Icon


              Container(

                height:120,

                width:120,


                decoration:
                BoxDecoration(

                  color:
                  Colors.green.withOpacity(0.15),


                  shape:
                  BoxShape.circle,

                ),



                child:
                const Icon(

                  Icons.check_circle,

                  size:100,

                  color:
                  Colors.green,

                ),



              ),






              const SizedBox(height:30),






              const Text(

                "Order Successful!",


                style:
                TextStyle(

                  fontSize:28,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),





              const SizedBox(height:15),






              const Text(

                "Your pet products have been ordered successfully.",


                textAlign:
                TextAlign.center,


                style:
                TextStyle(

                  fontSize:16,

                  color:
                  Colors.grey,

                ),

              ),







              const SizedBox(height:35),






              Container(

                width:
                double.infinity,


                padding:
                const EdgeInsets.all(20),



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





                    orderInfo(

                      "Order ID",

                      "#BP20260001",

                    ),





                    const Divider(),






                    orderInfo(

                      "Estimated Delivery",

                      "2 - 3 Days",

                    ),






                    const Divider(),






                    orderInfo(

                      "Payment Status",

                      "Paid",

                    ),



                  ],



                ),



              ),






              const SizedBox(height:35),







              SizedBox(

                width:
                double.infinity,


                height:
                55,



                child:
                ElevatedButton(


                  onPressed:(){


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:
                            (context)=>

                        const MyOrdersPage(),

                      ),

                    );


                  },


                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.orange,


                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                    ),

                  ),



                  child:
                  const Text(

                    "Track Order",

                    style:
                    TextStyle(

                      color:
                      Colors.white,


                      fontSize:17,


                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                ),


              ),







              const SizedBox(height:15),







              SizedBox(

                width:
                double.infinity,


                height:
                55,



                child:
                OutlinedButton(


                  onPressed:(){


                    Navigator.popUntil(

                      context,

                          (route)=>route.isFirst,

                    );


                  },



                  style:
                  OutlinedButton.styleFrom(

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(15),

                    ),

                  ),



                  child:
                  const Text(

                    "Continue Shopping",

                    style:
                    TextStyle(

                      fontSize:16,

                    ),

                  ),


                ),


              )






            ],



          ),



        ),



      ),



    );

  }









  Widget orderInfo(
      String title,
      String value,
      ){



    return Row(


      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,



      children:[



        Text(

          title,

          style:
          const TextStyle(

            color:
            Colors.grey,

            fontSize:15,

          ),

        ),





        Text(

          value,


          style:
          const TextStyle(

            fontWeight:
            FontWeight.bold,

            fontSize:15,

          ),

        )



      ],


    );

  }



}