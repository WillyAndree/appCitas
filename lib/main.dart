import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:prycitas/view/loginpage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(ignoreSsl: true );
  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

