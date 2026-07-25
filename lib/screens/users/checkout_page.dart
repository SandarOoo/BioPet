import 'package:flutter/material.dart';
import 'payment_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}


class _CheckoutPageState extends State<CheckoutPage> {


  String deliveryType = "Standard Delivery";


  final TextEditingController noteController =
  TextEditingController();



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: const Color(0xffF7F7F7),


      appBar: AppBar(

        title: const Text(
          "Checkout",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        backgroundColor: Colors.white,

        elevation: 0,

        iconTheme:
        const IconThemeData(
          color: Colors.black,
        ),

      ),




      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),


        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [



            sectionTitle("Delivery Address"),



            const SizedBox(height:10),



            addressCard(),






            const SizedBox(height:25),





            sectionTitle("Delivery Option"),




            const SizedBox(height:10),




            deliveryOption(
              "Standard Delivery",
              "2-3 Days",
            ),



            deliveryOption(
              "Express Delivery",
              "1 Day",
            ),






            const SizedBox(height:25),





            sectionTitle("Order Note"),




            const SizedBox(height:10),




            Container(

              padding:
              const EdgeInsets.all(12),


              decoration:
              BoxDecoration(

                color:Colors.white,

                borderRadius:
                BorderRadius.circular(15),

              ),


              child:TextField(

                controller:
                noteController,


                maxLines:3,


                decoration:
                const InputDecoration(

                  hintText:
                  "Write note for seller",

                  border:
                  InputBorder.none,

                ),

              ),

            ),







            const SizedBox(height:25),





            sectionTitle("Order Summary"),




            const SizedBox(height:10),




            summaryCard(),






            const SizedBox(height:30),







            SizedBox(

              width:double.infinity,

              height:55,


              child:ElevatedButton(

                onPressed:(){



                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:(context)=>
                      const PaymentPage(),

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

                  "Continue Payment",

                  style:
                  TextStyle(

                    color:Colors.white,

                    fontSize:17,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


              ),

            )




          ],

        ),

      ),


    );

  }








  Widget sectionTitle(String title){


    return Text(

      title,

      style:
      const TextStyle(

        fontSize:19,

        fontWeight:
        FontWeight.bold,

      ),

    );


  }









  Widget addressCard(){



    return Container(

      padding:
      const EdgeInsets.all(16),


      decoration:
      BoxDecoration(

        color:Colors.white,


        borderRadius:
        BorderRadius.circular(18),

      ),



      child:Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,


        children:[



          const Text(

            "Chit Snow Oo",

            style:
            TextStyle(

              fontSize:17,

              fontWeight:
              FontWeight.bold,

            ),

          ),





          const SizedBox(height:8),





          const Text(

            "Phone: 09xxxxxxxxx",

          ),




          const SizedBox(height:8),





          const Text(

            "Address: Yangon, Myanmar",

          ),





          Align(

            alignment:
            Alignment.centerRight,


            child:
            TextButton(

              onPressed:(){},


              child:
              const Text(
                "Change",
              ),

            ),

          )


        ],

      ),


    );


  }









  Widget deliveryOption(
      String title,
      String subtitle,
      ){



    return Container(

      margin:
      const EdgeInsets.only(
        bottom:12,
      ),



      decoration:
      BoxDecoration(

        color:Colors.white,

        borderRadius:
        BorderRadius.circular(15),

      ),



      child:RadioListTile(

        value:title,


        groupValue:
        deliveryType,


        onChanged:(value){


          setState((){

            deliveryType =
                value.toString();


          });


        },


        title:
        Text(

          title,

          style:
          const TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),


        subtitle:
        Text(subtitle),


        activeColor:
        Colors.orange,

      ),

    );

  }









  Widget summaryCard(){


    return Container(

      padding:
      const EdgeInsets.all(16),


      decoration:
      BoxDecoration(

        color:Colors.white,

        borderRadius:
        BorderRadius.circular(18),

      ),



      child:Column(

        children:[


          summaryRow(
            "Subtotal",
            "90,000 MMK",
          ),


          summaryRow(
            "Delivery Fee",
            "3,000 MMK",
          ),



          const Divider(),



          summaryRow(
            "Total",
            "93,000 MMK",
            bold:true,
          ),



        ],

      ),

    );

  }









  Widget summaryRow(
      String title,
      String value,
      {
        bool bold=false
      }
      ){


    return Padding(

      padding:
      const EdgeInsets.symmetric(
        vertical:8,
      ),


      child:Row(

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

              fontWeight:
              bold
                  ? FontWeight.bold
                  : FontWeight.normal,


              color:
              bold
                  ? Colors.green
                  : Colors.black,

            ),

          )



        ],

      ),

    );


  }



}