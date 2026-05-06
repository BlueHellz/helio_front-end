import 'package:flutter/material.dart';

/// Monospace for metrics / numbers only (JetBrains Mono from pubspec).
const String _fontMono = 'JetBrainsMono';

// ─────────────────────────────────────────────
// LIMYÈ — tokens (strict design language)
// Sans-serif: Theme default / system (no bundled Inter/Manrope).
// ─────────────────────────────────────────────

class LimyeColors {
  LimyeColors._();

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);

  /// Nested cards / final CTA band (light).
  static const Color surfaceMuted = Color(0xFFF1F3F5);

  static const Color border = Color(0xFFE8EAED);

  /// Card / stroke neutrals aligned with Material [ColorScheme.outline].
  static const Color outline = border;

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

class LimyeSpacing {
  LimyeSpacing._();

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

  /// Homeowner AI guided intake modal max width (desktop).
  static const double guidedFormModalMaxWidth = 550;
}

class LimyeRadius {
  LimyeRadius._();

  static const double card = 16;
  static const double input = 14;
  static const double inputMobile = 14;
  static const double chip = 28;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

class LimyeTextStyles {
  LimyeTextStyles._();

  /// -0.02em ≈ -0.02 × fontSize in logical pixels.
  static TextStyle hero({Color color = LimyeColors.textPrimary}) => TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
        color: color,
      );

  static TextStyle sectionHeading({Color color = LimyeColors.textPrimary}) =>
      TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle cardHeading({Color color = LimyeColors.textPrimary}) =>
      TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle body({Color color = LimyeColors.textBody}) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color,
      );

  static TextStyle bodyBold({Color color = LimyeColors.textPrimary}) =>
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: color,
      );

  static TextStyle caption({Color color = LimyeColors.textCaption}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle captionBold({Color color = LimyeColors.textCaption}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  /// Numbers / metrics — 14px mono, weight 500.
  static TextStyle data({Color color = LimyeColors.textPrimary}) => TextStyle(
        fontFamily: _fontMono,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color,
      );

  static TextStyle dataInline({Color color = LimyeColors.textBody}) =>
      TextStyle(
        fontFamily: _fontMono,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color,
      );

  static TextStyle dataLarge({Color color = LimyeColors.textPrimary}) =>
      TextStyle(
        fontFamily: _fontMono,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color,
      );

  static TextStyle mobileH1({Color color = LimyeColors.textPrimary}) =>
      sectionHeading(color: color);

  static TextStyle mobileH2({Color color = LimyeColors.textPrimary}) =>
      cardHeading(color: color);

  static TextStyle mobileH3({Color color = LimyeColors.textPrimary}) =>
      cardHeading(color: color);

  static TextStyle mobileButton({Color color = Colors.white}) =>
      bodyBold(color: color);

  static TextStyle mobileBody({Color color = LimyeColors.textBody}) =>
      body(color: color);

  static TextStyle mobileLabelBold({Color color = LimyeColors.textBody}) =>
      captionBold(color: color);
}

/// Dark palette (LIMYÈ premium / org). Sizes match light theme.
class LimyeDarkColors {
  LimyeDarkColors._();

  static const Color background = Color(0xFF0B1E33);
  static const Color surface = Color(0xFF111F2F);
  static const Color border = Color(0xFF1A2D44);

  /// Nested cards / final CTA band (dark).
  static const Color surfaceMuted = Color(0xFF1A2D44);
  static const Color textPrimary = Color(0xFFE8EDF2);
  static const Color textBody = Color(0xFF8A9BB5);
}

/// Theme-aware tokens for shells and surfaces that must track light/dark org mode.
class LimyeAdaptive {
  LimyeAdaptive._();

  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      _dark(context) ? LimyeDarkColors.background : LimyeColors.background;

  static Color surface(BuildContext context) =>
      _dark(context) ? LimyeDarkColors.surface : LimyeColors.surface;

  static Color border(BuildContext context) =>
      _dark(context) ? LimyeDarkColors.border : LimyeColors.border;

  static Color textPrimary(BuildContext context) =>
      _dark(context) ? LimyeDarkColors.textPrimary : LimyeColors.textPrimary;

  static Color textBody(BuildContext context) =>
      _dark(context) ? LimyeDarkColors.textBody : LimyeColors.textBody;

  static Color textCaption(BuildContext context) =>
      _dark(context) ? LimyeDarkColors.textBody : LimyeColors.textCaption;

  static Color sidebarBg(BuildContext context) => surface(context);

  static Color sidebarBorder(BuildContext context) => border(context);

  static Color sidebarInactiveText(BuildContext context) => textBody(context);

  static Color sidebarHoverBg(BuildContext context) =>
      _dark(context) ? LimyeDarkColors.background : LimyeColors.sidebarHoverBg;
}

/// Theme tokens via `context.colors` — prefer over hardcoded hex in widgets.
class LimyePalette {
  LimyePalette(this._context);
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
  Color get warning => LimyeColors.amber;

  /// Muted / secondary text (matches caption tone in light and dark themes).
  Color get onSurfaceMuted => _t.colorScheme.onSurfaceVariant;

  /// Secondary fill for nested cards / column bodies.
  Color get surfaceMuted => brightness == Brightness.dark
      ? LimyeDarkColors.surfaceMuted
      : LimyeColors.surfaceMuted;
}

extension LimyeContextPalette on BuildContext {
  LimyePalette get colors => LimyePalette(this);
}

class LimyeTheme {
  LimyeTheme._();

  static ThemeData lightTheme() => buildLimyeTheme();

  static ThemeData darkTheme() {
    const bg = LimyeDarkColors.background;
    const surface = LimyeDarkColors.surface;
    const borderC = LimyeDarkColors.border;
    const onSurf = LimyeDarkColors.textPrimary;
    const bodyC = LimyeDarkColors.textBody;

    final baseSans = LimyeTextStyles.body(color: bodyC);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      cardColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: LimyeColors.accent,
        onPrimary: Colors.white,
        secondary: LimyeColors.green,
        onSecondary: Colors.white,
        error: LimyeColors.error,
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
        displayLarge: LimyeTextStyles.hero(color: onSurf),
        displayMedium: LimyeTextStyles.sectionHeading(color: onSurf),
        displaySmall: LimyeTextStyles.cardHeading(color: onSurf),
        headlineLarge: LimyeTextStyles.sectionHeading(color: onSurf),
        headlineMedium: LimyeTextStyles.sectionHeading(color: onSurf),
        headlineSmall: LimyeTextStyles.cardHeading(color: onSurf),
        titleLarge: LimyeTextStyles.cardHeading(color: onSurf),
        titleMedium: LimyeTextStyles.bodyBold(color: onSurf),
        titleSmall: LimyeTextStyles.bodyBold(color: onSurf),
        bodyLarge: baseSans,
        bodyMedium: baseSans,
        bodySmall: LimyeTextStyles.caption(color: bodyC),
        labelLarge: LimyeTextStyles.bodyBold(color: onSurf),
        labelMedium: LimyeTextStyles.caption(color: bodyC),
        labelSmall: LimyeTextStyles.caption(color: bodyC),
      ),
      primaryTextTheme: TextTheme(
        bodyLarge: LimyeTextStyles.bodyBold(color: Colors.white),
        bodyMedium: LimyeTextStyles.bodyBold(color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurf,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: LimyeTextStyles.cardHeading(color: onSurf),
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
          borderRadius: BorderRadius.circular(LimyeRadius.input),
          borderSide: const BorderSide(color: borderC),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LimyeRadius.input),
          borderSide: const BorderSide(color: borderC),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LimyeRadius.input),
          borderSide: const BorderSide(color: LimyeColors.accent, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: LimyeTextStyles.caption(color: bodyC),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LimyeColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(64, LimyeSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: LimyeTextStyles.bodyBold(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LimyeColors.accent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          side: const BorderSide(color: LimyeColors.accent, width: 1),
          minimumSize: const Size(64, LimyeSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: LimyeTextStyles.bodyBold(color: LimyeColors.accent),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LimyeRadius.card),
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
        selectedItemColor: LimyeColors.accent,
        unselectedItemColor: bodyC,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LimyeRadius.card),
          side: const BorderSide(color: borderC, width: 1),
        ),
        titleTextStyle: LimyeTextStyles.cardHeading(color: onSurf),
        contentTextStyle: baseSans,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: baseSans,
        actionTextColor: LimyeColors.accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LimyeRadius.md),
          side: const BorderSide(color: borderC, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: LimyeColors.accent,
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

ThemeData buildLimyeTheme() {
  final baseSans = LimyeTextStyles.body();
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: LimyeColors.background,
    colorScheme: const ColorScheme.light(
      primary: LimyeColors.accent,
      onPrimary: Colors.white,
      secondary: LimyeColors.green,
      onSecondary: Colors.white,
      error: LimyeColors.error,
      surface: LimyeColors.surface,
      onSurface: LimyeColors.textPrimary,
      outline: LimyeColors.border,
      onSurfaceVariant: LimyeColors.textCaption,
    ),
    fontFamily: null,
    iconTheme: const IconThemeData(
      size: 24,
      color: LimyeColors.textBody,
    ),
    textTheme: TextTheme(
      displayLarge: LimyeTextStyles.hero(),
      headlineLarge: LimyeTextStyles.sectionHeading(),
      titleLarge: LimyeTextStyles.cardHeading(),
      bodyLarge: baseSans,
      bodyMedium: baseSans,
      bodySmall: LimyeTextStyles.caption(),
      labelLarge: LimyeTextStyles.bodyBold(),
      labelMedium: LimyeTextStyles.caption(),
      labelSmall: LimyeTextStyles.caption(),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: LimyeColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: LimyeTextStyles.cardHeading(),
      iconTheme: const IconThemeData(color: LimyeColors.textBody),
      surfaceTintColor: Colors.transparent,
      shape: const Border(
        bottom: BorderSide(color: LimyeColors.border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LimyeColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LimyeRadius.input),
        borderSide: const BorderSide(color: LimyeColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LimyeRadius.input),
        borderSide: const BorderSide(color: LimyeColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LimyeRadius.input),
        borderSide: const BorderSide(color: LimyeColors.accent, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: LimyeTextStyles.caption(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LimyeColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(64, LimyeSpacing.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
        textStyle: LimyeTextStyles.bodyBold(color: Colors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: LimyeColors.accent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        side: const BorderSide(color: LimyeColors.accent, width: 1),
        minimumSize: const Size(64, LimyeSpacing.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
        textStyle: LimyeTextStyles.bodyBold(color: LimyeColors.accent),
      ),
    ),
    cardTheme: CardThemeData(
      color: LimyeColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        side: const BorderSide(color: LimyeColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: LimyeColors.border,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: LimyeColors.surface,
      selectedItemColor: LimyeColors.accent,
      unselectedItemColor: LimyeColors.textBody,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
