import 'package:flutter/material.dart';

import '../../../theme/limye_theme.dart';
import '../../brand/blacklight_brand_logo.dart';
import '../../content/content_registry.dart';
import '../../ui/app_feedback.dart';

/// Public marketing layout: top navbar + scrollable body + shared footer.
class HomeownerPublicChrome extends StatelessWidget {
  const HomeownerPublicChrome({
    super.key,
    required this.child,
    this.activeNavIndex = 0,
    this.onHomeTap,
    this.onMyProjects,
    this.onSignIn,
  });

  final Widget child;
  final int activeNavIndex;
  final VoidCallback? onHomeTap;
  final VoidCallback? onMyProjects;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PublicNavbar(
            activeIndex: activeNavIndex,
            onHomeTap: onHomeTap,
            onMyProjects: onMyProjects,
            onSignIn: onSignIn,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  child,
                  const BlackLightFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicNavbar extends StatelessWidget {
  const _PublicNavbar({
    required this.activeIndex,
    this.onHomeTap,
    this.onMyProjects,
    this.onSignIn,
  });

  final int activeIndex;
  final VoidCallback? onHomeTap;
  final VoidCallback? onMyProjects;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LimyeSpacing.navbarHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: LimyeSpacing.containerMax),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: LimyeSpacing.gutter),
            child: Row(
              children: [
                MouseRegion(
                  cursor: onHomeTap == null
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onHomeTap,
                    child: const BlackLightLogo(height: 36, maxWidth: 220),
                  ),
                ),
                const Spacer(),
                _NavLink(
                  label: NavigationContent.preAuthHomeowners,
                  isActive: activeIndex == 0,
                  onTap: onHomeTap,
                ),
                const SizedBox(width: 24),
                _NavLink(
                  label: NavigationContent.preAuthMyProjects,
                  isActive: activeIndex == 2,
                  onTap: onMyProjects,
                ),
                const SizedBox(width: 32),
                GestureDetector(
                  onTap: onSignIn,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        NavigationContent.preAuthSignIn,
                        style: LimyeTextStyles.body(
                            color: LimyeColors.accent),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: LimyeColors.accent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: LimyeSpacing.navbarHeight,
          alignment: Alignment.center,
          decoration: isActive
              ? const BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: LimyeColors.accent, width: 2),
                  ),
                )
              : null,
          child: Text(
            label,
            style: LimyeTextStyles.body(
              color: isActive
                  ? LimyeColors.accent
                  : LimyeColors.textBody,
            ).copyWith(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

/// Shared footer — used on public and authenticated homeowner web layouts.
class BlackLightFooter extends StatelessWidget {
  const BlackLightFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LimyeSpacing.footerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Center(
        child: Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(FooterContent.copyrightLine,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
            _FooterLink(
              label: FooterContent.privacyLink,
              onTap: () {
                AppFeedback.showInfoDialog(
                  context,
                  title: FooterContent.privacyDialogTitle,
                  message: FooterContent.privacyDialogMessage,
                );
              },
            ),
            _FooterLink(
              label: FooterContent.termsLink,
              onTap: () {
                AppFeedback.showInfoDialog(
                  context,
                  title: FooterContent.termsDialogTitle,
                  message: FooterContent.termsDialogMessage,
                );
              },
            ),
            _FooterLink(
              label: FooterContent.contactLink,
              onTap: () {
                AppFeedback.showInfoDialog(
                  context,
                  title: FooterContent.contactDialogTitle,
                  message: FooterContent.contactDialogMessage,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem {
  const _SidebarItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

const _homeownerSidebarItems = [
  _SidebarItem(NavigationContent.sidebarProjects, Icons.folder_outlined),
  _SidebarItem(NavigationContent.sidebarNewDesign, Icons.add_circle_outline),
  _SidebarItem(NavigationContent.sidebarMessages, Icons.chat_bubble_outline),
  _SidebarItem(NavigationContent.sidebarWallet, Icons.account_balance_wallet_outlined),
  _SidebarItem(NavigationContent.sidebarHelp, Icons.help_outline),
];

/// Indices: 0 dashboard, 1 intake, 2 chat, 3 wallet/settings, 4 help
class HomeownerAuthenticatedChrome extends StatelessWidget {
  const HomeownerAuthenticatedChrome({
    super.key,
    required this.child,
    required this.activeIndex,
    this.userName = '',
    this.hlioBalance = 0.0,
    this.onNavTap,
    this.onSignOut,
  });

  final Widget child;
  final int activeIndex;
  final String userName;
  final double hlioBalance;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LimyeAdaptive.background(context),
      body: Row(
        children: [
          _Sidebar(
            activeIndex: activeIndex,
            userName: userName,
            hlioBalance: hlioBalance,
            onNavTap: onNavTap,
            onSignOut: onSignOut,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: child),
                const BlackLightFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.activeIndex,
    required this.userName,
    required this.hlioBalance,
    this.onNavTap,
    this.onSignOut,
  });

  final int activeIndex;
  final String userName;
  final double hlioBalance;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LimyeSpacing.sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: LimyeAdaptive.sidebarBg(context),
        border: Border(
          right: BorderSide(color: LimyeAdaptive.sidebarBorder(context)),
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: BlackLightLogo(height: 32, maxWidth: 192),
          ),
          Expanded(
            child: Column(
              children: [
                for (var i = 0; i < _homeownerSidebarItems.length; i++)
                  _SidebarNavItem(
                    item: _homeownerSidebarItems[i],
                    isActive: activeIndex == i,
                    onTap: () => onNavTap?.call(i),
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: LimyeAdaptive.surface(context),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: LimyeAdaptive.border(context)),
                      ),
                      child: Icon(Icons.person_outline,
                          size: 18,
                          color: LimyeAdaptive.textBody(context)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userName.isEmpty
                            ? NavigationContent.shellUserFallback
                            : userName,
                        style: LimyeTextStyles.body(
                                color: LimyeAdaptive.textPrimary(context))
                            .copyWith(
                                fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (hlioBalance > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${WalletContent.hlioTicker} ${hlioBalance.toStringAsFixed(2)}',
                    style: LimyeTextStyles.caption(
                        color: LimyeAdaptive.textCaption(context)),
                  ),
                ],
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onSignOut,
                  child: Row(
                    children: [
                      Icon(Icons.logout_outlined,
                          size: 16,
                          color: LimyeAdaptive.textCaption(context)),
                      const SizedBox(width: 8),
                      Text(
                        NavigationContent.shellSignOut,
                        style: LimyeTextStyles.caption(
                            color: LimyeAdaptive.textCaption(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.item,
    required this.isActive,
    this.onTap,
  });

  final _SidebarItem item;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          border: isActive
              ? Border(
                  left: BorderSide(color: context.colors.primary, width: 3),
                )
              : const Border(
                  left: BorderSide(color: Colors.transparent, width: 3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: isActive
                  ? context.colors.primary
                  : LimyeAdaptive.textBody(context),
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: LimyeTextStyles.body(
                color: isActive
                    ? context.colors.primary
                    : LimyeAdaptive.textBody(context),
              ).copyWith(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
