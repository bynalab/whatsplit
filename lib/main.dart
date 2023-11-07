import 'package:flutter/material.dart';
import 'package:whatsplit/splash_screen.dart';

void main() {
  runApp(const WhatSplit());
}

class WhatSplit extends StatelessWidget {
  const WhatSplit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
