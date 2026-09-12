import 'package:fitvision_ai/features/camera/screens/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'features/camera/screens/camera_screen.dart';

void main() {
  runApp(const FitVisionApp());
}

class FitVisionApp extends StatelessWidget {
  const FitVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitVision AI',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}