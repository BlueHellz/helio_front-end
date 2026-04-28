import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:provider/provider.dart';

import 'app_state.dart';
import '../theme/blacklight_theme.dart';
import 'router.dart';
import 'providers/session_providers.dart';

class BlackLightApp extends StatelessWidget {
  const BlackLightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BlackLightAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Black Light',
        theme: buildBlackLightTheme(),
        home: const _HydratedSessionHome(),
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
    final s = ref.read(sessionProvider);
    final app = context.read<BlackLightAppState>();
    if (s.isLoggedIn) {
      app.signIn(
        role: userRoleFromApiString(s.userRole),
        name: s.fullName ?? '',
        companyName: s.companyName ?? '',
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
