import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  Restaurant? _currentRestaurant;
  String _orderNote = '';
  String _paymentMethod = 'Nakit';
  String? _promoCode;
  double _discount = 0;

  String? get promoCode => _promoCode;
  double get discount => _discount;
  double get discountAmount => subtotal * (_discount / 100);
  String get orderNote => _orderNote;
  String get paymentMethod => _paymentMethod;
  void setOrderNote(String v) { _orderNote = v; notifyListeners(); }
  void setPaymentMethod(String v) { _paymentMethod = v; notifyListeners(); }

  List<CartItem> get items => _items;
  Restaurant? get currentRestaurant => _currentRestaurant;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => _currentRestaurant?.deliveryFee ?? 0;
  double get minOrder => _currentRestaurant?.minOrder ?? 0;
  bool get meetsMinOrder => subtotal >= minOrder;
  double get total => subtotal + deliveryFee - discountAmount;

  bool get isEmpty => _items.isEmpty;

  void addCartItem(CartItem ci) {
    addItem(ci.item, ci.restaurant);
  }

  void addCustomItem(CartItem ci) {
    if (_currentRestaurant != null && _currentRestaurant!.id != ci.restaurant.id) {
      clearCart();
    }
    _currentRestaurant = ci.restaurant;
    // Always add as new entry for custom items (different options = different entry)
    _items.add(ci);
    notifyListeners();
  }

  void addItem(MenuItem item, Restaurant restaurant) {
    if (_currentRestaurant != null && _currentRestaurant!.id != restaurant.id) {
      // Different restaurant - clear cart
      clearCart();
    }

    _currentRestaurant = restaurant;

    final existingIndex = _items.indexWhere((ci) => ci.item.id == item.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(item: item, restaurant: restaurant));
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    final index = _items.indexWhere((ci) => ci.item.id == itemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      if (_items.isEmpty) _currentRestaurant = null;
    }
    notifyListeners();
  }

  void deleteItem(String itemId) {
    _items.removeWhere((ci) => ci.item.id == itemId);
    if (_items.isEmpty) _currentRestaurant = null;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _currentRestaurant = null;
    _orderNote = '';
    _paymentMethod = 'Nakit';
    _promoCode = null;
    _discount = 0;
    notifyListeners();
  }

  static const Map<String, double> _promoCodes = {
    'BIYEMEK30': 30, 'HOSGELDIN': 20, 'YEMEK15': 15, 'INDIRIM25': 25,
  };

  String? applyPromoCode(String code) {
    final upper = code.trim().toUpperCase();
    if (_promoCodes.containsKey(upper)) {
      _promoCode = upper;
      _discount = _promoCodes[upper]!;
      notifyListeners();
      return null; // success
    }
    return 'Geçersiz promosyon kodu';
  }

  void removePromoCode() {
    _promoCode = null;
    _discount = 0;
    notifyListeners();
  }

  int getItemQuantity(String itemId) {
    final item = _items.where((ci) => ci.item.id == itemId);
    return item.isEmpty ? 0 : item.first.quantity;
  }
}
