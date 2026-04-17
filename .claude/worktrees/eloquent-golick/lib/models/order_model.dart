import '../models/restaurant.dart';

enum OrderStatus {
  pending, confirmed, preparing, onTheWay, delivered, cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:   return 'Bekliyor';
      case OrderStatus.confirmed: return 'Onaylandı';
      case OrderStatus.preparing: return 'Hazırlanıyor';
      case OrderStatus.onTheWay:  return 'Yola Çıktı';
      case OrderStatus.delivered: return 'Teslim Edildi';
      case OrderStatus.cancelled: return 'İptal Edildi';
    }
  }

  String get emoji {
    switch (this) {
      case OrderStatus.pending:   return '⏳';
      case OrderStatus.confirmed: return '✅';
      case OrderStatus.preparing: return '👨‍🍳';
      case OrderStatus.onTheWay:  return '🛵';
      case OrderStatus.delivered: return '🎉';
      case OrderStatus.cancelled: return '❌';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:   return 'Siparişiniz işleme alınıyor';
      case OrderStatus.confirmed: return 'Restoran siparişinizi aldı';
      case OrderStatus.preparing: return 'Lezzetli yemeğiniz hazırlanıyor';
      case OrderStatus.onTheWay:  return 'Kurye siparişinizi teslim almaya gidiyor';
      case OrderStatus.delivered: return 'Siparişiniz teslim edildi. Afiyet olsun!';
      case OrderStatus.cancelled: return 'Siparişiniz iptal edildi';
    }
  }

  bool get isActive =>
      this != OrderStatus.delivered && this != OrderStatus.cancelled;
}

// Sipariş satırı için hafif snapshot — Restaurant bağımlılığı yok
class OrderItem {
  final String name;
  final String imageUrl;
  final int quantity;
  final double unitPrice;
  final String options; // seçili ekstralar virgülle

  const OrderItem({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    this.options = '',
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toMap() => {
    'name'     : name,
    'imageUrl' : imageUrl,
    'quantity' : quantity,
    'unitPrice': unitPrice,
    'options'  : options,
  };

  static OrderItem fromMap(Map<String, dynamic> m) => OrderItem(
    name      : m['name']      ?? '',
    imageUrl  : m['imageUrl']  ?? '',
    quantity  : (m['quantity'] ?? 1) as int,
    unitPrice : (m['unitPrice'] ?? 0).toDouble(),
    options   : m['options']   ?? '',
  );

  // CartItem → OrderItem dönüşümü
  static OrderItem fromCartItem(CartItem ci) => OrderItem(
    name      : ci.item.name,
    imageUrl  : ci.item.imageUrl,
    quantity  : ci.quantity,
    unitPrice : ci.item.price + ci.optionsPrice / ci.quantity,
    options   : ci.selectedOptions.map((o) => o.name).join(', '),
  );
}

class OrderModel {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final List<OrderItem> items;   // ← artık OrderItem, CartItem değil
  final String deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double total;
  OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  String? courierName;
  String? note;
  String paymentMethod;
  double discountPct;
  final String userEmail;
  final String userName;

  OrderModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    this.courierName,
    this.note,
    this.paymentMethod = 'Nakit',
    this.discountPct = 0,
    this.userEmail = '',
    this.userName = '',
  });

  OrderModel copyWith({OrderStatus? status, String? courierName, String? note}) => OrderModel(
    id: id, restaurantId: restaurantId,
    restaurantName: restaurantName, restaurantImage: restaurantImage,
    items: items, deliveryAddress: deliveryAddress,
    subtotal: subtotal, deliveryFee: deliveryFee, total: total,
    status: status ?? this.status,
    createdAt: createdAt, estimatedDelivery: estimatedDelivery,
    courierName: courierName ?? this.courierName,
    note: note ?? this.note,
    paymentMethod: paymentMethod,
    discountPct: discountPct,
    userEmail: userEmail,
    userName: userName,
  );

  Map<String, dynamic> toMap() => {
    'id'               : id,
    'restaurantId'     : restaurantId,
    'restaurantName'   : restaurantName,
    'restaurantImage'  : restaurantImage,
    'deliveryAddress'  : deliveryAddress,
    'subtotal'         : subtotal,
    'deliveryFee'      : deliveryFee,
    'total'            : total,
    'status'           : status.name,
    'createdAt'        : createdAt.toIso8601String(),
    'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    'courierName'      : courierName,
    'note'             : note,
    'paymentMethod'    : paymentMethod,
    'discountPct'      : discountPct,
    'userEmail'        : userEmail,
    'userName'         : userName,
    'items'            : items.map((i) => i.toMap()).toList(),
  };

  static OrderModel fromMap(Map<String, dynamic> map) => OrderModel(
    id              : map['id']             ?? '',
    restaurantId    : map['restaurantId']   ?? '',
    restaurantName  : map['restaurantName'] ?? '',
    restaurantImage : map['restaurantImage'] ?? '',
    items           : (map['items'] as List? ?? [])
                          .map((m) => OrderItem.fromMap(m as Map<String, dynamic>))
                          .toList(),
    deliveryAddress : map['deliveryAddress'] ?? '',
    subtotal        : (map['subtotal']    ?? 0).toDouble(),
    deliveryFee     : (map['deliveryFee'] ?? 0).toDouble(),
    total           : (map['total']       ?? 0).toDouble(),
    status          : OrderStatus.values.firstWhere(
                          (s) => s.name == map['status'],
                          orElse: () => OrderStatus.delivered),
    createdAt       : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    estimatedDelivery: map['estimatedDelivery'] != null
                          ? DateTime.tryParse(map['estimatedDelivery'])
                          : null,
    courierName     : map['courierName'],
    note            : map['note'],
    paymentMethod   : map['paymentMethod'] ?? 'Nakit',
    discountPct     : (map['discountPct'] ?? 0).toDouble(),
    userEmail       : map['userEmail'] ?? '',
    userName        : map['userName'] ?? '',
  );
}
