import 'package:flutter/material.dart';

import '../../config.dart';
import '../app_state.dart';

/// Chooses [ThemeMode] from config and session. Premium org (bypass + installer
/// role) uses dark Black Light theme; homeowners, drone ops, and public stay light.
ThemeMode blackLightThemeMode(BlackLightAppState app) {
  if (!BlackLightConfig.bypassMode) return ThemeMode.light;
  if (!app.isAuthenticated) return ThemeMode.light;
  if (app.role == UserRole.organization) return ThemeMode.dark;
  return ThemeMode.light;
}
