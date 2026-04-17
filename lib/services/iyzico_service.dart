import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// ─── Sonuç sınıfları ──────────────────────────────────────────────────────────

class IyzicoPaymentResult {
  final bool success;
  final String? paymentId;
  final String? errorMessage;
  const IyzicoPaymentResult({
    required this.success,
    this.paymentId,
    this.errorMessage,
  });
}

class IyzicoInit3DSResult {
  final bool success;
  final String? htmlContent;
  final String? conversationId;
  final String? errorMessage;
  const IyzicoInit3DSResult({
    required this.success,
    this.htmlContent,
    this.conversationId,
    this.errorMessage,
  });
}

// ─── Servis ───────────────────────────────────────────────────────────────────

class IyzicoService {
  static const _apiKey    = 'sandbox-BC8ZLPcHehhyBxnVS2gOxwdpgR0cl7kq';
  static const _secretKey = 'tE46L79NBWgbvtbqvvO6WlyvdXgekjlB';
  static const _baseUrl   = 'https://sandbox-api.iyzipay.com';

  /// 3D Secure callback URL — WebView bu URL'e navigate etmeye çalışınca yakalanır.
  static const callbackUrl = 'https://biyemek.app/payment/callback';

  // ── İmza ────────────────────────────────────────────────────────────────────

  static String _authHeader(String randomKey, List<int> bodyBytes, String endpoint) {
    final keyBytes  = utf8.encode(_secretKey);
    final dataBytes = <int>[
      ...utf8.encode(randomKey),
      ...utf8.encode(endpoint),
      ...bodyBytes,
    ];
    final hmac      = Hmac(sha256, keyBytes);
    final signature = hmac.convert(dataBytes).toString();
    final params    = 'apiKey:$_apiKey&randomKey:$randomKey&signature:$signature';
    return 'IYZWSv2 ${base64Encode(utf8.encode(params))}';
  }

  // ── Türkçe → ASCII ──────────────────────────────────────────────────────────

  static String _ascii(String s) => s
      .replaceAll('ı', 'i').replaceAll('İ', 'I')
      .replaceAll('ğ', 'g').replaceAll('Ğ', 'G')
      .replaceAll('ü', 'u').replaceAll('Ü', 'U')
      .replaceAll('ş', 's').replaceAll('Ş', 'S')
      .replaceAll('ö', 'o').replaceAll('Ö', 'O')
      .replaceAll('ç', 'c').replaceAll('Ç', 'C');

  // ── Ortak istek gövdesi ──────────────────────────────────────────────────────

  static Map<String, dynamic> _buildBody({
    required String conversationId,
    required String priceStr,
    required String safeHolder,
    required String cardNumber,
    required String expireMonth,
    required String expireYear,
    required String cvc,
    required String safeName,
    required String safeSur,
    required String safeEmail,
    required String buyerPhone,
    required String safeAddr,
  }) {
    return {
      'locale'        : 'tr',
      'conversationId': conversationId,
      'price'         : priceStr,
      'paidPrice'     : priceStr,
      'currency'      : 'TRY',
      'installment'   : 1,
      'basketId'      : 'BYM$conversationId',
      'paymentChannel': 'MOBILE',
      'paymentGroup'  : 'PRODUCT',
      'paymentCard': {
        'cardHolderName': safeHolder,
        'cardNumber'    : cardNumber.replaceAll(' ', ''),
        'expireMonth'   : expireMonth,
        'expireYear'    : expireYear,
        'cvc'           : cvc,
        'registerCard'  : 0,
      },
      'buyer': {
        'id'                  : 'BYM_USER',
        'name'                : safeName,
        'surname'             : safeSur,
        'gsmNumber'           : buyerPhone,
        'email'               : safeEmail,
        'identityNumber'      : '74300864791',
        'lastLoginDate'       : '2025-01-01 12:00:00',
        'registrationDate'    : '2025-01-01 12:00:00',
        'registrationAddress' : safeAddr,
        'ip'                  : '85.104.7.1',
        'city'                : 'Istanbul',
        'country'             : 'Turkey',
        'zipCode'             : '34000',
      },
      'shippingAddress': {
        'contactName': '$safeName $safeSur',
        'city'       : 'Istanbul',
        'country'    : 'Turkey',
        'address'    : safeAddr,
        'zipCode'    : '34000',
      },
      'billingAddress': {
        'contactName': '$safeName $safeSur',
        'city'       : 'Istanbul',
        'country'    : 'Turkey',
        'address'    : safeAddr,
        'zipCode'    : '34000',
      },
      'basketItems': [
        {
          'id'       : 'ITEM_$conversationId',
          'name'     : 'Yemek Siparisi',
          'category1': 'Yemek',
          'itemType' : 'VIRTUAL',
          'price'    : priceStr,
        }
      ],
    };
  }

  // ── HTTP yardımcısı ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> bodyMap) async {
    final randomKey  = const Uuid().v4().replaceAll('-', '');
    final body       = jsonEncode(bodyMap);
    final bodyBytes  = utf8.encode(body);
    final authHdr    = _authHeader(randomKey, bodyBytes, endpoint);

    debugPrint('İyzico POST $endpoint');
    debugPrint('İyzico auth: $authHdr');
    debugPrint('İyzico body: $body');

    final client = HttpClient();
    try {
      final req = await client
          .postUrl(Uri.parse('$_baseUrl$endpoint'))
          .timeout(const Duration(seconds: 30));

      req.headers.set('Content-Type',          'application/json');
      req.headers.set('Accept',                'application/json');
      req.headers.set('Authorization',         authHdr);
      req.headers.set('x-iyzi-rnd',            randomKey);
      req.headers.set('x-iyzi-client-version', 'iyzipay-dart-2.0.0');
      req.contentLength = bodyBytes.length;
      req.add(bodyBytes);

      final resp    = await req.close().timeout(const Duration(seconds: 30));
      final respStr = await resp.transform(utf8.decoder).join();
      debugPrint('İyzico HTTP ${resp.statusCode}: $respStr');
      return jsonDecode(respStr) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  // ── 3DS Başlat ───────────────────────────────────────────────────────────────

  /// Adım 1: /payment/3dsecure/initialize → HTML içeriği döner.
  /// Bu HTML WebView içinde yüklenir, kullanıcı OTP girer (sandbox: 123456).
  static Future<IyzicoInit3DSResult> initialize3DS({
    required String cardHolderName,
    required String cardNumber,
    required String expireMonth,
    required String expireYear,
    required String cvc,
    required double price,
    required String buyerName,
    required String buyerSurname,
    required String buyerEmail,
    required String buyerPhone,
    required String deliveryAddress,
  }) async {
    try {
      final conversationId = DateTime.now().millisecondsSinceEpoch.toString();
      final priceStr       = price.toStringAsFixed(2);
      final safeAddr       = _ascii(deliveryAddress);
      final safeName       = _ascii(buyerName);
      final safeSur        = _ascii(buyerSurname);
      final safeHolder     = _ascii(cardHolderName);
      final safeEmail      = buyerEmail.isNotEmpty ? buyerEmail : 'musteri@biyemek.com';

      final body = _buildBody(
        conversationId: conversationId,
        priceStr: priceStr,
        safeHolder: safeHolder,
        cardNumber: cardNumber,
        expireMonth: expireMonth,
        expireYear: expireYear,
        cvc: cvc,
        safeName: safeName,
        safeSur: safeSur,
        safeEmail: safeEmail,
        buyerPhone: buyerPhone,
        safeAddr: safeAddr,
      );
      body['callbackUrl'] = callbackUrl;

      final result = await _post('/payment/3dsecure/initialize', body);

      if (result['status'] == 'success') {
        // İyzico HTML içeriğini base64 veya düz metin olarak döner
        String html = result['threeDSHtmlContent']?.toString() ?? '';
        // Eğer base64 ise decode et
        if (html.isNotEmpty && !html.trimLeft().startsWith('<')) {
          try {
            html = utf8.decode(base64Decode(html));
          } catch (_) {}
        }
        return IyzicoInit3DSResult(
          success       : true,
          htmlContent   : html,
          conversationId: conversationId,
        );
      } else {
        final code = result['errorCode'] != null ? ' (${result['errorCode']})' : '';
        return IyzicoInit3DSResult(
          success     : false,
          errorMessage: '${result['errorMessage'] ?? '3DS başlatılamadı'}$code',
        );
      }
    } catch (e, st) {
      debugPrint('initialize3DS exception: $e\n$st');
      return IyzicoInit3DSResult(
        success     : false,
        errorMessage: 'Bağlantı hatası: $e',
      );
    }
  }

  // ── 3DS Tamamla ──────────────────────────────────────────────────────────────

  /// Adım 2: OTP doğrulama sonrası callback'ten gelen paymentId ile ödemeyi tamamla.
  static Future<IyzicoPaymentResult> auth3DS({
    required String paymentId,
    required String conversationId,
  }) async {
    try {
      final body = {
        'locale'        : 'tr',
        'conversationId': conversationId,
        'paymentId'     : paymentId,
      };

      final result = await _post('/payment/3dsecure/auth', body);

      if (result['status'] == 'success') {
        return IyzicoPaymentResult(
          success  : true,
          paymentId: result['paymentId']?.toString(),
        );
      } else {
        final code = result['errorCode'] != null ? ' (${result['errorCode']})' : '';
        return IyzicoPaymentResult(
          success     : false,
          errorMessage: '${result['errorMessage'] ?? 'Ödeme tamamlanamadı'}$code',
        );
      }
    } catch (e, st) {
      debugPrint('auth3DS exception: $e\n$st');
      return IyzicoPaymentResult(
        success     : false,
        errorMessage: 'Bağlantı hatası: $e',
      );
    }
  }

  // ── Direkt ödeme (3DS yok — fallback) ────────────────────────────────────────

  static Future<IyzicoPaymentResult> createPayment({
    required String cardHolderName,
    required String cardNumber,
    required String expireMonth,
    required String expireYear,
    required String cvc,
    required double price,
    required String buyerName,
    required String buyerSurname,
    required String buyerEmail,
    required String buyerPhone,
    required String deliveryAddress,
  }) async {
    try {
      final conversationId = DateTime.now().millisecondsSinceEpoch.toString();
      final priceStr       = price.toStringAsFixed(2);
      final safeAddr       = _ascii(deliveryAddress);
      final safeName       = _ascii(buyerName);
      final safeSur        = _ascii(buyerSurname);
      final safeHolder     = _ascii(cardHolderName);
      final safeEmail      = buyerEmail.isNotEmpty ? buyerEmail : 'musteri@biyemek.com';

      final body = _buildBody(
        conversationId: conversationId,
        priceStr: priceStr,
        safeHolder: safeHolder,
        cardNumber: cardNumber,
        expireMonth: expireMonth,
        expireYear: expireYear,
        cvc: cvc,
        safeName: safeName,
        safeSur: safeSur,
        safeEmail: safeEmail,
        buyerPhone: buyerPhone,
        safeAddr: safeAddr,
      );

      final result = await _post('/payment/auth', body);

      if (result['status'] == 'success') {
        return IyzicoPaymentResult(
          success  : true,
          paymentId: result['paymentId']?.toString(),
        );
      } else {
        final code = result['errorCode'] != null ? ' (${result['errorCode']})' : '';
        return IyzicoPaymentResult(
          success     : false,
          errorMessage: '${result['errorMessage'] ?? 'Ödeme başarısız'}$code',
        );
      }
    } catch (e, st) {
      debugPrint('İyzico exception: $e\n$st');
      return IyzicoPaymentResult(
        success     : false,
        errorMessage: 'Bağlantı hatası: $e',
      );
    }
  }
}
