import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/shell/web/pre_auth_shell.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';

// ─────────────────────────────────────────────
// BLACK LIGHT — EV Charging info page (web)
// CTA-only public landing. Apply-as-host flow comes later.
// ─────────────────────────────────────────────

class EvInfoPage extends StatelessWidget {
  final VoidCallback? onApplyAsHost;
  final VoidCallback? onHomeTap;
  final VoidCallback? onSignIn;

  const EvInfoPage({
    super.key,
    this.onApplyAsHost,
    this.onHomeTap,
    this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return PreAuthShell(
      activeNavIndex: 0,
      onHomeTap: onHomeTap,
      onSignIn: onSignIn,
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: BlackLightSpacing.containerMax),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: BlackLightSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: BlackLightSpacing.xl),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: const IsometricEvCarChargerIllustration(
                      width: 400,
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(height: BlackLightSpacing.lg),
                _EvHero(onApplyAsHost: onApplyAsHost),
                const SizedBox(height: BlackLightSpacing.xl),
                const _EvWhy(),
                const SizedBox(height: BlackLightSpacing.lg),
                _EvNetworkSection(),
                const SizedBox(height: BlackLightSpacing.xl),
                _EvCta(onApplyAsHost: onApplyAsHost),
                const SizedBox(height: BlackLightSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EvHero extends StatelessWidget {
  final VoidCallback? onApplyAsHost;

  const _EvHero({this.onApplyAsHost});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: BlackLightColors.surface,
            border: Border.all(color: BlackLightColors.border),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(EvHostContent.heroEyebrow,
              style: BlackLightTextStyles.captionBold(
                  color: BlackLightColors.textBody)),
        ),
        const SizedBox(height: BlackLightSpacing.md),
        Text(EvHostContent.heroTitle, style: BlackLightTextStyles.hero()),
        const SizedBox(height: BlackLightSpacing.md),
        Text(
          EvHostContent.heroBody,
          style: BlackLightTextStyles.body(),
        ),
        const SizedBox(height: BlackLightSpacing.md),
        Wrap(
          spacing: BlackLightSpacing.sm,
          runSpacing: BlackLightSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              height: BlackLightSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: onApplyAsHost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BlackLightColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: Text(EvHostContent.applyCta,
                    style: BlackLightTextStyles.bodyBold(color: Colors.white)),
              ),
            ),
            Text(EvHostContent.applicationsOpenLine,
                style: BlackLightTextStyles.caption(
                    color: BlackLightColors.textBody)),
          ],
        ),
      ],
    );
  }
}

class _EvNetworkSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.lg),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EvHostContent.networkSectionTitle,
            style: BlackLightTextStyles.sectionHeading(),
          ),
          const SizedBox(height: BlackLightSpacing.xs),
          Text(
            EvHostContent.networkSectionLead,
            style: BlackLightTextStyles.body(),
          ),
          const SizedBox(height: BlackLightSpacing.md),
          Text(
            EvHostContent.networkBullet1,
            style: BlackLightTextStyles.body(),
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          Text(
            EvHostContent.networkBullet2,
            style: BlackLightTextStyles.body(),
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          Text(
            EvHostContent.networkBullet3,
            style: BlackLightTextStyles.body(),
          ),
        ],
      ),
    );
  }
}

class _EvWhy extends StatelessWidget {
  const _EvWhy();

  static final _items = [
    (
      Icons.bolt_outlined,
      EvHostContent.whyCard1Title,
      EvHostContent.whyCard1Body,
    ),
    (
      Icons.public_outlined,
      EvHostContent.whyCard2Title,
      EvHostContent.whyCard2Body,
    ),
    (
      Icons.shield_outlined,
      EvHostContent.whyCard3Title,
      EvHostContent.whyCard3Body,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(EvHostContent.whyHostTitle, style: BlackLightTextStyles.sectionHeading()),
        const SizedBox(height: BlackLightSpacing.xs),
        Text(EvHostContent.whyHostSubtitle,
            style: BlackLightTextStyles.body()),
        const SizedBox(height: BlackLightSpacing.lg),
        LayoutBuilder(builder: (context, c) {
          final isWide = c.maxWidth > 860;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _items
                  .map((i) => Expanded(
                      child: _EvCard(
                          icon: i.$1, title: i.$2, body: i.$3)))
                  .expand((w) =>
                      [w, const SizedBox(width: BlackLightSpacing.gutter)])
                  .take(_items.length * 2 - 1)
                  .toList(),
            );
          }
          return Column(
            children: _items
                .map((i) =>
                    _EvCard(icon: i.$1, title: i.$2, body: i.$3))
                .expand((w) => [w, const SizedBox(height: BlackLightSpacing.md)])
                .take(_items.length * 2 - 1)
                .toList(),
          );
        }),
      ],
    );
  }
}

class _EvCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _EvCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: BlackLightColors.background,
              border: Border.all(color: BlackLightColors.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 22, color: BlackLightColors.accent),
          ),
          const SizedBox(height: BlackLightSpacing.md),
          Text(title, style: BlackLightTextStyles.cardHeading()),
          const SizedBox(height: 6),
          Text(body, style: BlackLightTextStyles.body()),
        ],
      ),
    );
  }
}

class _EvCta extends StatelessWidget {
  final VoidCallback? onApplyAsHost;

  const _EvCta({this.onApplyAsHost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.lg),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final isWide = c.maxWidth > 760;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(EvHostContent.readyTitle,
                style: BlackLightTextStyles.sectionHeading()),
            const SizedBox(height: BlackLightSpacing.xs),
            Text(
                EvHostContent.readyBody,
                style: BlackLightTextStyles.body()),
          ],
        );
        final right = SizedBox(
          height: BlackLightSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: onApplyAsHost,
            style: ElevatedButton.styleFrom(
              backgroundColor: BlackLightColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
            ),
            child: Text(EvHostContent.applyCta,
                style: BlackLightTextStyles.bodyBold(color: Colors.white)),
          ),
        );
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: left),
              const SizedBox(width: BlackLightSpacing.xl),
              right,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            left,
            const SizedBox(height: BlackLightSpacing.md),
            right,
          ],
        );
      }),
    );
  }
}
