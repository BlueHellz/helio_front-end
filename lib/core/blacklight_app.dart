import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'providers/theme_provider.dart';
import 'router.dart';
import 'providers/session_providers.dart';
import '../services/auth_api.dart';
import '../theme/limye_theme.dart';

class LimyeApp extends ConsumerWidget {
  const LimyeApp({super.key, this.title = 'LIMYÈ'});

  /// OS / task switcher title (see [main]).
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(blackLightAppStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      themeMode: blackLightThemeMode(appState),
      theme: LimyeTheme.lightTheme(),
      darkTheme: LimyeTheme.darkTheme(),
      home: const _HydratedSessionHome(),
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
    final app = ref.read(blackLightAppStateProvider);
    if (s.isLoggedIn && apiRoleIsHomeowner(s.userRole)) {
      final name = s.fullName ?? '';
      app.signIn(
        role: UserRole.homeowner,
        name: name,
      );
    } else if (s.isLoggedIn && !apiRoleIsHomeowner(s.userRole)) {
      await ref.read(sessionProvider.notifier).clear();
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
