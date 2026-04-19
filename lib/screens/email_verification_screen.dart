import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _sending = false;
  bool _verified = false;
  int _resendCooldown = 60;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startCooldown();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await context.read<AuthProvider>().reloadUser();
      if (context.read<AuthProvider>().isEmailVerified) {
        _timer?.cancel();
        setState(() => _verified = true);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        }
      }
    });
  }

  void _startCooldown() {
    _resendCooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        _cooldownTimer?.cancel();
      }
    });
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    setState(() => _sending = true);
    final err = await context.read<AuthProvider>().sendVerificationEmail();
    setState(() => _sending = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? 'Doğrulama maili tekrar gönderildi'),
      backgroundColor: err != null ? AppTheme.red : AppTheme.primaryGreen,
    ));
    if (err == null) _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _verified ? Icons.check_circle : Icons.mark_email_unread_outlined,
                  size: 64,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _verified ? 'E-posta Doğrulandı!' : 'E-postanı Doğrula',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _verified
                    ? 'Hesabın başarıyla oluşturuldu, yönlendiriliyorsun...'
                    : '${widget.email} adresine doğrulama linki gönderdik.\nLinke tıkladıktan sonra otomatik olarak giriş yapılacak.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.grey, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 40),
              if (!_verified) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _resendCooldown > 0 || _sending ? null : _resend,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send),
                    label: Text(_resendCooldown > 0
                        ? 'Tekrar Gönder (${_resendCooldown}s)'
                        : 'Tekrar Gönder'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<AuthProvider>().signOut().then((_) {
                    if (mounted) Navigator.of(context).pop();
                  }),
                  child: const Text('Farklı hesapla giriş yap',
                      style: TextStyle(color: AppTheme.grey)),
                ),
              ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
