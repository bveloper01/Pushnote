import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Text(
        'Loading...',
        style: TextStyle(fontSize: 25),
      )),
    );
  }
}
