import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Lottie.asset("lib/assets/paws_animation.json")
        ],
      ),
    );
  }
}
