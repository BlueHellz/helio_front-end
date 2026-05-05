import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/shell/web/homeowner_web_chrome.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';

// ─────────────────────────────────────────────
// BLACK LIGHT — Community Solar (SolarPool) info page
// Public landing — what it is, how it works, why it matters.
// No mock pool data; real pool list will arrive from backend later.
// ─────────────────────────────────────────────

class PoolInfoPage extends StatelessWidget {
  final VoidCallback? onJoinWaitlist;
  final VoidCallback? onHomeTap;
  final VoidCallback? onSignIn;
  final VoidCallback? onMyProjects;

  const PoolInfoPage({
    super.key,
    this.onJoinWaitlist,
    this.onHomeTap,
    this.onSignIn,
    this.onMyProjects,
  });

  @override
  Widget build(BuildContext context) {
    return HomeownerPublicChrome(
      activeNavIndex: 0,
      onHomeTap: onHomeTap,
      onSignIn: onSignIn,
      onMyProjects: onMyProjects,
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
                _PoolHero(
                  onReadWhitepaper: () => AppFeedback.whitepaperStub(context),
                  onJoinOrWaitlist: onJoinWaitlist,
                ),
                const SizedBox(height: BlackLightSpacing.xl),
                const _StatsStrip(),
                const SizedBox(height: BlackLightSpacing.xl),
                const _HowPoolsWork(),
                const SizedBox(height: BlackLightSpacing.xl),
                _ComingSoon(onJoinWaitlist: onJoinWaitlist),
                const SizedBox(height: BlackLightSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO
// ─────────────────────────────────────────────
class _PoolHero extends StatelessWidget {
  final VoidCallback onReadWhitepaper;
  final VoidCallback? onJoinOrWaitlist;

  const _PoolHero({
    required this.onReadWhitepaper,
    this.onJoinOrWaitlist,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.hasBoundedWidth && c.maxWidth > 860;
      final left = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(label: PoolFundingContent.heroEyebrow),
          const SizedBox(height: BlackLightSpacing.md),
          Text(
              '${PoolFundingContent.heroTitleLine1}\n${PoolFundingContent.heroTitleLine2}',
              style: BlackLightTextStyles.hero()),
          const SizedBox(height: BlackLightSpacing.md),
          Text(
            PoolFundingContent.heroBody,
            style: BlackLightTextStyles.body(),
          ),
          const SizedBox(height: BlackLightSpacing.md),
          Wrap(
            spacing: BlackLightSpacing.sm,
            runSpacing: BlackLightSpacing.xs,
            children: [
              SizedBox(
                height: BlackLightSpacing.buttonHeight,
                child: OutlinedButton(
                  onPressed: onReadWhitepaper,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BlackLightColors.textPrimary,
                    side:
                        const BorderSide(color: BlackLightColors.border),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: Text(PoolFundingContent.readWhitepaper,
                      style: BlackLightTextStyles.bodyBold(
                          color: BlackLightColors.textPrimary)),
                ),
              ),
              SizedBox(
                height: BlackLightSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: onJoinOrWaitlist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BlackLightColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: Text(PoolFundingContent.joinWaitlist,
                      style: BlackLightTextStyles.bodyBold(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      );

      final visual = AspectRatio(
        aspectRatio: 1.05,
        child: Container(
          decoration: BoxDecoration(
            color: BlackLightColors.surface,
            border: Border.all(color: BlackLightColors.border),
            borderRadius: BorderRadius.circular(BlackLightRadius.card),
          ),
          child: const _PoolVisual(),
        ),
      );

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 55, child: left),
            const SizedBox(width: BlackLightSpacing.xl),
            Expanded(flex: 45, child: visual),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          const SizedBox(height: BlackLightSpacing.lg),
          visual,
        ],
      );
    });
  }
}

class _Eyebrow extends StatelessWidget {
  final String label;

  const _Eyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: BlackLightTextStyles.captionBold(
              color: BlackLightColors.textBody)),
    );
  }
}

class _PoolVisual extends StatelessWidget {
  const _PoolVisual();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BlackLightRadius.card),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _PoolMeshPainter())),
          Positioned(
            left: 24,
            top: 24,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: BlackLightColors.surface,
                border: Border.all(color: BlackLightColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(PoolFundingContent.livePreviewEyebrow,
                  style: BlackLightTextStyles.captionBold(
                      color: BlackLightColors.textBody)),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(PoolFundingContent.totalPooledLabel,
                    style: BlackLightTextStyles.captionBold(
                        color: BlackLightColors.textBody)),
                const SizedBox(height: 6),
                Text(CommonContent.emDash,
                    style: BlackLightTextStyles.hero()
                        .copyWith(fontSize: 48, height: 1.0)),
                const SizedBox(height: 2),
                Text(PoolFundingContent.hlioTicker,
                    style: BlackLightTextStyles.body(
                        color: BlackLightColors.textBody)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PoolMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BlackLightColors.border
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const step = 28.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Diagonals
    final diag = Paint()
      ..color = BlackLightColors.accent
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, 0), diag);
    canvas.drawLine(
        Offset(0, 0), Offset(size.width, size.height), diag);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// STATS — schema explainer (no live numbers)
// ─────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  static final _items = [
    (PoolFundingContent.statBackedByLabel, PoolFundingContent.statBackedByValue),
    (PoolFundingContent.statReturnedLabel, PoolFundingContent.statReturnedValue),
    (PoolFundingContent.statVisibilityLabel, PoolFundingContent.statVisibilityValue),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: BlackLightSpacing.lg,
          vertical: BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final isWide = c.hasBoundedWidth && c.maxWidth > 720;
        final children = _items
            .map((e) => _StatItem(label: e.$1, value: e.$2))
            .toList();
        if (isWide) {
          return Row(
            children: List.generate(children.length, (i) {
              return Expanded(
                child: Row(
                  children: [
                    if (i > 0) ...[
                      const SizedBox(
                        height: 36,
                        child: VerticalDivider(width: 1),
                      ),
                      const SizedBox(width: BlackLightSpacing.md),
                    ],
                    Expanded(child: children[i]),
                  ],
                ),
              );
            }),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
              .expand((w) => [w, const SizedBox(height: BlackLightSpacing.sm)])
              .take(children.length * 2 - 1)
              .toList(),
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: BlackLightTextStyles.captionBold(
                color: BlackLightColors.textBody)),
        const SizedBox(height: 4),
        Text(value, style: BlackLightTextStyles.cardHeading()),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// HOW POOLS WORK
// ─────────────────────────────────────────────
class _HowPoolsWork extends StatelessWidget {
  const _HowPoolsWork();

  static final _steps = [
    (
      Icons.savings_outlined,
      PoolFundingContent.step1Title,
      PoolFundingContent.step1Body,
    ),
    (
      Icons.solar_power_outlined,
      PoolFundingContent.step2Title,
      PoolFundingContent.step2Body,
    ),
    (
      Icons.toll_outlined,
      PoolFundingContent.step3Title,
      PoolFundingContent.step3Body,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(PoolFundingContent.howTitle,
            style: BlackLightTextStyles.sectionHeading()),
        const SizedBox(height: BlackLightSpacing.xs),
        Text(PoolFundingContent.howSubtitle,
            style: BlackLightTextStyles.body()),
        const SizedBox(height: BlackLightSpacing.lg),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: const IsometricPoolCommunityIllustration(
              width: 320,
              height: 140,
            ),
          ),
        ),
        const SizedBox(height: BlackLightSpacing.lg),
        LayoutBuilder(builder: (context, c) {
          final isWide = c.hasBoundedWidth && c.maxWidth > 760;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _steps
                  .map((s) => Expanded(
                      child: _PoolStepCard(
                          icon: s.$1, title: s.$2, body: s.$3)))
                  .expand((w) =>
                      [w, const SizedBox(width: BlackLightSpacing.gutter)])
                  .take(_steps.length * 2 - 1)
                  .toList(),
            );
          }
          return Column(
            children: _steps
                .map((s) =>
                    _PoolStepCard(icon: s.$1, title: s.$2, body: s.$3))
                .expand((w) => [w, const SizedBox(height: BlackLightSpacing.md)])
                .take(_steps.length * 2 - 1)
                .toList(),
          );
        }),
      ],
    );
  }
}

class _PoolStepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PoolStepCard(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BlackLightColors.surface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 20, color: BlackLightColors.accent),
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

// ─────────────────────────────────────────────
// COMING SOON / WAITLIST
// ─────────────────────────────────────────────
class _ComingSoon extends StatelessWidget {
  final VoidCallback? onJoinWaitlist;

  const _ComingSoon({this.onJoinWaitlist});

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
        final isWide = c.hasBoundedWidth && c.maxWidth > 760;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(PoolFundingContent.activePoolsTitle,
                style: BlackLightTextStyles.sectionHeading()),
            const SizedBox(height: BlackLightSpacing.xs),
            Text(
                PoolFundingContent.activePoolsBody,
                style: BlackLightTextStyles.body()),
            const SizedBox(height: BlackLightSpacing.md),
            Text(
              PoolFundingContent.samplePoolsHint,
              style: BlackLightTextStyles.caption(
                  color: BlackLightColors.textBody),
            ),
            const SizedBox(height: BlackLightSpacing.md),
            LayoutBuilder(builder: (ctx, bx) {
              final wide = bx.hasBoundedWidth && bx.maxWidth > 520;
              final c1 = _SamplePoolCard(
                title: PoolFundingContent.samplePoolCard1Title,
                meta: PoolFundingContent.samplePoolCard1Meta,
                statLabel: PoolFundingContent.samplePoolCard1StatLabel,
                statValue: PoolFundingContent.samplePoolCard1StatValue,
              );
              final c2 = _SamplePoolCard(
                title: PoolFundingContent.samplePoolCard2Title,
                meta: PoolFundingContent.samplePoolCard2Meta,
                statLabel: PoolFundingContent.samplePoolCard2StatLabel,
                statValue: PoolFundingContent.samplePoolCard2StatValue,
              );
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: c1),
                    const SizedBox(width: BlackLightSpacing.md),
                    Expanded(child: c2),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  c1,
                  const SizedBox(height: BlackLightSpacing.md),
                  c2,
                ],
              );
            }),
          ],
        );
        final right = SizedBox(
          height: BlackLightSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: onJoinWaitlist,
            style: ElevatedButton.styleFrom(
              backgroundColor: BlackLightColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
            ),
            child: Text(PoolFundingContent.notifyMe,
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

class _SamplePoolCard extends StatelessWidget {
  const _SamplePoolCard({
    required this.title,
    required this.meta,
    required this.statLabel,
    required this.statValue,
  });

  final String title;
  final String meta;
  final String statLabel;
  final String statValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.background,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BlackLightTextStyles.cardHeading()),
          const SizedBox(height: 4),
          Text(meta, style: BlackLightTextStyles.caption()),
          const SizedBox(height: BlackLightSpacing.sm),
          Row(
            children: [
              Text(
                statLabel.toUpperCase(),
                style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10),
              ),
              const SizedBox(width: 8),
              Text(statValue, style: BlackLightTextStyles.data()),
            ],
          ),
        ],
      ),
    );
  }
}
