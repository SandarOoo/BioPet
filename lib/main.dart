
import 'package:biopet/Login_Screen.dart';
import 'package:biopet/map_screen.dart';
import 'package:biopet/newfeed_screen.dart';
import 'package:biopet/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  print("BASE URL => ${dotenv.env['BASE_URL']}");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioPet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          primary: const Color(0xFF6d3b1f),
          secondary: const Color(0xFFa0522d),
          surface: const Color(0xFFfdf6f0),
          background: const Color(0xFFfdf6f0),
        ),
        scaffoldBackgroundColor: const Color(0xFFfdf6f0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6d3b1f),
          foregroundColor: Color(0xFFfff8f2),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF3d1f0d),
          selectedItemColor: Color(0xFFf5c18a),
          unselectedItemColor: Color(0xFFc8a882),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6d3b1f),
            foregroundColor: const Color(0xFFfff8f2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8B4513),
            side: const BorderSide(color: Color(0xFF8B4513)),
                shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          selectedColor: const Color(0xFF8B4513),
          labelStyle: const TextStyle(fontSize: 12),
          side: const BorderSide(color: Color(0xFF8B4513)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home:LoginScreen(),
    );
  }
}

