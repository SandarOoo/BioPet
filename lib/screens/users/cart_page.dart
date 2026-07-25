import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}


class _CartPageState extends State<CartPage> {


  List<Map<String,dynamic>> cartItems = [

    {
      "name":"Royal Canin Puppy Food",
      "image":"https://images.unsplash.com/photo-1589924691995-400dc9ecc119",
      "price":45000,
      "quantity":1,
    },


    {
      "name":"Pet Toy Ball",
      "image":"https://images.unsplash.com/photo-1548199973-03cce0bbc87b",
      "price":15000,
      "quantity":2,
    },

  ];



  double get subtotal {

    double total = 0;

    for(var item in cartItems){

      total += item["price"] * item["quantity"];

    }

    return total;

  }



  double deliveryFee = 3000;



  @override
  Widget build(BuildContext context) {


    double total = subtotal + deliveryFee;



    return Scaffold(

      backgroundColor: const Color(0xffF7F7F7),


      appBar: AppBar(

        title: const Text(
          "My Cart",
          style:TextStyle(
            color:Colors.black,
            fontWeight:FontWeight.bold,
          ),
        ),

        centerTitle:true,

        backgroundColor:Colors.white,

        elevation:0,

        iconTheme:
        const IconThemeData(
          color:Colors.black,
        ),

      ),




      body: cartItems.isEmpty

          ? const Center(

        child: Text(
          "Your cart is empty",
          style:TextStyle(
            fontSize:18,
          ),
        ),

      )


          : Column(

        children: [



          Expanded(

            child:ListView.builder(

              padding:
              const EdgeInsets.all(15),


              itemCount:cartItems.length,


              itemBuilder:(context,index){


                var item = cartItems[index];



                return CartItemCard(

                  item:item,


                  onAdd:(){

                    setState((){

                      item["quantity"]++;

                    });

                  },


                  onRemoveQuantity:(){

                    if(item["quantity"]>1){

                      setState((){

                        item["quantity"]--;

                      });

                    }

                  },



                  onDelete:(){

                    setState((){

                      cartItems.removeAt(index);

                    });

                  },


                );


              },

            ),

          ),






          // Bottom Summary


          Container(

            padding:
            const EdgeInsets.all(20),


            decoration:
            const BoxDecoration(

              color:Colors.white,

              borderRadius:
              BorderRadius.only(

                topLeft:
                Radius.circular(25),


                topRight:
                Radius.circular(25),

              ),

            ),



            child:Column(

              children:[



                priceRow(
                  "Subtotal",
                  subtotal,
                ),



                priceRow(
                  "Delivery Fee",
                  deliveryFee,
                ),




                const Divider(),




                priceRow(
                  "Total",
                  total,
                  bold:true,
                ),




                const SizedBox(height:15),





                SizedBox(

                  width:double.infinity,

                  height:55,


                  child:ElevatedButton(

                    onPressed:(){


                      // Navigate checkout later


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

                      "Proceed Checkout",

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


          )



        ],

      ),


    );

  }







  Widget priceRow(
      String title,
      double value,
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

            style:TextStyle(

              fontSize:16,

              fontWeight:
              bold
                  ? FontWeight.bold
                  : FontWeight.normal,

            ),

          ),




          Text(

            "${value.toStringAsFixed(0)} MMK",

            style:TextStyle(

              fontSize:16,

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








class CartItemCard extends StatelessWidget {


  final Map<String,dynamic> item;

  final VoidCallback onAdd;

  final VoidCallback onRemoveQuantity;

  final VoidCallback onDelete;



  const CartItemCard({

    super.key,

    required this.item,

    required this.onAdd,

    required this.onRemoveQuantity,

    required this.onDelete,

  });




  @override
  Widget build(BuildContext context){



    return Container(

      margin:
      const EdgeInsets.only(
        bottom:15,
      ),



      padding:
      const EdgeInsets.all(12),


      decoration:
      BoxDecoration(

        color:Colors.white,


        borderRadius:
        BorderRadius.circular(18),


      ),




      child:Row(

        children:[




          ClipRRect(

            borderRadius:
            BorderRadius.circular(15),


            child:
            Image.network(

              item["image"],

              width:80,

              height:80,

              fit:BoxFit.cover,


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





          Expanded(

            child:Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,


              children:[



                Text(

                  item["name"],

                  maxLines:2,

                  overflow:
                  TextOverflow.ellipsis,


                  style:
                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    fontSize:16,

                  ),

                ),




                const SizedBox(height:8),




                Text(

                  "${item["price"]} MMK",

                  style:
                  const TextStyle(

                    color:Colors.green,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),




                Row(

                  children:[


                    IconButton(

                      onPressed:
                      onRemoveQuantity,


                      icon:
                      const Icon(
                        Icons.remove_circle_outline,
                      ),

                    ),



                    Text(
                      item["quantity"].toString(),
                    ),



                    IconButton(

                      onPressed:
                      onAdd,


                      icon:
                      const Icon(
                        Icons.add_circle_outline,
                      ),

                    ),



                  ],

                )


              ],

            ),

          ),






          IconButton(

            onPressed:
            onDelete,


            icon:
            const Icon(

              Icons.delete,

              color:Colors.red,

            ),

          )



        ],

      ),


    );

  }


}