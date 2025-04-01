import 'package:flutter/material.dart';
import 'package:prycitas/view/citasList.dart';
import 'package:prycitas/view/loginpage.dart';
import 'package:prycitas/view/menu_principal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home:  LoginPage(),
    );
  }
}

