import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'business_dashboard.dart';


class BusinessPendingScreen extends StatefulWidget {

  const BusinessPendingScreen({
    super.key,
  });

  @override
  State<BusinessPendingScreen> createState() =>
      _BusinessPendingScreenState();

}



class _BusinessPendingScreenState
    extends State<BusinessPendingScreen> {


  Timer? timer;


  @override
  void initState() {
    super.initState();

    startChecking();

  }



  void startChecking(){

    timer = Timer.periodic(
      const Duration(seconds: 3),
          (timer){

        checkStatus();

      },
    );

  }



  Future<void> checkStatus() async {


    try {

      final data = await ApiService.getCurrentUser();


     if(data?['success'] == true){

        final user = data?['user'];

        final status =
        user['businessProfile']
        ['verificationStatus'];



        if(status == "approved"){


          timer?.cancel();


          if(!mounted) return;


          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (_) =>
              const BusinessDashboard(),

            ),

          );


        }


      }


    }
    catch(e){

      print(e);

    }


  }



  @override
  void dispose(){

    timer?.cancel();

    super.dispose();

  }



  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
            "Application Status"
        ),

      ),


      body:

      Center(

        child:

        Column(

          mainAxisAlignment:
          MainAxisAlignment.center,


          children:[


            const Icon(

              Icons.hourglass_top,

              size:90,

            ),



            const SizedBox(
                height:20
            ),



            const Text(

              "Waiting for Admin Approval",

              style:

              TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold

              ),

            ),



            const SizedBox(
                height:10
            ),



            const Text(

              "Your business application is under review.",

              textAlign:
              TextAlign.center,

            ),



            const SizedBox(
                height:30
            ),



            const CircularProgressIndicator(),


          ],

        ),

      ),

    );

  }

}