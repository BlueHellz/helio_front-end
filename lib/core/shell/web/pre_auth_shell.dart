import 'package:flutter/material.dart';
import '../../../theme/blacklight_theme.dart';
import '../../brand/blacklight_brand_logo.dart';
import '../../content/content_registry.dart';
import '../../ui/app_feedback.dart';

/// MODE A — Pre-Auth shell: top navbar + footer, no sidebar
class PreAuthShell extends StatelessWidget {
  final Widget child;
  final int activeNavIndex; // 0=Homeowners, 1=For Business
  final VoidCallback? onSignIn;
  final VoidCallback? onHomeTap;

  const PreAuthShell({
    super.key,
    required this.child,
    this.activeNavIndex = 0,
    this.onSignIn,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreAuthNavbar(
            activeIndex: activeNavIndex,
            onSignIn: onSignIn,
            onHomeTap: onHomeTap,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  child,
                  const _BlackLightFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreAuthNavbar extends StatelessWidget {
  final int activeIndex;
  final VoidCallback? onSignIn;
  final VoidCallback? onHomeTap;

  const _PreAuthNavbar({
    required this.activeIndex,
    this.onSignIn,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: BlackLightSpacing.navbarHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: BlackLightSpacing.containerMax),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: BlackLightSpacing.gutter),
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
                  label: NavigationContent.preAuthForBusiness,
                  isActive: activeIndex == 1,
                ),
                const SizedBox(width: 32),
                GestureDetector(
                  onTap: onSignIn,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        NavigationContent.preAuthSignIn,
                        style: BlackLightTextStyles.body(
                            color: BlackLightColors.accent),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: BlackLightColors.accent),
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
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavLink({required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: BlackLightSpacing.navbarHeight,
          alignment: Alignment.center,
          decoration: isActive
              ? const BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: BlackLightColors.accent, width: 2),
                  ),
                )
              : null,
          child: Text(
            label,
            style: BlackLightTextStyles.body(
              color: isActive
                  ? BlackLightColors.accent
                  : BlackLightColors.textBody,
            ).copyWith(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

/// Shared footer — identical on ALL screens
class _BlackLightFooter extends StatelessWidget {
  const _BlackLightFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: BlackLightSpacing.footerHeight,
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
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

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

/// Public wrapper for the shared app footer.
class BlackLightFooter extends StatelessWidget {
  const BlackLightFooter({super.key});

  @override
  Widget build(BuildContext context) => const _BlackLightFooter();
}
