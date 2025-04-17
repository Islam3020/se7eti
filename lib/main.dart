import 'package:flutter/material.dart';
import 'package:se7eti/feature/intro/splash_view.dart';

void main() {
  runApp(const Se7eti());
}
class Se7eti extends StatelessWidget {
  const Se7eti({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}