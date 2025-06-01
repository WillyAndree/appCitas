
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService{
  static final FlutterLocalNotificationsPlugin _notificationsPlugin= FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context){

    final InitializationSettings initializationSettings =
    InitializationSettings(android:  AndroidInitializationSettings("@mipmap/ic_launcher"), iOS: DarwinInitializationSettings(
      requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true, onDidReceiveLocalNotification: (id, title, body, payload) async{},));
    _notificationsPlugin.initialize(initializationSettings);

  }

  Future<void> initNotifications()async{
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings("@mipmap/ic_launcher",);

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission:true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:(int id, String? title, String? body, String? payload) async{});

    var inilitiationsSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS
    );
    await _notificationsPlugin.initialize(inilitiationsSettings,onDidReceiveBackgroundNotificationResponse: (NotificationResponse notificationResponse) async{});
  }



  notificationsDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          "prycitas",
          "prycitas channel",
          // "this is channel",
          importance: Importance.max,
          priority: Priority.high,
        playSound: true,

      ),
        iOS:  DarwinNotificationDetails(threadIdentifier: "prycitas",
            subtitle: "prycitas",
            presentAlert: true,
            presentBadge: true,
            presentSound: true
        )
    );
  }

  Future showNotification({int id = 0, String? title, String? body, String? payload}) async{
    return _notificationsPlugin.show(id, title, body, await notificationsDetails(),);
}


}