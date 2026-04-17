// Kalıcı kullanıcı hesapları veritabanı.
// SharedPreferences'ın aksine bu dosya Documents klasöründe saklanır —
// Android yedekleme (Google One Backup) ile korunur.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class UserDatabase {
  static const _fileName = 'biyemek_accounts.json';

  // ── Dosya yolu ─────────────────────────────────────────────────
  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // ── Tüm hesapları oku ──────────────────────────────────────────
  static Future<Map<String, dynamic>> readAll() async {
    try {
      final f = await _file();
      if (!await f.exists()) return {};
      final raw = await f.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {};
    } catch (e) {
      debugPrint('UserDatabase.readAll error: $e');
      return {};
    }
  }

  // ── Hesap kaydet / güncelle ────────────────────────────────────
  static Future<void> saveAccount(String email, Map<String, dynamic> data) async {
    try {
      final db = await readAll();
      db[email.trim().toLowerCase()] = {
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _write(db);
    } catch (e) {
      debugPrint('UserDatabase.saveAccount error: $e');
    }
  }

  // ── Hesap sorgula ──────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getAccount(String email) async {
    final db = await readAll();
    return db[email.trim().toLowerCase()] as Map<String, dynamic>?;
  }

  // ── Hesabın kişisel verisini sil, kimlik bilgisi kalır ──────────
  // Kullanıcı hesabını silerken şifre ve uid korunur;
  // sadece kişisel veri temizlenir. Bu şekilde tekrar giriş yapılabilir.
  static Future<void> clearPersonalData(String email) async {
    try {
      final db = await readAll();
      final key = email.trim().toLowerCase();
      if (!db.containsKey(key)) return;
      final entry = Map<String, dynamic>.from(db[key] as Map);
      // Sadece kimlik bilgisini tut
      db[key] = {
        'uid'      : entry['uid'],
        'password' : entry['password'],
        'name'     : entry['name'],
        'phone'    : entry['phone'] ?? '',
        'updatedAt': DateTime.now().toIso8601String(),
        'deletedAt': DateTime.now().toIso8601String(), // işaretleme
      };
      await _write(db);
    } catch (e) {
      debugPrint('UserDatabase.clearPersonalData error: $e');
    }
  }

  // ── Kullanıcı verisini güncelle (adres, sipariş notları vb.) ────
  static Future<void> updateUserData(
      String email, Map<String, dynamic> extra) async {
    try {
      final db = await readAll();
      final key = email.trim().toLowerCase();
      if (!db.containsKey(key)) return;
      final entry = Map<String, dynamic>.from(db[key] as Map);
      entry.addAll(extra);
      entry['updatedAt'] = DateTime.now().toIso8601String();
      db[key] = entry;
      await _write(db);
    } catch (e) {
      debugPrint('UserDatabase.updateUserData error: $e');
    }
  }

  static Future<void> _write(Map<String, dynamic> db) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(db), flush: true);
  }
}
