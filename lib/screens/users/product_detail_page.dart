import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final String productName;
  final String image;
  final String category;
  final String brand;
  final double price;
  final double rating;
  final String description;

  const ProductDetailPage({
    super.key,
    required this.productName,
    required this.image,
    required this.category,
    required this.brand,
    required this.price,
    required this.rating,
    required this.description,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}


class _ProductDetailPageState extends State<ProductDetailPage> {

  int quantity = 1;
  bool isFavorite = false;


  @override
  Widget build(BuildContext context) {

    double totalPrice = widget.price * quantity;


    return Scaffold(

      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(

        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          "Product Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),


        actions: [

          IconButton(

            icon: Icon(
              isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,

              color: isFavorite
                  ? Colors.red
                  : Colors.black,
            ),


            onPressed: (){

              setState(() {

                isFavorite = !isFavorite;

              });

            },

          )

        ],

      ),



      body: SingleChildScrollView(

        child: Column(

          children: [


            // Product Image

            Container(

              height: 300,

              width: double.infinity,

              color: Colors.white,


              child: Image.network(

                widget.image,

                fit: BoxFit.contain,


                errorBuilder: (context,error,stack){

                  return const Icon(

                    Icons.pets,

                    size:100,

                    color: Colors.orange,

                  );

                },

              ),

            ),





            Container(

              padding: const EdgeInsets.all(20),


              decoration: const BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.only(

                  topLeft: Radius.circular(25),

                  topRight: Radius.circular(25),

                ),

              ),



              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,


                children: [




                  // Product Name


                  Text(

                    widget.productName,


                    style: const TextStyle(

                      fontSize:24,

                      fontWeight:FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height:10),





                  Row(

                    children: [

                      const Icon(

                        Icons.star,

                        color:Colors.orange,

                      ),


                      const SizedBox(width:5),


                      Text(

                        "${widget.rating} (120 Reviews)",


                        style: const TextStyle(

                          fontSize:15,

                        ),

                      )

                    ],

                  ),




                  const SizedBox(height:15),





                  Text(

                    "${widget.price.toStringAsFixed(0)} MMK",


                    style: const TextStyle(

                      color:Colors.green,

                      fontSize:26,

                      fontWeight:FontWeight.bold,

                    ),

                  ),






                  const SizedBox(height:25),





                  // Product Information


                  const Text(

                    "Product Information",

                    style: TextStyle(

                      fontSize:18,

                      fontWeight:FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height:10),



                  productInfo(
                    "Category",
                    widget.category,
                  ),


                  productInfo(
                    "Brand",
                    widget.brand,
                  ),


                  productInfo(
                    "Stock",
                    "Available",
                  ),



                  const SizedBox(height:25),






                  const Text(

                    "Description",

                    style:TextStyle(

                      fontSize:18,

                      fontWeight:FontWeight.bold,

                    ),

                  ),




                  const SizedBox(height:10),



                  Text(

                    widget.description,


                    style: const TextStyle(

                      fontSize:15,

                      color:Colors.black87,

                    ),

                  ),






                  const SizedBox(height:25),





                  // Quantity


                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,


                    children: [


                      const Text(

                        "Quantity",

                        style:TextStyle(

                          fontSize:18,

                          fontWeight:FontWeight.bold,

                        ),

                      ),





                      Container(

                        decoration:BoxDecoration(

                          color:Colors.grey.shade200,

                          borderRadius:
                          BorderRadius.circular(15),

                        ),


                        child:Row(

                          children: [



                            IconButton(

                              onPressed:(){

                                if(quantity>1){

                                  setState((){

                                    quantity--;

                                  });

                                }

                              },


                              icon:
                              const Icon(Icons.remove),

                            ),





                            Text(

                              quantity.toString(),

                              style:const TextStyle(

                                fontSize:18,

                                fontWeight:FontWeight.bold,

                              ),

                            ),





                            IconButton(

                              onPressed:(){

                                setState((){

                                  quantity++;

                                });

                              },


                              icon:
                              const Icon(Icons.add),

                            ),



                          ],

                        ),

                      )



                    ],

                  ),





                  const SizedBox(height:30),






                  // Buttons


                  Row(

                    children: [



                      Expanded(

                        child:SizedBox(

                          height:55,


                          child:OutlinedButton(

                            onPressed:(){},


                            style:OutlinedButton.styleFrom(

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(15),

                              ),

                            ),


                            child:const Text(

                              "Add To Cart",

                            ),

                          ),

                        ),

                      ),





                      const SizedBox(width:15),






                      Expanded(

                        child:SizedBox(

                          height:55,


                          child:ElevatedButton(

                            onPressed:(){},


                            style:ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.orange,


                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(15),

                              ),

                            ),



                            child:Text(

                              "Buy ${totalPrice.toStringAsFixed(0)} MMK",


                              style:const TextStyle(

                                color:Colors.white,

                              ),

                            ),


                          ),

                        ),

                      )



                    ],

                  )





                ],

              ),

            )



          ],

        ),

      ),

    );

  }





  Widget productInfo(String title,String value){

    return Padding(

      padding:const EdgeInsets.symmetric(
        vertical:6,
      ),


      child:Row(

        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,


        children:[


          Text(

            title,

            style:const TextStyle(

              color:Colors.grey,

            ),

          ),



          Text(

            value,

            style:const TextStyle(

              fontWeight:FontWeight.bold,

            ),

          )

        ],

      ),

    );

  }


}