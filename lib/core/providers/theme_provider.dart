import 'package:flutter/material.dart';

import '../app_state.dart';

ThemeMode blackLightThemeMode(BlackLightAppState app) {
  return ThemeMode.light;
}

/// Retained for call sites; org-only dark chrome has been removed.
Widget wrapPremiumBlackLightShell(BlackLightAppState app, Widget child) {
  return child;
}
