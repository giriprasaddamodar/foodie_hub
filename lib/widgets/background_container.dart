import 'dart:ui';
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background logo
        Image.asset(
          'assets/logo.png',
          fit: BoxFit.fill,
        ),

        // Blur layer
        Container(color: Colors.black.withOpacity(0.8)),

        // Optional gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black54,
              ],
            ),
          ),
        ),

        // Actual page content
        child,
      ],
    );
  }
}
