import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class Notification {
  final String id;
  final String title;
  final String body;
  final String data;
  final String cliente;
  final String trabajador;
  final DateTime timestamp;
  final String hora;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.cliente,
    required this.trabajador,
    required this.timestamp,
    required this.hora,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      data: json['data'],
      cliente: json['cliente'],
      trabajador: json['trabajador'],
      timestamp: DateTime.parse(json['timestamp']),
      hora: json['hora'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'cliente': cliente,
      'trabajador': trabajador,
      'timestamp': timestamp.toIso8601String(),
      'hora': hora,
    };
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> addNotification(Notification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    final notificationsList = json.decode(notificationsJson) as List;

    notificationsList.add(notification.toJson());

    await prefs.setString('notifications', json.encode(notificationsList));
  }

  Future<List<Notification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    final notificationsList = json.decode(notificationsJson) as List;

    return notificationsList
        .map((notificationJson) => Notification.fromJson(notificationJson))
        .toList();
  }

  Future<void> removeNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    final notificationsList = json.decode(notificationsJson) as List;

    notificationsList.removeWhere((notification) => notification['id'] == id);

    await prefs.setString('notifications', json.encode(notificationsList));
  }
  Future<bool> hasUnreadNotifications() async {
    final notifications = await getNotifications();
    return notifications.isNotEmpty;
  }
}

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Notification> _notifications = [];
  String phone = "";
  String email = "";
  String username = "";
  String foto = "";
  @override
  void initState() {
    super.initState();
    _obtenerPrefLogueo();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notifications = await NotificationService().getNotifications();
    setState(() {
      _notifications = notifications;
    });
  }

  void _removeNotification(String id) async {
    await NotificationService().removeNotification(id);
    _loadNotifications();
  }

  Future<void>_obtenerPrefLogueo() async {
    //await
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phone = (prefs.get("phone") ?? "") as String;
      email = (prefs.get("email") ?? "") as String;
      username = (prefs.get("name") ?? "") as String;
      foto = (prefs.get("foto") ?? "") as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
      body: _notifications.isEmpty
          ? Center(
        child: Text('No tienes notificaciones no leídas'),
      )
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Dismissible(
            key: Key(notification.id),
            onDismissed: (direction) {
              _removeNotification(notification.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notificación eliminada')),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  notification.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(notification.body),
                    SizedBox(height: 4),
                    Text(
                      '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {


                },
              ),
            ),
          );
        },
      ),
    );
  }
}

