import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _kKey = 'welcome_shown_v1';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_kKey) ?? false);
  }

  static Future<void> _markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kKey, true);
  }

  void _goToAuth(BuildContext context) {
    _markShown();
    // push (replace değil) — geri tuşu welcome ekranına döner
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _continueAsGuest(BuildContext context) {
    _markShown();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return PopScope(
      canPop: false, // geri tuşunu/gesture'ı devre dışı bırak
      child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Arka plan fotoğrafı ──────────────────────────────────
          CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF1A1A1A)),
            errorWidget: (_, __, ___) =>
                Container(color: const Color(0xFF1A1A1A)),
          ),
          // ── Karartma gradyanı ────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0xBB000000),
                  Color(0xEE000000),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          // ── İçerik ──────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  // Başlık
                  _headline('ACIKTIN'),
                  _headline('MI?'),
                  Text(
                    "Bİ'YEMEK",
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 58,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -1.5,
                    ),
                  ),
                  _headline('SÖYLE'),
                  const SizedBox(height: 22),
                  // Alt yazı
                  const Text(
                    'Şehrinizin en özel lezzetleri tek tıkla\nkapınıza gelsin.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 44),
                  // Giriş butonu
                  _PrimaryButton(
                    label: 'Giriş Yap / Kayıt Ol',
                    onTap: () => _goToAuth(context),
                  ),
                  const SizedBox(height: 12),
                  // Üye olmadan devam
                  _SecondaryButton(
                    label: 'Üye Olmadan Devam Et',
                    onTap: () => _continueAsGuest(context),
                  ),
                  const SizedBox(height: 24),
                  // Alt bilgi
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.security_outlined,
                            color: Colors.white38, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'GÜVENLİ ÖDEME & HIZLI TESLİMAT',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    ), // Scaffold
    ); // PopScope
  }

  Widget _headline(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 58,
          fontWeight: FontWeight.w900,
          height: 1.0,
          letterSpacing: -1.5,
        ),
      );
}

// ── Giriş butonu ────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Üye olmadan devam butonu ─────────────────────────────────────
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
