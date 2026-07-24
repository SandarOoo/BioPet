import 'package:flutter/material.dart';
import 'admin_business_list_screen.dart';


class AdminDashboardScreen extends StatelessWidget {

  const AdminDashboardScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
        ),
      ),


      body: Center(

        child: ElevatedButton(

          child: const Text(
            "Pending Businesses",
          ),


          onPressed: (){

            Navigator.push(
              context,

              MaterialPageRoute(

                builder: (_) =>
                const AdminBusinessListScreen(),

              ),

            );

          },

        ),

      ),

    );

  }
}