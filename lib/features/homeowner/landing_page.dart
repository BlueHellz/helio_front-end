import 'package:flutter/material.dart';
import 'package:blacklight_app/core/content/content_registry.dart';

import '../../core/ui/app_feedback.dart';
import '../../theme/blacklight_theme.dart';
import '../../core/illustrations/geometric_illustrations.dart';
import '../../core/shell/web/pre_auth_shell.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback? onGetStarted;
  final VoidCallback? onSignIn;
  final VoidCallback? onHomeTap;
  final VoidCallback? onOpenDroneOps;
  final VoidCallback? onOpenPool;
  final VoidCallback? onOpenEv;

  const LandingPage({
    super.key,
    this.onGetStarted,
    this.onSignIn,
    this.onHomeTap,
    this.onOpenDroneOps,
    this.onOpenPool,
    this.onOpenEv,
  });

  @override
  Widget build(BuildContext context) {
    return PreAuthShell(
      activeNavIndex: 0,
      onSignIn: onSignIn,
      onHomeTap: onHomeTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero — constrained to max width, centered
          _Constrained(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: BlackLightSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: BlackLightSpacing.sectionPaddingVertical),
                  _HeroSection(onGetStarted: onGetStarted),
                  const SizedBox(height: BlackLightSpacing.sectionPaddingVertical),
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
                  horizontal: BlackLightSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: BlackLightSpacing.sectionPaddingVertical),
                  _HowItWorks(),
                  SizedBox(height: BlackLightSpacing.sectionPaddingVertical),
                ],
              ),
            ),
          ),

          // Pillars — three programs (drone ops / pool / EV)
          _Constrained(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: BlackLightSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: BlackLightSpacing.sectionPaddingVertical),
                  _PillarsSection(
                    onOpenDroneOps: onOpenDroneOps,
                    onOpenPool: onOpenPool,
                    onOpenEv: onOpenEv,
                  ),
                  const SizedBox(height: BlackLightSpacing.sectionPaddingVertical),
                ],
              ),
            ),
          ),

          // For business — full bleed
          const _ForBusinessSection(),

          // Wallet — constrained, centered
          _Constrained(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: BlackLightSpacing.gutter),
              child: const Column(
                children: [
                  SizedBox(height: BlackLightSpacing.sectionPaddingVertical),
                  _WalletSection(),
                  SizedBox(height: BlackLightSpacing.sectionPaddingVertical),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PILLARS — Drone Ops · Solar Pool · EV Charging
// ─────────────────────────────────────────────
class _PillarsSection extends StatelessWidget {
  final VoidCallback? onOpenDroneOps;
  final VoidCallback? onOpenPool;
  final VoidCallback? onOpenEv;

  const _PillarsSection({
    this.onOpenDroneOps,
    this.onOpenPool,
    this.onOpenEv,
  });

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
        onTap: onOpenDroneOps,
      ),
      _PillarCardData(
        eyebrow: LandingContent.pillarPoolEyebrow,
        title: LandingContent.pillarPoolTitle,
        body:
            LandingContent.pillarPoolBody,
        icon: Icons.savings_outlined,
        cta: LandingContent.pillarPoolCta,
        onTap: onOpenPool,
      ),
      _PillarCardData(
        eyebrow: LandingContent.pillarEvEyebrow,
        title: LandingContent.pillarEvTitle,
        body:
            LandingContent.pillarEvBody,
        icon: Icons.ev_station_outlined,
        cta: LandingContent.pillarEvCta,
        onTap: onOpenEv,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LandingContent.programsHeadline,
            style: BlackLightTextStyles.sectionHeading()),
        const SizedBox(height: BlackLightSpacing.xs),
        Text(
            LandingContent.programsSubcopy,
            style: BlackLightTextStyles.body()),
        const SizedBox(height: BlackLightSpacing.lg),
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
                        const SizedBox(width: BlackLightSpacing.cardGap),
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
                .expand((w) => [w, const SizedBox(height: BlackLightSpacing.md)])
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
          padding: const EdgeInsets.all(BlackLightSpacing.cardPadding),
          decoration: BoxDecoration(
            color: BlackLightColors.surface,
            borderRadius: BorderRadius.circular(BlackLightRadius.card),
            border: Border.all(
                color: _hover
                    ? BlackLightColors.accent
                    : BlackLightColors.border),
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
                child: Icon(widget.data.icon,
                    size: 22, color: BlackLightColors.accent),
              ),
              const SizedBox(height: BlackLightSpacing.md),
              Text(widget.data.eyebrow,
                  style: BlackLightTextStyles.captionBold(
                      color: BlackLightColors.textBody)),
              const SizedBox(height: 4),
              Text(widget.data.title,
                  style: BlackLightTextStyles.cardHeading()),
              const SizedBox(height: 6),
              Text(widget.data.body, style: BlackLightTextStyles.body()),
              const SizedBox(height: BlackLightSpacing.md),
              Row(
                children: [
                  Text(widget.data.cta,
                      style: BlackLightTextStyles.bodyBold(
                          color: BlackLightColors.accent)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      size: 16, color: BlackLightColors.accent),
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
            const BoxConstraints(maxWidth: BlackLightSpacing.containerMax),
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
          const SizedBox(width: BlackLightSpacing.xl),
          const Expanded(
            flex: 45,
            child: Center(
              child: IsometricHouseIllustration(width: 480, height: 400),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroContent(onGetStarted: onGetStarted),
        const SizedBox(height: BlackLightSpacing.lg),
        const IsometricHouseIllustration(width: double.infinity, height: 280),
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
          style: BlackLightTextStyles.hero(),
        ),
        const SizedBox(height: BlackLightSpacing.md),
        Text(
          LandingContent.heroBody,
          style: BlackLightTextStyles.body(),
        ),
        const SizedBox(height: BlackLightSpacing.lg),
        _AddressInputRow(
          controller: _addressCtrl,
          onGetStarted: widget.onGetStarted,
        ),
        const SizedBox(height: BlackLightSpacing.xs),
        Row(
          children: [
            const Icon(Icons.bolt,
                size: 14, color: BlackLightColors.textCaption),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                LandingContent.heroTrustLine,
                style: BlackLightTextStyles.caption(
                    color: BlackLightColors.textCaption),
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
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LandingContent.heroAddressLabel,
                  style: BlackLightTextStyles.captionBold(
                      color: BlackLightColors.textCaption),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: BlackLightSpacing.inputHeight,
                  child: TextField(
                    controller: controller,
                    style: BlackLightTextStyles.body(
                        color: BlackLightColors.textPrimary),
                    decoration: _inputDeco(LandingContent.heroAddressPlaceholder),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: BlackLightSpacing.sm),
          SizedBox(
            height: BlackLightSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: BlackLightColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
              ),
              child: Text(
                LandingContent.heroPrimaryCta,
                style: BlackLightTextStyles.bodyBold(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: BlackLightSpacing.inputHeight,
          child: TextField(
            controller: controller,
            style:
                BlackLightTextStyles.body(color: BlackLightColors.textPrimary),
            decoration: _inputDeco(LandingContent.heroAddressPlaceholder),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: BlackLightSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: BlackLightColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: Text(
              LandingContent.heroPrimaryCta,
              style: BlackLightTextStyles.bodyBold(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            BlackLightTextStyles.body(color: BlackLightColors.textCaption),
        filled: true,
        fillColor: BlackLightColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.input),
          borderSide: const BorderSide(color: BlackLightColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.input),
          borderSide: const BorderSide(color: BlackLightColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.input),
          borderSide:
              const BorderSide(color: BlackLightColors.accent, width: 1.5),
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
      padding: const EdgeInsets.symmetric(vertical: BlackLightSpacing.md),
      decoration: const BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: BlackLightColors.border),
        ),
      ),
      child: Wrap(
        spacing: BlackLightSpacing.xl,
        runSpacing: BlackLightSpacing.sm,
        alignment: WrapAlignment.center,
        children: _items
            .map(
              (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$1, size: 18, color: BlackLightColors.textBody),
                  const SizedBox(width: 6),
                  Text(
                    item.$2,
                    style: BlackLightTextStyles.caption(
                        color: BlackLightColors.textBody),
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
    (
      LandingContent.step1Title,
      LandingContent.step1Body,
      Icons.location_on_outlined,
    ),
    (
      LandingContent.step2Title,
      LandingContent.step2Body,
      Icons.bolt_outlined,
    ),
    (
      LandingContent.step3Title,
      LandingContent.step3Body,
      Icons.architecture_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LandingContent.howItWorksTitle, style: BlackLightTextStyles.sectionHeading()),
        const SizedBox(height: BlackLightSpacing.lg),
        // Row + Expanded requires bounded width. Unbounded maxWidth in some
        // browsers makes `infinity > 700` true, which would pick the Row and
        // crash layout — content below (pillars, footer) never shows.
        LayoutBuilder(builder: (context, constraints) {
          final isWide =
              constraints.hasBoundedWidth && constraints.maxWidth > 700;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _steps
                  .map((s) => Expanded(child: _StepCard(step: s)))
                  .expand((w) => [
                        w,
                        const SizedBox(width: BlackLightSpacing.cardGap),
                      ])
                  .take(_steps.length * 2 - 1)
                  .toList(),
            );
          }
          return Column(
            children: _steps
                .map((s) => _StepCard(step: s))
                .expand((w) => [
                      w,
                      const SizedBox(height: BlackLightSpacing.cardGap),
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
  final (String, String, IconData) step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.cardPadding),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
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
            child: Icon(step.$3, size: 20, color: BlackLightColors.accent),
          ),
          const SizedBox(height: BlackLightSpacing.md),
          Text(step.$1, style: BlackLightTextStyles.cardHeading()),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.xs),
          Text(step.$2, style: BlackLightTextStyles.body()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FOR BUSINESS — full bleed
// ─────────────────────────────────────────────
class _ForBusinessSection extends StatelessWidget {
  const _ForBusinessSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: BlackLightSpacing.gutter,
          vertical: BlackLightSpacing.sectionPaddingVertical),
      color: BlackLightColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: BlackLightSpacing.containerMax),
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
                            style: BlackLightTextStyles.sectionHeading()),
                        const SizedBox(height: BlackLightSpacing.xs),
                        Text(
                          LandingContent.forBusinessBody,
                          style: BlackLightTextStyles.body(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: BlackLightSpacing.xl),
                  SizedBox(
                    height: BlackLightSpacing.buttonHeight,
                    child: OutlinedButton(
                      onPressed: () {
                        AppFeedback.showInfoDialog(
                          context,
                          title: LandingContent.forBusinessDialogTitle,
                          message: LandingContent.forBusinessDialogMessage,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BlackLightColors.textPrimary,
                        side: const BorderSide(color: BlackLightColors.border),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                      ),
                      child: Text(LandingContent.forBusinessLearnMore,
                          style: BlackLightTextStyles.bodyBold(
                              color: BlackLightColors.textPrimary)),
                    ),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LandingContent.forBusinessTitle,
                    style: BlackLightTextStyles.sectionHeading()),
                const SizedBox(height: BlackLightSpacing.xs),
                Text(
                  LandingContent.forBusinessBody,
                  style: BlackLightTextStyles.body(),
                ),
                const SizedBox(height: BlackLightSpacing.md),
                SizedBox(
                  height: BlackLightSpacing.buttonHeight,
                  child: OutlinedButton(
                    onPressed: () {
                      AppFeedback.showInfoDialog(
                        context,
                        title: LandingContent.forBusinessDialogTitle,
                        message: LandingContent.forBusinessDialogMessage,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BlackLightColors.textPrimary,
                      side: const BorderSide(color: BlackLightColors.border),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(LandingContent.forBusinessLearnMore,
                        style: BlackLightTextStyles.bodyBold(
                            color: BlackLightColors.textPrimary)),
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
          padding: const EdgeInsets.all(BlackLightSpacing.lg),
          decoration: BoxDecoration(
            color: BlackLightColors.surface,
            borderRadius: BorderRadius.circular(BlackLightRadius.card),
            border: Border.all(color: BlackLightColors.border),
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
                  const SizedBox(width: BlackLightSpacing.md),
                  _ConnectWalletBtn(),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WalletBalance(),
                const SizedBox(height: BlackLightSpacing.md),
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
            color: BlackLightColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: BlackLightColors.border),
          ),
          child: const Icon(Icons.account_balance_wallet_outlined,
              size: 22, color: BlackLightColors.textBody),
        ),
        const SizedBox(width: BlackLightSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(WalletContent.hlioBalanceLabel,
                style: BlackLightTextStyles.caption(
                    color: BlackLightColors.textCaption)),
            Row(
              children: [
                Text(WalletContent.demoBalanceAmount,
                    style: BlackLightTextStyles.dataLarge()),
                const SizedBox(width: 6),
                Text(WalletContent.hlioTicker,
                    style: BlackLightTextStyles.body(
                        color: BlackLightColors.textBody)),
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
      height: BlackLightSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: () {
          AppFeedback.snack(
            context,
            WalletContent.landingWalletSnack,
          );
        },
        icon: const Icon(Icons.link, size: 18),
        label: Text(WalletContent.connectWallet,
            style: BlackLightTextStyles.bodyBold(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: BlackLightColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}
