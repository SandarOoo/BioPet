import 'package:flutter/material.dart';

import 'package:biopet/models/product.dart';
import '../../services/business_service.dart';
import 'add_product_screen.dart';



class SellerProductsScreen extends StatefulWidget {

  const SellerProductsScreen({
    super.key
  });


  @override
  State<SellerProductsScreen> createState()
  => _SellerProductsScreenState();

}



class _SellerProductsScreenState
    extends State<SellerProductsScreen>{


  final BusinessService service =
  BusinessService();


  List<Product> products = [];


  bool loading = true;



  @override
  void initState(){

    super.initState();

    loadProducts();

  }





  Future<void> loadProducts() async {


    try{


      final result =
      await service.getProducts();
      setState((){

        products = result;

        loading=false;

      });


    }catch(e){

      setState((){

        loading=false;

      });


      ScaffoldMessenger.of(context)
          .showSnackBar(

          SnackBar(
            content:
            Text(e.toString()),
          )

      );

    }


  }





  Future<void> deleteProduct(
      String id
      ) async{


    final success =
    await service.deleteProduct(id);



    if(success){


      loadProducts();


    }



  }





  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar: AppBar(

        title:
        const Text(
            "My Products"
        ),


      ),



      floatingActionButton:
      FloatingActionButton.extended(


        backgroundColor:
        Colors.green,


        onPressed:(){


          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(_)=>
              const AddProductScreen(),

            ),

          ).then((value){

            loadProducts();

          });


        },


        icon:
        const Icon(
            Icons.add
        ),


        label:
        const Text(
            "Add Product"
        ),


      ),





      body:


      loading

          ?

      const Center(

        child:
        CircularProgressIndicator(),

      )


          :

      products.isEmpty

          ?

      const Center(

        child:
        Text(
            "No Products Yet"
        ),

      )


          :


      RefreshIndicator(


        onRefresh:
        loadProducts,


        child:
        ListView.builder(


          padding:
          const EdgeInsets.all(16),


          itemCount:
          products.length,


          itemBuilder:
              (context,index){


            final product =
            products[index];



            return Card(


              elevation:3,


              margin:
              const EdgeInsets.only(
                  bottom:15
              ),



              child:
              ListTile(



                leading:

                CircleAvatar(

                  backgroundColor:
                  Colors.green.shade100,


                  child:

                  const Icon(
                      Icons.pets,
                      color:Colors.green
                  ),


                ),




                title:
                Text(

                    product.name,

                    style:
                    const TextStyle(

                        fontWeight:
                        FontWeight.bold

                    )

                ),




                subtitle:

                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children:[


                    Text(
                      product.category,
                    ),


                    Text(
                      "${product.price} MMK",
                    ),


                    Text(
                      "Stock: ${product.stock}",
                    ),


                  ],


                ),





                trailing:

                PopupMenuButton(


                  itemBuilder:
                      (context)=>[


                    const PopupMenuItem(

                      value:"edit",

                      child:
                      Text(
                          "Edit"
                      ),

                    ),



                    const PopupMenuItem(

                      value:"delete",

                      child:
                      Text(
                          "Delete"
                      ),

                    ),


                  ],



                  onSelected:
                      (value){



                    if(value=="delete"){


                      deleteProduct(
                          product.id
                      );


                    }


                    if(value=="edit"){


                      // next step


                    }



                  },


                ),



              ),



            );


          },


        ),


      ),



    );


  }



}