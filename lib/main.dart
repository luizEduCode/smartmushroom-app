import 'package:flutter/material.dart';
import 'package:smartmushroom_app/screen/home_page.dart';
import 'package:smartmushroom_app/screen/painelSalas_page.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PainelsalasPage(),
    );
  }
}
