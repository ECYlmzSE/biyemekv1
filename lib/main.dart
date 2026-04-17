import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/card_provider.dart';
import 'providers/location_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';
import 'widgets/in_app_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  // Allow all orientations (tablet support)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide the system navigation bar (tablet/phone bottom bar) but keep status bar.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const BiYemekApp());
}

class BiYemekApp extends StatefulWidget {
  const BiYemekApp({super.key});
  @override
  State<BiYemekApp> createState() => _BiYemekAppState();
}

class _BiYemekAppState extends State<BiYemekApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-hide the system navigation bar every time the app comes to foreground.
  /// Android restores it on certain events (keyboard, dialogs, etc.).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()..load()),
        ChangeNotifierProxyProvider<AuthProvider, CardProvider>(
          create: (_) => CardProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? CardProvider();
            final uid = auth.currentUser?.uid ?? 'guest';
            provider.switchUser(uid);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()..initialize()),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? OrderProvider();
            final uid = auth.currentUser?.uid ?? 'guest';
            provider.switchUser(uid);
            return provider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, tp, __) => MaterialApp(
          title: "Bi'Yemek",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: tp.themeMode,
          home: const InAppNotificationWrapper(child: SplashScreen()),
        ),
      ),
    );
  }
}
