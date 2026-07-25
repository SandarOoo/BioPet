import 'package:flutter/material.dart';
import 'order_summary_page.dart';


class PaymentPage extends StatefulWidget {

  const PaymentPage({super.key});


  @override
  State<PaymentPage> createState() => _PaymentPageState();

}



class _PaymentPageState extends State<PaymentPage> {


  String selectedPayment = "KBZPay";



  final List<Map<String,dynamic>> paymentMethods = [

    {
      "name":"KBZPay",
      "icon":Icons.account_balance_wallet,
      "color":Colors.blue,
    },


    {
      "name":"Wave Pay",
      "icon":Icons.phone_android,
      "color":Colors.orange,
    },


    {
      "name":"AYA Pay",
      "icon":Icons.account_balance,
      "color":Colors.green,
    },


    {
      "name":"Cash On Delivery",
      "icon":Icons.local_shipping,
      "color":Colors.brown,
    },

  ];





  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      const Color(0xffF7F7F7),



      appBar: AppBar(

        title:
        const Text(

          "Payment",

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


      ),






      body:Padding(

        padding:
        const EdgeInsets.all(16),



        child:Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,



          children:[





            const Text(

              "Select Payment Method",

              style:
              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),





            const SizedBox(height:15),







            Expanded(

              child:
              ListView.builder(

                itemCount:
                paymentMethods.length,


                itemBuilder:
                    (context,index){



                  var payment =
                  paymentMethods[index];



                  return paymentCard(

                    payment["name"],

                    payment["icon"],

                    payment["color"],

                  );


                },

              ),

            ),






            Container(

              padding:
              const EdgeInsets.all(18),


              decoration:
              BoxDecoration(

                color:
                Colors.white,


                borderRadius:
                BorderRadius.circular(20),


              ),



              child:Column(

                children:[



                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,


                    children:[


                      const Text(

                        "Total Amount",

                        style:
                        TextStyle(

                          fontSize:17,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),





                      const Text(

                        "93,000 MMK",

                        style:
                        TextStyle(

                          fontSize:18,

                          color:
                          Colors.green,


                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),



                    ],

                  ),






                  const SizedBox(height:15),





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

                            const OrderSummaryPage(),

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

                        "Confirm Payment",

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

                  )



                ],

              ),

            )





          ],


        ),


      ),


    );


  }









  Widget paymentCard(

      String name,

      IconData icon,

      Color color,

      ){



    return Container(


      margin:
      const EdgeInsets.only(
        bottom:12,
      ),



      decoration:
      BoxDecoration(

        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(18),

      ),




      child:
      RadioListTile(


        value:name,


        groupValue:
        selectedPayment,



        onChanged:(value){


          setState((){


            selectedPayment =
                value.toString();


          });


        },



        activeColor:
        Colors.orange,



        title:
        Row(


          children:[



            CircleAvatar(

              backgroundColor:
              color.withOpacity(0.15),


              child:
              Icon(

                icon,

                color:
                color,

              ),

            ),




            const SizedBox(width:15),





            Text(

              name,


              style:
              const TextStyle(

                fontSize:16,


                fontWeight:
                FontWeight.bold,

              ),


            )



          ],

        ),


      ),



    );


  }



}