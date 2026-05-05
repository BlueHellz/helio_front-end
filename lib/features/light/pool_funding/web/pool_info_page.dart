import 'package:limye_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:limye_app/core/ui/app_feedback.dart';
import 'package:limye_app/theme/limye_theme.dart';
import 'package:limye_app/core/shell/web/homeowner_web_chrome.dart';
import 'package:limye_app/core/illustrations/geometric_illustrations.dart';

// ─────────────────────────────────────────────
// LIMYÈ — Community Solar (SolarPool) info page
// Public landing — what it is, how it works, why it matters.
// No mock pool data; real pool list will arrive from backend later.
// ─────────────────────────────────────────────

class PoolInfoPage extends StatelessWidget {
  final VoidCallback? onJoinWaitlist;
  final VoidCallback? onHomeTap;
  final VoidCallback? onMyProjects;

  const PoolInfoPage({
    super.key,
    this.onJoinWaitlist,
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
                _PoolHero(
                  onReadWhitepaper: () => AppFeedback.whitepaperStub(context),
                  onJoinOrWaitlist: onJoinWaitlist,
                ),
                const SizedBox(height: LimyeSpacing.xl),
                const _StatsStrip(),
                const SizedBox(height: LimyeSpacing.xl),
                const _HowPoolsWork(),
                const SizedBox(height: LimyeSpacing.xl),
                _ComingSoon(onJoinWaitlist: onJoinWaitlist),
                const SizedBox(height: LimyeSpacing.xl),
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
          const SizedBox(height: LimyeSpacing.md),
          Text(
              '${PoolFundingContent.heroTitleLine1}\n${PoolFundingContent.heroTitleLine2}',
              style: LimyeTextStyles.hero()),
          const SizedBox(height: LimyeSpacing.md),
          Text(
            PoolFundingContent.heroBody,
            style: LimyeTextStyles.body(),
          ),
          const SizedBox(height: LimyeSpacing.md),
          Wrap(
            spacing: LimyeSpacing.sm,
            runSpacing: LimyeSpacing.xs,
            children: [
              SizedBox(
                height: LimyeSpacing.buttonHeight,
                child: OutlinedButton(
                  onPressed: onReadWhitepaper,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LimyeColors.textPrimary,
                    side:
                        const BorderSide(color: LimyeColors.border),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: Text(PoolFundingContent.readWhitepaper,
                      style: LimyeTextStyles.bodyBold(
                          color: LimyeColors.textPrimary)),
                ),
              ),
              SizedBox(
                height: LimyeSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: onJoinOrWaitlist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LimyeColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: Text(PoolFundingContent.joinWaitlist,
                      style: LimyeTextStyles.bodyBold(color: Colors.white)),
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
            color: LimyeColors.surface,
            border: Border.all(color: LimyeColors.border),
            borderRadius: BorderRadius.circular(LimyeRadius.card),
          ),
          child: const _PoolVisual(),
        ),
      );

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 55, child: left),
            const SizedBox(width: LimyeSpacing.xl),
            Expanded(flex: 45, child: visual),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          const SizedBox(height: LimyeSpacing.lg),
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
        color: LimyeColors.surface,
        border: Border.all(color: LimyeColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: LimyeTextStyles.captionBold(
              color: LimyeColors.textBody)),
    );
  }
}

class _PoolVisual extends StatelessWidget {
  const _PoolVisual();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(LimyeRadius.card),
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
                color: LimyeColors.surface,
                border: Border.all(color: LimyeColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(PoolFundingContent.livePreviewEyebrow,
                  style: LimyeTextStyles.captionBold(
                      color: LimyeColors.textBody)),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(PoolFundingContent.totalPooledLabel,
                    style: LimyeTextStyles.captionBold(
                        color: LimyeColors.textBody)),
                const SizedBox(height: 6),
                Text(CommonContent.emDash,
                    style: LimyeTextStyles.hero()
                        .copyWith(fontSize: 48, height: 1.0)),
                const SizedBox(height: 2),
                Text(PoolFundingContent.hlioTicker,
                    style: LimyeTextStyles.body(
                        color: LimyeColors.textBody)),
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
      ..color = LimyeColors.border
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
      ..color = LimyeColors.accent
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
          horizontal: LimyeSpacing.lg,
          vertical: LimyeSpacing.md),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        border: Border.all(color: LimyeColors.border),
        borderRadius: BorderRadius.circular(LimyeRadius.card),
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
                      const SizedBox(width: LimyeSpacing.md),
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
              .expand((w) => [w, const SizedBox(height: LimyeSpacing.sm)])
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
            style: LimyeTextStyles.captionBold(
                color: LimyeColors.textBody)),
        const SizedBox(height: 4),
        Text(value, style: LimyeTextStyles.cardHeading()),
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
            style: LimyeTextStyles.sectionHeading()),
        const SizedBox(height: LimyeSpacing.xs),
        Text(PoolFundingContent.howSubtitle,
            style: LimyeTextStyles.body()),
        const SizedBox(height: LimyeSpacing.lg),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: const IsometricPoolCommunityIllustration(
              width: 320,
              height: 140,
            ),
          ),
        ),
        const SizedBox(height: LimyeSpacing.lg),
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
                      [w, const SizedBox(width: LimyeSpacing.gutter)])
                  .take(_steps.length * 2 - 1)
                  .toList(),
            );
          }
          return Column(
            children: _steps
                .map((s) =>
                    _PoolStepCard(icon: s.$1, title: s.$2, body: s.$3))
                .expand((w) => [w, const SizedBox(height: LimyeSpacing.md)])
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: LimyeColors.surface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 20, color: LimyeColors.accent),
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

// ─────────────────────────────────────────────
// COMING SOON / WAITLIST
// ─────────────────────────────────────────────
class _ComingSoon extends StatelessWidget {
  final VoidCallback? onJoinWaitlist;

  const _ComingSoon({this.onJoinWaitlist});

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
        final isWide = c.hasBoundedWidth && c.maxWidth > 760;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(PoolFundingContent.activePoolsTitle,
                style: LimyeTextStyles.sectionHeading()),
            const SizedBox(height: LimyeSpacing.xs),
            Text(
                PoolFundingContent.activePoolsBody,
                style: LimyeTextStyles.body()),
            const SizedBox(height: LimyeSpacing.md),
            Text(
              PoolFundingContent.samplePoolsHint,
              style: LimyeTextStyles.caption(
                  color: LimyeColors.textBody),
            ),
            const SizedBox(height: LimyeSpacing.md),
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
                    const SizedBox(width: LimyeSpacing.md),
                    Expanded(child: c2),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  c1,
                  const SizedBox(height: LimyeSpacing.md),
                  c2,
                ],
              );
            }),
          ],
        );
        final right = SizedBox(
          height: LimyeSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: onJoinWaitlist,
            style: ElevatedButton.styleFrom(
              backgroundColor: LimyeColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
            ),
            child: Text(PoolFundingContent.notifyMe,
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
      padding: const EdgeInsets.all(LimyeSpacing.md),
      decoration: BoxDecoration(
        color: LimyeColors.background,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: LimyeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: LimyeTextStyles.cardHeading()),
          const SizedBox(height: 4),
          Text(meta, style: LimyeTextStyles.caption()),
          const SizedBox(height: LimyeSpacing.sm),
          Row(
            children: [
              Text(
                statLabel.toUpperCase(),
                style: LimyeTextStyles.captionBold().copyWith(fontSize: 10),
              ),
              const SizedBox(width: 8),
              Text(statValue, style: LimyeTextStyles.data()),
            ],
          ),
        ],
      ),
    );
  }
}
