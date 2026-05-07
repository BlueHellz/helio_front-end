import 'package:flutter/material.dart';

import '../../../theme/kooyoh_theme.dart';
import '../../brand/blacklight_brand_logo.dart';
import '../../content/content_registry.dart';
import '../../ui/app_feedback.dart';

/// Public marketing layout: top navbar + scrollable body + shared footer.
class HomeownerPublicChrome extends StatelessWidget {
  const HomeownerPublicChrome({
    super.key,
    required this.child,
    this.onHomeTap,
    required this.onBusinesses,
    required this.onEnterprise,
  });

  final Widget child;
  final VoidCallback? onHomeTap;
  final VoidCallback onBusinesses;
  final VoidCallback onEnterprise;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PublicNavbar(
            onHomeTap: onHomeTap,
            onBusinesses: onBusinesses,
            onEnterprise: onEnterprise,
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
    this.onHomeTap,
    required this.onBusinesses,
    required this.onEnterprise,
  });

  final VoidCallback? onHomeTap;
  final VoidCallback onBusinesses;
  final VoidCallback onEnterprise;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: KooyohSpacing.navbarHeight,
      decoration: const BoxDecoration(
        color: KooyohColors.surface,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: KooyohSpacing.containerMax),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.gutter),
            child: Row(
              children: [
                MouseRegion(
                  cursor: onHomeTap == null
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onHomeTap,
                    child: const BlackLightLogo(height: 46, maxWidth: 260),
                  ),
                ),
                const Spacer(),
                _PublicNavPill(
                  label: NavigationContent.navBusinesses,
                  primary: false,
                  onTap: onBusinesses,
                ),
                const SizedBox(width: KooyohSpacing.sm),
                _PublicNavPill(
                  label: NavigationContent.preAuthEnterprise,
                  primary: true,
                  onTap: onEnterprise,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PublicNavPill extends StatefulWidget {
  const _PublicNavPill({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  State<_PublicNavPill> createState() => _PublicNavPillState();
}

class _PublicNavPillState extends State<_PublicNavPill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final borderW = _hover ? 2.0 : 1.5;
    final accentBorder =
        Border.all(color: KooyohColors.accent, width: borderW);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hover ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 160),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: KooyohSpacing.inputHeightMobile,
            padding: const EdgeInsets.symmetric(horizontal: KooyohSpacing.md),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.primary ? KooyohColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(KooyohSpacing.inputHeightMobile / 2),
              border: widget.primary
                  ? Border.all(
                      color: _hover ? KooyohColors.accent : KooyohColors.accent,
                      width: borderW,
                    )
                  : accentBorder,
            ),
            child: Text(
              widget.label,
              style: KooyohTextStyles.captionBold(
                color:
                    widget.primary ? Colors.white : KooyohColors.accent,
              ).copyWith(letterSpacing: 0.6, fontSize: 12),
            ),
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
      height: KooyohSpacing.footerHeight,
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
    this.kyhBalance = 0.0,
    this.onNavTap,
    this.onSignOut,
  });

  final Widget child;
  final int activeIndex;
  final String userName;
  final double kyhBalance;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KooyohAdaptive.background(context),
      body: Row(
        children: [
          _Sidebar(
            activeIndex: activeIndex,
            userName: userName,
            kyhBalance: kyhBalance,
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
    required this.kyhBalance,
    this.onNavTap,
    this.onSignOut,
  });

  final int activeIndex;
  final String userName;
  final double kyhBalance;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KooyohSpacing.sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: KooyohAdaptive.sidebarBg(context),
        border: Border(
          right: BorderSide(color: KooyohAdaptive.sidebarBorder(context)),
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: BlackLightLogo(height: 42, maxWidth: 220),
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
                        color: KooyohAdaptive.surface(context),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: KooyohAdaptive.border(context)),
                      ),
                      child: Icon(Icons.person_outline,
                          size: 18,
                          color: KooyohAdaptive.textBody(context)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userName.isEmpty
                            ? NavigationContent.shellUserFallback
                            : userName,
                        style: KooyohTextStyles.body(
                                color: KooyohAdaptive.textPrimary(context))
                            .copyWith(
                                fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (kyhBalance > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${WalletContent.kyhTicker} ${kyhBalance.toStringAsFixed(2)}',
                    style: KooyohTextStyles.caption(
                        color: KooyohAdaptive.textCaption(context)),
                  ),
                ],
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onSignOut,
                  child: Row(
                    children: [
                      Icon(Icons.logout_outlined,
                          size: 16,
                          color: KooyohAdaptive.textCaption(context)),
                      const SizedBox(width: 8),
                      Text(
                        NavigationContent.shellSignOut,
                        style: KooyohTextStyles.caption(
                            color: KooyohAdaptive.textCaption(context)),
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
                  : KooyohAdaptive.textBody(context),
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: KooyohTextStyles.body(
                color: isActive
                    ? context.colors.primary
                    : KooyohAdaptive.textBody(context),
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
