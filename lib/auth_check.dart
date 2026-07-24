import 'package:biopet/Login_Screen.dart';
import 'package:biopet/main_navigation.dart';
import 'package:biopet/screens/business/business_dashboard.dart';
import 'package:biopet/screens/business/business_pending_screen.dart';
import 'package:biopet/services/api_service.dart';
import 'package:flutter/material.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {

    final token = await ApiService.getToken();

    if (!mounted) return;

    // No token -> Login
    if (token == null || token.isEmpty) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

      return;
    }

    try {

      final data = await ApiService.getCurrentUser();

      if (data == null || data["success"] != true) {

        await ApiService.logout();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );

        return;
      }

      final user = data["user"];

      final role = user["role"];

      // BUSINESS OWNER
      if (role == "business_owner") {

        final businessProfile = user["businessProfile"] ?? {};

        final status =
            businessProfile["verificationStatus"] ?? "none";

        if (status == "pending") {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const BusinessPendingScreen(),
            ),
          );

          return;
        }

        // approved (BusinessDashboard မရှိသေးလို့ MainNavigation)
        if (status == "approved") {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const BusinessDashboard(),
            ),
          );

          return;
        }

        // none / rejected
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(),
          ),
        );

        return;
      }

      // Normal User
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        ),
      );

    } catch (e) {

      await ApiService.logout();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );

  }
}