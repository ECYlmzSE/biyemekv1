import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/restaurant.dart';
import '../services/email_service.dart';
import '../services/firebase_service.dart';
import '../widgets/in_app_notification.dart';

class OrderProvider extends ChangeNotifier {
  String _uid = 'guest';
  List<OrderModel> _orders = [];
  List<OrderModel> get orders       => _orders;
  List<OrderModel> get activeOrders => _orders.where((o) =>  o.status.isActive).toList();
  List<OrderModel> get pastOrders   => _orders.where((o) => !o.status.isActive).toList();

  String get _ordersKey  => 'orders_' + _uid;
  String get _reviewsKey => 'reviews_' + _uid;

  // Per-order timers: orderId → list of timers
  final Map<String, List<Timer>> _orderTimers = {};
  final Random _rng = Random();
  final List<String> _couriers = [
    'Mehmet K.','Ali D.','Mustafa Y.','Ahmet Ç.','Emre S.',
    'Fatih K.','Burak T.','Serkan A.','Osman B.','Kemal R.',
  ];

  Future<void> initialize({String uid = 'guest'}) async {
    _uid = uid;
    await _loadOrders();
    await _loadReviews();
    _resumeActiveOrders();
  }

  Future<void> switchUser(String uid) async {
    _uid = uid;
    _cancelAllTimers();
    _orders = [];
    _reviews.clear();
    await _loadOrders();
    await _loadReviews();
    _resumeActiveOrders();
    notifyListeners();
  }

  void _cancelAllTimers() {
    for (final timers in _orderTimers.values) {
      for (final t in timers) t.cancel();
    }
    _orderTimers.clear();
  }

  void _cancelOrderTimers(String orderId) {
    final timers = _orderTimers.remove(orderId) ?? [];
    for (final t in timers) t.cancel();
  }

  void _addOrderTimer(String orderId, Timer timer) {
    _orderTimers.putIfAbsent(orderId, () => []).add(timer);
  }

  // ── Resume simulation for orders that were active before app closed ──────
  void _resumeActiveOrders() {
    for (final order in _orders) {
      if (!order.status.isActive) continue;
      final elapsed = DateTime.now().difference(order.createdAt).inSeconds;
      _resumeSimulation(order.id, order.restaurantName, elapsed, order.status);
    }
  }

  void _resumeSimulation(String orderId, String restaurantName,
      int elapsedSeconds, OrderStatus currentStatus) {
    // Simulation timeline (in seconds):
    //  0s   → confirmed
    //  120s → preparing  (2 min)
    //  360s → onTheWay   (6 min)
    //  720s → delivered  (12 min)

    const preparingAt  = 120;
    const onTheWayAt   = 360;
    const deliveredAt  = 720;

    if (elapsedSeconds < preparingAt) {
      final remaining = preparingAt - elapsedSeconds;
      _addOrderTimer(orderId, Timer(Duration(seconds: remaining), () async {
        if (!_isOrderActive(orderId)) return; // cancelled — skip
        await _updateStatus(orderId, OrderStatus.preparing,
            courierName: _couriers[_rng.nextInt(_couriers.length)]);
        const title = '👨‍🍳 Hazırlanıyor';
        final body = '$restaurantName siparişinizi hazırlıyor';
        InAppNotificationService.show(title, body, emoji: '👨‍🍳');
        FirebaseService.sendLocalNotification(NotificationPayload(
          title: title, body: body, orderId: orderId, emoji: '👨‍🍳',
        ));
      }));
    } else if (currentStatus == OrderStatus.confirmed) {
      _updateStatus(orderId, OrderStatus.preparing,
          courierName: _couriers[_rng.nextInt(_couriers.length)]);
    }

    if (elapsedSeconds < onTheWayAt) {
      final remaining = onTheWayAt - elapsedSeconds;
      _addOrderTimer(orderId, Timer(Duration(seconds: remaining), () async {
        if (!_isOrderActive(orderId)) return;
        await _updateStatus(orderId, OrderStatus.onTheWay);
        const title = '🛵 Yola Çıktı!';
        const body = 'Kurye siparişinizi teslim almaya gidiyor';
        InAppNotificationService.show(title, body, emoji: '🛵');
        FirebaseService.sendLocalNotification(NotificationPayload(
          title: title, body: body, orderId: orderId, emoji: '🛵',
        ));
      }));
    } else if (currentStatus == OrderStatus.preparing) {
      _updateStatus(orderId, OrderStatus.onTheWay);
    }

    if (elapsedSeconds < deliveredAt) {
      final remaining = deliveredAt - elapsedSeconds;
      _addOrderTimer(orderId, Timer(Duration(seconds: remaining), () async {
        if (!_isOrderActive(orderId)) return;
        await _updateStatus(orderId, OrderStatus.delivered);
        const title = '🎉 Teslim Edildi!';
        const body = 'Siparişiniz teslim edildi. Afiyet olsun!';
        InAppNotificationService.show(title, body, emoji: '🎉');
        FirebaseService.sendLocalNotification(NotificationPayload(
          title: title, body: body, orderId: orderId, emoji: '🎉',
        ));
        // Teslim maili
        final idx = _orders.indexWhere((o) => o.id == orderId);
        if (idx >= 0) {
          final o = _orders[idx];
          if (o.userEmail.isNotEmpty) {
            EmailService.sendDeliveryNotification(
              toEmail: o.userEmail,
              toName: o.userName.isNotEmpty ? o.userName : 'Değerli Müşterimiz',
              orderId: o.id,
              restaurantName: o.restaurantName,
              total: o.total,
            );
          }
        }
      }));
    } else if (currentStatus == OrderStatus.onTheWay) {
      _updateStatus(orderId, OrderStatus.delivered);
    }
  }

  bool _isOrderActive(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    return idx >= 0 && _orders[idx].status.isActive;
  }

  Future<void> placeOrder({
    required Restaurant restaurant,
    required List<CartItem> items,
    required String deliveryAddress,
    required double subtotal,
    required double deliveryFee,
    String? note,
    String paymentMethod = 'Nakit',
    double discountPct = 0,
    String userEmail = '',
    String userName = '',
  }) async {
    final snapshots = items.map(OrderItem.fromCartItem).toList();

    final order = OrderModel(
      id: 'BYM-${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      restaurantImage: restaurant.imageUrl,
      items: snapshots,
      deliveryAddress: deliveryAddress,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: subtotal + deliveryFee,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(Duration(minutes: restaurant.deliveryTimeMin)),
      note: note,
      paymentMethod: paymentMethod,
      discountPct: discountPct,
      userEmail: userEmail,
      userName: userName,
    );

    _orders.insert(0, order);
    await _saveOrders();
    notifyListeners();

    const confirmedTitle = '✅ Siparişiniz Alındı!';
    final confirmedBody = '${restaurant.name} siparişinizi hazırlamaya başlıyor';
    InAppNotificationService.show(confirmedTitle, confirmedBody, emoji: '✅');
    FirebaseService.sendLocalNotification(NotificationPayload(
      title: confirmedTitle, body: confirmedBody,
      orderId: order.id, emoji: '✅',
    ));

    // Sipariş onay maili
    if (userEmail.isNotEmpty) {
      final itemNames = items.map((i) => '${i.item.name} x${i.quantity}').toList();
      EmailService.sendOrderConfirmation(
        toEmail: userEmail,
        toName: userName.isNotEmpty ? userName : 'Değerli Müşterimiz',
        orderId: order.id,
        restaurantName: restaurant.name,
        itemNames: itemNames,
        total: subtotal + deliveryFee,
        deliveryAddress: deliveryAddress,
        estimatedTime: '${restaurant.deliveryTimeMin}-${restaurant.deliveryTimeMax} dakika',
      );
    }

    _resumeSimulation(order.id, restaurant.name, 0, OrderStatus.confirmed);
  }

  Future<void> _updateStatus(String orderId, OrderStatus status,
      {String? courierName}) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;
    _orders[idx] = _orders[idx].copyWith(
      status: status,
      courierName: courierName ?? _orders[idx].courierName,
    );
    await _saveOrders();
    notifyListeners();
  }

  Future<void> cancelOrder(String orderId) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx < 0 || !_orders[idx].status.isActive) return;
    // Cancel all pending timers for this order first
    _cancelOrderTimers(orderId);
    _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
    await _saveOrders();
    notifyListeners();
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ordersKey,
          jsonEncode(_orders.map((o) => o.toMap()).toList()));
    } catch (e) { debugPrint('OrderProvider save error: $e'); }
  }

  Future<void> _loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_ordersKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _orders = list.map((m) => OrderModel.fromMap(m as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('OrderProvider load error: $e');
      _orders = [];
    }
  }

  // ── Reviews ──────────────────────────────────────────────────
  final Map<String, Review> _reviews = {};
  Map<String, Review> get reviews => _reviews;
  bool hasReview(String orderId) => _reviews.containsKey(orderId);

  Future<void> addReview(String orderId, Review review) async {
    _reviews[orderId] = review;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _reviews.map((k, v) => MapEntry(k, {
        'id': v.id, 'userName': v.userName, 'rating': v.rating,
        'comment': v.comment, 'createdAt': v.createdAt.toIso8601String(),
        'orderId': v.orderId,
      }));
      await prefs.setString(_reviewsKey, jsonEncode(map));
    } catch (_) {}
  }

  Future<void> _loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_reviewsKey);
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _reviews.clear();
        for (final entry in map.entries) {
          final v = entry.value as Map<String, dynamic>;
          _reviews[entry.key] = Review(
            id: v['id'] ?? '',
            userName: v['userName'] ?? 'Kullanıcı',
            rating: (v['rating'] as num).toDouble(),
            comment: v['comment'] ?? '',
            createdAt: DateTime.tryParse(v['createdAt'] ?? '') ?? DateTime.now(),
            orderId: v['orderId'],
          );
        }
        notifyListeners();
      }
    } catch (e) { debugPrint('Review load error: $e'); }
  }

  @override
  void dispose() {
    _cancelAllTimers();
    super.dispose();
  }
}
