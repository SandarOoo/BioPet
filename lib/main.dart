import 'package:biopet/Login_Screen.dart';
import 'package:biopet/auth_check.dart';
import 'package:biopet/dashboard_page.dart';
import 'package:biopet/profile_page.dart';
import 'package:biopet/providers/classification_provider.dart';
import 'package:biopet/providers/history_provider.dart';
import 'package:biopet/screens/admin/admin_dashboard_screen.dart';
import 'package:biopet/screens/business/seller_products_screen.dart';
import 'package:biopet/screens/users/ShopPage.dart';
import 'package:biopet/seller_center_page.dart';
import 'package:biopet/services/classification_service.dart';
import 'package:biopet/services/history_service.dart';
import 'package:biopet/shop_owner/home_screen.dart';
import 'package:biopet/shop_owner/order_details_screen.dart';

import 'package:biopet/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:biopet/services/api_service.dart';
import 'package:biopet/main_navigation.dart';
import 'package:biopet/screens/business/business_location_screen.dart';
import 'package:biopet/screens/business/business_submit_screen.dart';
import 'package:biopet/screens/business/business_pending_screen.dart';
import 'package:biopet/screens/business/business_dashboard.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await dotenv.load(fileName: ".env");


  print(
      "BASE URL => ${dotenv.env['BASE_URL']}"
  );


  final classificationService = ClassificationService();

  final historyService = HistoryService();



  runApp(

    MultiProvider(

      providers: [


        ChangeNotifierProvider(

          create: (_) => ClassificationProvider(

            classificationService: classificationService,

            historyService: historyService,

          ),

        ),



        ChangeNotifierProvider(

          create: (_) => HistoryProvider(

            historyService: historyService,

          ),

        ),


      ],


      child: const MyApp(),

    ),

  );

}





class MyApp extends StatelessWidget {


  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {


    return MaterialApp(

      debugShowCheckedModeBanner: false,


      title: "BioPet",



      theme: ThemeData(


        colorScheme: ColorScheme.fromSeed(

          seedColor: const Color(0xFF8B4513),

          primary: const Color(0xFF6d3b1f),

          secondary: const Color(0xFFa0522d),

          surface: const Color(0xFFfdf6f0),

        ),



        scaffoldBackgroundColor:
        const Color(0xFFfdf6f0),



        appBarTheme: const AppBarTheme(

          backgroundColor:
          Color(0xFF6d3b1f),

          foregroundColor:
          Color(0xFFfff8f2),

          elevation: 0,

        ),



        bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(

          backgroundColor:
          Color(0xFF3d1f0d),

          selectedItemColor:
          Color(0xFFf5c18a),

          unselectedItemColor:
          Color(0xFFc8a882),
        ),
      ),
      // Start with Login
      home:  const AuthCheck(),
      onGenerateRoute: (settings) {
        if(settings.name == "/business-location"){
          return MaterialPageRoute(
            builder: (_) =>
                BusinessLocationScreen(),
          );
        }

        if(settings.name == "/business-submit"){
          return MaterialPageRoute(
            builder: (_) =>
                BusinessSubmitScreen(),
          );
        }
        if (settings.name == "/business-dashboard") {
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          );
        }
        if(settings.name == "/business-pending"){
          return MaterialPageRoute(
            builder: (_) =>
            const BusinessPendingScreen(),
          );
        }
        return null;
      },
    );
  }
}