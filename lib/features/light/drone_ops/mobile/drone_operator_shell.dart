import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/content/content_registry.dart';

// ─────────────────────────────────────────────
// BLACK LIGHT — Drone Operator (mobile) shell
// Matches the design language of the installer MobileShell, but
// with a drone-operator focused 4-tab bottom nav.
// Future layout polish: Taskez-inspired task density when operator ratings mature.
// ─────────────────────────────────────────────

class _DroneNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _DroneNavItem(this.label, this.icon, this.activeIcon);
}

const _droneNavItems = [
  _DroneNavItem(NavigationContent.droneJobs, Icons.work_outline, Icons.work),
  _DroneNavItem(NavigationContent.droneCapture, Icons.photo_camera_outlined, Icons.photo_camera),
  _DroneNavItem(NavigationContent.droneEarnings, Icons.payments_outlined, Icons.payments),
  _DroneNavItem(NavigationContent.droneProfile, Icons.person_outline, Icons.person),
];

class DroneOperatorShell extends StatelessWidget {
  final Widget child;
  final int activeIndex;
  final ValueChanged<int>? onNavTap;

  const DroneOperatorShell({
    super.key,
    required this.child,
    required this.activeIndex,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      body: child,
      bottomNavigationBar: _DroneBottomNav(
        activeIndex: activeIndex,
        onTap: onNavTap,
      ),
    );
  }
}

class _DroneBottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onTap;

  const _DroneBottomNav({required this.activeIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BlackLightColors.surface,
        border: Border(top: BorderSide(color: BlackLightColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_droneNavItems.length, (i) {
              final item = _droneNavItems[i];
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
                            : BlackLightColors.textBody,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: BlackLightTextStyles.mobileLabelBold(
                          color: isActive
                              ? BlackLightColors.accent
                              : BlackLightColors.textBody,
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

// ─────────────────────────────────────────────
// Shared portal app bar — used by every drone-operator screen
// ─────────────────────────────────────────────
class DroneOperatorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? trailing;
  final bool showAvatar;
  final VoidCallback? onMenu;

  const DroneOperatorAppBar({
    super.key,
    required this.title,
    this.trailing,
    this.showAvatar = true,
    this.onMenu,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: BlackLightColors.surface,
        border: Border(bottom: BorderSide(color: BlackLightColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BlackLightSpacing.sm),
          child: Row(
            children: [
              IconButton(
                onPressed: onMenu,
                icon: const Icon(Icons.menu, size: 22),
                color: BlackLightColors.textPrimary,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(title,
                    style: BlackLightTextStyles.mobileH2(),
                    overflow: TextOverflow.ellipsis),
              ),
              if (trailing != null) ...trailing!,
              if (showAvatar) ...[
                const SizedBox(width: 8),
                const _AvatarPlaceholder(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person_outline,
          size: 18, color: BlackLightColors.textBody),
    );
  }
}
