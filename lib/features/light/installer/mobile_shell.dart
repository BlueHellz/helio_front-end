import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/content/content_registry.dart';

// ─────────────────────────────────────────────────────────
// BOTTOM NAV ITEMS — LOCKED ORDER, NEVER CHANGES
// ─────────────────────────────────────────────────────────
class _MobileNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _MobileNavItem(this.label, this.icon, this.activeIcon);
}

const _mobileNavItems = [
  _MobileNavItem(NavigationContent.mobileProjects, Icons.folder_outlined, Icons.folder),
  _MobileNavItem(NavigationContent.mobileNew, Icons.add_circle_outline, Icons.add_circle),
  _MobileNavItem(NavigationContent.mobileCrm, Icons.group_outlined, Icons.group),
  _MobileNavItem(NavigationContent.mobileSettings, Icons.settings_outlined, Icons.settings),
];

/// Mobile shell: bottom nav bar + content area
class MobileShell extends StatelessWidget {
  final Widget child;
  final int activeIndex;
  final ValueChanged<int>? onNavTap;

  const MobileShell({
    super.key,
    required this.child,
    required this.activeIndex,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlackLightAdaptive.background(context),
      body: child,
      bottomNavigationBar: _BlackLightBottomNav(
        activeIndex: activeIndex,
        onTap: onNavTap,
      ),
    );
  }
}

class _BlackLightBottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onTap;

  const _BlackLightBottomNav({required this.activeIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BlackLightAdaptive.surface(context),
        border: Border(
            top: BorderSide(color: BlackLightAdaptive.border(context))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_mobileNavItems.length, (i) {
              final item = _mobileNavItems[i];
              final isActive = i == activeIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap?.call(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 24,
                        color: isActive
                            ? BlackLightColors.accent
                            : BlackLightAdaptive.textBody(context),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: BlackLightTextStyles.mobileLabelBold(
                          color: isActive
                              ? BlackLightColors.accent
                              : BlackLightAdaptive.textBody(context),
                        ).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
