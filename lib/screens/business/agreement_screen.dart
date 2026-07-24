import 'package:biopet/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../services/business_service.dart';


class AgreementScreen extends StatefulWidget {
  const AgreementScreen({
    super.key,
  });


  @override
  State<AgreementScreen> createState()
  => _AgreementScreenState();

}



class _AgreementScreenState
    extends State<AgreementScreen> {


  bool accepted = false;
  bool loading = false;


  final BusinessService service =
  BusinessService();



  Future<void> submit() async {


    if (!accepted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text(
              "Please accept agreement"
          ),
        ),
      );

      return;
    }



    setState(() {
      loading = true;
    });

    final token = await ApiService.getToken();
  if(token == null) {
    return;
  }
    final success =
    await service.acceptAgreement(token);



    setState(() {
      loading = false;
    });



    if (success) {


      Navigator.pushReplacementNamed(
        context,
        "/business-location",
      );


    } else {


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "Failed to accept agreement"
          ),

        ),

      );


    }

  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title:
        const Text(
          "Business Agreement",
        ),

      ),



      body: Padding(


        padding:
        const EdgeInsets.all(20),



        child: Column(


          children: [



            const Expanded(


              child:

              SingleChildScrollView(


                child:

                Text(

                  """
BioPet Business Owner Agreement

1. Owner must provide correct shop information.

2. Location must match the real shop location.

3. BioPet can review and verify business information.

4. Fake information may result in rejection.

5. Business owners are responsible for their shop data.

""",

                  style:
                  TextStyle(
                    fontSize:16,
                    height:1.5,
                  ),

                ),

              ),

            ),





            CheckboxListTile(


              value: accepted,


              onChanged: (value) {


                setState(() {

                  accepted =
                      value ?? false;

                });


              },


              title:

              const Text(

                "I agree with terms and conditions",

              ),


            ),





            const SizedBox(
              height:10,
            ),





            SizedBox(


              width:
              double.infinity,



              child:

              ElevatedButton(


                onPressed:

                loading
                    ?
                null
                    :
                submit,



                child:

                loading


                    ?

                const SizedBox(

                  height:20,

                  width:20,

                  child:

                  CircularProgressIndicator(

                    strokeWidth:2,

                  ),

                )

                    :


                const Text(

                  "Accept & Continue",

                ),


              ),

            ),



          ],

        ),

      ),

    );


  }

}