import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../providers/order_provider.dart';
import '../providers/restaurant_provider.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textCtrl;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  bool _noInternet = false;

  @override
  void initState() {
    super.initState();

    // Text fade+slide in after a short delay
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    // Show text after animation starts
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textCtrl.forward();
    });

    // Run internet check + min splash delay in parallel
    Future.wait([
      Future.delayed(const Duration(milliseconds: 2400)),
      _checkAndPreload(),
    ]).then((_) {
      if (mounted && !_noInternet) _navigate();
    });
  }

  Future<void> _checkAndPreload() async {
    final online = await _hasInternet();
    if (!mounted) return;
    if (!online) {
      setState(() => _noInternet = true);
      return;
    }
    // Kick off restaurant preload so HomeScreen shows data faster.
    _preloadRestaurants();
  }

  Future<void> _preloadRestaurants() async {
    if (!mounted) return;
    try {
      final auth = context.read<AuthProvider>();
      final rp = context.read<RestaurantProvider>();
      if (rp.hasRealData || rp.isLoadingReal) return;
      final addr = auth.selectedAddress;
      if (addr != null && addr.lat != null && addr.lng != null &&
          addr.lat! != 0.0 && addr.lng! != 0.0) {
        unawaited(rp.loadRealRestaurants(addr.lat!, addr.lng!));
      } else if (addr != null && addr.city.isNotEmpty) {
        final coords = DataService.getCityCoordinates(addr.city);
        unawaited(rp.loadRealRestaurants(coords.lat, coords.lng));
      }
    } catch (_) {}
  }

  /// Returns true if there is actual internet (not just a network interface).
  Future<bool> _hasInternet() async {
    try {
      // Use Google's generate_204 endpoint — returns HTTP 204 instantly.
      final resp = await http
          .head(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 5));
      return resp.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  Future<void> _navigate() async {
    if (!mounted || _noInternet) return;

    final auth = context.read<AuthProvider>();
    final rp = context.read<RestaurantProvider>();
    final uid = auth.isLoggedIn ? auth.currentUser!.uid : 'guest';
    await context.read<OrderProvider>().initialize(uid: uid);
    if (auth.isLoggedIn) {
      await context.read<CardProvider>().initialize(uid);
    }
    if (!mounted) return;
    final city = auth.selectedAddress?.city;
    if (city != null && city.isNotEmpty) rp.syncCity(city);
    if (!mounted) return;

    // İlk kurulumda karşılama ekranını göster
    final showWelcome = await WelcomeScreen.shouldShow();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            showWelcome ? const WelcomeScreen() : const HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_noInternet) {
      return _NoInternetSplash(
        onRetry: () async {
          // Check internet FIRST — only proceed if we're actually online.
          final online = await _hasInternet();
          if (!mounted) return;
          if (!online) return; // still offline → button resets, no flash
          setState(() => _noInternet = false);
          unawaited(_preloadRestaurants());
          await _navigate();
        },
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Lottie animasyonu (beyaz kart içinde) ───────────
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Lottie.asset(
                  'assets/lottie/splash_animation.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  repeat: true,
                  errorBuilder: (_, err, __) {
                    debugPrint('Lottie error: $err');
                    return const Icon(Icons.fastfood, size: 80, color: AppTheme.primaryGreen);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Uygulama adı + slogan ────────────────────────────
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    "Bİ'YEMEK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lezzet ayağınıza geliyor ...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// stitch (2): Splash → no-internet screen
// ─────────────────────────────────────────────────────────────
class _NoInternetSplash extends StatefulWidget {
  final Future<void> Function() onRetry;
  const _NoInternetSplash({required this.onRetry});
  @override
  State<_NoInternetSplash> createState() => _NoInternetSplashState();
}

class _NoInternetSplashState extends State<_NoInternetSplash> {
  bool _checking = false;

  @override
  Widget build(BuildContext context) {
    const primaryRed  = Color(0xFFD32F2F);
    const darkRed     = Color(0xFFB71C1C);
    const bgColor     = Color(0xFFF9F9F9);
    const onSurface   = Color(0xFF1A1C1C);
    const secondary   = Color(0xFF5F5E5E);
    const surfHigh    = Color(0xFFE2E2E2);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(children: [
        // Background blur decorations
        Positioned(
          top: -60, right: -60,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryRed.withOpacity(0.05),
            ),
            child: BackdropFilter(
              filter: ColorFilter.matrix(const <double>[1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0]),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned(
          bottom: 120, left: -60,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryRed.withOpacity(0.04),
            ),
          ),
        ),
        // Main content
        SafeArea(
          child: Column(children: [
            const Spacer(),
            // Illustration card
            Center(
              child: SizedBox(
                width: 240, height: 240,
                child: Stack(alignment: Alignment.center, children: [
                  // Blurred background ring
                  Container(
                    width: 220, height: 220,
                    decoration: BoxDecoration(
                      color: primaryRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(48),
                    ),
                  ),
                  // Frosted glass layer
                  Container(
                    width: 210, height: 210,
                    decoration: BoxDecoration(
                      color: surfHigh.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  // Icon group
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Stack(clipBehavior: Clip.none, children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 110, color: primaryRed),
                      Positioned(
                        bottom: 8, right: -10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: surfHigh, width: 3),
                          ),
                          child: const Icon(Icons.wifi_off,
                              size: 28, color: primaryRed),
                        ),
                      ),
                    ]),
                  ]),
                  // "BAĞLANTI YOK" badge
                  Positioned(
                    top: 16, right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryRed,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [BoxShadow(color: primaryRed.withOpacity(0.3), blurRadius: 8)],
                      ),
                      child: const Text('BAĞLANTI YOK',
                        style: TextStyle(color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 36),
            // Text cluster
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(children: [
                const Text(
                  'Lezzete Ulaşılamıyor',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
                      color: onSurface, height: 1.2, letterSpacing: -0.5),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Sipariş verebilmek ve restoranları\ngörüntülemek için lütfen internet\nbağlantınızı kontrol edin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: secondary,
                      fontWeight: FontWeight.w500, height: 1.6),
                ),
              ]),
            ),
            const Spacer(),
            // CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryRed, darkRed],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(
                      color: primaryRed.withOpacity(0.3),
                      blurRadius: 16, offset: const Offset(0, 6),
                    )],
                  ),
                  child: TextButton(
                    onPressed: _checking ? null : () async {
                      setState(() => _checking = true);
                      await widget.onRetry();
                      if (mounted) setState(() => _checking = false);
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    child: _checking
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Tekrar Dene',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
