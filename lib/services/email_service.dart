import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// EmailJS REST API ile mail gönderir.
/// https://www.emailjs.com — ücretsiz 200 mail/ay
///
/// Kurulum:
/// 1. emailjs.com'da ücretsiz hesap aç
/// 2. Email Service ekle (Gmail, Outlook vb.)
/// 3. İki template oluştur (sipariş onayı + teslim bilgisi)
/// 4. Aşağıdaki sabitleri doldur
class EmailService {
  // ── Buraya kendi EmailJS bilgilerini gir ──────────────────────
  static const _publicKey   = 'pM2gUZGExkXiVNIk_';
  static const _serviceId   = 'service_oeftn79';
  static const _orderTemplateId      = 'template_7kckv4i';
  static const _deliveryTemplateId   = 'template_hvar76p';
  // ─────────────────────────────────────────────────────────────

  static const _apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  static bool get isConfigured =>
      _publicKey.isNotEmpty &&
      _serviceId.isNotEmpty &&
      _orderTemplateId.isNotEmpty &&
      _deliveryTemplateId.isNotEmpty;

  /// Sipariş onay maili gönder
  static Future<void> sendOrderConfirmation({
    required String toEmail,
    required String toName,
    required String orderId,
    required String restaurantName,
    required List<String> itemNames,
    required double total,
    required String deliveryAddress,
    required String estimatedTime,
  }) async {
    if (!isConfigured) {
      debugPrint('EmailService: not configured, skipping order confirmation email');
      return;
    }
    try {
      await _send(
        templateId: _orderTemplateId,
        params: {
          'to_email'        : toEmail,
          'to_name'         : toName,
          'order_id'        : orderId,
          'restaurant_name' : restaurantName,
          'items_list'      : itemNames.join(', '),
          'total_amount'    : '₺${total.toStringAsFixed(2)}',
          'delivery_address': deliveryAddress,
          'estimated_time'  : estimatedTime,
        },
      );
      debugPrint('EmailService: order confirmation sent to $toEmail');
    } catch (e) {
      debugPrint('EmailService: order confirmation failed: $e');
    }
  }

  /// Teslim edildi maili gönder
  static Future<void> sendDeliveryNotification({
    required String toEmail,
    required String toName,
    required String orderId,
    required String restaurantName,
    required double total,
  }) async {
    if (!isConfigured) {
      debugPrint('EmailService: not configured, skipping delivery email');
      return;
    }
    try {
      await _send(
        templateId: _deliveryTemplateId,
        params: {
          'to_email'        : toEmail,
          'to_name'         : toName,
          'order_id'        : orderId,
          'restaurant_name' : restaurantName,
          'total_amount'    : '₺${total.toStringAsFixed(2)}',
          'order_status'    : 'Teslim Edildi',
          'status_message'  : 'Siparişiniz teslim edildi. Afiyet olsun! 🎉',
        },
      );
      debugPrint('EmailService: delivery notification sent to $toEmail');
    } catch (e) {
      debugPrint('EmailService: delivery notification failed: $e');
    }
  }

  static Future<void> _send({
    required String templateId,
    required Map<String, String> params,
  }) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'origin': 'http://localhost',
      },
      body: jsonEncode({
        'service_id'     : _serviceId,
        'template_id'    : templateId,
        'user_id'        : _publicKey,
        'template_params': params,
      }),
    );
    debugPrint('EmailJS response: ${response.statusCode} — ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('EmailJS error ${response.statusCode}: ${response.body}');
    }
  }
}
