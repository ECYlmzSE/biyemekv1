import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final connected = context.watch<ConnectivityProvider>().isConnected;
    if (connected) return child;
    return const _NoInternetInApp();
  }
}

// ─────────────────────────────────────────────────────────────
// stitch (4): In-app internet-lost screen
// ─────────────────────────────────────────────────────────────
class _NoInternetInApp extends StatefulWidget {
  const _NoInternetInApp();
  @override
  State<_NoInternetInApp> createState() => _NoInternetInAppState();
}

class _NoInternetInAppState extends State<_NoInternetInApp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;
  late final Animation<double> _bobAnim;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _bobAnim = Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: _bob, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor       = Color(0xFFF9F9F9);
    const onSurface     = Color(0xFF1A1C1C);
    const onSurfaceVar  = Color(0xFF5B403D);
    const errorColor    = Color(0xFFBA1A1A);
    const errorCont     = Color(0xFFFFDAD6);
    const primaryRed    = Color(0xFFAF101A);
    const surfContLow   = Color(0xFFF3F3F3);
    const surfContHigh  = Color(0xFFE2E2E2);
    const primaryFixDim = Color(0xFFFFB3AC);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(children: [
        // Background decorations
        Positioned(
          top: -60, right: -60,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: errorCont.withOpacity(0.3),
            ),
            child: ImageFiltered(
              imageFilter: ColorFilter.mode(
                  Colors.transparent, BlendMode.dst),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned(
          bottom: -60, left: -60,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryFixDim.withOpacity(0.2),
            ),
          ),
        ),
        // Main content
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // wifi_off icon circle
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: errorCont,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: errorColor.withOpacity(0.12),
                            blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Icon(Icons.wifi_off,
                        size: 48, color: errorColor),
                  ),
                  const SizedBox(height: 64),
                  // Text cluster
                  const Text(
                    'Lezzet Bağlantısı Kesildi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: onSurface, height: 1.2, letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lezzet yolculuğuna devam edebilmek için\ninternete bağlı olduğunuzdan emin olun.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15, color: onSurfaceVar,
                      fontWeight: FontWeight.w500, height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Waiting status card with bobbing moped
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: surfContLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: surfContHigh.withOpacity(0.7), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _bobAnim,
                          builder: (_, __) => Transform.translate(
                            offset: Offset(0, _bobAnim.value),
                            child: const Icon(Icons.moped,
                                size: 26, color: primaryRed),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Bağlantı bekleniyor...',
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: onSurfaceVar, letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
