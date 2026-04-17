import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAddress {
  final String id;
  final String title;
  final String city;
  final String district;
  final String neighborhood;
  final String street;
  final String aptName;      // Site/Apt Adı (Ev) veya Üniversite Adı (Okul)
  final String buildingNo;   // Bina/Blok (Ev/İş) veya Fakülte/Blok (Okul)
  final String floor;        // Kat No
  final String apartmentNo;  // Daire No
  final String directions;   // Adres tarifi (opsiyonel)
  // Legacy fields kept for backward compat
  final String no;
  final String buildingInfo;
  final double? lat;
  final double? lng;

  const UserAddress({
    required this.id,
    required this.title,
    this.city = 'İstanbul',
    this.district = '',
    this.neighborhood = '',
    this.street = '',
    this.aptName = '',
    this.buildingNo = '',
    this.floor = '',
    this.apartmentNo = '',
    this.directions = '',
    this.no = '',
    this.buildingInfo = '',
    this.lat,
    this.lng,
  });

  String get displayAddress {
    final parts = <String>[
      if (aptName.isNotEmpty) aptName,
      if (neighborhood.isNotEmpty) neighborhood,
      if (street.isNotEmpty) street,
      if (buildingNo.isNotEmpty) buildingNo,
      if (floor.isNotEmpty) 'Kat:$floor',
      if (apartmentNo.isNotEmpty) 'D:$apartmentNo',
      if (district.isNotEmpty) district,
      if (city.isNotEmpty) city,
    ];
    return parts.isEmpty ? city : parts.join(', ');
  }

  String get shortAddress {
    if (neighborhood.isNotEmpty && district.isNotEmpty) return '$neighborhood, $district';
    if (neighborhood.isNotEmpty) return '$neighborhood, $city';
    if (district.isNotEmpty) return '$district, $city';
    return city;
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'city': city,
    'district': district, 'neighborhood': neighborhood,
    'street': street, 'aptName': aptName,
    'buildingNo': buildingNo, 'floor': floor, 'apartmentNo': apartmentNo,
    'directions': directions,
    'no': no, 'buildingInfo': buildingInfo,
    'lat': lat, 'lng': lng,
  };

  static UserAddress fromMap(Map<String, dynamic> m) => UserAddress(
    id: m['id'] ?? '',
    title: m['title'] ?? 'Adresim',
    city: m['city'] ?? 'İstanbul',
    district: m['district'] ?? '',
    neighborhood: m['neighborhood'] ?? '',
    street: m['street'] ?? '',
    aptName: m['aptName'] ?? '',
    buildingNo: m['buildingNo'] ?? '',
    floor: m['floor'] ?? '',
    apartmentNo: m['apartmentNo'] ?? (m['no'] ?? ''),
    directions: m['directions'] ?? (m['buildingInfo'] ?? ''),
    no: m['no'] ?? '',
    buildingInfo: m['buildingInfo'] ?? '',
    lat: (m['lat'] as num?)?.toDouble(),
    lng: (m['lng'] as num?)?.toDouble(),
  );

  UserAddress copyWith({
    String? id, String? title, String? city, String? district,
    String? neighborhood, String? street, String? aptName,
    String? buildingNo, String? floor, String? apartmentNo,
    String? directions, String? no, String? buildingInfo,
    double? lat, double? lng,
  }) => UserAddress(
    id: id ?? this.id, title: title ?? this.title, city: city ?? this.city,
    district: district ?? this.district, neighborhood: neighborhood ?? this.neighborhood,
    street: street ?? this.street, aptName: aptName ?? this.aptName,
    buildingNo: buildingNo ?? this.buildingNo,
    floor: floor ?? this.floor,
    apartmentNo: apartmentNo ?? this.apartmentNo,
    directions: directions ?? this.directions,
    no: no ?? this.no, buildingInfo: buildingInfo ?? this.buildingInfo,
    lat: lat ?? this.lat, lng: lng ?? this.lng,
  );
}

// Uygulama genelinde kullanılan ince sarmalayıcı
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phone;
  const MockUser({required this.uid, this.email, this.displayName, this.phone});

  Map<String, dynamic> toMap() => {
    'uid': uid, 'email': email,
    'displayName': displayName, 'phone': phone,
  };
}

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  static final _gSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  MockUser? _user;
  List<UserAddress> _addresses = [];
  int _selectedAddressIdx = 0;
  Set<String> _favorites = {};
  double _balance = 0.0;

  bool get isLoggedIn => _user != null;
  MockUser? get currentUser => _user;
  List<UserAddress> get addresses => _addresses;
  Set<String> get favorites => _favorites;
  double get balance => _balance;
  UserAddress? get selectedAddress =>
      _addresses.isEmpty ? null : _addresses[_selectedAddressIdx.clamp(0, _addresses.length - 1)];

  // ── User-scoped pref keys ───────────────────────────────────
  String get _uid => _user?.uid ?? 'guest';
  String get _addrKey    => 'addr_$_uid';
  String get _selKey     => 'addr_sel_$_uid';
  String get _favKey     => 'fav_$_uid';
  String get _balanceKey => 'balance_$_uid';

  bool isFavorite(String restaurantId) => _favorites.contains(restaurantId);

  Future<void> toggleFavorite(String restaurantId) async {
    if (_favorites.contains(restaurantId)) {
      _favorites.remove(restaurantId);
    } else {
      _favorites.add(restaurantId);
    }
    notifyListeners();
    await _persistFavorites();
  }

  // ── Initialize: Firebase auth state listener ────────────────
  Future<void> initialize() async {
    try {
      final fbUser = _auth.currentUser;
      if (fbUser != null) {
        await _loadFromFirebase(fbUser);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider init error: $e');
    }
  }

  Future<void> _loadFromFirebase(User fbUser) async {
    String? phone;
    try {
      final doc = await _firestore.collection('users').doc(fbUser.uid).get();
      phone = doc.data()?['phone'] as String?;
    } catch (_) {}

    _user = MockUser(
      uid: fbUser.uid,
      email: fbUser.email,
      displayName: fbUser.displayName,
      phone: phone,
    );
    final prefs = await SharedPreferences.getInstance();
    await _loadUserData(prefs);

    // Firestore'dan yükle (migration ile geriye dönük uyumluluk)
    await _loadFromFirestore(prefs);
  }

  Future<void> _loadFromFirestore(SharedPreferences prefs) async {
    if (_user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      final data = doc.data();

      if (data != null && data.containsKey('addresses')) {
        // Firestore'da adres var → kullan
        final list = data['addresses'] as List? ?? [];
        _addresses = list.map((m) => UserAddress.fromMap(m as Map<String, dynamic>)).toList();
      } else if (_addresses.isNotEmpty) {
        // Migration: SharedPreferences'taki adresleri Firestore'a yaz
        await _persistAddresses();
      }

      if (data != null && data.containsKey('favorites')) {
        // Firestore'da favori var → kullan
        final list = data['favorites'] as List? ?? [];
        _favorites = Set<String>.from(list.map((e) => e.toString()));
      } else if (_favorites.isNotEmpty) {
        // Migration: SharedPreferences'taki favorileri Firestore'a yaz
        await _persistFavorites();
      }

      if (data != null && data.containsKey('balance')) {
        _balance = (data['balance'] as num?)?.toDouble() ?? _balance;
      } else if (_balance != 0.0) {
        await _persistBalance();
      }
    } catch (e) {
      debugPrint('AuthProvider Firestore load error: $e');
    }
  }

  Future<void> _loadUserData(SharedPreferences prefs) async {
    final addrJson = prefs.getString(_addrKey);
    if (addrJson != null) {
      try {
        final list = jsonDecode(addrJson) as List;
        _addresses = list.map((m) => UserAddress.fromMap(m as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    _selectedAddressIdx = prefs.getInt(_selKey) ?? 0;

    final favJson = prefs.getString(_favKey);
    if (favJson != null) {
      try {
        _favorites = Set<String>.from(jsonDecode(favJson) as List);
      } catch (_) {}
    }

    _balance = prefs.getDouble(_balanceKey) ?? 0.0;
  }

  // ── Hata mesajlarını Türkçe'ye çevir ────────────────────────
  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':    return 'Bu e-posta adresi zaten kayıtlı';
      case 'invalid-email':           return 'Geçerli bir e-posta adresi giriniz';
      case 'weak-password':           return 'Şifre en az 6 karakter olmalıdır';
      case 'user-not-found':          return 'Bu e-posta adresi kayıtlı değil';
      case 'wrong-password':          return 'Şifre hatalı';
      case 'invalid-credential':      return 'E-posta veya şifre hatalı';
      case 'too-many-requests':       return 'Çok fazla deneme. Lütfen bekleyiniz';
      case 'user-disabled':           return 'Bu hesap devre dışı bırakılmış';
      case 'network-request-failed':  return 'İnternet bağlantısı yok';
      default:                        return 'Giriş yapılamadı. Tekrar deneyiniz';
    }
  }

  // ── Register ─────────────────────────────────────────────────
  Future<String?> register(String email, String password,
      {String? name, String? phone}) async {
    final e = email.trim().toLowerCase();
    if (e.isEmpty) return 'E-posta adresi giriniz';
    if (name == null || name.trim().isEmpty) return 'Ad Soyad giriniz';
    if (password.length < 6) return 'Şifre en az 6 karakter olmalıdır';

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: e, password: password);
      final fbUser = cred.user!;

      // Display name'i Firebase Auth'a kaydet
      await fbUser.updateDisplayName(name.trim());

      // Telefonu ve ek bilgileri Firestore'a kaydet
      await _firestore.collection('users').doc(fbUser.uid).set({
        'name': name.trim(),
        'phone': phone?.trim() ?? '',
        'email': e,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _user = MockUser(
          uid: fbUser.uid, email: e,
          displayName: name.trim(),
          phone: phone?.trim().isNotEmpty == true ? phone!.trim() : null);
      final prefs = await SharedPreferences.getInstance();
      await _loadUserData(prefs);

      // E-posta doğrulama maili gönder
      try {
        await fbUser.sendEmailVerification();
      } catch (_) {}

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (ex) {
      return _authError(ex.code);
    } catch (ex) {
      return 'Kayıt yapılamadı: $ex';
    }
  }

  // ── Login ─────────────────────────────────────────────────────
  Future<String?> login(String email, String password) async {
    final e = email.trim().toLowerCase();
    if (e.isEmpty) return 'E-posta adresi giriniz';
    if (password.isEmpty) return 'Şifre giriniz';
    if (password.length < 6) return 'Şifre en az 6 karakter olmalıdır';

    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: e, password: password);
      await _loadFromFirebase(cred.user!);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (ex) {
      return _authError(ex.code);
    } catch (ex) {
      return 'Giriş yapılamadı: $ex';
    }
  }

  // ── Update Profile ───────────────────────────────────────────
  Future<void> updateProfile({String? displayName, String? phone}) async {
    if (_user == null) return;
    try {
      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }
      await _firestore.collection('users').doc(_user!.uid).update({
        if (displayName != null) 'name': displayName,
        if (phone != null) 'phone': phone,
      });
    } catch (_) {}
    _user = MockUser(
      uid: _user!.uid,
      email: _user!.email,
      displayName: displayName ?? _user!.displayName,
      phone: phone ?? _user!.phone,
    );
    notifyListeners();
  }

  // ── Google Sign In ────────────────────────────────────────────
  Future<String?> signInWithGoogle() async {
    try {
      final account = await _gSignIn.signIn();
      if (account == null) return null;

      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      final fbUser = cred.user!;

      // Yeni kayıt ise Firestore'a ekle
      if (cred.additionalUserInfo?.isNewUser == true) {
        await _firestore.collection('users').doc(fbUser.uid).set({
          'name': fbUser.displayName ?? '',
          'phone': '',
          'email': fbUser.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await _loadFromFirebase(fbUser);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return 'Google ile giriş yapılamadı. Lütfen tekrar deneyin.';
    }
  }

  // ── Email Verification ───────────────────────────────────────
  Future<String?> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Oturum açık değil';
      await user.sendEmailVerification();
      return null;
    } catch (e) {
      return 'Mail gönderilemedi: $e';
    }
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (_) {}
  }

  // ── Sign Out ─────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    try { await _gSignIn.signOut(); } catch (_) {}
    _user = null;
    _addresses = [];
    _favorites = {};
    _balance = 0.0;
    _selectedAddressIdx = 0;
    notifyListeners();
  }

  // ── Delete Account ───────────────────────────────────────────
  Future<void> deleteAccount() async {
    if (_user == null) return;
    final uid = _user!.uid;

    // 1. SharedPreferences — tüm kullanıcı anahtarlarını temizle
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_addrKey);
    await prefs.remove(_selKey);
    await prefs.remove(_favKey);
    await prefs.remove(_balanceKey);
    await prefs.remove('orders_$uid');
    await prefs.remove('reviews_$uid');
    await prefs.remove('cards_$uid');

    // 2. Firestore — subcollection'ları (orders, reviews) ve ana dokümanı sil
    try {
      final userRef = _firestore.collection('users').doc(uid);

      // orders subcollection
      final ordersSnap = await userRef.collection('orders').get();
      for (final doc in ordersSnap.docs) {
        await doc.reference.delete();
      }

      // reviews subcollection
      final reviewsSnap = await userRef.collection('reviews').get();
      for (final doc in reviewsSnap.docs) {
        await doc.reference.delete();
      }

      // ana kullanıcı dokümanı (kartlar dahil)
      await userRef.delete();

      // 3. Firebase Auth hesabını sil
      await _auth.currentUser?.delete();
    } catch (_) {}

    _user = null;
    _addresses = [];
    _favorites = {};
    _balance = 0.0;
    _selectedAddressIdx = 0;
    notifyListeners();
  }

  // ── Balance ──────────────────────────────────────────────────
  Future<void> addBalance(double amount) async {
    _balance += amount;
    notifyListeners();
    await _persistBalance();
  }

  Future<bool> deductBalance(double amount) async {
    if (_balance < amount) return false;
    _balance -= amount;
    notifyListeners();
    await _persistBalance();
    return true;
  }

  Future<void> _persistBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_balanceKey, _balance);
    } catch (_) {}
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.uid).set(
          {'balance': _balance},
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('AuthProvider Firestore balance write error: $e');
      }
    }
  }

  // ── Addresses ────────────────────────────────────────────────
  Future<void> addAddress(UserAddress addr) async {
    _addresses.add(addr);
    _selectedAddressIdx = _addresses.length - 1;
    await _persistAddresses();
    notifyListeners();
  }

  Future<void> updateAddress(UserAddress addr) async {
    final idx = _addresses.indexWhere((a) => a.id == addr.id);
    if (idx >= 0) {
      _addresses[idx] = addr;
      await _persistAddresses();
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((a) => a.id == id);
    _selectedAddressIdx = 0;
    await _persistAddresses();
    notifyListeners();
  }

  Future<void> selectAddress(int idx) async {
    _selectedAddressIdx = idx.clamp(0, _addresses.isEmpty ? 0 : _addresses.length - 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selKey, _selectedAddressIdx);
    notifyListeners();
  }

  Future<void> _persistAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_addrKey,
          jsonEncode(_addresses.map((a) => a.toMap()).toList()));
    } catch (_) {}
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.uid).set(
          {'addresses': _addresses.map((a) => a.toMap()).toList()},
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('AuthProvider Firestore addresses write error: $e');
      }
    }
  }

  Future<void> _persistFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favKey, jsonEncode(_favorites.toList()));
    } catch (_) {}
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.uid).set(
          {'favorites': _favorites.toList()},
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('AuthProvider Firestore favorites write error: $e');
      }
    }
  }
}
