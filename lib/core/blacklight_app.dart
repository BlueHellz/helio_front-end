import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide Consumer, ChangeNotifierProvider;
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'content/content_registry.dart';
import 'providers/theme_provider.dart';
import '../theme/blacklight_theme.dart';
import 'router.dart';
import 'providers/session_providers.dart';
import '../services/auth_api.dart';

class BlackLightApp extends StatelessWidget {
  const BlackLightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BlackLightAppState(),
      child: Consumer<BlackLightAppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: CommonContent.appName,
            themeMode: blackLightThemeMode(appState),
            theme: BlackLightTheme.lightTheme(),
            // Kept for API completeness; root never uses ThemeMode.dark — premium
            // org chrome is wrapped with [wrapPremiumBlackLightShell] in the router.
            darkTheme: BlackLightTheme.darkTheme(),
            home: const _HydratedSessionHome(),
          );
        },
      ),
    );
  }
}

class _HydratedSessionHome extends ConsumerStatefulWidget {
  const _HydratedSessionHome();

  @override
  ConsumerState<_HydratedSessionHome> createState() =>
      _HydratedSessionHomeState();
}

class _HydratedSessionHomeState extends ConsumerState<_HydratedSessionHome> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  Future<void> _restore() async {
    await ref.read(sessionProvider.notifier).restoreFromStorage();
    if (!mounted) return;
    AuthSession s = ref.read(sessionProvider);
    if (s.isLoggedIn) {
      try {
        final auth = ref.read(authApiProvider);
        final enriched = await auth.enrichWithMe(AuthResult(
          accessToken: s.bearerToken!,
          refreshToken: s.refreshToken ?? '',
          userId: s.userId,
          orgId: s.orgId,
          role: s.userRole,
          fullName: s.fullName,
          companyName: s.companyName,
        ));
        await ref.read(sessionProvider.notifier).applyAuthResult(enriched);
        if (!mounted) return;
        s = ref.read(sessionProvider);
      } catch (_) {}
    }
    final app = context.read<BlackLightAppState>();
    if (s.isLoggedIn) {
      final apiRole = userRoleFromApiString(s.userRole);
      final name = s.fullName ?? '';
      final comp = s.companyName?.trim();
      final displayCompany = (comp != null && comp.isNotEmpty)
          ? comp
          : (apiRole == UserRole.organization ? name : '');
      app.signIn(
        role: apiRole,
        name: name,
        companyName: displayCompany,
      );
    }
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const BlackLightRouter();
  }
}
