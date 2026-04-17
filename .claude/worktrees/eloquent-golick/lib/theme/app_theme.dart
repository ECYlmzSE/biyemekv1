import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Light palette ───────────────────────────────────────────
  static const Color primaryGreen = Color(0xFFE53935); // Kırmızı tema
  static const Color black        = Color(0xFF1A1A1A);
  static const Color grey         = Color(0xFF8A8A8A);
  static const Color lightGrey    = Color(0xFFF5F5F5);
  static const Color orange       = Color(0xFFFF6B35);
  static const Color red          = Color(0xFFE53E3E);
  static const Color cardShadow   = Color(0x0D000000);

  // ── Dark palette — slightly lighter for readability ─────────
  static const Color darkBg       = Color(0xFF121212); // slightly lighter than pure black
  static const Color darkCard     = Color(0xFF1E1E1E); // visible separation from bg
  static const Color darkSurface  = Color(0xFF2A2A2A); // inputs, chips
  static const Color darkElevated = Color(0xFF333333); // elevated cards, bottom sheets
  static const Color darkDivider  = Color(0xFF323232);
  static const Color darkText     = Color(0xFFF0F0F0); // near-white, not pure white
  static const Color darkSubtext  = Color(0xFFAAAAAA); // readable secondary text
  static const Color darkHint     = Color(0xFF707070); // placeholder text

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen, brightness: Brightness.light),
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFEEEEEE),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, elevation: 0, scrolledUnderElevation: 0,
      foregroundColor: black, centerTitle: false,
      titleTextStyle: TextStyle(color: black, fontWeight: FontWeight.bold, fontSize: 17),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white, selectedItemColor: primaryGreen, unselectedItemColor: grey,
    ),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen, foregroundColor: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: lightGrey,
      labelStyle: const TextStyle(color: grey),
      hintStyle: const TextStyle(color: grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 1.5)),
    ),
    chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
  );

  static ThemeData get darkTheme {
    final base = ThemeData(brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen, brightness: Brightness.dark,
        surface: darkCard,
        primary: primaryGreen, onPrimary: Colors.white,
      ).copyWith(
        surface: darkCard,
        onSurface: darkText,
        background: darkBg,
        onBackground: darkText,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: darkText, displayColor: darkText,
      ),
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      dividerColor: darkDivider,
      canvasColor: darkElevated,
      dialogBackgroundColor: darkElevated,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkElevated, modalBackgroundColor: darkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard, elevation: 0, scrolledUnderElevation: 0,
        foregroundColor: darkText, centerTitle: false,
        titleTextStyle: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 17),
        iconTheme: IconThemeData(color: darkText),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCard, selectedItemColor: primaryGreen, unselectedItemColor: darkSubtext,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        indicatorColor: primaryGreen.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, color: darkSubtext)),
        iconTheme: MaterialStateProperty.resolveWith((s) =>
          IconThemeData(color: s.contains(MaterialState.selected) ? primaryGreen : darkSubtext)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen, foregroundColor: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryGreen),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: darkSurface,
        labelStyle: const TextStyle(color: darkSubtext),
        hintStyle: const TextStyle(color: darkHint),
        prefixIconColor: darkSubtext,
        suffixIconColor: darkSubtext,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkDivider, width: 1)),
        counterStyle: const TextStyle(color: darkHint),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: darkSurface, labelStyle: const TextStyle(color: darkText),
        selectedColor: primaryGreen.withOpacity(0.2),
        side: const BorderSide(color: darkDivider),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: darkText, iconColor: darkSubtext,
        tileColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? primaryGreen : darkSubtext),
        trackColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? primaryGreen.withOpacity(0.3) : darkSurface),
      ),
      iconTheme: const IconThemeData(color: darkText),
      cardTheme: CardThemeData(
        color: darkCard, elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkDivider, width: 0.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkElevated, contentTextStyle: const TextStyle(color: darkText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      popupMenuTheme: const PopupMenuThemeData(color: darkElevated, elevation: 4),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: primaryGreen,
        labelColor: primaryGreen,
        unselectedLabelColor: darkSubtext,
      ),
    );
  }
}
