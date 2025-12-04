import 'package:foodie_hub/screens/entry_screen.dart';
import 'package:flutter/material.dart';
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EntryScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
        // Background logo
        Image.asset(
        'assets/logo.png',
        fit: BoxFit.fill,
      ),

        Container(color: Colors.black.withOpacity(0.4)),

]
      )
    );
  }
}
