import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:prycitas/view/loginpage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prycitas/view/notifications/notifications_page.dart' as noti;

Future<void> backgorundHandler(RemoteMessage message) async{

  print(message.data.toString());
  noti.NotificationService().addNotification(noti.Notification(
    id: message.senderId.toString(),
    title: message.notification!.title!,
    body: message.notification!.body!,
    data: message.data["idcita"],
    cliente: message.data["cliente"],
    trabajador: message.data["trabajador"],
    timestamp: DateTime.now(),
    hora: message.data["hora"]??"",
  ));
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(backgorundHandler);

  await FlutterDownloader.initialize(ignoreSsl: true );
  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';
  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyD6xSv9g4IY1AXsOG9LGMANxms0zxhUZPY',
          appId: '1:1068164903271:android:0ff4ce513c4fbdb28cffc2',
          messagingSenderId: '1068164903271',
          projectId: 'appcitas-45aca',
          storageBucket: 'appcitas-45aca.firebasestorage.app',

        )
    );
    runApp(MyApp(),
    );

  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }
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

