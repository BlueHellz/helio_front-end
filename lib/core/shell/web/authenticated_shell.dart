import 'package:flutter/material.dart';
import '../../../theme/blacklight_theme.dart';
import '../../brand/blacklight_brand_logo.dart';
import '../../content/content_registry.dart';
import 'pre_auth_shell.dart';

// ─────────────────────────────────────────────────────────
// SIDEBAR NAV ITEMS — LOCKED ORDER, NEVER CHANGES
// ─────────────────────────────────────────────────────────
class _SidebarItem {
  final String label;
  final IconData icon;
  const _SidebarItem(this.label, this.icon);
}

/// Homeowner: no CRM (consumer product only).
const _homeownerSidebarItems = [
  _SidebarItem(NavigationContent.sidebarProjects, Icons.folder_outlined),
  _SidebarItem(NavigationContent.sidebarNewDesign, Icons.add_circle_outline),
  _SidebarItem(NavigationContent.sidebarWallet, Icons.account_balance_wallet_outlined),
  _SidebarItem(NavigationContent.sidebarSettings, Icons.settings_outlined),
  _SidebarItem(NavigationContent.sidebarHelp, Icons.help_outline),
];

/// Business / installer — order MUST match `_OrgFlow` indices in `router.dart`:
/// 0 Projects, 1 New Design, 2 CRM, 3 Wallet, 4 Settings (hub), 5 Help.
const _orgSidebarItems = [
  _SidebarItem(NavigationContent.sidebarProjects, Icons.folder_outlined),
  _SidebarItem(NavigationContent.sidebarNewDesign, Icons.add_circle_outline),
  _SidebarItem(NavigationContent.sidebarCrm, Icons.view_kanban_outlined),
  _SidebarItem(NavigationContent.sidebarWallet, Icons.account_balance_wallet_outlined),
  _SidebarItem(NavigationContent.sidebarSettings, Icons.settings_outlined),
  _SidebarItem(NavigationContent.sidebarHelp, Icons.help_outline),
];

/// MODE B — Authenticated shell: sidebar (240px) + content + footer
class AuthenticatedShell extends StatelessWidget {
  final Widget child;
  final int activeIndex;
  /// `true` = business (installer) nav including CRM. Homeowners never see CRM.
  final bool isOrganization;
  final String userName;
  final double hlioBalance;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onSignOut;

  const AuthenticatedShell({
    super.key,
    required this.child,
    required this.activeIndex,
    this.isOrganization = false,
    this.userName = '',
    this.hlioBalance = 0.0,
    this.onNavTap,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      body: Row(
        children: [
          _Sidebar(
            isOrganization: isOrganization,
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
                Expanded(
                  child: child,
                ),
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
  final bool isOrganization;
  final int activeIndex;
  final String userName;
  final double hlioBalance;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onSignOut;

  const _Sidebar({
    required this.isOrganization,
    required this.activeIndex,
    required this.userName,
    required this.hlioBalance,
    this.onNavTap,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: BlackLightSpacing.sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: BlackLightColors.sidebarBg,
        border:
            Border(right: BorderSide(color: BlackLightColors.sidebarBorder)),
      ),
      child: Column(
        children: [
          // Brand header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: const BlackLightLogo(
              height: 32,
              maxWidth: 192,
            ),
          ),

          // Nav items — homeowner vs org (CRM only for orgs)
          Expanded(
            child: Column(
              children: [
                for (int i = 0;
                    i < (isOrganization
                        ? _orgSidebarItems.length
                        : _homeownerSidebarItems.length);
                    i++)
                  _SidebarNavItem(
                    item: isOrganization
                        ? _orgSidebarItems[i]
                        : _homeownerSidebarItems[i],
                    isActive: activeIndex == i,
                    onTap: () => onNavTap?.call(i),
                  ),
              ],
            ),
          ),

          // Bottom: user + sign out
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
                        color: BlackLightColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: BlackLightColors.border),
                      ),
                      child: const Icon(Icons.person_outline,
                          size: 18, color: BlackLightColors.textBody),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userName.isEmpty ? NavigationContent.shellUserFallback : userName,
                        style: BlackLightTextStyles.body(
                                color: BlackLightColors.textPrimary)
                            .copyWith(
                                fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onSignOut,
                  child: Row(
                    children: [
                      const Icon(Icons.logout_outlined,
                          size: 16, color: BlackLightColors.textCaption),
                      const SizedBox(width: 8),
                      Text(
                        NavigationContent.shellSignOut,
                        style: BlackLightTextStyles.caption(
                            color: BlackLightColors.textCaption),
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
  final _SidebarItem item;
  final bool isActive;
  final VoidCallback? onTap;

  const _SidebarNavItem({
    required this.item,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color:
              isActive ? BlackLightColors.sidebarActiveBg : Colors.transparent,
          border: isActive
              ? const Border(
                  left: BorderSide(
                      color: BlackLightColors.sidebarActiveText, width: 3),
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
                  ? BlackLightColors.sidebarActiveText
                  : BlackLightColors.sidebarInactiveText,
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: BlackLightTextStyles.body(
                color: isActive
                    ? BlackLightColors.sidebarActiveText
                    : BlackLightColors.sidebarInactiveText,
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
