import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  void setOrderNote(String v) { _orderNote = v; notifyListeners(); _save(); }
  void setPaymentMethod(String v) { _paymentMethod = v; notifyListeners(); _save(); }

  List<CartItem> get items => _items;
  Restaurant? get currentRestaurant => _currentRestaurant;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => _currentRestaurant?.deliveryFee ?? 0;
  double get minOrder => _currentRestaurant?.minOrder ?? 0;
  bool get meetsMinOrder => subtotal >= minOrder;
  double get total => subtotal + deliveryFee - discountAmount;

  bool get isEmpty => _items.isEmpty;

  // ── Persistence ──────────────────────────────────────────────

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Restore restaurant
      final restJson = prefs.getString('cart_restaurant');
      if (restJson != null) {
        final m = jsonDecode(restJson) as Map<String, dynamic>;
        _currentRestaurant = Restaurant(
          id: m['id'] ?? '',
          name: m['name'] ?? '',
          imageUrl: m['imageUrl'] ?? '',
          cuisine: m['cuisine'] ?? '',
          rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
          reviewCount: 0,
          deliveryTimeMin: (m['deliveryTimeMin'] as num?)?.toInt() ?? 30,
          deliveryTimeMax: (m['deliveryTimeMax'] as num?)?.toInt() ?? 45,
          deliveryFee: (m['deliveryFee'] as num?)?.toDouble() ?? 0.0,
          minOrder: (m['minOrder'] as num?)?.toDouble() ?? 0.0,
          isOpen: true,
          tags: const [],
          menu: const [],
          address: m['address'] ?? '',
          distance: (m['distance'] as num?)?.toDouble() ?? 0.0,
        );
      }

      // Restore items
      final itemsJson = prefs.getString('cart_items');
      if (itemsJson != null && _currentRestaurant != null) {
        final list = jsonDecode(itemsJson) as List;
        _items.clear();
        for (final raw in list) {
          final m = raw as Map<String, dynamic>;
          final menuItem = MenuItem(
            id: m['itemId'] ?? '',
            name: m['itemName'] ?? '',
            description: m['itemDescription'] ?? '',
            price: (m['itemPrice'] as num?)?.toDouble() ?? 0.0,
            imageUrl: m['itemImageUrl'] ?? '',
          );

          MenuOption _parseOption(Map<String, dynamic> o) => MenuOption(
            id: o['id'] ?? '',
            name: o['name'] ?? '',
            price: (o['price'] as num?)?.toDouble() ?? 0.0,
          );

          final selectedOptions = (m['selectedOptions'] as List? ?? [])
              .map((o) => _parseOption(o as Map<String, dynamic>))
              .toList();
          final removedIngredients = (m['removedIngredients'] as List? ?? [])
              .map((o) => _parseOption(o as Map<String, dynamic>))
              .toList();
          final sideItems = (m['sideItems'] as List? ?? [])
              .map((o) => _parseOption(o as Map<String, dynamic>))
              .toList();

          _items.add(CartItem(
            item: menuItem,
            restaurant: _currentRestaurant!,
            quantity: (m['quantity'] as num?)?.toInt() ?? 1,
            note: m['note'] as String?,
            selectedOptions: selectedOptions,
            removedIngredients: removedIngredients,
            sideItems: sideItems,
          ));
        }
      }

      // Restore other fields (payment method always resets to default)
      _paymentMethod = 'Nakit';
      _orderNote = prefs.getString('cart_note') ?? '';
      _promoCode = prefs.getString('cart_promo');
      _discount = prefs.getDouble('cart_discount') ?? 0.0;

      if (_items.isEmpty) _currentRestaurant = null;

      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider load error: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentRestaurant != null) {
        final r = _currentRestaurant!;
        await prefs.setString('cart_restaurant', jsonEncode({
          'id': r.id,
          'name': r.name,
          'imageUrl': r.imageUrl,
          'cuisine': r.cuisine,
          'rating': r.rating,
          'deliveryFee': r.deliveryFee,
          'minOrder': r.minOrder,
          'deliveryTimeMin': r.deliveryTimeMin,
          'deliveryTimeMax': r.deliveryTimeMax,
          'address': r.address,
          'distance': r.distance,
        }));
      } else {
        await prefs.remove('cart_restaurant');
      }

      Map<String, dynamic> _optionToMap(MenuOption o) =>
          {'id': o.id, 'name': o.name, 'price': o.price};

      final itemsList = _items.map((ci) => {
        'itemId': ci.item.id,
        'itemName': ci.item.name,
        'itemPrice': ci.item.price,
        'itemImageUrl': ci.item.imageUrl,
        'itemDescription': ci.item.description,
        'quantity': ci.quantity,
        'note': ci.note,
        'selectedOptions': ci.selectedOptions.map(_optionToMap).toList(),
        'removedIngredients': ci.removedIngredients.map(_optionToMap).toList(),
        'sideItems': ci.sideItems.map(_optionToMap).toList(),
      }).toList();

      await prefs.setString('cart_items', jsonEncode(itemsList));
      await prefs.setString('cart_note', _orderNote);

      if (_promoCode != null) {
        await prefs.setString('cart_promo', _promoCode!);
      } else {
        await prefs.remove('cart_promo');
      }
      await prefs.setDouble('cart_discount', _discount);
    } catch (e) {
      debugPrint('CartProvider save error: $e');
    }
  }

  // ── Cart operations ──────────────────────────────────────────

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
    _save();
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
    _save();
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
    _save();
  }

  void deleteItem(String itemId) {
    _items.removeWhere((ci) => ci.item.id == itemId);
    if (_items.isEmpty) _currentRestaurant = null;
    notifyListeners();
    _save();
  }

  void clearCart() {
    _items.clear();
    _currentRestaurant = null;
    _orderNote = '';
    _paymentMethod = 'Nakit';
    _promoCode = null;
    _discount = 0;
    notifyListeners();
    _save();
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
      _save();
      return null; // success
    }
    return 'Geçersiz promosyon kodu';
  }

  void removePromoCode() {
    _promoCode = null;
    _discount = 0;
    notifyListeners();
    _save();
  }

  int getItemQuantity(String itemId) {
    final item = _items.where((ci) => ci.item.id == itemId);
    return item.isEmpty ? 0 : item.first.quantity;
  }
}
