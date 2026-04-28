import 'package:flutter/material.dart';

/// Monospace for metrics / numbers only (JetBrains Mono from pubspec).
const String _fontMono = 'JetBrainsMono';

// ─────────────────────────────────────────────
// BLACK LIGHT — tokens (strict design language)
// Sans-serif: Theme default / system (no bundled Inter/Manrope).
// ─────────────────────────────────────────────

class BlackLightColors {
  BlackLightColors._();

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE8EAED);
  static const Color inputBorder = Color(0xFFDDE1E6);

  static const Color textPrimary = Color(0xFF0B1E33);
  static const Color textBody = Color(0xFF5F6B7A);
  static const Color textCaption = Color(0xFF9AA5B4);

  static const Color accent = Color(0xFF0066FF);
  static const Color green = Color(0xFF00A86B);
  static const Color amber = Color(0xFFFFB347);

  static const Color error = Color(0xFFBA1A1A);

  static const Color footerText = textCaption;

  static const Color sidebarBg = surface;
  static const Color sidebarBorder = border;
  static const Color sidebarActiveText = accent;
  static const Color sidebarActiveBg = Color(0x140066FF);
  static const Color sidebarInactiveText = textBody;
  static const Color sidebarHoverBg = background;
}

class BlackLightSpacing {
  BlackLightSpacing._();

  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 40;
  static const double xl = 64;
  static const double gutter = 24;
  static const double sectionPaddingVertical = 80;
  static const double cardGap = 20;
  static const double cardPadding = 28;
  static const double containerMax = 1200;
  static const double sidebarWidth = 240;
  static const double footerHeight = 64;
  static const double navbarHeight = 72;
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double inputHeightMobile = 48;
  static const double tapTarget = 48;
}

class BlackLightRadius {
  BlackLightRadius._();

  static const double card = 16;
  static const double input = 14;
  static const double inputMobile = 14;
  static const double chip = 28;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

class BlackLightTextStyles {
  BlackLightTextStyles._();

  /// -0.02em ≈ -0.02 × fontSize in logical pixels.
  static TextStyle hero({Color color = BlackLightColors.textPrimary}) =>
      TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
        color: color,
      );

  static TextStyle sectionHeading(
          {Color color = BlackLightColors.textPrimary}) =>
      TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle cardHeading({Color color = BlackLightColors.textPrimary}) =>
      TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle body({Color color = BlackLightColors.textBody}) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color,
      );

  static TextStyle bodyBold({Color color = BlackLightColors.textPrimary}) =>
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: color,
      );

  static TextStyle caption({Color color = BlackLightColors.textCaption}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle captionBold({Color color = BlackLightColors.textCaption}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  /// Numbers / metrics — 14px mono, weight 500.
  static TextStyle data({Color color = BlackLightColors.textPrimary}) =>
      TextStyle(
        fontFamily: _fontMono,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color,
      );

  static TextStyle dataInline({Color color = BlackLightColors.textBody}) =>
      TextStyle(
        fontFamily: _fontMono,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color,
      );

  static TextStyle dataLarge({Color color = BlackLightColors.textPrimary}) =>
      TextStyle(
        fontFamily: _fontMono,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color,
      );

  static TextStyle mobileH1({Color color = BlackLightColors.textPrimary}) =>
      sectionHeading(color: color);

  static TextStyle mobileH2({Color color = BlackLightColors.textPrimary}) =>
      cardHeading(color: color);

  static TextStyle mobileH3({Color color = BlackLightColors.textPrimary}) =>
      cardHeading(color: color);

  static TextStyle mobileButton({Color color = Colors.white}) =>
      bodyBold(color: color);

  static TextStyle mobileBody({Color color = BlackLightColors.textBody}) =>
      body(color: color);

  static TextStyle mobileLabelBold({Color color = BlackLightColors.textBody}) =>
      captionBold(color: color);
}

ThemeData buildBlackLightTheme() {
  final baseSans = BlackLightTextStyles.body();
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: BlackLightColors.background,
    colorScheme: const ColorScheme.light(
      primary: BlackLightColors.accent,
      onPrimary: Colors.white,
      secondary: BlackLightColors.green,
      onSecondary: Colors.white,
      error: BlackLightColors.error,
      surface: BlackLightColors.surface,
      onSurface: BlackLightColors.textPrimary,
    ),
    fontFamily: null,
    iconTheme: const IconThemeData(
      size: 24,
      color: BlackLightColors.textBody,
    ),
    textTheme: TextTheme(
      displayLarge: BlackLightTextStyles.hero(),
      headlineLarge: BlackLightTextStyles.sectionHeading(),
      titleLarge: BlackLightTextStyles.cardHeading(),
      bodyLarge: baseSans,
      bodyMedium: baseSans,
      bodySmall: BlackLightTextStyles.caption(),
      labelLarge: BlackLightTextStyles.bodyBold(),
      labelMedium: BlackLightTextStyles.caption(),
      labelSmall: BlackLightTextStyles.caption(),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: BlackLightColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: BlackLightTextStyles.cardHeading(),
      iconTheme: const IconThemeData(color: BlackLightColors.textBody),
      surfaceTintColor: Colors.transparent,
      shape: const Border(
        bottom: BorderSide(color: BlackLightColors.border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BlackLightColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BlackLightRadius.input),
        borderSide: const BorderSide(color: BlackLightColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BlackLightRadius.input),
        borderSide: const BorderSide(color: BlackLightColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BlackLightRadius.input),
        borderSide: const BorderSide(color: BlackLightColors.accent, width: 1),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: BlackLightTextStyles.caption(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BlackLightColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(64, BlackLightSpacing.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
        textStyle: BlackLightTextStyles.bodyBold(color: Colors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BlackLightColors.accent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        side: const BorderSide(color: BlackLightColors.accent, width: 1),
        minimumSize: const Size(64, BlackLightSpacing.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
        textStyle: BlackLightTextStyles.bodyBold(color: BlackLightColors.accent),
      ),
    ),
    cardTheme: CardThemeData(
      color: BlackLightColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        side: const BorderSide(color: BlackLightColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: BlackLightColors.border,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: BlackLightColors.surface,
      selectedItemColor: BlackLightColors.accent,
      unselectedItemColor: BlackLightColors.textBody,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
