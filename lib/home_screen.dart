import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _token;
  final List<String> _notificationsList = [];

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  void _initializeFCM() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _firebaseMessaging.getToken();
      setState(() {
        _token = token;
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );

        setState(() {
          _notificationsList.add(notification.title ?? 'New Notification');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Notifications'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.notifications_active_outlined,
              size: 80,
              color: Colors.teal,
            ),
            const SizedBox(height: 24),
            const Text(
              'Device FCM Token:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _token ?? 'Fetching token...',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Received Notifications:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _notificationsList.isEmpty
                  ? const Center(
                      child: Text('No notifications received yet'),
                    )
                  : ListView.builder(
                      itemCount: _notificationsList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(_notificationsList[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
