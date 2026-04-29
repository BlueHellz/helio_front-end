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

  /// Nested cards / final CTA band (light).
  static const Color surfaceMuted = Color(0xFFF1F3F5);

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

/// Dark palette (Black Light premium / org). Sizes match light theme.
class BlackLightDarkColors {
  BlackLightDarkColors._();

  static const Color background = Color(0xFF0B1E33);
  static const Color surface = Color(0xFF111F2F);
  static const Color border = Color(0xFF1A2D44);

  /// Nested cards / final CTA band (dark).
  static const Color surfaceMuted = Color(0xFF1A2D44);
  static const Color textPrimary = Color(0xFFE8EDF2);
  static const Color textBody = Color(0xFF8A9BB5);
}

/// Theme-aware tokens for shells and surfaces that must track light/dark org mode.
class BlackLightAdaptive {
  BlackLightAdaptive._();

  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) => _dark(context)
      ? BlackLightDarkColors.background
      : BlackLightColors.background;

  static Color surface(BuildContext context) => _dark(context)
      ? BlackLightDarkColors.surface
      : BlackLightColors.surface;

  static Color border(BuildContext context) => _dark(context)
      ? BlackLightDarkColors.border
      : BlackLightColors.border;

  static Color textPrimary(BuildContext context) => _dark(context)
      ? BlackLightDarkColors.textPrimary
      : BlackLightColors.textPrimary;

  static Color textBody(BuildContext context) => _dark(context)
      ? BlackLightDarkColors.textBody
      : BlackLightColors.textBody;

  static Color textCaption(BuildContext context) => _dark(context)
      ? BlackLightDarkColors.textBody
      : BlackLightColors.textCaption;

  static Color sidebarBg(BuildContext context) => surface(context);

  static Color sidebarBorder(BuildContext context) => border(context);

  static Color sidebarInactiveText(BuildContext context) => textBody(context);

  static Color sidebarHoverBg(BuildContext context) => _dark(context)
      ? BlackLightDarkColors.background
      : BlackLightColors.sidebarHoverBg;
}

/// Theme tokens via `context.colors` — prefer over hardcoded hex in widgets.
class BlackLightPalette {
  BlackLightPalette(this._context);
  final BuildContext _context;

  ThemeData get _t => Theme.of(_context);
  Brightness get brightness => _t.brightness;

  Color get scaffold => _t.scaffoldBackgroundColor;
  Color get surface => _t.colorScheme.surface;
  Color get onSurface => _t.colorScheme.onSurface;
  Color get outline => _t.colorScheme.outline;
  Color get primary => _t.colorScheme.primary;
  Color get onPrimary => _t.colorScheme.onPrimary;
  Color get secondary => _t.colorScheme.secondary;
  Color get error => _t.colorScheme.error;

  /// Semantic accents not mapped to [ColorScheme] (CRM status, chips).
  Color get warning => BlackLightColors.amber;

  /// Muted / secondary text (matches caption tone in light and dark themes).
  Color get onSurfaceMuted => _t.colorScheme.onSurfaceVariant;

  /// Secondary fill for nested cards / column bodies.
  Color get surfaceMuted => brightness == Brightness.dark
      ? BlackLightDarkColors.surfaceMuted
      : BlackLightColors.surfaceMuted;
}

extension BlackLightContextPalette on BuildContext {
  BlackLightPalette get colors => BlackLightPalette(this);
}

class BlackLightTheme {
  BlackLightTheme._();

  static ThemeData lightTheme() => buildBlackLightTheme();

  static ThemeData darkTheme() {
    const bg = BlackLightDarkColors.background;
    const surface = BlackLightDarkColors.surface;
    const borderC = BlackLightDarkColors.border;
    const onSurf = BlackLightDarkColors.textPrimary;
    const bodyC = BlackLightDarkColors.textBody;

    final baseSans = BlackLightTextStyles.body(color: bodyC);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      cardColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: BlackLightColors.accent,
        onPrimary: Colors.white,
        secondary: BlackLightColors.green,
        onSecondary: Colors.white,
        error: BlackLightColors.error,
        surface: surface,
        onSurface: onSurf,
        outline: borderC,
        onSurfaceVariant: bodyC,
      ),
      fontFamily: null,
      iconTheme: IconThemeData(
        size: 24,
        color: bodyC,
      ),
      textTheme: TextTheme(
        displayLarge: BlackLightTextStyles.hero(color: onSurf),
        displayMedium: BlackLightTextStyles.sectionHeading(color: onSurf),
        displaySmall: BlackLightTextStyles.cardHeading(color: onSurf),
        headlineLarge: BlackLightTextStyles.sectionHeading(color: onSurf),
        headlineMedium: BlackLightTextStyles.sectionHeading(color: onSurf),
        headlineSmall: BlackLightTextStyles.cardHeading(color: onSurf),
        titleLarge: BlackLightTextStyles.cardHeading(color: onSurf),
        titleMedium: BlackLightTextStyles.bodyBold(color: onSurf),
        titleSmall: BlackLightTextStyles.bodyBold(color: onSurf),
        bodyLarge: baseSans,
        bodyMedium: baseSans,
        bodySmall: BlackLightTextStyles.caption(color: bodyC),
        labelLarge: BlackLightTextStyles.bodyBold(color: onSurf),
        labelMedium: BlackLightTextStyles.caption(color: bodyC),
        labelSmall: BlackLightTextStyles.caption(color: bodyC),
      ),
      primaryTextTheme: TextTheme(
        bodyLarge: BlackLightTextStyles.bodyBold(color: Colors.white),
        bodyMedium: BlackLightTextStyles.bodyBold(color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurf,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: BlackLightTextStyles.cardHeading(color: onSurf),
        iconTheme: IconThemeData(color: bodyC),
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: borderC, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.input),
          borderSide: const BorderSide(color: borderC),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.input),
          borderSide: const BorderSide(color: borderC),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.input),
          borderSide: const BorderSide(color: BlackLightColors.accent, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: BlackLightTextStyles.caption(color: bodyC),
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
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.card),
          side: const BorderSide(color: borderC, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: borderC,
        thickness: 1,
        space: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: BlackLightColors.accent,
        unselectedItemColor: bodyC,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.card),
          side: const BorderSide(color: borderC, width: 1),
        ),
        titleTextStyle: BlackLightTextStyles.cardHeading(color: onSurf),
        contentTextStyle: baseSans,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: baseSans,
        actionTextColor: BlackLightColors.accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.md),
          side: const BorderSide(color: borderC, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: BlackLightColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surface),
          side: const WidgetStatePropertyAll(BorderSide(color: borderC)),
        ),
        textStyle: baseSans,
      ),
    );
  }
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
      outline: BlackLightColors.border,
      onSurfaceVariant: BlackLightColors.textCaption,
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
