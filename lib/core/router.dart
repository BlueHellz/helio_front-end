import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/platform/web_history.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

import 'app_state.dart';
import 'providers/session_providers.dart';
import 'providers/theme_provider.dart';
import 'shell/web/homeowner_web_chrome.dart';
import 'ui/app_feedback.dart';

import 'package:kooyoh_app/features/light/landing/landing_page.dart';
import 'package:kooyoh_app/features/light/auth/auth_page.dart';
import 'package:kooyoh_app/features/light/enterprise/enterprise_auth_page.dart';
import 'package:kooyoh_app/features/light/enterprise/business_solutions_page.dart';
import 'package:kooyoh_app/features/light/homeowner/project_tracking_page.dart';
import 'package:kooyoh_app/features/light/homeowner/intake_page.dart';
import 'package:kooyoh_app/features/light/homeowner/ai_chat_page.dart';
import 'package:kooyoh_app/features/light/homeowner/homeowner_design_result_page.dart';
import 'package:kooyoh_app/features/light/homeowner/homeowner_wallet_page.dart';
import 'package:kooyoh_app/features/light/homeowner/mobile_homeowner_shell.dart';
import 'package:kooyoh_app/features/light/auth/mobile_auth.dart';

/// Root router: public marketing, auth-free design chat, enterprise funnel;
/// homeowner vs org dashboards after login.
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
  enterprise,
  enterpriseAuth,
  publicDesignChat,
  login,
  signup,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) return;
      final raw = readAppPath();
      final path = raw.split('?').first;
      if (path == '/intake') {
        pushAppPath('/design-chat');
      }
      final mapped =
          _pageForBrowserPath(path == '/intake' ? '/design-chat' : path);
      if (mounted) setState(() => _public = mapped);
    });
  }

  _WebPublicPage _pageForBrowserPath(String raw) {
    final path = raw.split('?').first;
    if (path == '/enterprise-auth') return _WebPublicPage.enterpriseAuth;
    if (path == '/enterprise') return _WebPublicPage.enterprise;
    if (path == '/design-chat') return _WebPublicPage.publicDesignChat;
    if (path == '/my-projects') return _WebPublicPage.login;
    if (path == '/create-account') return _WebPublicPage.signup;
    if (path == '/design-summary') return _WebPublicPage.designSummary;
    return _WebPublicPage.landing;
  }

  String _pathForPage(_WebPublicPage p) {
    switch (p) {
      case _WebPublicPage.landing:
        return '/';
      case _WebPublicPage.enterprise:
        return '/enterprise';
      case _WebPublicPage.enterpriseAuth:
        return '/enterprise-auth';
      case _WebPublicPage.publicDesignChat:
        return '/design-chat';
      case _WebPublicPage.login:
        return '/my-projects';
      case _WebPublicPage.signup:
        return '/create-account';
      case _WebPublicPage.designSummary:
        return '/design-summary';
    }
  }

  void _go(_WebPublicPage p) {
    setState(() => _public = p);
    if (kIsWeb) pushAppPath(_pathForPage(p));
  }

  Future<void> _signOut() async {
    ref.read(sessionProvider.notifier).clear();
    widget.app.signOut();
    setState(() => _public = _WebPublicPage.landing);
    if (kIsWeb) pushAppPath('/');
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
            onBusinesses: () => _go(_WebPublicPage.enterprise),
            onEnterprise: () => _go(_WebPublicPage.enterpriseAuth),
          );
        case _WebPublicPage.signup:
          return AuthPage(
            initialSignupMode: true,
            onHomeTap: () => _go(_WebPublicPage.landing),
            onBusinesses: () => _go(_WebPublicPage.enterprise),
            onEnterprise: () => _go(_WebPublicPage.enterpriseAuth),
          );
        case _WebPublicPage.enterpriseAuth:
          return EnterpriseAuthPage(
            onHomeTap: () => _go(_WebPublicPage.landing),
            onBusinesses: () => _go(_WebPublicPage.enterprise),
            onEnterprise: () => _go(_WebPublicPage.enterpriseAuth),
          );
        case _WebPublicPage.enterprise:
          return BusinessSolutionsPage(
            onHomeTap: () => _go(_WebPublicPage.landing),
            onBusinesses: () => _go(_WebPublicPage.enterprise),
            onEnterprise: () => _go(_WebPublicPage.enterpriseAuth),
          );
        case _WebPublicPage.publicDesignChat:
          return AiChatPage(
            designFlowMode: true,
            onBackTap: () => _go(_WebPublicPage.landing),
            onOpenHomeownerLogin: () => _go(_WebPublicPage.login),
            onOpenHomeownerSignup: () => _go(_WebPublicPage.signup),
          );
        case _WebPublicPage.designSummary:
          return Scaffold(
            appBar: AppBar(
              title: Text(HomeownerDesignSummaryContent.title),
              leading: BackButton(
                onPressed: () => _go(_WebPublicPage.publicDesignChat),
              ),
            ),
            body: const HomeownerDesignResultPage(),
          );
        case _WebPublicPage.landing:
          return LandingPage(
            onHomeTap: () => _go(_WebPublicPage.landing),
            onGetStarted: () => _go(_WebPublicPage.publicDesignChat),
            onBusinesses: () => _go(_WebPublicPage.enterprise),
            onEnterprise: () => _go(_WebPublicPage.enterpriseAuth),
          );
      }
    }

    final role = resolvedNavigationRole(
      authenticated: app.isAuthenticated,
      appRole: app.role,
      session: session,
    );

    if (role == UserRole.organization) {
      return _EnterpriseOrgHome(
        userName: app.userName,
        companyName: app.companyName,
        onSignOut: _signOut,
      );
    }

    if (role != UserRole.homeowner) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(KooyohSpacing.gutter),
          child: Text(
            AuthContent.homeownerLoginOnly,
            textAlign: TextAlign.center,
            style: KooyohTextStyles.body(),
          ),
        ),
      );
    }

    final idx = app.webSidebarIndex;
    final Widget body = switch (idx) {
      1 => const HomeownerIntakePage(),
      2 => const AiChatPage(),
      3 => HomeownerWalletPage(
          userName: app.userName,
          kyhBalance: app.kyhBalance,
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
        kyhBalance: app.kyhBalance,
        onNavTap: app.setWebSidebarIndex,
        onSignOut: _signOut,
        child: body,
      ),
    );
  }
}

class _EnterpriseOrgHome extends StatelessWidget {
  const _EnterpriseOrgHome({
    required this.userName,
    required this.companyName,
    required this.onSignOut,
  });

  final String userName;
  final String companyName;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EnterpriseContent.orgPortalTitle),
        actions: [
          TextButton(
            onPressed: onSignOut,
            child: Text(
              EnterpriseContent.orgPortalSignOut,
              style: KooyohTextStyles.bodyBold(color: KooyohColors.accent),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KooyohSpacing.gutter),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (companyName.isNotEmpty)
                  Text(
                    companyName,
                    style: KooyohTextStyles.sectionHeading(),
                  ),
                if (userName.isNotEmpty) ...[
                  const SizedBox(height: KooyohSpacing.sm),
                  Text(userName, style: KooyohTextStyles.body()),
                ],
                const SizedBox(height: KooyohSpacing.lg),
                Text(
                  EnterpriseContent.orgPortalBody,
                  style: KooyohTextStyles.body(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebHelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(KooyohSpacing.gutter),
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
              const SizedBox(height: KooyohSpacing.md),
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

enum _MobilePublic {
  home,
  designChat,
  enterprise,
  enterpriseAuth,
  designSummary,
  login,
  signup,
}

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
  _MobilePublic? _loginReturnTarget;

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
            initialSignupMode: false,
            onBack: () {
              setState(() {
                _pub = _loginReturnTarget ?? _MobilePublic.home;
                _loginReturnTarget = null;
              });
            },
          );
        case _MobilePublic.signup:
          return MobileAuth(
            initialSignupMode: true,
            onBack: () {
              setState(() {
                _pub = _loginReturnTarget ?? _MobilePublic.home;
                _loginReturnTarget = null;
              });
            },
          );
        case _MobilePublic.enterpriseAuth:
          return EnterpriseAuthPage(
            onHomeTap: () => setState(() => _pub = _MobilePublic.home),
            onBusinesses: () =>
                setState(() => _pub = _MobilePublic.enterprise),
            onEnterprise: () =>
                setState(() => _pub = _MobilePublic.enterpriseAuth),
          );
        case _MobilePublic.enterprise:
          return BusinessSolutionsPage(
            onHomeTap: () => setState(() => _pub = _MobilePublic.home),
            onBusinesses: () =>
                setState(() => _pub = _MobilePublic.enterprise),
            onEnterprise: () =>
                setState(() => _pub = _MobilePublic.enterpriseAuth),
          );
        case _MobilePublic.designChat:
          return AiChatPage(
            designFlowMode: true,
            onBackTap: () => setState(() => _pub = _MobilePublic.home),
            onOpenHomeownerLogin: () => setState(() {
              _loginReturnTarget = _MobilePublic.designChat;
              _pub = _MobilePublic.login;
            }),
            onOpenHomeownerSignup: () => setState(() {
              _loginReturnTarget = _MobilePublic.designChat;
              _pub = _MobilePublic.signup;
            }),
          );
        case _MobilePublic.designSummary:
          return Scaffold(
            appBar: AppBar(
              title: Text(HomeownerDesignSummaryContent.title),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    setState(() => _pub = _MobilePublic.designChat),
              ),
            ),
            body: const HomeownerDesignResultPage(),
          );
        case _MobilePublic.home:
          return Scaffold(
            backgroundColor: KooyohColors.background,
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(KooyohSpacing.gutter),
                children: [
                  const SizedBox(height: KooyohSpacing.lg),
                  Text(
                    LandingContent.heroTitle,
                    style: KooyohTextStyles.hero(),
                  ),
                  const SizedBox(height: KooyohSpacing.md),
                  Text(LandingContent.heroBody,
                      style: KooyohTextStyles.body()),
                  const SizedBox(height: KooyohSpacing.xl),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _pub = _MobilePublic.designChat),
                    child: Text(LandingContent.heroPrimaryCta,
                        style: KooyohTextStyles.bodyBold(color: Colors.white)),
                  ),
                  const SizedBox(height: KooyohSpacing.md),
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _pub = _MobilePublic.enterprise),
                    child: Text(
                      NavigationContent.navBusinesses,
                      style: KooyohTextStyles.bodyBold(),
                    ),
                  ),
                  const SizedBox(height: KooyohSpacing.sm),
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _pub = _MobilePublic.enterpriseAuth),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: KooyohColors.accent),
                    ),
                    child: Text(
                      NavigationContent.preAuthEnterprise,
                      style: KooyohTextStyles.bodyBold(color: KooyohColors.accent),
                    ),
                  ),
                  const SizedBox(height: KooyohSpacing.md),
                  OutlinedButton(
                    onPressed: () => setState(() {
                      _loginReturnTarget = null;
                      _pub = _MobilePublic.login;
                    }),
                    child: Text(HomeownerDashboardContent.myProjectsPageTitle,
                        style: KooyohTextStyles.bodyBold()),
                  ),
                ],
              ),
            ),
          );
      }
    }

    final role = resolvedNavigationRole(
      authenticated: app.isAuthenticated,
      appRole: app.role,
      session: session,
    );

    if (role == UserRole.organization) {
      return _EnterpriseOrgHome(
        userName: app.userName,
        companyName: app.companyName,
        onSignOut: _signOut,
      );
    }

    if (role != UserRole.homeowner) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(KooyohSpacing.gutter),
          child: Text(
            AuthContent.homeownerLoginOnly,
            textAlign: TextAlign.center,
            style: KooyohTextStyles.body(),
          ),
        ),
      );
    }

    final idx = app.mobileNavIndex;
    final body = switch (idx) {
      1 => const HomeownerIntakePage(),
      2 => const AiChatPage(),
      3 => HomeownerWalletPage(
          userName: app.userName,
          kyhBalance: app.kyhBalance,
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
