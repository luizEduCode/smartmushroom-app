import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smartmushroom_app/screen/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter está pronto
  await initializeDateFormatting('pt_BR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}
