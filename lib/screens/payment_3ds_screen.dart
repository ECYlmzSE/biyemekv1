import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum _Phase { phoneEntry, sending, otpInput, verifying, success }

/// Firebase Phone Auth tabanlı 3D Secure doğrulama ekranı.
/// [initialPhone] hesaba kayıtlı telefon numarası — boşsa kullanıcıdan istenir.
/// Doğrulama başarılıysa [true] döner.
class Payment3DSScreen extends StatefulWidget {
  final String initialPhone;
  final String cardLastFour;

  const Payment3DSScreen({
    super.key,
    this.initialPhone = '',
    this.cardLastFour = '****',
  });

  @override
  State<Payment3DSScreen> createState() => _Payment3DSScreenState();
}

class _Payment3DSScreenState extends State<Payment3DSScreen>
    with TickerProviderStateMixin {
  late _Phase _phase;

  late String _phone;
  final _phoneCtrl = TextEditingController();

  final _otpCtrl  = TextEditingController();
  final _otpFocus = FocusNode();

  // Firebase
  String? _verificationId;
  int?    _resendToken;

  Timer? _timer;
  int  _remaining     = 120;
  int  _resendCooldown = 30;
  bool _canResend     = false;

  String? _error;

  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();
    final raw = widget.initialPhone.trim();
    _phone = raw.isEmpty ? '' : _normalizePhone(raw);
    _phoneCtrl.text = _phone;
    _phase = _phone.isEmpty ? _Phase.phoneEntry : _Phase.sending;

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);

    _otpCtrl.addListener(() => setState(() {}));

    if (_phase == _Phase.sending) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendCode());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _otpFocus.dispose();
    _phoneCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  String get _maskedPhone {
    final digits = _phone
        .replaceFirst('+90', '')
        .replaceFirst(RegExp(r'^0'), '')
        .replaceAll(' ', '');
    if (digits.length < 10) return _phone;
    return '+90 ${digits.substring(0, 3)} *** **${digits.substring(8)}';
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('90') && digits.length == 12) return '+$digits';
    if (digits.startsWith('0') && digits.length == 11) return '+90${digits.substring(1)}';
    if (digits.length == 10) return '+90$digits';
    return '+$digits';
  }

  String get _timerText {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining      = 120;
    _resendCooldown = 30;
    _canResend      = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) _remaining--;
        if (_resendCooldown > 0) {
          _resendCooldown--;
          if (_resendCooldown == 0) _canResend = true;
        }
      });
    });
  }

  Future<void> _sendCode({bool resend = false}) async {
    setState(() { _phase = _Phase.sending; _error = null; });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phone,
      timeout: const Duration(seconds: 120),
      forceResendingToken: resend ? _resendToken : null,
      verificationCompleted: (credential) async {
        await _verify(credential);
      },
      verificationFailed: (e) {
        debugPrint('verifyPhoneNumber failed: ${e.code} | ${e.message}');
        if (!mounted) return;
        // Her hata durumunda telefon giriş ekranına dön (OTP ekranına geçme,
        // verificationId null olduğu için kod doğrulanamaz)
        setState(() {
          _phase = _Phase.phoneEntry;
          _error = _mapFirebaseError(e.code, e.message);
        });
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken    = resendToken;
        if (!mounted) return;
        setState(() { _phase = _Phase.otpInput; _error = null; _otpCtrl.clear(); });
        _startTimer();
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _otpFocus.requestFocus());
      },
      codeAutoRetrievalTimeout: (id) => _verificationId = id,
    );
  }

  String _mapFirebaseError(String code, String? msg) {
    // Error code 39 = Firebase internal error (genellikle geçici)
    final isInternalErr = (msg ?? '').contains('Error code:39') ||
        (msg ?? '').contains('internal error') ||
        code == 'internal-error';
    if (isInternalErr) {
      return 'SMS geçici olarak gönderilemedi. Lütfen birkaç dakika bekleyip tekrar deneyin.';
    }
    return switch (code) {
      'invalid-phone-number'   => 'Telefon numarası geçersiz. Lütfen düzeltin.',
      'too-many-requests'      => 'Çok fazla deneme yapıldı. Lütfen bekleyin.',
      'quota-exceeded'         => 'SMS kotası doldu. Daha sonra deneyin.',
      'network-request-failed' => 'İnternet bağlantısını kontrol edin.',
      'operation-not-allowed'  => 'Telefon doğrulama aktif değil.',
      _                        => 'SMS gönderilemedi. Tekrar deneyin.',
    };
  }

  Future<void> _confirmCode() async {
    final code = _otpCtrl.text.trim();
    if (code.length < 6) {
      setState(() => _error = '6 haneli kodu eksiksiz girin');
      _shakeCtrl.forward(from: 0);
      return;
    }
    if (_verificationId == null) {
      setState(() => _error = 'Oturum sona erdi. Tekrar gönderin.');
      return;
    }
    setState(() { _phase = _Phase.verifying; _error = null; });
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: code,
    );
    await _verify(credential);
  }

  Future<void> _verify(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      _timer?.cancel();
      if (mounted) {
        setState(() => _phase = _Phase.success);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('_verify error: ${e.code}');
      if (e.code == 'credential-already-in-use' ||
          e.code == 'account-exists-with-different-credential' ||
          e.code == 'provider-already-linked' ||
          e.code == 'email-already-in-use') {
        _timer?.cancel();
        if (mounted) {
          setState(() => _phase = _Phase.success);
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) Navigator.pop(context, true);
        }
      } else if (e.code == 'invalid-verification-code') {
        if (mounted) {
          setState(() {
            _phase = _Phase.otpInput;
            _error = 'Hatalı kod. Tekrar deneyin.';
            _otpCtrl.clear();
          });
          _shakeCtrl.forward(from: 0);
          _otpFocus.requestFocus();
        }
      } else if (e.code == 'session-expired') {
        if (mounted) setState(() {
          _phase = _Phase.otpInput;
          _error = 'Kodun süresi doldu. Tekrar gönderin.';
        });
      } else {
        if (mounted) setState(() {
          _phase = _Phase.otpInput;
          _error = e.message ?? 'Doğrulama başarısız (${e.code})';
        });
      }
    }
  }

  static const _blue  = Color(0xFF0D47A1);
  static const _blue2 = Color(0xFF1565C0);
  static const _gold  = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: _gold, borderRadius: BorderRadius.circular(4)),
            child: Text('3D',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Text('Güvenli Ödeme',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        ]),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.lock_rounded, color: Colors.white70, size: 20),
          ),
        ],
      ),
      body: Column(children: [
        _buildCardHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: switch (_phase) {
              _Phase.phoneEntry => _buildPhoneEntryPhase(),
              _Phase.sending    => _buildSendingState(),
              _Phase.success    => _buildSuccessState(),
              _                 => _buildOtpPhase(),
            },
          ),
        ),
        _buildFooter(),
      ]),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [_blue, _blue2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(children: [
        Container(
          width: 44, height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('**** **** **** ${widget.cardLastFour}',
                style: GoogleFonts.spaceMono(
                    color: Colors.white, fontSize: 14, letterSpacing: 1.5)),
            const SizedBox(height: 2),
            const Text('Kredi Kartı Ödemesi',
                style: TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ),
        Row(children: [
          _netBadge('VISA', Colors.blue.shade200),
          const SizedBox(width: 6),
          _netBadge('MC', Colors.orange.shade200),
        ]),
      ]),
    );
  }

  Widget _netBadge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                color: color, fontSize: 10, fontWeight: FontWeight.w800)),
      );

  Widget _buildPhoneEntryPhase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
              color: _blue.withOpacity(0.08), shape: BoxShape.circle),
          child: const Icon(Icons.phone_android_rounded, color: _blue2, size: 34),
        ),
        const SizedBox(height: 20),
        Text('Telefon Numaranızı Girin',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        Text('Ödemeyi doğrulamak için SMS kodu göndereceğiz.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5)),
        const SizedBox(height: 32),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-\(\)]'))
          ],
          decoration: InputDecoration(
            labelText: 'Telefon Numarası',
            hintText: '0545 123 45 67',
            prefixIcon: const Icon(Icons.phone_outlined, color: _blue2),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _blue2, width: 2),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 16),
              const SizedBox(width: 8),
              Flexible(child: Text(_error!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12, height: 1.5))),
            ]),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
                _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length >= 10
                    ? () {
                        setState(() {
                          _phone = _normalizePhone(_phoneCtrl.text);
                          _error = null;
                        });
                        _sendCode();
                      }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue2,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.send_rounded, size: 18),
              const SizedBox(width: 8),
              Text('SMS Kodu Gönder',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSendingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: _blue2, strokeWidth: 3),
        const SizedBox(height: 24),
        Text('SMS Kodu Gönderiliyor…',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        Text(_maskedPhone,
            style: GoogleFonts.spaceMono(
                color: _blue2, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('numarasına doğrulama kodu gönderiliyor.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
          child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 48),
        ),
        const SizedBox(height: 20),
        Text('Doğrulama Başarılı!',
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.green.shade700)),
        const SizedBox(height: 8),
        Text('Ödemeniz işleniyor…',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
      ],
    );
  }

  Widget _buildOtpPhase() {
    final verifying = _phase == _Phase.verifying;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
          child: Icon(Icons.mark_email_read_rounded,
              color: Colors.green.shade600, size: 30),
        ),
        const SizedBox(height: 14),
        Text('SMS Kodu Gönderildi',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
            children: [
              const TextSpan(text: 'Numarasına gönderilen\n'),
              TextSpan(
                text: _maskedPhone,
                style: GoogleFonts.spaceMono(
                    color: _blue2, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const TextSpan(text: '\n6 haneli kodu girin.'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: _shakeAnim,
          builder: (_, child) =>
              Transform.translate(offset: Offset(_shakeAnim.value, 0), child: child),
          child: _buildOtpBoxes(verifying),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 14),
            const SizedBox(width: 6),
            Flexible(child: Text(_error!,
                style: TextStyle(color: Colors.red.shade600, fontSize: 12))),
          ]),
        ],
        const SizedBox(height: 24),
        if (_remaining > 0)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.timer_outlined, size: 15, color: Colors.grey.shade500),
            const SizedBox(width: 5),
            Text('Kodun geçerliliği: ',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            Text(_timerText,
                style: GoogleFonts.spaceMono(
                    color: _remaining < 30 ? Colors.red : _blue2,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ])
        else
          Text('Kodun süresi doldu.',
              style: TextStyle(color: Colors.red.shade400, fontSize: 12)),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (verifying || _remaining == 0) ? null : _confirmCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue2,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: verifying
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.verified_user_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('Kodu Doğrula',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ]),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _canResend ? () => _sendCode(resend: true) : null,
          child: Text(
            _canResend ? '↺  Kodu tekrar gönder' : 'Tekrar gönder ($_resendCooldown s)',
            style: TextStyle(
              color: _canResend ? _blue2 : Colors.grey.shade400,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBoxes(bool disabled) {
    final digits = _otpCtrl.text;
    return Stack(alignment: Alignment.center, children: [
      Opacity(
        opacity: 0,
        child: SizedBox(
          width: 1, height: 1,
          child: TextField(
            controller: _otpCtrl,
            focusNode: _otpFocus,
            enabled: !disabled,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(counterText: ''),
          ),
        ),
      ),
      GestureDetector(
        onTap: disabled ? null : () => _otpFocus.requestFocus(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final digit  = i < digits.length ? digits[i] : '';
            final active = _otpFocus.hasFocus && i == digits.length;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 42, height: 52,
              decoration: BoxDecoration(
                color: digit.isNotEmpty
                    ? _blue.withOpacity(0.06)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active
                      ? _blue2
                      : digit.isNotEmpty
                          ? _blue2.withOpacity(0.4)
                          : Colors.grey.shade300,
                  width: active ? 2 : 1.5,
                ),
                boxShadow: active
                    ? [BoxShadow(color: _blue2.withOpacity(0.15), blurRadius: 6)]
                    : null,
              ),
              alignment: Alignment.center,
              child: digit.isNotEmpty
                  ? Text(digit,
                      style: GoogleFonts.spaceMono(
                          fontSize: 22, fontWeight: FontWeight.w700, color: _blue))
                  : active
                      ? Container(width: 2, height: 22, color: _blue2)
                      : null,
            );
          }),
        ),
      ),
    ]);
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.lock_outlined, size: 13, color: Colors.grey.shade400),
        const SizedBox(width: 5),
        Text('SSL ile şifrelenmiş güvenli bağlantı',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        const SizedBox(width: 12),
        Text('VISA',
            style: GoogleFonts.inter(
                color: Colors.blue.shade400, fontWeight: FontWeight.w900, fontSize: 11)),
        const SizedBox(width: 8),
        Text('MC',
            style: GoogleFonts.inter(
                color: Colors.orange.shade400, fontWeight: FontWeight.w900, fontSize: 11)),
        const SizedBox(width: 8),
        Text('TROY',
            style: GoogleFonts.inter(
                color: Colors.red.shade400, fontWeight: FontWeight.w900, fontSize: 11)),
      ]),
    );
  }
}
