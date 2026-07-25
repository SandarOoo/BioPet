import 'package:flutter/material.dart';
import 'order_success_page.dart';


class OrderSummaryPage extends StatelessWidget {

  const OrderSummaryPage({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      const Color(0xffF7F7F7),



      appBar: AppBar(

        title:
        const Text(

          "Order Summary",

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






      body:
      SingleChildScrollView(


        padding:
        const EdgeInsets.all(16),



        child:
        Column(


          crossAxisAlignment:
          CrossAxisAlignment.start,



          children:[






            sectionTitle(
              "Products",
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
              "Payment Method",
            ),




            const SizedBox(height:10),




            infoCard([

              "Payment: KBZPay",

              "Status: Pending",

            ]),





            const SizedBox(height:25),





            sectionTitle(
              "Price Details",
            ),




            const SizedBox(height:10),




            priceCard(),





            const SizedBox(height:30),






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

                      const OrderSuccessPage(),

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

                  "Place Order",

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









  Widget productCard(){


    return Container(


      padding:
      const EdgeInsets.all(15),


      decoration:
      BoxDecoration(

        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(18),

      ),



      child:
      Row(


        children:[



          ClipRRect(

            borderRadius:
            BorderRadius.circular(15),


            child:
            Image.network(

              "https://images.unsplash.com/photo-1589924691995-400dc9ecc119",


              width:80,

              height:80,


              fit:
              BoxFit.cover,


              errorBuilder:
                  (_,__,___){

                return const Icon(
                  Icons.pets,
                  size:60,
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









  Widget infoCard(List<String> data){


    return Container(


      padding:
      const EdgeInsets.all(15),


      decoration:
      BoxDecoration(

        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(18),

      ),



      child:
      Column(


        crossAxisAlignment:
        CrossAxisAlignment.start,



        children:
        data.map((e)=>Padding(

          padding:
          const EdgeInsets.symmetric(
            vertical:5,
          ),


          child:
          Text(

            e,

            style:
            const TextStyle(

              fontSize:15,

            ),

          ),


        )).toList(),


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
        BorderRadius.circular(18),

      ),




      child:
      Column(

        children:[


          priceRow(
            "Subtotal",
            "90,000 MMK",
          ),


          priceRow(
            "Delivery Fee",
            "3,000 MMK",
          ),



          const Divider(),




          priceRow(
            "Total",
            "93,000 MMK",
            bold:true,
          ),



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



}