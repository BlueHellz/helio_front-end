import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';
import 'package:kooyoh_app/core/shell/web/homeowner_web_chrome.dart';
import 'package:kooyoh_app/core/illustrations/geometric_illustrations.dart';

// ─────────────────────────────────────────────
// KOO-YOH — EV Charging info page (web)
// CTA-only public landing. Apply-as-host flow comes later.
// ─────────────────────────────────────────────

class EvInfoPage extends StatelessWidget {
  const EvInfoPage({
    super.key,
    this.onApplyAsHost,
    this.onHomeTap,
    this.onBusinesses,
    this.onEnterprise,
  });

  final VoidCallback? onApplyAsHost;
  final VoidCallback? onHomeTap;
  final VoidCallback? onBusinesses;
  final VoidCallback? onEnterprise;

  @override
  Widget build(BuildContext context) {
    return HomeownerPublicChrome(
      onHomeTap: onHomeTap,
      onBusinesses: onBusinesses ?? () {},
      onEnterprise: onEnterprise ?? () {},
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: KooyohSpacing.containerMax),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.gutter),
            child: EvProgramBody(onApplyAsHost: onApplyAsHost),
          ),
        ),
      ),
    );
  }
}

/// EV host program content without public chrome (e.g. landing inline).
class EvProgramBody extends StatelessWidget {
  const EvProgramBody({super.key, this.onApplyAsHost});

  final VoidCallback? onApplyAsHost;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: KooyohSpacing.xl),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: const IsometricEvCarChargerIllustration(
              width: 400,
              height: 200,
            ),
          ),
        ),
        const SizedBox(height: KooyohSpacing.lg),
        _EvHero(onApplyAsHost: onApplyAsHost),
        const SizedBox(height: KooyohSpacing.xl),
        const _EvWhy(),
        const SizedBox(height: KooyohSpacing.lg),
        _EvNetworkSection(),
        const SizedBox(height: KooyohSpacing.xl),
        _EvCta(onApplyAsHost: onApplyAsHost),
        const SizedBox(height: KooyohSpacing.xl),
      ],
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
            color: KooyohColors.surface,
            border: Border.all(color: KooyohColors.border),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(EvHostContent.heroEyebrow,
              style: KooyohTextStyles.captionBold(
                  color: KooyohColors.textBody)),
        ),
        const SizedBox(height: KooyohSpacing.md),
        Text(EvHostContent.heroTitle, style: KooyohTextStyles.hero()),
        const SizedBox(height: KooyohSpacing.md),
        Text(
          EvHostContent.heroBody,
          style: KooyohTextStyles.body(),
        ),
        const SizedBox(height: KooyohSpacing.md),
        Wrap(
          spacing: KooyohSpacing.sm,
          runSpacing: KooyohSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              height: KooyohSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: onApplyAsHost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KooyohColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: Text(EvHostContent.applyCta,
                    style: KooyohTextStyles.bodyBold(color: Colors.white)),
              ),
            ),
            Text(EvHostContent.applicationsOpenLine,
                style: KooyohTextStyles.caption(
                    color: KooyohColors.textBody)),
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
      padding: const EdgeInsets.all(KooyohSpacing.lg),
      decoration: BoxDecoration(
        color: KooyohColors.surface,
        border: Border.all(color: KooyohColors.border),
        borderRadius: BorderRadius.circular(KooyohRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EvHostContent.networkSectionTitle,
            style: KooyohTextStyles.sectionHeading(),
          ),
          const SizedBox(height: KooyohSpacing.xs),
          Text(
            EvHostContent.networkSectionLead,
            style: KooyohTextStyles.body(),
          ),
          const SizedBox(height: KooyohSpacing.md),
          Text(
            EvHostContent.networkBullet1,
            style: KooyohTextStyles.body(),
          ),
          const SizedBox(height: KooyohSpacing.sm),
          Text(
            EvHostContent.networkBullet2,
            style: KooyohTextStyles.body(),
          ),
          const SizedBox(height: KooyohSpacing.sm),
          Text(
            EvHostContent.networkBullet3,
            style: KooyohTextStyles.body(),
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
        Text(EvHostContent.whyHostTitle, style: KooyohTextStyles.sectionHeading()),
        const SizedBox(height: KooyohSpacing.xs),
        Text(EvHostContent.whyHostSubtitle,
            style: KooyohTextStyles.body()),
        const SizedBox(height: KooyohSpacing.lg),
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
                      [w, const SizedBox(width: KooyohSpacing.gutter)])
                  .take(_items.length * 2 - 1)
                  .toList(),
            );
          }
          return Column(
            children: _items
                .map((i) =>
                    _EvCard(icon: i.$1, title: i.$2, body: i.$3))
                .expand((w) => [w, const SizedBox(height: KooyohSpacing.md)])
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
      padding: const EdgeInsets.all(KooyohSpacing.md),
      decoration: BoxDecoration(
        color: KooyohColors.surface,
        border: Border.all(color: KooyohColors.border),
        borderRadius: BorderRadius.circular(KooyohRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: KooyohColors.background,
              border: Border.all(color: KooyohColors.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 22, color: KooyohColors.accent),
          ),
          const SizedBox(height: KooyohSpacing.md),
          Text(title, style: KooyohTextStyles.cardHeading()),
          const SizedBox(height: 6),
          Text(body, style: KooyohTextStyles.body()),
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
      padding: const EdgeInsets.all(KooyohSpacing.lg),
      decoration: BoxDecoration(
        color: KooyohColors.surface,
        border: Border.all(color: KooyohColors.border),
        borderRadius: BorderRadius.circular(KooyohRadius.card),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final isWide = c.maxWidth > 760;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(EvHostContent.readyTitle,
                style: KooyohTextStyles.sectionHeading()),
            const SizedBox(height: KooyohSpacing.xs),
            Text(
                EvHostContent.readyBody,
                style: KooyohTextStyles.body()),
          ],
        );
        final right = SizedBox(
          height: KooyohSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: onApplyAsHost,
            style: ElevatedButton.styleFrom(
              backgroundColor: KooyohColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
            ),
            child: Text(EvHostContent.applyCta,
                style: KooyohTextStyles.bodyBold(color: Colors.white)),
          ),
        );
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: left),
              const SizedBox(width: KooyohSpacing.xl),
              right,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            left,
            const SizedBox(height: KooyohSpacing.md),
            right,
          ],
        );
      }),
    );
  }
}
