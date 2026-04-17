import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/order_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showOrderStatusNotification(OrderModel order) async {
    const androidDetails = AndroidNotificationDetails(
      'order_channel',
      'Sipariş Bildirimleri',
      channelDescription: 'Siparişinizin durumu hakkında bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      order.id.hashCode,
      '${order.status.emoji} ${order.status.label}',
      order.status.description,
      details,
    );
  }

  static Future<void> showOrderConfirmedNotification(String orderId, String restaurantName) async {
    const androidDetails = AndroidNotificationDetails(
      'order_channel',
      'Sipariş Bildirimleri',
      channelDescription: 'Siparişinizin durumu hakkında bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      orderId.hashCode,
      '✅ Siparişiniz Alındı!',
      '$restaurantName siparişinizi hazırlamaya başlıyor',
      details,
    );
  }
}
