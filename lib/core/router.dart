import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import 'package:blacklight_app/core/content/content_registry.dart';

import 'app_state.dart';
import 'providers/session_providers.dart';
import 'ui/app_feedback.dart';

// Web shells
import 'shell/web/authenticated_shell.dart';

// Homeowner (web pre-auth + homeowner flows)
import '../features/homeowner/landing_page.dart';
import '../features/homeowner/auth_page.dart';
import '../features/homeowner/dashboard_page.dart';
import '../features/homeowner/intake_page.dart';
import '../features/homeowner/chat_page.dart';

// Public sub-pages
import '../features/drone_ops/web/drone_ops_info_page.dart';
import '../features/pool_funding/web/pool_info_page.dart';
import '../features/ev/ev_info_page.dart';

// Org (installer)
import '../features/org/projects_page.dart';
import '../features/org/new_project_page.dart';
import '../features/org/crm_board_page.dart';
import '../features/org/org_settings_hub_page.dart';

import '../features/installer/mobile_shell.dart';
import '../features/installer/mobile_auth.dart';
import '../features/installer/mobile_settings.dart';

// Drone operator (mobile)
import '../features/drone_ops/mobile/drone_operator_shell.dart';
import '../features/drone_ops/mobile/drone_jobs_screen.dart';
import '../features/drone_ops/mobile/drone_capture_screen.dart';
import '../features/drone_ops/mobile/drone_earnings_screen.dart';
import '../features/drone_ops/mobile/drone_profile_screen.dart';

// Shared settings
import 'settings/settings_wallet.dart';

// ─────────────────────────────────────────────
// ROOT ROUTER — decides platform + auth routing
// ─────────────────────────────────────────────
class BlackLightRouter extends ConsumerWidget {
  const BlackLightRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = context.watch<BlackLightAppState>();

    if (kIsWeb) {
      return _WebRouter(state: state, ref: ref);
    } else {
      return _MobileRouter(state: state, ref: ref);
    }
  }
}

// ─────────────────────────────────────────────
// WEB ROUTER
// ─────────────────────────────────────────────
class _WebRouter extends StatelessWidget {
  final BlackLightAppState state;
  final WidgetRef ref;

  const _WebRouter({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (!state.isAuthenticated) {
      return _WebPreAuthFlow(state: state);
    }
    if (state.role == UserRole.homeowner) {
      return _HomeownerFlow(state: state, ref: ref);
    }
    return _OrgFlow(state: state, ref: ref);
  }
}

enum _PreAuthPage {
  landing,
  droneOps,
  pool,
  ev,
  auth,
}

class _WebPreAuthFlow extends StatefulWidget {
  final BlackLightAppState state;

  const _WebPreAuthFlow({required this.state});

  @override
  State<_WebPreAuthFlow> createState() => _WebPreAuthFlowState();
}

class _WebPreAuthFlowState extends State<_WebPreAuthFlow> {
  _PreAuthPage _page = _PreAuthPage.landing;

  void _go(_PreAuthPage page) => setState(() => _page = page);

  @override
  Widget build(BuildContext context) {
    switch (_page) {
      case _PreAuthPage.auth:
        return AuthPage(
          onHomeTap: () => _go(_PreAuthPage.landing),
          onNavbarSignIn: () => _go(_PreAuthPage.auth),
        );
      case _PreAuthPage.droneOps:
        return DroneOpsInfoPage(
          onHomeTap: () => _go(_PreAuthPage.landing),
          onSignIn: () => _go(_PreAuthPage.auth),
          onApplicationApproved: (role) => widget.state.signIn(role: role),
        );
      case _PreAuthPage.pool:
        return PoolInfoPage(
          onHomeTap: () => _go(_PreAuthPage.landing),
          onSignIn: () => _go(_PreAuthPage.auth),
          onJoinWaitlist: () => _go(_PreAuthPage.auth),
        );
      case _PreAuthPage.ev:
        return EvInfoPage(
          onHomeTap: () => _go(_PreAuthPage.landing),
          onSignIn: () => _go(_PreAuthPage.auth),
          onApplyAsHost: () => _go(_PreAuthPage.auth),
        );
      case _PreAuthPage.landing:
        return LandingPage(
          onHomeTap: () => _go(_PreAuthPage.landing),
          onGetStarted: () => _go(_PreAuthPage.auth),
          onSignIn: () => _go(_PreAuthPage.auth),
          onOpenDroneOps: () => _go(_PreAuthPage.droneOps),
          onOpenPool: () => _go(_PreAuthPage.pool),
          onOpenEv: () => _go(_PreAuthPage.ev),
        );
    }
  }
}

class _HomeownerFlow extends StatefulWidget {
  final BlackLightAppState state;
  final WidgetRef ref;

  const _HomeownerFlow({required this.state, required this.ref});

  @override
  State<_HomeownerFlow> createState() => _HomeownerFlowState();
}

class _HomeownerFlowState extends State<_HomeownerFlow> {
  void _signOut() {
    widget.ref.read(sessionProvider.notifier).clear();
    widget.state.signOut();
  }

  void _openWalletConnect(BlackLightAppState state) {
    AppFeedback.showWalletConnectDialog(
      context,
      onAddress: (addr) {
        state.connectWallet(addr);
        AppFeedback.snack(context, RouterStrings.walletSavedSession);
      },
    );
  }

  Future<void> _editName(BlackLightAppState state) async {
    final v = await AppFeedback.showEditStringDialog(
      context,
      title: RouterStrings.editFullNameTitle,
      initial: state.userName,
    );
    if (v != null && v.isNotEmpty) state.updateLocalProfile(userName: v);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final idx = state.webSidebarIndex;

    final Widget contentBody = switch (idx) {
      1 => const HomeownerIntakePage(),
      2 => SettingsWallet(
          userName: state.userName,
          hlioBalance: state.hlioBalance,
          onConnectWallet: () => _openWalletConnect(state),
          onSignOut: _signOut,
          onEditUserName: () => _editName(state),
          onEditEmail: () => AppFeedback.comingSoon(
                context,
                feature: FeedbackStrings.featureEmailChanges,
              ),
        ),
      3 => SettingsWallet(
          userName: state.userName,
          hlioBalance: state.hlioBalance,
          onSignOut: _signOut,
          onConnectWallet: () => _openWalletConnect(state),
          onEditUserName: () => _editName(state),
          onEditEmail: () => AppFeedback.comingSoon(
                context,
                feature: FeedbackStrings.featureEmailChanges,
              ),
        ),
      4 => const HomeownerChatPage(),
      _ => const HomeownerDashboardPage(),
    };

    return AuthenticatedShell(
      activeIndex: idx,
      isOrganization: false,
      userName: state.userName,
      hlioBalance: state.hlioBalance,
      onNavTap: state.setWebSidebarIndex,
      onSignOut: _signOut,
      child: contentBody,
    );
  }
}

class _OrgFlow extends StatefulWidget {
  final BlackLightAppState state;
  final WidgetRef ref;

  const _OrgFlow({required this.state, required this.ref});

  @override
  State<_OrgFlow> createState() => _OrgFlowState();
}

class _OrgFlowState extends State<_OrgFlow> {
  void _signOut() {
    widget.ref.read(sessionProvider.notifier).clear();
    widget.state.signOut();
  }

  void _openWalletConnect(BlackLightAppState state) {
    AppFeedback.showWalletConnectDialog(
      context,
      onAddress: (addr) {
        state.connectWallet(addr);
        AppFeedback.snack(context, RouterStrings.walletSavedSession);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final idx = state.webSidebarIndex;

    final Widget contentBody = switch (idx) {
      1 => const OrgNewProjectPage(),
      2 => const CrmBoardPage(),
      3 => SettingsWallet(
          userName: state.userName,
          companyName: state.companyName,
          hlioBalance: state.hlioBalance,
          onConnectWallet: () => _openWalletConnect(state),
          onSignOut: _signOut,
          onEditUserName: () async {
            final v = await AppFeedback.showEditStringDialog(
              context,
              title: RouterStrings.editFullNameTitle,
              initial: state.userName,
            );
            if (v != null && v.isNotEmpty) {
              state.updateLocalProfile(userName: v);
            }
          },
          onEditEmail: () => AppFeedback.comingSoon(
                context,
                feature: FeedbackStrings.featureEmailChanges,
              ),
          onEditCompany: () async {
            final v = await AppFeedback.showEditStringDialog(
              context,
              title: RouterStrings.editCompanyNameTitle,
              initial: state.companyName,
            );
            if (v != null) state.updateLocalProfile(companyName: v);
          },
        ),
      4 => const OrgSettingsHubPage(),
      5 => SettingsWallet(
          userName: state.userName,
          companyName: state.companyName,
          onSignOut: _signOut,
          onConnectWallet: () => _openWalletConnect(state),
          onEditUserName: () async {
            final v = await AppFeedback.showEditStringDialog(
              context,
              title: RouterStrings.editFullNameTitle,
              initial: state.userName,
            );
            if (v != null && v.isNotEmpty) {
              state.updateLocalProfile(userName: v);
            }
          },
          onEditEmail: () => AppFeedback.comingSoon(
                context,
                feature: FeedbackStrings.featureEmailChanges,
              ),
          onEditCompany: () async {
            final v = await AppFeedback.showEditStringDialog(
              context,
              title: RouterStrings.editCompanyNameTitle,
              initial: state.companyName,
            );
            if (v != null) state.updateLocalProfile(companyName: v);
          },
        ),
      _ => OrgProjectsPage(
          orgName: state.companyName,
          walletBalance: state.hlioBalance,
        ),
    };

    return AuthenticatedShell(
      activeIndex: idx,
      isOrganization: true,
      userName: state.userName,
      hlioBalance: state.hlioBalance,
      onNavTap: state.setWebSidebarIndex,
      onSignOut: _signOut,
      child: contentBody,
    );
  }
}

// ─────────────────────────────────────────────
// MOBILE ROUTER
// ─────────────────────────────────────────────
class _MobileRouter extends StatelessWidget {
  final BlackLightAppState state;
  final WidgetRef ref;

  const _MobileRouter({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (!state.isAuthenticated) {
      return MobileAuth();
    }
    if (state.role == UserRole.droneOperator) {
      return _MobileDroneOperatorFlow(state: state, ref: ref);
    }
    return _MobileAuthenticatedFlow(state: state, ref: ref);
  }
}

class _MobileAuthenticatedFlow extends StatefulWidget {
  final BlackLightAppState state;
  final WidgetRef ref;

  const _MobileAuthenticatedFlow({required this.state, required this.ref});

  @override
  State<_MobileAuthenticatedFlow> createState() =>
      _MobileAuthenticatedFlowState();
}

class _MobileAuthenticatedFlowState extends State<_MobileAuthenticatedFlow> {
  void _signOut() {
    widget.ref.read(sessionProvider.notifier).clear();
    widget.state.signOut();
  }

  void _openWallet(BlackLightAppState state) {
    AppFeedback.showWalletConnectDialog(
      context,
      onAddress: (addr) {
        state.connectWallet(addr);
        AppFeedback.snack(context, RouterStrings.walletSavedSession);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final idx = state.mobileNavIndex;

    if (state.role == UserRole.homeowner) {
      final body = switch (idx) {
        1 => const HomeownerIntakePage(),
        2 => const HomeownerChatPage(),
        3 => MobileSettings(
            userName: state.userName,
            companyName: state.companyName,
            hlioBalance: state.hlioBalance,
            walletAddress: state.walletAddress,
            onConnectWallet: () => _openWallet(state),
            onSignOut: _signOut,
          ),
        _ => const HomeownerDashboardPage(),
      };
      return MobileShell(
        activeIndex: idx,
        onNavTap: state.setMobileNavIndex,
        child: body,
      );
    }

    final body = switch (idx) {
      1 => const OrgNewProjectPage(),
      2 => const CrmBoardPage(),
      3 => MobileSettings(
          userName: state.userName,
          companyName: state.companyName,
          hlioBalance: state.hlioBalance,
          walletAddress: state.walletAddress,
          onConnectWallet: () => _openWallet(state),
          onSignOut: _signOut,
        ),
      _ => OrgProjectsPage(
          orgName: state.companyName,
          walletBalance: state.hlioBalance,
        ),
    };

    return MobileShell(
      activeIndex: idx,
      onNavTap: state.setMobileNavIndex,
      child: body,
    );
  }
}

// ─────────────────────────────────────────────
// MOBILE DRONE-OPERATOR FLOW
// ─────────────────────────────────────────────
class _MobileDroneOperatorFlow extends StatefulWidget {
  final BlackLightAppState state;
  final WidgetRef ref;

  const _MobileDroneOperatorFlow({required this.state, required this.ref});

  @override
  State<_MobileDroneOperatorFlow> createState() =>
      _MobileDroneOperatorFlowState();
}

class _MobileDroneOperatorFlowState extends State<_MobileDroneOperatorFlow> {
  bool _showCapture = false;

  void _signOut() {
    widget.ref.read(sessionProvider.notifier).clear();
    widget.state.signOut();
  }

  void _openWallet(BlackLightAppState state) {
    AppFeedback.showWalletConnectDialog(
      context,
      onAddress: (addr) {
        state.connectWallet(addr);
        AppFeedback.snack(context, RouterStrings.walletSavedSession);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final idx = state.droneOperatorNavIndex;

    // Full-screen viewfinder takes precedence over the tabbed shell.
    if (_showCapture) {
      return DroneCaptureScreen(
        onClose: () => setState(() => _showCapture = false),
      );
    }

    Widget body;
    switch (idx) {
      case 0:
        body = const DroneJobsScreen();
        break;
      case 2:
        body = DroneEarningsScreen(hlioBalance: state.hlioBalance);
        break;
      case 3:
        body = DroneProfileScreen(
          operatorName: state.userName,
          walletAddress: state.walletAddress,
          onConnectWallet: () => _openWallet(state),
          onSignOut: _signOut,
        );
        break;
      default:
        // Capture (idx == 1) opens as a full-screen overlay; the underlying
        // tab falls back to Jobs so the back state is consistent.
        body = const DroneJobsScreen();
    }

    return DroneOperatorShell(
      activeIndex: idx,
      onNavTap: (i) {
        if (i == 1) {
          // Tapping Capture launches the viewfinder overlay rather than
          // swapping the body — the tab itself never "stays" selected.
          setState(() => _showCapture = true);
          return;
        }
        state.setDroneOperatorNavIndex(i);
      },
      child: body,
    );
  }
}
