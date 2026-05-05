import 'package:limye_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:limye_app/theme/limye_theme.dart';
import 'package:limye_app/core/shell/web/homeowner_web_chrome.dart';
import 'package:limye_app/core/illustrations/geometric_illustrations.dart';

// ─────────────────────────────────────────────
// LIMYÈ — EV Charging info page (web)
// CTA-only public landing. Apply-as-host flow comes later.
// ─────────────────────────────────────────────

class EvInfoPage extends StatelessWidget {
  final VoidCallback? onApplyAsHost;
  final VoidCallback? onHomeTap;
  final VoidCallback? onMyProjects;

  const EvInfoPage({
    super.key,
    this.onApplyAsHost,
    this.onHomeTap,
    this.onMyProjects,
  });

  @override
  Widget build(BuildContext context) {
    return HomeownerPublicChrome(
      activeNavIndex: 0,
      onHomeTap: onHomeTap,
      onMyProjects: onMyProjects,
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: LimyeSpacing.containerMax),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: LimyeSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: LimyeSpacing.xl),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: const IsometricEvCarChargerIllustration(
                      width: 400,
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(height: LimyeSpacing.lg),
                _EvHero(onApplyAsHost: onApplyAsHost),
                const SizedBox(height: LimyeSpacing.xl),
                const _EvWhy(),
                const SizedBox(height: LimyeSpacing.lg),
                _EvNetworkSection(),
                const SizedBox(height: LimyeSpacing.xl),
                _EvCta(onApplyAsHost: onApplyAsHost),
                const SizedBox(height: LimyeSpacing.xl),
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
            color: LimyeColors.surface,
            border: Border.all(color: LimyeColors.border),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(EvHostContent.heroEyebrow,
              style: LimyeTextStyles.captionBold(
                  color: LimyeColors.textBody)),
        ),
        const SizedBox(height: LimyeSpacing.md),
        Text(EvHostContent.heroTitle, style: LimyeTextStyles.hero()),
        const SizedBox(height: LimyeSpacing.md),
        Text(
          EvHostContent.heroBody,
          style: LimyeTextStyles.body(),
        ),
        const SizedBox(height: LimyeSpacing.md),
        Wrap(
          spacing: LimyeSpacing.sm,
          runSpacing: LimyeSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              height: LimyeSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: onApplyAsHost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LimyeColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: Text(EvHostContent.applyCta,
                    style: LimyeTextStyles.bodyBold(color: Colors.white)),
              ),
            ),
            Text(EvHostContent.applicationsOpenLine,
                style: LimyeTextStyles.caption(
                    color: LimyeColors.textBody)),
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
      padding: const EdgeInsets.all(LimyeSpacing.lg),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        border: Border.all(color: LimyeColors.border),
        borderRadius: BorderRadius.circular(LimyeRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EvHostContent.networkSectionTitle,
            style: LimyeTextStyles.sectionHeading(),
          ),
          const SizedBox(height: LimyeSpacing.xs),
          Text(
            EvHostContent.networkSectionLead,
            style: LimyeTextStyles.body(),
          ),
          const SizedBox(height: LimyeSpacing.md),
          Text(
            EvHostContent.networkBullet1,
            style: LimyeTextStyles.body(),
          ),
          const SizedBox(height: LimyeSpacing.sm),
          Text(
            EvHostContent.networkBullet2,
            style: LimyeTextStyles.body(),
          ),
          const SizedBox(height: LimyeSpacing.sm),
          Text(
            EvHostContent.networkBullet3,
            style: LimyeTextStyles.body(),
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
        Text(EvHostContent.whyHostTitle, style: LimyeTextStyles.sectionHeading()),
        const SizedBox(height: LimyeSpacing.xs),
        Text(EvHostContent.whyHostSubtitle,
            style: LimyeTextStyles.body()),
        const SizedBox(height: LimyeSpacing.lg),
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
                      [w, const SizedBox(width: LimyeSpacing.gutter)])
                  .take(_items.length * 2 - 1)
                  .toList(),
            );
          }
          return Column(
            children: _items
                .map((i) =>
                    _EvCard(icon: i.$1, title: i.$2, body: i.$3))
                .expand((w) => [w, const SizedBox(height: LimyeSpacing.md)])
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
      padding: const EdgeInsets.all(LimyeSpacing.md),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        border: Border.all(color: LimyeColors.border),
        borderRadius: BorderRadius.circular(LimyeRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LimyeColors.background,
              border: Border.all(color: LimyeColors.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 22, color: LimyeColors.accent),
          ),
          const SizedBox(height: LimyeSpacing.md),
          Text(title, style: LimyeTextStyles.cardHeading()),
          const SizedBox(height: 6),
          Text(body, style: LimyeTextStyles.body()),
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
      padding: const EdgeInsets.all(LimyeSpacing.lg),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        border: Border.all(color: LimyeColors.border),
        borderRadius: BorderRadius.circular(LimyeRadius.card),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final isWide = c.maxWidth > 760;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(EvHostContent.readyTitle,
                style: LimyeTextStyles.sectionHeading()),
            const SizedBox(height: LimyeSpacing.xs),
            Text(
                EvHostContent.readyBody,
                style: LimyeTextStyles.body()),
          ],
        );
        final right = SizedBox(
          height: LimyeSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: onApplyAsHost,
            style: ElevatedButton.styleFrom(
              backgroundColor: LimyeColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
            ),
            child: Text(EvHostContent.applyCta,
                style: LimyeTextStyles.bodyBold(color: Colors.white)),
          ),
        );
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: left),
              const SizedBox(width: LimyeSpacing.xl),
              right,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            left,
            const SizedBox(height: LimyeSpacing.md),
            right,
          ],
        );
      }),
    );
  }
}
