import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/theme/limye_theme.dart';

import 'app_state.dart';
import 'providers/session_providers.dart';
import 'providers/theme_provider.dart';
import 'shell/web/homeowner_web_chrome.dart';
import 'ui/app_feedback.dart';

import 'package:limye_app/features/light/landing/landing_page.dart';
import 'package:limye_app/features/light/auth/auth_page.dart';
import 'package:limye_app/features/light/homeowner/project_tracking_page.dart';
import 'package:limye_app/features/light/homeowner/intake_page.dart';
import 'package:limye_app/features/light/homeowner/chat_page.dart';
import 'package:limye_app/features/light/homeowner/homeowner_design_result_page.dart';
import 'package:limye_app/features/light/homeowner/homeowner_wallet_page.dart';
import 'package:limye_app/features/light/homeowner/mobile_homeowner_shell.dart';
import 'package:limye_app/features/light/auth/mobile_auth.dart';

import 'package:limye_app/features/light/drone_ops/web/drone_ops_info_page.dart';
import 'package:limye_app/features/light/pool_funding/web/pool_info_page.dart';
import 'package:limye_app/features/light/ev/ev_info_page.dart';

/// Root router: public homeowner marketing + intake without auth; dashboard after login.
class BlackLightRouter extends ConsumerWidget {
  const BlackLightRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(blackLightAppStateProvider);
    final session = ref.watch(sessionProvider);

    if (kIsWeb) {
      return _WebSwitch(app: app, session: session);
    }
    return _MobileSwitch(app: app, session: session);
  }
}

// ─── Web ───────────────────────────────────────────────────────────

enum _WebPublicPage {
  landing,
  droneOps,
  pool,
  ev,
  login,
  intake,
  designSummary,
}

class _WebSwitch extends ConsumerStatefulWidget {
  const _WebSwitch({
    required this.app,
    required this.session,
  });

  final BlackLightAppState app;
  final AuthSession session;

  @override
  ConsumerState<_WebSwitch> createState() => _WebSwitchState();
}

class _WebSwitchState extends ConsumerState<_WebSwitch> {
  _WebPublicPage _public = _WebPublicPage.landing;

  void _go(_WebPublicPage p) => setState(() => _public = p);

  Future<void> _signOut() async {
    ref.read(sessionProvider.notifier).clear();
    widget.app.signOut();
    setState(() => _public = _WebPublicPage.landing);
  }

  void _openWalletConnect() {
    AppFeedback.showWalletConnectDialog(
      context,
      onAddress: (addr) {
        widget.app.connectWallet(addr);
        AppFeedback.snack(context, RouterStrings.walletSavedSession);
      },
    );
  }

  Future<void> _editName() async {
    final v = await AppFeedback.showEditStringDialog(
      context,
      title: RouterStrings.editFullNameTitle,
      initial: widget.app.userName,
    );
    if (v != null && v.isNotEmpty) widget.app.updateLocalProfile(userName: v);
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final session = widget.session;

    if (!app.isAuthenticated || !session.isLoggedIn) {
      switch (_public) {
        case _WebPublicPage.login:
          return AuthPage(
            onHomeTap: () => _go(_WebPublicPage.landing),
            onNavbarSignIn: () => _go(_WebPublicPage.login),
          );
        case _WebPublicPage.droneOps:
          return DroneOpsInfoPage(
            onHomeTap: () => _go(_WebPublicPage.landing),
            onSignIn: () => _go(_WebPublicPage.login),
            onMyProjects: () => _go(_WebPublicPage.login),
            onLaunchTerminal: () => _go(_WebPublicPage.login),
          );
        case _WebPublicPage.pool:
          return PoolInfoPage(
            onHomeTap: () => _go(_WebPublicPage.landing),
            onSignIn: () => _go(_WebPublicPage.login),
            onMyProjects: () => _go(_WebPublicPage.login),
            onJoinWaitlist: () => _go(_WebPublicPage.login),
          );
        case _WebPublicPage.ev:
          return EvInfoPage(
            onHomeTap: () => _go(_WebPublicPage.landing),
            onSignIn: () => _go(_WebPublicPage.login),
            onMyProjects: () => _go(_WebPublicPage.login),
            onApplyAsHost: () => _go(_WebPublicPage.login),
          );
        case _WebPublicPage.intake:
          return HomeownerIntakePage(
            onLocalDesignReady: () =>
                setState(() => _public = _WebPublicPage.designSummary),
            onAbandon: () => _go(_WebPublicPage.landing),
          );
        case _WebPublicPage.designSummary:
          return Scaffold(
            appBar: AppBar(
              title: Text(HomeownerDesignSummaryContent.title),
              leading: BackButton(
                onPressed: () => _go(_WebPublicPage.intake),
              ),
            ),
            body: const HomeownerDesignResultPage(),
          );
        case _WebPublicPage.landing:
          return LandingPage(
            onHomeTap: () => _go(_WebPublicPage.landing),
            onGetStarted: () => _go(_WebPublicPage.intake),
            onSignIn: () => _go(_WebPublicPage.login),
            onMyProjects: () => _go(_WebPublicPage.login),
            onOpenDroneOps: () => _go(_WebPublicPage.droneOps),
            onOpenPool: () => _go(_WebPublicPage.pool),
            onOpenEv: () => _go(_WebPublicPage.ev),
          );
      }
    }

    final role = resolvedNavigationRole(
      authenticated: app.isAuthenticated,
      appRole: app.role,
      session: session,
    );
    if (role != UserRole.homeowner) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(LimyeSpacing.gutter),
          child: Text(
            AuthContent.homeownerLoginOnly,
            textAlign: TextAlign.center,
            style: LimyeTextStyles.body(),
          ),
        ),
      );
    }

    final idx = app.webSidebarIndex;
    final Widget body = switch (idx) {
      1 => const HomeownerIntakePage(),
      2 => const HomeownerChatPage(),
      3 => HomeownerWalletPage(
          userName: app.userName,
          hlioBalance: app.hlioBalance,
          walletAddress: app.walletAddress,
          onConnectWallet: _openWalletConnect,
          onSignOut: _signOut,
          onEditUserName: _editName,
          onEditEmail: () => AppFeedback.comingSoon(
                context,
                feature: FeedbackStrings.featureEmailChanges,
              ),
        ),
      4 => _WebHelpPage(),
      _ => const ProjectTrackingPage(),
    };

    return wrapPremiumBlackLightShell(
      app,
      HomeownerAuthenticatedChrome(
        activeIndex: idx,
        userName: app.userName,
        hlioBalance: app.hlioBalance,
        onNavTap: app.setWebSidebarIndex,
        onSignOut: _signOut,
        child: body,
      ),
    );
  }
}

class _WebHelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LimyeSpacing.gutter),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                NavigationContent.sidebarHelp,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: LimyeSpacing.md),
              Text(
                RouterStrings.orgWebHelpBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mobile ──────────────────────────────────────────────────────────

enum _MobilePublic { home, intake, designSummary, login }

class _MobileSwitch extends ConsumerStatefulWidget {
  const _MobileSwitch({
    required this.app,
    required this.session,
  });

  final BlackLightAppState app;
  final AuthSession session;

  @override
  ConsumerState<_MobileSwitch> createState() => _MobileSwitchState();
}

class _MobileSwitchState extends ConsumerState<_MobileSwitch> {
  _MobilePublic _pub = _MobilePublic.home;

  void _signOut() {
    ref.read(sessionProvider.notifier).clear();
    widget.app.signOut();
    setState(() => _pub = _MobilePublic.home);
  }

  void _openWallet(BlackLightAppState app) {
    AppFeedback.showWalletConnectDialog(
      context,
      onAddress: (addr) {
        app.connectWallet(addr);
        AppFeedback.snack(context, RouterStrings.walletSavedSession);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final session = widget.session;

    if (!app.isAuthenticated || !session.isLoggedIn) {
      switch (_pub) {
        case _MobilePublic.login:
          return MobileAuth(
            onBack: () => setState(() => _pub = _MobilePublic.home),
          );
        case _MobilePublic.intake:
          return HomeownerIntakePage(
            onLocalDesignReady: () =>
                setState(() => _pub = _MobilePublic.designSummary),
          );
        case _MobilePublic.designSummary:
          return Scaffold(
            appBar: AppBar(
              title: Text(HomeownerDesignSummaryContent.title),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    setState(() => _pub = _MobilePublic.intake),
              ),
            ),
            body: const HomeownerDesignResultPage(),
          );
        case _MobilePublic.home:
          return Scaffold(
            backgroundColor: LimyeColors.background,
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(LimyeSpacing.gutter),
                children: [
                  const SizedBox(height: LimyeSpacing.lg),
                  Text(
                    LandingContent.heroTitle,
                    style: LimyeTextStyles.hero(),
                  ),
                  const SizedBox(height: LimyeSpacing.md),
                  Text(LandingContent.heroBody,
                      style: LimyeTextStyles.body()),
                  const SizedBox(height: LimyeSpacing.xl),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _pub = _MobilePublic.intake),
                    child: Text(LandingContent.heroPrimaryCta,
                        style: LimyeTextStyles.bodyBold(color: Colors.white)),
                  ),
                  const SizedBox(height: LimyeSpacing.md),
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _pub = _MobilePublic.login),
                    child: Text(HomeownerDashboardContent.myProjectsPageTitle,
                        style: LimyeTextStyles.bodyBold()),
                  ),
                ],
              ),
            ),
          );
      }
    }

    final idx = app.mobileNavIndex;
    final body = switch (idx) {
      1 => const HomeownerIntakePage(),
      2 => const HomeownerChatPage(),
      3 => HomeownerWalletPage(
          userName: app.userName,
          hlioBalance: app.hlioBalance,
          walletAddress: app.walletAddress,
          onConnectWallet: () => _openWallet(app),
          onSignOut: _signOut,
          onEditUserName: () async {
            final v = await AppFeedback.showEditStringDialog(
              context,
              title: RouterStrings.editFullNameTitle,
              initial: app.userName,
            );
            if (v != null && v.isNotEmpty) app.updateLocalProfile(userName: v);
          },
          onEditEmail: () => AppFeedback.comingSoon(
                context,
                feature: FeedbackStrings.featureEmailChanges,
              ),
        ),
      _ => const ProjectTrackingPage(),
    };

    return wrapPremiumBlackLightShell(
      app,
      MobileHomeownerShell(
        activeIndex: idx,
        onNavTap: app.setMobileNavIndex,
        child: body,
      ),
    );
  }
}
