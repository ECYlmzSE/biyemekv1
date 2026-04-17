import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPayload {
  final String title;
  final String body;
  final String? orderId;
  final String emoji;
  const NotificationPayload({
    required this.title,
    required this.body,
    this.orderId,
    this.emoji = '🍽️',
  });
}

class FirebaseService {
  static final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static int _notifId = 0;

  /// Notification ID for a given order — same order always reuses same slot.
  static int orderNotifId(String orderId) => orderId.hashCode.abs() % 100000;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _notif.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onResponse,
      );
      // Request Android 13+ notification permission
      final androidPlugin = _notif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();

      _initialized = true;
      debugPrint('FirebaseService: notifications initialized');
    } catch (e) {
      debugPrint('FirebaseService init error: $e');
    }
  }

  static void _onResponse(NotificationResponse resp) {
    debugPrint('Notification tapped: ${resp.payload}');
  }

  static Future<void> sendLocalNotification(NotificationPayload payload) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'biyemek_orders',
        'Sipariş Bildirimleri',
        channelDescription: "Bi'Yemek sipariş güncellemeleri",
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      // Use order-specific ID so status updates replace each other in the tray.
      final id = payload.orderId != null
          ? orderNotifId(payload.orderId!)
          : _notifId++;
      await _notif.show(
        id,
        payload.title,
        payload.body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload.orderId,
      );
    } catch (e) {
      debugPrint('Notification send error: $e');
    }
  }
}
