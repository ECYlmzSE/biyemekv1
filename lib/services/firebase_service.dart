import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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
  static bool _canScheduleExact = false;
  static int _notifId = 0;

  /// Notification ID for a given order — same order always reuses same slot.
  static int orderNotifId(String orderId) => orderId.hashCode.abs() % 100000;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
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

      final androidPlugin = _notif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Android 13+ bildirim izni
      await androidPlugin?.requestNotificationsPermission();

      // Android 12+ exact alarm izni — yoksa ayarlar ekranını aç
      try {
        final canExact =
            await androidPlugin?.canScheduleExactNotifications() ?? false;
        if (!canExact) {
          debugPrint(
              'FirebaseService: exact alarm izni yok, isteniyor...');
          await androidPlugin?.requestExactAlarmsPermission();
          _canScheduleExact =
              await androidPlugin?.canScheduleExactNotifications() ?? false;
        } else {
          _canScheduleExact = true;
        }
      } catch (_) {
        // API 31 öncesinde bu metod yoktur, varsayılan olarak exact kullan
        _canScheduleExact = true;
      }

      _initialized = true;
      debugPrint(
          'FirebaseService: başlatıldı | canScheduleExact=$_canScheduleExact');
    } catch (e) {
      debugPrint('FirebaseService init error: $e');
    }
  }

  static void _onResponse(NotificationResponse resp) {
    debugPrint('Bildirime tıklandı: ${resp.payload}');
  }

  /// Sipariş verildiğinde 3 aşama için zamanlanmış bildirim kur.
  /// Uygulama arka planda/kapalıyken de tetiklenir.
  static Future<void> scheduleOrderNotifications(
      String orderId, String restaurantName) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'biyemek_orders',
        'Sipariş Bildirimleri',
        channelDescription: "Bi'Yemek sipariş güncellemeleri",
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
      const details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      // Exact alarm varsa exactAllowWhileIdle, yoksa inexactAllowWhileIdle
      final scheduleMode = _canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      final baseId = orderNotifId(orderId);
      final now = tz.TZDateTime.now(tz.local);

      // +2 dk → Hazırlanıyor
      await _notif.zonedSchedule(
        baseId,
        '👨‍🍳 Hazırlanıyor',
        '$restaurantName siparişinizi hazırlıyor',
        now.add(const Duration(seconds: 120)),
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: orderId,
      );
      // +6 dk → Yolda
      await _notif.zonedSchedule(
        baseId + 1,
        '🛵 Yola Çıktı!',
        'Siparişiniz teslim edilmek üzere yola çıktı',
        now.add(const Duration(seconds: 360)),
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: orderId,
      );
      // +12 dk → Teslim edildi
      await _notif.zonedSchedule(
        baseId + 2,
        '🎉 Teslim Edildi!',
        'Siparişiniz teslim edildi. Afiyet olsun!',
        now.add(const Duration(seconds: 720)),
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: orderId,
      );
      debugPrint(
          'FirebaseService: $orderId için 3 bildirim zamanlandı (exact=$_canScheduleExact)');
    } catch (e) {
      debugPrint('scheduleOrderNotifications error: $e');
    }
  }

  /// Sipariş iptal edildiğinde zamanlanmış bildirimleri sil.
  static Future<void> cancelOrderNotifications(String orderId) async {
    if (!_initialized) return;
    try {
      final baseId = orderNotifId(orderId);
      await _notif.cancel(baseId);
      await _notif.cancel(baseId + 1);
      await _notif.cancel(baseId + 2);
    } catch (e) {
      debugPrint('cancelOrderNotifications error: $e');
    }
  }

  static Future<void> sendLocalNotification(NotificationPayload payload) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'biyemek_orders',
        'Sipariş Bildirimleri',
        channelDescription: "Bi'Yemek sipariş güncellemeleri",
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
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
