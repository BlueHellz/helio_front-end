import 'package:flutter/material.dart';

import '../../config.dart';
import '../app_state.dart';
import '../../theme/blacklight_theme.dart';

/// Root [MaterialApp] always uses light mode so public marketing, homeowners,
/// drone ops, and free installers never inherit a global dark theme.
ThemeMode blackLightThemeMode(BlackLightAppState app) {
  return ThemeMode.light;
}

/// Black Light (premium) dark UI applies only when **all** are true:
/// bypass simulates premium, user is authenticated as an org/installer, and
/// the caller is about to show the authenticated org shell (not public pages).
///
/// Homeowners never satisfy this (role != organization). Unauthenticated
/// flows never satisfy this. Free org (bypass off) never satisfies this.
bool premiumBlackLightDarkUiActive(BlackLightAppState app) {
  return BlackLightConfig.bypassMode &&
      app.isAuthenticated &&
      app.role == UserRole.organization;
}

/// Wraps org web/mobile shell in [BlackLightTheme.darkTheme] when premium is active.
Widget wrapPremiumBlackLightShell(BlackLightAppState app, Widget child) {
  if (premiumBlackLightDarkUiActive(app)) {
    return Theme(
      data: BlackLightTheme.darkTheme(),
      child: child,
    );
  }
  return child;
}
