import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  SAVED CARD MODEL
// ─────────────────────────────────────────────────────────────
class SavedCard {
  final String id;
  final String last4;        // Son 4 hane
  final String holderName;
  final String expiry;       // MM/YY
  final CardType type;
  final String label;        // Kullanıcının verdiği isim (ör. "İş Kartım")
  final String fullNumber;   // Ödeme için tam kart numarası
  final String cvv;          // Ödeme için CVV

  const SavedCard({
    required this.id,
    required this.last4,
    required this.holderName,
    required this.expiry,
    required this.type,
    this.label = '',
    this.fullNumber = '',
    this.cvv = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'last4': last4,
    'holderName': holderName,
    'expiry': expiry,
    'type': type.name,
    'label': label,
    'fullNumber': fullNumber,
    'cvv': cvv,
  };

  static SavedCard fromMap(Map<String, dynamic> m) => SavedCard(
    id: m['id'] ?? '',
    last4: m['last4'] ?? '****',
    holderName: m['holderName'] ?? '',
    expiry: m['expiry'] ?? '',
    type: CardType.values.firstWhere(
      (t) => t.name == m['type'],
      orElse: () => CardType.other,
    ),
    label: m['label'] ?? '',
    fullNumber: m['fullNumber'] ?? '',
    cvv: m['cvv'] ?? '',
  );

  String get maskedNumber => '**** **** **** $last4';

  String get displayName {
    switch (type) {
      case CardType.visa:        return 'Visa';
      case CardType.mastercard:  return 'Mastercard';
      case CardType.troy:        return 'Troy';
      case CardType.other:       return 'Kart';
    }
  }

  /// Karta verilen isim varsa onu, yoksa tip adını göster
  String get title => label.isNotEmpty ? label : displayName;
}

enum CardType { visa, mastercard, troy, other }

// ─────────────────────────────────────────────────────────────
//  CARD PROVIDER
// ─────────────────────────────────────────────────────────────
class CardProvider extends ChangeNotifier {
  String _uid = 'guest';
  final _firestore = FirebaseFirestore.instance;
  List<SavedCard> _cards = [];

  List<SavedCard> get cards => _cards;
  String get _cardsKey => 'cards_$_uid';

  Future<void> initialize(String uid) async {
    _uid = uid;
    await _load();
    notifyListeners();
  }

  Future<void> switchUser(String uid) async {
    _uid = uid;
    _cards = [];
    await _load();
    notifyListeners();
  }

  Future<void> addCard(SavedCard card) async {
    _cards.add(card);
    await _save();
    notifyListeners();
  }

  Future<void> deleteCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> renameCard(String id, String label) async {
    final idx = _cards.indexWhere((c) => c.id == id);
    if (idx < 0) return;
    final old = _cards[idx];
    _cards[idx] = SavedCard(
      id: old.id,
      last4: old.last4,
      holderName: old.holderName,
      expiry: old.expiry,
      type: old.type,
      label: label,
      fullNumber: old.fullNumber,
      cvv: old.cvv,
    );
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final cardMaps = _cards.map((c) => c.toMap()).toList();

    // SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cardsKey, jsonEncode(cardMaps));
    } catch (e) {
      debugPrint('CardProvider SharedPreferences save error: $e');
    }

    // Firestore (guest hariç)
    if (_uid != 'guest') {
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .set({'cards': cardMaps}, SetOptions(merge: true));
      } catch (e) {
        debugPrint('CardProvider Firestore save error: $e');
      }
    }
  }

  Future<void> _load() async {
    // SharedPreferences'tan yükle
    List<SavedCard> spCards = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cardsKey);
      if (raw != null) {
        spCards = (jsonDecode(raw) as List)
            .map((m) => SavedCard.fromMap(m as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('CardProvider SharedPreferences load error: $e');
    }

    // Firestore'dan yükle ve merge et (guest değilse)
    if (_uid != 'guest') {
      try {
        final doc = await _firestore.collection('users').doc(_uid).get();
        final data = doc.data();
        if (data != null && data['cards'] is List) {
          final fsCards = (data['cards'] as List)
              .map((m) => SavedCard.fromMap(m as Map<String, dynamic>))
              .toList();
          if (fsCards.isNotEmpty) {
            // Firestore öncelikli: id bazlı merge
            final merged = <String, SavedCard>{};
            for (final c in spCards) merged[c.id] = c;
            for (final c in fsCards) merged[c.id] = c;
            _cards = merged.values.toList();
            return;
          }
        }
      } catch (e) {
        debugPrint('CardProvider Firestore load error: $e');
      }
    }

    _cards = spCards;
  }
}
