import 'package:flutter/material.dart';
import 'package:kooyoh_app/core/content/content_registry.dart';

import 'package:kooyoh_app/core/ui/app_feedback.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';
import 'package:kooyoh_app/core/illustrations/geometric_illustrations.dart';
import 'package:kooyoh_app/core/shell/web/homeowner_web_chrome.dart';
import 'package:kooyoh_app/features/light/landing/landing_inline_program.dart';
import 'package:kooyoh_app/features/light/landing/landing_program_expanded.dart';

class LandingPage extends StatefulWidget {
  final VoidCallback? onGetStarted;
  final VoidCallback? onHomeTap;
  final VoidCallback? onBusinesses;
  final VoidCallback? onEnterprise;

  const LandingPage({
    super.key,
    this.onGetStarted,
    this.onHomeTap,
    this.onBusinesses,
    this.onEnterprise,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  LandingInlineProgram? _program;

  void _exitProgram() {
    setState(() => _program = null);
  }

  void _handleHomeTap() {
    _exitProgram();
    widget.onHomeTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return HomeownerPublicChrome(
      onHomeTap: _handleHomeTap,
      onBusinesses: widget.onBusinesses ?? () {},
      onEnterprise: widget.onEnterprise ?? () {},
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _program == null
            ? KeyedSubtree(
                key: const ValueKey<String>('landing-main'),
                child: _MainLandingColumn(
                  onGetStarted: widget.onGetStarted,
                  onSelectProgram: (LandingInlineProgram p) {
                    setState(() => _program = p);
                  },
                  onNavigateBusinesses: widget.onBusinesses,
                ),
              )
            : KeyedSubtree(
                key: ValueKey<String>('landing-program-$_program'),
                child: LandingProgramExpanded(
                  program: _program!,
                  onBack: _exitProgram,
                ),
              ),
      ),
    );
  }
}

class _MainLandingColumn extends StatelessWidget {
  final VoidCallback? onGetStarted;
  final void Function(LandingInlineProgram) onSelectProgram;
  final VoidCallback? onNavigateBusinesses;

  const _MainLandingColumn({
    required this.onSelectProgram,
    this.onGetStarted,
    this.onNavigateBusinesses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero — constrained to max width, centered
        _Constrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
                _HeroSection(onGetStarted: onGetStarted),
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
              ],
            ),
          ),
        ),

        // Trust strip — full bleed
        const _TrustStrip(),

        // How it works — constrained
        _Constrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
                _HowItWorks(),
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
                _FeaturesDeepDive(),
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
                const _SocialProofSection(),
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
              ],
            ),
          ),
        ),

        // Pillars — three programs (drone ops / pool / EV)
        _Constrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
                _PillarsSection(onSelectProgram: onSelectProgram),
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
              ],
            ),
          ),
        ),

        // For business — full bleed
        _ForBusinessSection(onNavigateEnterprise: onNavigateBusinesses),

        // In-product mockups
        _Constrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.gutter),
            child: const Column(
              children: [
                SizedBox(height: KooyohSpacing.sectionPaddingVertical),
                _SeeLightInActionSection(),
                SizedBox(height: KooyohSpacing.sectionPaddingVertical),
              ],
            ),
          ),
        ),

        // Wallet — constrained, centered
        _Constrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.gutter),
            child: Column(
              children: [
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
                const _WalletSection(),
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
                _FinalCtaSection(onStart: onGetStarted),
                const SizedBox(height: KooyohSpacing.sectionPaddingVertical),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PILLARS — Drone Ops · Solar Pool · EV Charging
// ─────────────────────────────────────────────
class _PillarsSection extends StatelessWidget {
  final void Function(LandingInlineProgram) onSelectProgram;

  const _PillarsSection({required this.onSelectProgram});

  @override
  Widget build(BuildContext context) {
    final pillars = [
      _PillarCardData(
        eyebrow: LandingContent.pillarDroneEyebrow,
        title: LandingContent.pillarDroneTitle,
        body:
            LandingContent.pillarDroneBody,
        icon: Icons.flight_takeoff_outlined,
        cta: LandingContent.pillarDroneCta,
        onTap: () => onSelectProgram(LandingInlineProgram.drone),
      ),
      _PillarCardData(
        eyebrow: LandingContent.pillarPoolEyebrow,
        title: LandingContent.pillarPoolTitle,
        body:
            LandingContent.pillarPoolBody,
        icon: Icons.savings_outlined,
        cta: LandingContent.pillarPoolCta,
        onTap: () => onSelectProgram(LandingInlineProgram.pool),
      ),
      _PillarCardData(
        eyebrow: LandingContent.pillarEvEyebrow,
        title: LandingContent.pillarEvTitle,
        body:
            LandingContent.pillarEvBody,
        icon: Icons.ev_station_outlined,
        cta: LandingContent.pillarEvCta,
        onTap: () => onSelectProgram(LandingInlineProgram.ev),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LandingContent.programsHeadline,
            style: KooyohTextStyles.sectionHeading()),
        const SizedBox(height: KooyohSpacing.xs),
        Text(
            LandingContent.programsSubcopy,
            style: KooyohTextStyles.body()),
        const SizedBox(height: KooyohSpacing.lg),
        // Row + Expanded *requires* bounded width. Some browsers (e.g. Brave)
        // can pass an unbounded maxWidth here; that throws during layout and
        // the rest of the page (and footer) never paints.
        LayoutBuilder(builder: (context, c) {
          final isWide = c.hasBoundedWidth && c.maxWidth > 860;
          if (isWide) {
            // `stretch` in a scrollable Column gets unbounded height on web; IntrinsicHeight
            // gives the Row a finite cross-extent so equal-height cards layout safely.
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: pillars
                    .map((p) => Expanded(child: _PillarCard(data: p)))
                    .expand((w) => [
                        w,
                        const SizedBox(width: KooyohSpacing.cardGap),
                      ])
                    .take(pillars.length * 2 - 1)
                    .toList(),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: pillars
                .map((p) => _PillarCard(data: p))
                .expand((w) => [w, const SizedBox(height: KooyohSpacing.md)])
                .take(pillars.length * 2 - 1)
                .toList(),
          );
        }),
      ],
    );
  }
}

class _PillarCardData {
  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final String cta;
  final VoidCallback? onTap;

  _PillarCardData({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.cta,
    this.onTap,
  });
}

class _PillarCard extends StatefulWidget {
  final _PillarCardData data;

  const _PillarCard({required this.data});

  @override
  State<_PillarCard> createState() => _PillarCardState();
}

class _PillarCardState extends State<_PillarCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.data.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(KooyohSpacing.cardPadding),
          decoration: BoxDecoration(
            color: KooyohColors.surface,
            borderRadius: BorderRadius.circular(KooyohRadius.card),
            border: Border.all(
                color: _hover
                    ? KooyohColors.accent
                    : KooyohColors.border),
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
                child: Icon(widget.data.icon,
                    size: 22, color: KooyohColors.accent),
              ),
              const SizedBox(height: KooyohSpacing.md),
              Text(widget.data.eyebrow,
                  style: KooyohTextStyles.captionBold(
                      color: KooyohColors.textBody)),
              const SizedBox(height: 4),
              Text(widget.data.title,
                  style: KooyohTextStyles.cardHeading()),
              const SizedBox(height: 6),
              Text(widget.data.body, style: KooyohTextStyles.body()),
              const SizedBox(height: KooyohSpacing.md),
              Row(
                children: [
                  Text(widget.data.cta,
                      style: KooyohTextStyles.bodyBold(
                          color: KooyohColors.accent)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      size: 16, color: KooyohColors.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centers content and constrains to max container width
class _Constrained extends StatelessWidget {
  final Widget child;

  const _Constrained({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: KooyohSpacing.containerMax),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const _HeroSection({this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 860;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 55,
            child: _HeroContent(onGetStarted: onGetStarted),
          ),
          const SizedBox(width: KooyohSpacing.xl),
          Expanded(
            flex: 45,
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: SizedBox(
                  width: 540,
                  height: 450,
                  child: Image.asset(
                    'assets/images/hero_illustration.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroContent(onGetStarted: onGetStarted),
        const SizedBox(height: KooyohSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 300,
          child: Image.asset(
            'assets/images/hero_illustration.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

// Converted to StatefulWidget so TextEditingController is properly managed
class _HeroContent extends StatefulWidget {
  final VoidCallback? onGetStarted;

  const _HeroContent({this.onGetStarted});

  @override
  State<_HeroContent> createState() => _HeroContentState();
}

class _HeroContentState extends State<_HeroContent> {
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LandingContent.heroTitle,
          style: KooyohTextStyles.hero(),
        ),
        const SizedBox(height: KooyohSpacing.md),
        Text(
          LandingContent.heroBody,
          style: KooyohTextStyles.body(),
        ),
        const SizedBox(height: KooyohSpacing.lg),
        _AddressInputRow(
          controller: _addressCtrl,
          onGetStarted: widget.onGetStarted,
        ),
        const SizedBox(height: KooyohSpacing.md),
        Text(
          LandingContent.heroStatLabel,
          style: KooyohTextStyles.captionBold(
            color: KooyohColors.textCaption,
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<int>(
          tween: IntTween(
            begin: 0,
            end: int.tryParse(LandingContent.heroStatValue) ?? 2847,
          ),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Text(
              '$value',
              style: KooyohTextStyles.dataLarge(
                color: KooyohColors.accent,
              ),
            );
          },
        ),
        const SizedBox(height: KooyohSpacing.md),
        Text(
          LandingContent.trustedByLine,
          style: KooyohTextStyles.caption(
            color: KooyohColors.textCaption,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: KooyohSpacing.sm,
          runSpacing: 6,
          children: [
            for (final name in [
              LandingContent.trustedPlaceholder1,
              LandingContent.trustedPlaceholder2,
              LandingContent.trustedPlaceholder3,
              LandingContent.trustedPlaceholder4,
              LandingContent.trustedPlaceholder5,
            ])
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: KooyohColors.border),
                  borderRadius: BorderRadius.circular(999),
                  color: KooyohColors.surface,
                ),
                child: Text(
                  name,
                  style: KooyohTextStyles.caption(
                    color: KooyohColors.textCaption,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: KooyohSpacing.sm),
        Row(
          children: [
            const Icon(Icons.bolt,
                size: 14, color: KooyohColors.textCaption),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                LandingContent.heroTrustLine,
                style: KooyohTextStyles.caption(
                    color: KooyohColors.textCaption),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddressInputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onGetStarted;

  const _AddressInputRow({required this.controller, this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LandingContent.heroAddressLabel,
            style: KooyohTextStyles.captionBold(
                color: KooyohColors.textCaption),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: KooyohSpacing.inputHeight,
                  child: TextField(
                    controller: controller,
                    style: KooyohTextStyles.body(
                        color: KooyohColors.textPrimary),
                    decoration:
                        _inputDeco(LandingContent.heroAddressPlaceholder),
                  ),
                ),
              ),
              const SizedBox(width: KooyohSpacing.sm),
              SizedBox(
                height: KooyohSpacing.inputHeight,
                child: ElevatedButton(
                  onPressed: onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KooyohColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    LandingContent.heroPrimaryCta,
                    style: KooyohTextStyles.bodyBold(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: KooyohSpacing.inputHeight,
          child: TextField(
            controller: controller,
            style:
                KooyohTextStyles.body(color: KooyohColors.textPrimary),
            decoration: _inputDeco(LandingContent.heroAddressPlaceholder),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: KooyohSpacing.inputHeight,
          child: ElevatedButton(
            onPressed: onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: KooyohColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: KooyohSpacing.md),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              LandingContent.heroPrimaryCta,
              style: KooyohTextStyles.bodyBold(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            KooyohTextStyles.body(color: KooyohColors.textCaption),
        filled: true,
        fillColor: KooyohColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KooyohRadius.input),
          borderSide: const BorderSide(color: KooyohColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KooyohRadius.input),
          borderSide: const BorderSide(color: KooyohColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KooyohRadius.input),
          borderSide:
              const BorderSide(color: KooyohColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );
}

// ─────────────────────────────────────────────
// TRUST STRIP — full bleed
// ─────────────────────────────────────────────
class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  static final _items = [
    (Icons.gpp_good_outlined, LandingContent.trustNec),
    (Icons.memory_outlined, LandingContent.trustAi),
    (Icons.task_alt_outlined, LandingContent.trustPermit),
    (Icons.lock_outline, LandingContent.trustEncryption),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: KooyohSpacing.md),
      decoration: const BoxDecoration(
        color: KooyohColors.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: KooyohColors.border),
        ),
      ),
      child: Wrap(
        spacing: KooyohSpacing.xl,
        runSpacing: KooyohSpacing.sm,
        alignment: WrapAlignment.center,
        children: _items
            .map(
              (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$1, size: 18, color: KooyohColors.textBody),
                  const SizedBox(width: 6),
                  Text(
                    item.$2,
                    style: KooyohTextStyles.caption(
                        color: KooyohColors.textBody),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOW IT WORKS
// ─────────────────────────────────────────────
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static final _steps = [
    (LandingContent.step1Title, LandingContent.step1Body),
    (LandingContent.step2Title, LandingContent.step2Body),
    (LandingContent.step3Title, LandingContent.step3Body),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LandingContent.howItWorksTitle, style: KooyohTextStyles.sectionHeading()),
        const SizedBox(height: KooyohSpacing.lg),
        // Row + Expanded requires bounded width. Unbounded maxWidth in some
        // browsers makes `infinity > 700` true, which would pick the Row and
        // crash layout — content below (pillars, footer) never shows.
        LayoutBuilder(builder: (context, constraints) {
          final isWide =
              constraints.hasBoundedWidth && constraints.maxWidth > 700;
          if (isWide) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _steps
                    .asMap()
                    .entries
                    .map((e) => Expanded(
                        child: _StepCard(
                          stepIndex: e.key,
                          step: e.value,
                          expandBody: true,
                        )))
                    .expand((w) => [
                          w,
                          const SizedBox(width: KooyohSpacing.cardGap),
                        ])
                    .take(_steps.length * 2 - 1)
                    .toList(),
              ),
            );
          }
          return Column(
            children: _steps
                .asMap()
                .entries
                .map((e) => _StepCard(
                      stepIndex: e.key,
                      step: e.value,
                      expandBody: false,
                    ))
                .expand((w) => [
                      w,
                      const SizedBox(height: KooyohSpacing.cardGap),
                    ])
                .take(_steps.length * 2 - 1)
                .toList(),
          );
        }),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final int stepIndex;
  final (String, String) step;
  /// When true (desktop row), body fills remaining height so card heights match.
  final bool expandBody;

  const _StepCard({
    required this.stepIndex,
    required this.step,
    required this.expandBody,
  });

  static const int _bodyMaxLines = 3;

  @override
  Widget build(BuildContext context) {
    final body = Text(
      step.$2,
      style: KooyohTextStyles.body(),
      maxLines: _bodyMaxLines,
      overflow: TextOverflow.ellipsis,
    );

    return Container(
      padding: const EdgeInsets.all(KooyohSpacing.cardPadding),
      decoration: BoxDecoration(
        color: KooyohColors.surface,
        borderRadius: BorderRadius.circular(KooyohRadius.card),
        border: Border.all(color: KooyohColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KooyohColors.surface,
              border: Border.all(color: KooyohColors.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: _HowItWorksStepLeading(stepIndex: stepIndex),
            ),
          ),
          const SizedBox(height: KooyohSpacing.md),
          Text(step.$1, style: KooyohTextStyles.cardHeading()),
          const SizedBox(height: KooyohSpacing.xs / 2),
          const Divider(),
          const SizedBox(height: KooyohSpacing.xs),
          if (expandBody)
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: body,
              ),
            )
          else
            body,
        ],
      ),
    );
  }
}

class _HowItWorksStepLeading extends StatelessWidget {
  const _HowItWorksStepLeading({required this.stepIndex});

  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    switch (stepIndex) {
      case 0:
        return Icon(
          Icons.add_home_work_rounded,
          size: 22,
          color: KooyohColors.accent,
        );
      case 1:
        return SizedBox(
          width: 28,
          height: 22,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.chat_bubble_rounded,
                  size: 22,
                  color: KooyohColors.accent,
                ),
              ),
              Positioned(
                right: -2,
                top: -4,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 12,
                  color: KooyohColors.textBody,
                ),
              ),
            ],
          ),
        );
      case 2:
        return SizedBox(
          width: 26,
          height: 22,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.description_rounded,
                size: 22,
                color: KooyohColors.accent,
              ),
              Positioned(
                right: -4,
                bottom: -2,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: KooyohColors.accent,
                ),
              ),
            ],
          ),
        );
      default:
        return Icon(
          Icons.circle_outlined,
          size: 22,
          color: KooyohColors.accent,
        );
    }
  }
}

// ─────────────────────────────────────────────
// SEE LIGHT IN ACTION — browser mockups
// ─────────────────────────────────────────────
class _SeeLightInActionSection extends StatelessWidget {
  const _SeeLightInActionSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LandingContent.seeKooyohInActionTitle,
          style: KooyohTextStyles.sectionHeading(),
        ),
        const SizedBox(height: KooyohSpacing.xs),
        Text(
          LandingContent.seeKooyohInActionSubtitle,
          style: KooyohTextStyles.body(),
        ),
        const SizedBox(height: KooyohSpacing.lg),
        LayoutBuilder(builder: (context, c) {
          final wide = c.hasBoundedWidth && c.maxWidth > 860;
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(builder: (ctx, b) {
                final w = b.maxWidth.clamp(280.0, 520.0).toDouble();
                return BrowserMockupHomeownerIllustration(width: w, height: 240);
              }),
              const SizedBox(height: KooyohSpacing.xs),
              Text(
                LandingContent.mockupHomeownerCaption,
                style: KooyohTextStyles.caption(),
              ),
            ],
          );
          final right = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(builder: (ctx, b) {
                final w = b.maxWidth.clamp(280.0, 520.0).toDouble();
                return BrowserMockupOrgDashboardIllustration(width: w, height: 240);
              }),
              const SizedBox(height: KooyohSpacing.xs),
              Text(
                LandingContent.mockupOrgCaption,
                style: KooyohTextStyles.caption(),
              ),
            ],
          );
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: KooyohSpacing.cardGap),
                Expanded(child: right),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              const SizedBox(height: KooyohSpacing.lg),
              right,
            ],
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FOR BUSINESS — full bleed
// ─────────────────────────────────────────────
class _ForBusinessSection extends StatelessWidget {
  const _ForBusinessSection({this.onNavigateEnterprise});

  final VoidCallback? onNavigateEnterprise;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: KooyohSpacing.gutter,
          vertical: KooyohSpacing.sectionPaddingVertical),
      color: KooyohColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: KooyohSpacing.containerMax),
          child: LayoutBuilder(builder: (ctx, constraints) {
            final isWide =
                constraints.hasBoundedWidth && constraints.maxWidth > 700;
            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LandingContent.forBusinessTitle,
                            style: KooyohTextStyles.sectionHeading()),
                        const SizedBox(height: KooyohSpacing.xs),
                        Text(
                          LandingContent.forBusinessBody,
                          style: KooyohTextStyles.body(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KooyohSpacing.xl),
                  SizedBox(
                    height: KooyohSpacing.buttonHeight,
                    child: OutlinedButton(
                      onPressed: onNavigateEnterprise,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KooyohColors.textPrimary,
                        side: const BorderSide(color: KooyohColors.border),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                      ),
                      child: Text(LandingContent.forBusinessLearnMore,
                          style: KooyohTextStyles.bodyBold(
                              color: KooyohColors.textPrimary)),
                    ),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LandingContent.forBusinessTitle,
                    style: KooyohTextStyles.sectionHeading()),
                const SizedBox(height: KooyohSpacing.xs),
                Text(
                  LandingContent.forBusinessBody,
                  style: KooyohTextStyles.body(),
                ),
                const SizedBox(height: KooyohSpacing.md),
                SizedBox(
                  height: KooyohSpacing.buttonHeight,
                  child: OutlinedButton(
                    onPressed: onNavigateEnterprise,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KooyohColors.textPrimary,
                      side: const BorderSide(color: KooyohColors.border),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(LandingContent.forBusinessLearnMore,
                        style: KooyohTextStyles.bodyBold(
                            color: KooyohColors.textPrimary)),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FEATURES DEEP-DIVE
// ─────────────────────────────────────────────
class _FeaturesDeepDive extends StatelessWidget {
  const _FeaturesDeepDive();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LandingContent.featuresSectionTitle,
          style: KooyohTextStyles.sectionHeading(),
        ),
        const SizedBox(height: KooyohSpacing.lg),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.hasBoundedWidth && c.maxWidth > 760;
            Widget alternatingRow({
              required bool graphicOnLeft,
              required Widget graphic,
              required Widget copy,
            }) {
              if (wide) {
                final a = Expanded(child: graphic);
                final b = Expanded(child: copy);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: graphicOnLeft
                      ? [a, const SizedBox(width: KooyohSpacing.xl), b]
                      : [b, const SizedBox(width: KooyohSpacing.xl), a],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  graphic,
                  const SizedBox(height: KooyohSpacing.md),
                  copy,
                ],
              );
            }

            final chatIllo = SizedBox(
              height: 220,
              child: Center(
                child: _LandingChatIllustration(
                  color: KooyohColors.border,
                  accent: KooyohColors.accent,
                  wide: c.maxWidth.clamp(280.0, 360.0),
                ),
              ),
            );
            final permitIllo = SizedBox(
              height: 220,
              child: Center(
                child: _LandingPermitIllustration(
                  color: KooyohColors.border,
                  accent: KooyohColors.accent,
                  wide: c.maxWidth.clamp(280.0, 360.0),
                ),
              ),
            );
            final poolIllo = SizedBox(
              height: 220,
              child: Center(
                child: _LandingPoolIllustration(
                  color: KooyohColors.border,
                  accent: KooyohColors.accent,
                  wide: c.maxWidth.clamp(280.0, 360.0),
                ),
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                alternatingRow(
                  graphicOnLeft: true,
                  graphic: chatIllo,
                  copy: _FeatureCopyColumn(
                    title: LandingContent.featureAiTitle,
                    body: LandingContent.featureAiBody,
                    linkLabel: LandingContent.featureAiLink,
                    onLinkTap: () {
                      AppFeedback.showInfoDialog(
                        context,
                        title: LandingContent.featureAiDialogTitle,
                        message: LandingContent.featureAiDialogBody,
                      );
                    },
                  ),
                ),
                const SizedBox(height: KooyohSpacing.lg),
                alternatingRow(
                  graphicOnLeft: false,
                  graphic: permitIllo,
                  copy: _FeatureCopyColumn(
                    title: LandingContent.featurePermitTitle,
                    body: LandingContent.featurePermitBody,
                  ),
                ),
                const SizedBox(height: KooyohSpacing.lg),
                alternatingRow(
                  graphicOnLeft: true,
                  graphic: poolIllo,
                  copy: _FeatureCopyColumn(
                    title: LandingContent.featurePoolTitle,
                    body: LandingContent.featurePoolBody,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FeatureCopyColumn extends StatelessWidget {
  const _FeatureCopyColumn({
    required this.title,
    required this.body,
    this.linkLabel,
    this.onLinkTap,
  });

  final String title;
  final String body;
  final String? linkLabel;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: KooyohTextStyles.cardHeading()),
        const SizedBox(height: 8),
        Text(body, style: KooyohTextStyles.body()),
        if (linkLabel != null && onLinkTap != null) ...[
          const SizedBox(height: KooyohSpacing.sm),
          TextButton(
            onPressed: onLinkTap,
            style: TextButton.styleFrom(
              foregroundColor: KooyohColors.accent,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              linkLabel!,
              style: KooyohTextStyles.bodyBold(
                color: KooyohColors.accent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SOCIAL PROOF
// ─────────────────────────────────────────────
class _SocialProofSection extends StatelessWidget {
  const _SocialProofSection();

  static const _cards = [
    (
      LandingContent.testimonial1Quote,
      LandingContent.testimonial1Attribution,
    ),
    (
      LandingContent.testimonial2Quote,
      LandingContent.testimonial2Attribution,
    ),
    (
      LandingContent.testimonial3Quote,
      LandingContent.testimonial3Attribution,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LandingContent.socialProofHeadline,
          style: KooyohTextStyles.sectionHeading(),
        ),
        const SizedBox(height: KooyohSpacing.lg),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.hasBoundedWidth && c.maxWidth > 900;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: KooyohSpacing.cardGap),
                    Expanded(child: _TestimonialCard(data: _cards[i])),
                  ],
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final card in _cards) ...[
                  _TestimonialCard(data: card),
                  const SizedBox(height: KooyohSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.data});

  final (String quote, String attribution) data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KooyohSpacing.cardPadding),
      decoration: BoxDecoration(
        color: KooyohColors.surface,
        borderRadius: BorderRadius.circular(KooyohRadius.card),
        border: Border.all(color: KooyohColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${data.$1}"',
            style: KooyohTextStyles.body(),
          ),
          const SizedBox(height: 10),
          Text(
            data.$2,
            style: KooyohTextStyles.caption(
              color: KooyohColors.textCaption,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FINAL CTA
// ─────────────────────────────────────────────
class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Material(
          color: c.surfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KooyohRadius.lg),
            side: BorderSide(color: c.outline),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KooyohSpacing.lg,
              vertical: KooyohSpacing.md + 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  LandingContent.finalCtaTitle,
                  style: tt.headlineSmall?.copyWith(color: c.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  LandingContent.finalCtaBody,
                  style: tt.bodyMedium?.copyWith(color: c.onSurfaceMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: KooyohSpacing.md),
                FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: c.onPrimary,
                    elevation: 0,
                  ),
                  child: Text(LandingContent.finalCtaButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FEATURE ILLUSTRATIONS (CustomPaint)
// ─────────────────────────────────────────────
class _LandingChatIllustration extends StatelessWidget {
  const _LandingChatIllustration({
    required this.color,
    required this.accent,
    required this.wide,
  });

  final Color color;
  final Color accent;
  final double wide;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(wide, 200),
      painter: _LandingChatPainter(
        stroke: color,
        accent: accent,
      ),
    );
  }
}

class _LandingChatPainter extends CustomPainter {
  _LandingChatPainter({required this.stroke, required this.accent});

  final Color stroke;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = accent.withValues(alpha: 0.12);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 12, size.width * 0.56, 44),
      const Radius.circular(10),
    );
    canvas.drawRRect(r, fill);
    canvas.drawRRect(r, p);
    final r2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.38,
        72,
        size.width * 0.54,
        52,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(r2, Paint()..color = accent.withValues(alpha: 0.08));
    canvas.drawRRect(r2, p);
    final r3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, 140, size.width * 0.5, 40),
      const Radius.circular(10),
    );
    canvas.drawRRect(r3, fill);
    canvas.drawRRect(r3, p);
  }

  @override
  bool shouldRepaint(covariant _LandingChatPainter old) =>
      old.stroke != stroke || old.accent != accent;
}

class _LandingPermitIllustration extends StatelessWidget {
  const _LandingPermitIllustration({
    required this.color,
    required this.accent,
    required this.wide,
  });

  final Color color;
  final Color accent;
  final double wide;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(wide, 200),
      painter: _LandingPermitPainter(stroke: color, accent: accent),
    );
  }
}

class _LandingPermitPainter extends CustomPainter {
  _LandingPermitPainter({required this.stroke, required this.accent});

  final Color stroke;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final page = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 12, size.width - 36, size.height - 28),
      const Radius.circular(8),
    );
    canvas.drawRRect(page, p);
    var y = 32.0;
    for (var i = 0; i < 6; i++) {
      final lineW = size.width - 72 - (i.isEven ? 0 : 40);
      canvas.drawLine(Offset(40, y), Offset(40 + lineW, y), p);
      y += 18;
    }
    final seal = Paint()
      ..color = accent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(size.width * 0.72, 118), 28, seal);
  }

  @override
  bool shouldRepaint(covariant _LandingPermitPainter old) =>
      old.stroke != stroke || old.accent != accent;
}

class _LandingPoolIllustration extends StatelessWidget {
  const _LandingPoolIllustration({
    required this.color,
    required this.accent,
    required this.wide,
  });

  final Color color;
  final Color accent;
  final double wide;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(wide, 200),
      painter: _LandingPoolPainter(stroke: color, accent: accent),
    );
  }
}

class _LandingPoolPainter extends CustomPainter {
  _LandingPoolPainter({required this.stroke, required this.accent});

  final Color stroke;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final cx = size.width / 2;
    final cy = size.height / 2 + 4;
    canvas.drawCircle(Offset(cx - 52, cy), 32, p);
    canvas.drawCircle(Offset(cx, cy - 18), 36, p);
    canvas.drawCircle(Offset(cx + 56, cy), 30, p);
    final hub = Paint()
      ..color = accent.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx - 20, cy - 8), Offset(cx + 20, cy - 8), hub);
    canvas.drawLine(Offset(cx, cy - 38), Offset(cx, cy + 2), hub);
  }

  @override
  bool shouldRepaint(covariant _LandingPoolPainter old) =>
      old.stroke != stroke || old.accent != accent;
}

// ─────────────────────────────────────────────
// WALLET SECTION
// ─────────────────────────────────────────────
class _WalletSection extends StatelessWidget {
  const _WalletSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Container(
          padding: const EdgeInsets.all(KooyohSpacing.lg),
          decoration: BoxDecoration(
            color: KooyohColors.surface,
            borderRadius: BorderRadius.circular(KooyohRadius.card),
            border: Border.all(color: KooyohColors.border),
          ),
          child: LayoutBuilder(builder: (ctx, constraints) {
            final isWide =
                constraints.hasBoundedWidth && constraints.maxWidth > 550;
            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _WalletBalance(),
                  const SizedBox(width: KooyohSpacing.md),
                  _ConnectWalletBtn(),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WalletBalance(),
                const SizedBox(height: KooyohSpacing.md),
                _ConnectWalletBtn(),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _WalletBalance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: KooyohColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: KooyohColors.border),
          ),
          child: const Icon(Icons.account_balance_wallet_outlined,
              size: 22, color: KooyohColors.textBody),
        ),
        const SizedBox(width: KooyohSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(WalletContent.kyhBalanceLabel,
                style: KooyohTextStyles.caption(
                    color: KooyohColors.textCaption)),
            Row(
              children: [
                Text(WalletContent.demoBalanceAmount,
                    style: KooyohTextStyles.dataLarge()),
                const SizedBox(width: 6),
                Text(WalletContent.kyhTicker,
                    style: KooyohTextStyles.body(
                        color: KooyohColors.textBody)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ConnectWalletBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KooyohSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: () {
          AppFeedback.snack(
            context,
            WalletContent.landingWalletSnack,
          );
        },
        icon: const Icon(Icons.link, size: 18),
        label: Text(WalletContent.connectWallet,
            style: KooyohTextStyles.bodyBold(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: KooyohColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}
