import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/shell/web/homeowner_web_chrome.dart';
import 'package:limye_app/theme/limye_theme.dart';

/// Business Solutions marketing (`/enterprise`): Stitch body only — no extra chrome.
class BusinessSolutionsPage extends StatefulWidget {
  const BusinessSolutionsPage({
    super.key,
    this.onHomeTap,
    required this.onBusinesses,
    required this.onEnterprise,
  });

  final VoidCallback? onHomeTap;
  final VoidCallback onBusinesses;
  final VoidCallback onEnterprise;

  @override
  State<BusinessSolutionsPage> createState() => _BusinessSolutionsPageState();
}

class _BusinessSolutionsPageState extends State<BusinessSolutionsPage> {
  final GlobalKey _pricingSectionKey = GlobalKey();

  void _scrollToPricing() {
    final ctx = _pricingSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeownerPublicChrome(
      onHomeTap: widget.onHomeTap,
      onBusinesses: widget.onBusinesses,
      onEnterprise: widget.onEnterprise,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroArea(
            onPrimaryCta: widget.onEnterprise,
            onSecondaryCta: _scrollToPricing,
          ),
          _ProblemSection(),
          _HowItWorksSection(),
          _FeaturesSection(),
          _ComparisonSection(
            key: _pricingSectionKey,
            onEnterprise: widget.onEnterprise,
          ),
          _TestimonialsSection(),
          _FinalCtaSection(onEnterprise: widget.onEnterprise),
        ],
      ),
    );
  }
}

// ─── Layout helper ───────────────────────────────────────────────────────────

class _PageSection extends StatelessWidget {
  const _PageSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LimyeSpacing.gutter,
        vertical: LimyeSpacing.sectionPaddingVertical,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: LimyeSpacing.containerMax),
          child: child,
        ),
      ),
    );
  }
}

// ─── Hero ───────────────────────────────────────────────────────────────────

class _HeroArea extends StatelessWidget {
  const _HeroArea({
    required this.onPrimaryCta,
    required this.onSecondaryCta,
  });

  final VoidCallback onPrimaryCta;
  final VoidCallback onSecondaryCta;

  @override
  Widget build(BuildContext context) {
    final image = AspectRatio(
      aspectRatio: 16 / 9,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desiredWidth = constraints.maxWidth;
          final desiredHeight = constraints.maxHeight;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Transform.translate(
                offset: const Offset(12, 12),
                child: Container(
                  width: desiredWidth,
                  height: desiredHeight,
                  decoration: BoxDecoration(
                    color: LimyeColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: LimyeColors.accent.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: desiredWidth,
                  height: desiredHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: LimyeColors.outline, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/business_hero.png',
                    fit: BoxFit.cover,
                    semanticLabel:
                        BusinessSolutionsContent.heroImageAccessibilityLabel,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: context.colors.surfaceMuted,
                      child: Icon(
                        Icons.solar_power_rounded,
                        size: 64,
                        color: context.colors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BusinessSolutionsContent.heroTitle,
          style: LimyeTextStyles.hero(color: context.colors.onSurface),
        ),
        const SizedBox(height: LimyeSpacing.sm),
        Text(
          BusinessSolutionsContent.heroSubtitle,
          style: LimyeTextStyles.body(color: context.colors.onSurface),
        ),
        const SizedBox(height: LimyeSpacing.md),
        Wrap(
          spacing: LimyeSpacing.sm,
          runSpacing: LimyeSpacing.sm,
          children: [
            FilledButton(
              onPressed: onPrimaryCta,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                minimumSize: const Size(LimyeSpacing.tapTarget, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: LimyeSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LimyeRadius.md),
                ),
              ),
              child: Text(
                BusinessSolutionsContent.heroPrimaryCta,
                style:
                    LimyeTextStyles.bodyBold(color: context.colors.onPrimary),
              ),
            ),
            FilledButton(
              onPressed: onSecondaryCta,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.surfaceMuted,
                foregroundColor: context.colors.onSurface,
                elevation: 0,
                minimumSize: const Size(LimyeSpacing.tapTarget, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: LimyeSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LimyeRadius.md),
                ),
              ),
              child: Text(
                BusinessSolutionsContent.heroSecondaryCta,
                style:
                    LimyeTextStyles.bodyBold(color: context.colors.onSurface),
              ),
            ),
          ],
        ),
      ],
    );

    return _PageSection(
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 864;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 52,
                  child: image,
                ),
                const SizedBox(width: LimyeSpacing.lg),
                Expanded(
                  flex: 48,
                  child: copy,
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              image,
              const SizedBox(height: LimyeSpacing.lg),
              copy,
            ],
          );
        },
      ),
    );
  }
}

// ─── Problem cards ───────────────────────────────────────────────────────────

/// Max width for problem / how-it-works row cards (room for copy without cramping).
const double _kSectionCardMaxWidth = 380;

class _ProblemSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.payments_rounded,
        BusinessSolutionsContent.problemPerSeatTitle,
      ),
      (
        Icons.layers_rounded,
        BusinessSolutionsContent.problemThreeToolsTitle,
      ),
      (
        Icons.schedule_rounded,
        BusinessSolutionsContent.problemSlowProposalTitle,
      ),
    ];

    return _PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            BusinessSolutionsContent.problemsSectionTitle,
            textAlign: TextAlign.center,
            style: LimyeTextStyles.sectionHeading(
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: LimyeSpacing.sm),
          Text(
            BusinessSolutionsContent.problemsSectionSubtitle,
            textAlign: TextAlign.center,
            style: LimyeTextStyles.body(color: context.colors.onSurface),
          ),
          const SizedBox(height: LimyeSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = LimyeSpacing.cardGap;
              final w = constraints.maxWidth;
              final rowOfThree = w >= _kSectionCardMaxWidth * 3 + gap * 2;
              List<Widget> tiles(bool stretch) => [
                    for (final e in items)
                      _SmallInfoCard(
                        icon: e.$1,
                        title: e.$2,
                        caption: BusinessSolutionsContent.problemCardFixLine,
                        stretchInColumn: stretch,
                      ),
                  ];
              if (rowOfThree) {
                final list = tiles(true);
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < list.length; i++) ...[
                        if (i > 0) SizedBox(width: gap),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _kSectionCardMaxWidth,
                              ),
                              child: list[i],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              final list = tiles(false);
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < list.length; i++)
                    SizedBox(
                      width: math.min(_kSectionCardMaxWidth, w),
                      child: list[i],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.draw_rounded,
        BusinessSolutionsContent.howStep1Title,
        BusinessSolutionsContent.howStep1Body,
      ),
      (
        Icons.check_circle_rounded,
        BusinessSolutionsContent.howStep2Title,
        BusinessSolutionsContent.howStep2Body,
      ),
      (
        Icons.trending_up_rounded,
        BusinessSolutionsContent.howStep3Title,
        BusinessSolutionsContent.howStep3Body,
      ),
    ];
    return _PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            BusinessSolutionsContent.howSectionTitle,
            textAlign: TextAlign.center,
            style: LimyeTextStyles.sectionHeading(
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: LimyeSpacing.sm),
          Text(
            BusinessSolutionsContent.howSectionSubtitle,
            textAlign: TextAlign.center,
            style: LimyeTextStyles.body(color: context.colors.onSurface),
          ),
          const SizedBox(height: LimyeSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = LimyeSpacing.cardGap;
              final w = constraints.maxWidth;
              final rowOfThree = w >= _kSectionCardMaxWidth * 3 + gap * 2;
              List<Widget> tiles(bool stretch) => [
                    for (final e in items)
                      _SmallInfoCard(
                        icon: e.$1,
                        title: e.$2,
                        caption: e.$3,
                        stretchInColumn: stretch,
                      ),
                  ];
              if (rowOfThree) {
                final list = tiles(true);
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < list.length; i++) ...[
                        if (i > 0) SizedBox(width: gap),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _kSectionCardMaxWidth,
                              ),
                              child: list[i],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              final list = tiles(false);
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < list.length; i++)
                    SizedBox(
                      width: math.min(_kSectionCardMaxWidth, w),
                      child: list[i],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  static const List<
      (
        IconData icon,
        String title,
        String caption,
      )> _items = [
    (
      Icons.computer_rounded,
      BusinessSolutionsContent.featureAiDesignerTitle,
      BusinessSolutionsContent.featureAiDesignerBody,
    ),
    (
      Icons.groups_rounded,
      BusinessSolutionsContent.featureCrmTitle,
      BusinessSolutionsContent.featureCrmBody,
    ),
    (
      Icons.map_rounded,
      BusinessSolutionsContent.featureTrackingTitle,
      BusinessSolutionsContent.featureTrackingBody,
    ),
    (
      Icons.percent_rounded,
      BusinessSolutionsContent.featureSavingsTitle,
      BusinessSolutionsContent.featureSavingsBody,
    ),
    (
      Icons.description_rounded,
      BusinessSolutionsContent.featureContractTitle,
      BusinessSolutionsContent.featureContractBody,
    ),
    (
      Icons.photo_camera_rounded,
      BusinessSolutionsContent.featureDroneTitle,
      BusinessSolutionsContent.featureDroneBody,
    ),
    (
      Icons.account_balance_wallet_rounded,
      BusinessSolutionsContent.featureFundingTitle,
      BusinessSolutionsContent.featureFundingBody,
    ),
    (
      Icons.chat_rounded,
      BusinessSolutionsContent.featureCoachTitle,
      BusinessSolutionsContent.featureCoachBody,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gap = LimyeSpacing.cardGap;
    final items = _items;

    return _PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            BusinessSolutionsContent.featuresSectionTitle,
            textAlign: TextAlign.center,
            style: LimyeTextStyles.sectionHeading(
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: LimyeSpacing.sm),
          Text(
            BusinessSolutionsContent.featuresSectionSubtitle,
            textAlign: TextAlign.center,
            style: LimyeTextStyles.body(color: context.colors.onSurface),
          ),
          const SizedBox(height: LimyeSpacing.xl),
          LayoutBuilder(
            builder: (context, c) {
              final twoCol = c.maxWidth > 720;

              if (!twoCol) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) SizedBox(height: gap),
                      _FeatureInteractCard(
                        icon: items[i].$1,
                        title: items[i].$2,
                        caption: items[i].$3,
                      ),
                    ],
                  ],
                );
              }

              final left = items.sublist(0, 4);
              final right = items.sublist(4, 8);

              Widget column(List<(IconData, String, String)> slice) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < slice.length; i++) ...[
                        if (i > 0) SizedBox(height: gap),
                        _FeatureInteractCard(
                          icon: slice[i].$1,
                          title: slice[i].$2,
                          caption: slice[i].$3,
                        ),
                      ],
                    ],
                  );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: column(left)),
                  SizedBox(width: gap),
                  Expanded(child: column(right)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  const _SmallInfoCard({
    required this.icon,
    required this.title,
    required this.caption,
    this.stretchInColumn = false,
  });

  final IconData icon;
  final String title;
  final String caption;

  /// When true, fill row height allocated by [IntrinsicHeight] (How / Problem).
  final bool stretchInColumn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LimyeSpacing.cardPadding,
        vertical: LimyeSpacing.cardPadding,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: context.colors.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: stretchInColumn ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: context.colors.onSurface),
          const SizedBox(height: LimyeSpacing.sm),
          Text(
            title,
            style: LimyeTextStyles.bodyBold(color: context.colors.onSurface),
          ),
          const SizedBox(height: LimyeSpacing.xs / 2),
          Text(
            caption,
            style: LimyeTextStyles.caption(
              color: context.colors.onSurfaceMuted,
            ),
          ),
          if (stretchInColumn) const Spacer(),
        ],
      ),
    );
  }
}

/// Feature marketing card: bordered [Card], hover / long‑press elevation shadow only.
class _FeatureInteractCard extends StatefulWidget {
  const _FeatureInteractCard({
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  State<_FeatureInteractCard> createState() => _FeatureInteractCardState();
}

class _FeatureInteractCardState extends State<_FeatureInteractCard> {
  bool _hover = false;
  bool _longPressHeld = false;

  bool get _elevated => _hover || _longPressHeld;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onLongPressStart: (_) => setState(() => _longPressHeld = true),
        onLongPressEnd: (_) => setState(() => _longPressHeld = false),
        onLongPressCancel: () => setState(() => _longPressHeld = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LimyeRadius.card),
            boxShadow: _elevated
                ? const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            color: context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LimyeRadius.card),
              side: BorderSide(color: context.colors.outline, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(LimyeSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 24,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(height: LimyeSpacing.sm),
                  Text(
                    widget.title,
                    style: LimyeTextStyles.bodyBold(
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: LimyeSpacing.xs / 2),
                  Text(
                    widget.caption,
                    style: LimyeTextStyles.caption(
                      color: context.colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Comparison ─────────────────────────────────────────────────────────────

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection({
    super.key,
    required this.onEnterprise,
  });

  final VoidCallback onEnterprise;

  @override
  Widget build(BuildContext context) {
    return _PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              BusinessSolutionsContent.compareSectionTitle,
              textAlign: TextAlign.center,
              style: LimyeTextStyles.sectionHeading(
                color: context.colors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: LimyeSpacing.xl),
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth > 720;
              final free = _PricingCard(
                fillBottom: wide,
                name: BusinessSolutionsContent.compareLimyeName,
                tagline: BusinessSolutionsContent.compareLimyeTagline,
                priceLabel: BusinessSolutionsContent.compareLimyePrice,
                bullets: const [
                  BusinessSolutionsContent.compareLimyeBullet1,
                  BusinessSolutionsContent.compareLimyeBullet2,
                  BusinessSolutionsContent.compareLimyeBullet3,
                ],
                primary: true,
                ctaLabel: BusinessSolutionsContent.compareLimyeCta,
                onCta: onEnterprise,
              );
              final noir = _PricingCard(
                fillBottom: wide,
                name: BusinessSolutionsContent.compareNoirName,
                tagline: BusinessSolutionsContent.compareNoirTagline,
                priceLabel: BusinessSolutionsContent.compareNoirPrice,
                bullets: const [
                  BusinessSolutionsContent.compareNoirBullet1,
                  BusinessSolutionsContent.compareNoirBullet2,
                  BusinessSolutionsContent.compareNoirBullet3,
                  BusinessSolutionsContent.compareNoirBullet4,
                ],
                primary: false,
                ctaLabel: BusinessSolutionsContent.compareNoirCta,
                onCta: onEnterprise,
              );
              if (wide) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: free),
                      SizedBox(width: LimyeSpacing.gutter),
                      Expanded(child: noir),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  free,
                  SizedBox(height: LimyeSpacing.gutter),
                  noir,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.fillBottom,
    required this.name,
    required this.tagline,
    required this.priceLabel,
    required this.bullets,
    required this.primary,
    required this.ctaLabel,
    required this.onCta,
  });

  final bool fillBottom;
  final String name;
  final String tagline;
  final String priceLabel;
  final List<String> bullets;
  final bool primary;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LimyeSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: context.colors.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            name,
            style: LimyeTextStyles.cardHeading(color: context.colors.onSurface),
          ),
          const SizedBox(height: LimyeSpacing.sm),
          Text(
            tagline,
            style: LimyeTextStyles.body(color: context.colors.onSurfaceMuted),
          ),
          const SizedBox(height: LimyeSpacing.md),
          Text(
            priceLabel,
            style: LimyeTextStyles.hero(color: context.colors.onSurface),
          ),
          const SizedBox(height: LimyeSpacing.md),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: LimyeSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 22,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: LimyeSpacing.sm),
                  Expanded(
                    child: Text(
                      b,
                      style: LimyeTextStyles.body(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (fillBottom) const Spacer(),
          if (!fillBottom) const SizedBox(height: LimyeSpacing.md),
          if (primary)
            SizedBox(
              height: LimyeSpacing.buttonHeight,
              child: FilledButton(
                onPressed: onCta,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  ctaLabel,
                  style:
                      LimyeTextStyles.bodyBold(color: context.colors.onPrimary),
                ),
              ),
            )
          else
            SizedBox(
              height: LimyeSpacing.buttonHeight,
              child: OutlinedButton(
                onPressed: onCta,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.primary, width: 1),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  ctaLabel,
                  style:
                      LimyeTextStyles.bodyBold(color: context.colors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Testimonials ───────────────────────────────────────────────────────────

class _TestimonialsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        BusinessSolutionsContent.testimonial1Quote,
        BusinessSolutionsContent.testimonial1Name,
        BusinessSolutionsContent.testimonial1Role,
      ),
      (
        BusinessSolutionsContent.testimonial2Quote,
        BusinessSolutionsContent.testimonial2Name,
        BusinessSolutionsContent.testimonial2Role,
      ),
      (
        BusinessSolutionsContent.testimonial3Quote,
        BusinessSolutionsContent.testimonial3Name,
        BusinessSolutionsContent.testimonial3Role,
      ),
    ];
    return _PageSection(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: LimyeSpacing.lg),
            child: Text(
              BusinessSolutionsContent.testimonialsSectionTitle,
              textAlign: TextAlign.center,
              style: LimyeTextStyles.sectionHeading(
                color: context.colors.onSurface,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth > 720;
              final gap = LimyeSpacing.gutter;
              final items = cards
                  .map(
                    (e) => _TestimonialCard(
                      quote: e.$1,
                      name: e.$2,
                      role: e.$3,
                    ),
                  )
                  .toList();
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) SizedBox(width: gap),
                      Expanded(child: items[i]),
                    ],
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) SizedBox(height: gap),
                    items[i],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.quote,
    required this.name,
    required this.role,
  });

  final String quote;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LimyeSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: context.colors.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (_) => Icon(
                Icons.star_rounded,
                size: 22,
                color: context.colors.primary,
              ),
            ),
          ),
          const SizedBox(height: LimyeSpacing.sm),
          Text(
            '"$quote"',
            style: LimyeTextStyles.body(color: context.colors.onSurface),
          ),
          const SizedBox(height: LimyeSpacing.md),
          Divider(color: context.colors.outline, height: 1),
          const SizedBox(height: LimyeSpacing.sm),
          Text(
            name,
            style: LimyeTextStyles.bodyBold(color: context.colors.onSurface),
          ),
          Text(
            role,
            style: LimyeTextStyles.caption(
              color: context.colors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Final CTA ───────────────────────────────────────────────────────────────

class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({required this.onEnterprise});

  final VoidCallback onEnterprise;

  @override
  Widget build(BuildContext context) {
    return _PageSection(
      child: Container(
        padding: const EdgeInsets.all(LimyeSpacing.xl),
        decoration: BoxDecoration(
          color: context.colors.surfaceMuted,
          borderRadius: BorderRadius.circular(LimyeRadius.card),
          border: Border.all(color: context.colors.outline, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              BusinessSolutionsContent.finalCtaTitle,
              textAlign: TextAlign.center,
              style: LimyeTextStyles.sectionHeading(
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: LimyeSpacing.sm),
            Text(
              BusinessSolutionsContent.finalCtaSubtitle,
              textAlign: TextAlign.center,
              style: LimyeTextStyles.body(
                color: context.colors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: LimyeSpacing.lg),
            SizedBox(
              height: LimyeSpacing.buttonHeight,
              child: FilledButton(
                onPressed: onEnterprise,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: LimyeSpacing.lg),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  BusinessSolutionsContent.finalCtaButton,
                  style:
                      LimyeTextStyles.bodyBold(color: context.colors.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
