import 'package:flutter/material.dart';
import '../../services/business_service.dart';


class AddProductScreen extends StatefulWidget {

  const AddProductScreen({
    super.key,
  });


  @override
  State<AddProductScreen> createState()
  => _AddProductScreenState();

}



class _AddProductScreenState
    extends State<AddProductScreen>{
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  String category = "Food";
  bool loading = false;
  final BusinessService service = BusinessService();

  Future<void> addProduct() async{
    if(
    nameController.text.isEmpty ||
        priceController.text.isEmpty
    ){
      ScaffoldMessenger.of(context)
          .showSnackBar(

          const SnackBar(
              content:
              Text(
                  "Please fill required fields"
              )
          )

      );

      return;

    }



    setState(() {

      loading=true;

    });



    final success =
    await service.addProduct({

      "name":
      nameController.text,


      "category":
      category,


      "price":
      double.parse(
          priceController.text
      ),


      "stock":
      int.tryParse(
          stockController.text
      ) ?? 0,


      "description":
      descriptionController.text,


    });



    setState(() {

      loading=false;

    });



    if(success){


      ScaffoldMessenger.of(context)
          .showSnackBar(

          const SnackBar(
              content:
              Text(
                  "Product Added Successfully"
              )
          )

      );


      Navigator.pop(context);


    }


  }




  @override
  Widget build(BuildContext context){


    return Scaffold(

      appBar:
      AppBar(

        title:
        const Text(
            "Add Product"
        ),

      ),


      body:

      SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),


        child:

        Column(

          children:[



            Container(

              height:150,

              width:double.infinity,


              decoration:

              BoxDecoration(

                borderRadius:
                BorderRadius.circular(20),

                color:
                Colors.green.shade50,

              ),


              child:

              const Icon(

                Icons.add_photo_alternate,

                size:60,

                color:
                Colors.green,

              ),

            ),



            const SizedBox(
                height:20
            ),



            TextField(

              controller:
              nameController,


              decoration:
              InputDecoration(

                labelText:
                "Product Name",

                prefixIcon:
                const Icon(
                    Icons.shopping_bag
                ),

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                ),

              ),

            ),



            const SizedBox(
                height:15
            ),



            DropdownButtonFormField(

              value:
              category,


              items:
              [

                "Food",
                "Medicine",
                "Toy",
                "Accessory"

              ]

                  .map(

                      (e)=>

                      DropdownMenuItem(

                        value:e,

                        child:
                        Text(e),

                      )

              )

                  .toList(),


              onChanged:(value){

                setState(() {

                  category=value.toString();

                });

              },


              decoration:
              InputDecoration(

                labelText:
                "Category",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                ),

              ),

            ),



            const SizedBox(
                height:15
            ),



            TextField(

              controller:
              priceController,


              keyboardType:
              TextInputType.number,


              decoration:
              InputDecoration(

                labelText:
                "Price",

                prefixText:
                "MMK ",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                ),

              ),

            ),



            const SizedBox(
                height:15
            ),



            TextField(

              controller:
              stockController,


              keyboardType:
              TextInputType.number,


              decoration:
              InputDecoration(

                labelText:
                "Stock",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                ),

              ),

            ),



            const SizedBox(
                height:15
            ),



            TextField(

              controller:
              descriptionController,


              maxLines:4,


              decoration:
              InputDecoration(

                labelText:
                "Description",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(15),

                ),

              ),

            ),



            const SizedBox(
                height:25
            ),




            SizedBox(

              width:
              double.infinity,


              height:
              55,


              child:

              ElevatedButton(


                onPressed:
                loading
                    ?
                null
                    :
                addProduct,


                child:

                loading

                    ?

                const CircularProgressIndicator()

                    :

                const Text(

                    "Add Product",

                    style:
                    TextStyle(
                        fontSize:17
                    )

                ),

              ),

            )


          ],

        ),

      ),

    );

  }

}