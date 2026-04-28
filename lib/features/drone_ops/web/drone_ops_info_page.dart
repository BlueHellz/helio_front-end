import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import '../../../theme/blacklight_theme.dart';
import '../../../core/shell/web/pre_auth_shell.dart';
import '../../../core/app_state.dart';

// ─────────────────────────────────────────────
// BLACK LIGHT — Drone Operator Program (web)
// Public landing for prospective drone operators.
// All data lives in form controllers; submit is a UI state change only.
// ─────────────────────────────────────────────

class DroneOpsInfoPage extends StatefulWidget {
  /// Called when an applicant submits and the demo flow should treat them
  /// as a drone operator (role auto-applied — no role chooser anywhere).
  final void Function(UserRole role)? onApplicationApproved;
  final VoidCallback? onHomeTap;
  final VoidCallback? onSignIn;

  const DroneOpsInfoPage({
    super.key,
    this.onApplicationApproved,
    this.onHomeTap,
    this.onSignIn,
  });

  @override
  State<DroneOpsInfoPage> createState() => _DroneOpsInfoPageState();
}

class _DroneOpsInfoPageState extends State<DroneOpsInfoPage> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _droneModelCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  bool _submitted = false;

  // Locked role — drone operator applicants cannot select another role.
  static const UserRole _appliedRole = UserRole.droneOperator;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _droneModelCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return PreAuthShell(
      activeNavIndex: 1,
      onHomeTap: widget.onHomeTap,
      onSignIn: widget.onSignIn,
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
                const _Hero(),
                const SizedBox(height: BlackLightSpacing.xl),
                const _Benefits(),
                const SizedBox(height: BlackLightSpacing.xl),
                const _Process(),
                const SizedBox(height: BlackLightSpacing.xl),
                const _Requirements(),
                const SizedBox(height: BlackLightSpacing.xl),
                _ApplicationSection(
                  fullNameCtrl: _fullNameCtrl,
                  emailCtrl: _emailCtrl,
                  droneModelCtrl: _droneModelCtrl,
                  zipCtrl: _zipCtrl,
                  appliedRole: _appliedRole,
                  submitted: _submitted,
                  onSubmit: _handleSubmit,
                  onLaunchTerminal: () {
                    widget.onApplicationApproved?.call(_appliedRole);
                  },
                ),
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
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth > 860;
      final left = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RecruitmentPill(),
          const SizedBox(height: BlackLightSpacing.md),
          Text(DroneOpsContent.heroTitle,
              style: BlackLightTextStyles.hero()),
          const SizedBox(height: BlackLightSpacing.md),
          Text(
            DroneOpsContent.heroBody,
            style: BlackLightTextStyles.body(),
          ),
          const SizedBox(height: BlackLightSpacing.md),
          SizedBox(
            height: BlackLightSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                Scrollable.ensureVisible(context,
                    duration: const Duration(milliseconds: 400));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BlackLightColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
              ),
              child: Text(DroneOpsContent.applyNow,
                  style: BlackLightTextStyles.bodyBold(color: Colors.white)),
            ),
          ),
        ],
      );

      final telemetry = AspectRatio(
        aspectRatio: 1.05,
        child: Container(
          decoration: BoxDecoration(
            color: BlackLightColors.surface,
            border: Border.all(color: BlackLightColors.border),
            borderRadius: BorderRadius.circular(BlackLightRadius.card),
          ),
          child: const _TelemetryPanel(),
        ),
      );

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 55, child: left),
            const SizedBox(width: BlackLightSpacing.xl),
            Expanded(flex: 45, child: telemetry),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          const SizedBox(height: BlackLightSpacing.lg),
          telemetry,
        ],
      );
    });
  }
}

class _RecruitmentPill extends StatelessWidget {
  const _RecruitmentPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: BlackLightColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(DroneOpsContent.activeRecruitment,
              style: BlackLightTextStyles.captionBold(
                  color: BlackLightColors.textBody)),
        ],
      ),
    );
  }
}

class _TelemetryPanel extends StatelessWidget {
  const _TelemetryPanel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BlackLightRadius.card),
      child: Stack(
        children: [
          // Dot grid
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter()),
          ),
          // Concentric circles + crosshair
          const Center(child: _ConcentricTarget()),
          // Top-left status tag
          Positioned(
            top: 12,
            left: 12,
            child: _MetaChip(
              text: DroneOpsContent.telemetryChip,
              color: BlackLightColors.textBody,
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: _MetaChip(
              text: DroneOpsContent.hlioRewardChip,
              color: BlackLightColors.accent,
              borderColor: BlackLightColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()
      ..color = BlackLightColors.border
      ..style = PaintingStyle.fill;
    const step = 22.0;
    for (double y = step / 2; y < size.height; y += step) {
      for (double x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.0, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConcentricTarget extends StatelessWidget {
  const _ConcentricTarget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(painter: _TargetPainter()),
    );
  }
}

class _TargetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final ringOuter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = BlackLightColors.border;
    canvas.drawCircle(centre, size.width * 0.48, ringOuter);
    final ringMid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = BlackLightColors.accent;
    canvas.drawCircle(centre, size.width * 0.36, ringMid);
    canvas.drawCircle(
        centre,
        size.width * 0.18,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = BlackLightColors.accent);

    // Crosshair
    final ch = Paint()
      ..color = BlackLightColors.accent
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, centre.dy), Offset(size.width, centre.dy), ch);
    canvas.drawLine(Offset(centre.dx, 0), Offset(centre.dx, size.height), ch);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MetaChip extends StatelessWidget {
  final String text;
  final Color color;
  final Color? borderColor;

  const _MetaChip({required this.text, required this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: borderColor ?? BlackLightColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: BlackLightTextStyles.captionBold(color: color)
              .copyWith(fontSize: 10, letterSpacing: 0.06 * 10)),
    );
  }
}

// ─────────────────────────────────────────────
// BENEFITS
// ─────────────────────────────────────────────
class _Benefits extends StatelessWidget {
  const _Benefits();

  static final _items = [
    (
      Icons.schedule_outlined,
      DroneOpsContent.benefit1Title,
      DroneOpsContent.benefit1Body,
    ),
    (
      Icons.account_balance_wallet_outlined,
      DroneOpsContent.benefit2Title,
      DroneOpsContent.benefit2Body,
    ),
    (
      Icons.school_outlined,
      DroneOpsContent.benefit3Title,
      DroneOpsContent.benefit3Body,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DroneOpsContent.operationalAdvantagesTitle,
            style: BlackLightTextStyles.sectionHeading()),
        const SizedBox(height: BlackLightSpacing.xs),
        Text(DroneOpsContent.operationalAdvantagesSubtitle,
            style: BlackLightTextStyles.body()),
        const SizedBox(height: BlackLightSpacing.lg),
        LayoutBuilder(builder: (context, c) {
          final isWide = c.maxWidth > 860;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _items
                  .map((i) =>
                      Expanded(child: _BenefitCard(icon: i.$1, title: i.$2, body: i.$3)))
                  .expand((w) =>
                      [w, const SizedBox(width: BlackLightSpacing.gutter)])
                  .take(_items.length * 2 - 1)
                  .toList(),
            );
          }
          return Column(
            children: _items
                .map((i) => _BenefitCard(icon: i.$1, title: i.$2, body: i.$3))
                .expand((w) => [w, const SizedBox(height: BlackLightSpacing.md)])
                .take(_items.length * 2 - 1)
                .toList(),
          );
        }),
      ],
    );
  }
}

class _BenefitCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String body;

  const _BenefitCard(
      {required this.icon, required this.title, required this.body});

  @override
  State<_BenefitCard> createState() => _BenefitCardState();
}

class _BenefitCardState extends State<_BenefitCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(BlackLightSpacing.md),
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
              child: Icon(
                widget.icon,
                size: 22,
                color: _hover
                    ? BlackLightColors.accent
                    : BlackLightColors.textPrimary,
              ),
            ),
            const SizedBox(height: BlackLightSpacing.md),
            Text(widget.title, style: BlackLightTextStyles.cardHeading()),
            const SizedBox(height: 6),
            Text(widget.body, style: BlackLightTextStyles.body()),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROCESS
// ─────────────────────────────────────────────
class _Process extends StatelessWidget {
  const _Process();

  static final _steps = [
    (
      DroneOpsContent.processStep1Num,
      DroneOpsContent.processStep1Title,
      DroneOpsContent.processStep1Body,
    ),
    (
      DroneOpsContent.processStep2Num,
      DroneOpsContent.processStep2Title,
      DroneOpsContent.processStep2Body,
    ),
    (
      DroneOpsContent.processStep3Num,
      DroneOpsContent.processStep3Title,
      DroneOpsContent.processStep3Body,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: BlackLightSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: BlackLightColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DroneOpsContent.deploymentTitle,
              style: BlackLightTextStyles.sectionHeading()),
          const SizedBox(height: BlackLightSpacing.xs),
          Text(DroneOpsContent.deploymentSubtitle,
              style: BlackLightTextStyles.body()),
          const SizedBox(height: BlackLightSpacing.lg),
          LayoutBuilder(builder: (context, c) {
            final isWide = c.maxWidth > 720;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_steps.length, (i) {
                  final s = _steps[i];
                  final isLast = i == _steps.length - 1;
                  return Expanded(
                    child: _ProcessStep(
                        number: s.$1,
                        title: s.$2,
                        body: s.$3,
                        highlighted: isLast),
                  );
                }),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(_steps.length, (i) {
                final s = _steps[i];
                final isLast = i == _steps.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: BlackLightSpacing.md),
                  child: _ProcessStep(
                      number: s.$1,
                      title: s.$2,
                      body: s.$3,
                      highlighted: isLast),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final bool highlighted;

  const _ProcessStep({
    required this.number,
    required this.title,
    required this.body,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                highlighted ? BlackLightColors.accent : BlackLightColors.surface,
            border: Border.all(
                color: highlighted
                    ? BlackLightColors.accent
                    : BlackLightColors.border),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(number,
              style: BlackLightTextStyles.bodyBold(
                  color: highlighted
                      ? Colors.white
                      : BlackLightColors.textPrimary)),
        ),
        const SizedBox(height: BlackLightSpacing.md),
        Text(title,
            style: BlackLightTextStyles.cardHeading(),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(body,
            style: BlackLightTextStyles.body(), textAlign: TextAlign.center),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// REQUIREMENTS
// ─────────────────────────────────────────────
class _Requirements extends StatelessWidget {
  const _Requirements();

  static final _hardware = [
    DroneOpsContent.hardwareReq1,
    DroneOpsContent.hardwareReq2,
    DroneOpsContent.hardwareReq3,
  ];
  static final _eligibility = [
    DroneOpsContent.eligibilityReq1,
    DroneOpsContent.eligibilityReq2,
    DroneOpsContent.eligibilityReq3,
  ];

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
        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DroneOpsContent.systemRequirementsTitle,
                style: BlackLightTextStyles.sectionHeading()),
            const SizedBox(height: BlackLightSpacing.xs),
            Text(DroneOpsContent.systemRequirementsSubtitle,
                style: BlackLightTextStyles.body()),
          ],
        );
        final lists = LayoutBuilder(builder: (context, lc) {
          final isWideList = lc.maxWidth > 540;
          if (isWideList) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _ReqList(
                        icon: Icons.flight_takeoff_outlined,
                        label: DroneOpsContent.requirementsHardwareHeading,
                        items: _hardware)),
                const SizedBox(width: BlackLightSpacing.lg),
                Expanded(
                    child: _ReqList(
                        icon: Icons.verified_user_outlined,
                        label: DroneOpsContent.requirementsEligibilityHeading,
                        items: _eligibility)),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReqList(
                  icon: Icons.flight_takeoff_outlined,
                  label: DroneOpsContent.requirementsHardwareHeading,
                  items: _hardware),
              const SizedBox(height: BlackLightSpacing.md),
              _ReqList(
                  icon: Icons.verified_user_outlined,
                  label: DroneOpsContent.requirementsEligibilityHeading,
                  items: _eligibility),
            ],
          );
        });

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: intro),
              const SizedBox(width: BlackLightSpacing.lg),
              Expanded(flex: 2, child: lists),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            intro,
            const SizedBox(height: BlackLightSpacing.md),
            lists,
          ],
        );
      }),
    );
  }
}

class _ReqList extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;

  const _ReqList(
      {required this.icon, required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: BlackLightColors.textBody),
            const SizedBox(width: 8),
            Text(label,
                style: BlackLightTextStyles.captionBold(
                    color: BlackLightColors.textBody)),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7, right: 8),
                    child: Icon(Icons.circle,
                        size: 6, color: BlackLightColors.accent),
                  ),
                  Expanded(
                    child: Text(t,
                        style: BlackLightTextStyles.body(
                            color: BlackLightColors.textPrimary)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// APPLICATION
// ─────────────────────────────────────────────
class _ApplicationSection extends StatelessWidget {
  final TextEditingController fullNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController droneModelCtrl;
  final TextEditingController zipCtrl;
  final UserRole appliedRole;
  final bool submitted;
  final VoidCallback onSubmit;
  final VoidCallback onLaunchTerminal;

  const _ApplicationSection({
    required this.fullNameCtrl,
    required this.emailCtrl,
    required this.droneModelCtrl,
    required this.zipCtrl,
    required this.appliedRole,
    required this.submitted,
    required this.onSubmit,
    required this.onLaunchTerminal,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth > 880;
      final left = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DroneOpsContent.initiateApplicationTitle,
              style: BlackLightTextStyles.sectionHeading()),
          const SizedBox(height: BlackLightSpacing.xs),
          Text(
              DroneOpsContent.initiateApplicationBody,
              style: BlackLightTextStyles.body()),
          const SizedBox(height: BlackLightSpacing.md),
          Container(
            padding: const EdgeInsets.all(BlackLightSpacing.md),
            decoration: BoxDecoration(
              color: BlackLightColors.surface,
              border: Border.all(color: BlackLightColors.border),
              borderRadius: BorderRadius.circular(BlackLightRadius.card),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: BlackLightColors.accent, size: 22),
                const SizedBox(width: BlackLightSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DroneOpsContent.alreadyApprovedTitle,
                          style: BlackLightTextStyles.bodyBold()),
                      const SizedBox(height: 4),
                      Text(
                          DroneOpsContent.alreadyApprovedBody,
                          style: BlackLightTextStyles.body()),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: onLaunchTerminal,
                        child: Text(DroneOpsContent.launchTerminal,
                            style: BlackLightTextStyles.bodyBold(
                                color: BlackLightColors.accent)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );

      final right = _ApplicationForm(
        fullNameCtrl: fullNameCtrl,
        emailCtrl: emailCtrl,
        droneModelCtrl: droneModelCtrl,
        zipCtrl: zipCtrl,
        appliedRole: appliedRole,
        submitted: submitted,
        onSubmit: onSubmit,
      );

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: left),
            const SizedBox(width: BlackLightSpacing.xl),
            Expanded(flex: 7, child: right),
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
    });
  }
}

class _ApplicationForm extends StatelessWidget {
  final TextEditingController fullNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController droneModelCtrl;
  final TextEditingController zipCtrl;
  final UserRole appliedRole;
  final bool submitted;
  final VoidCallback onSubmit;

  const _ApplicationForm({
    required this.fullNameCtrl,
    required this.emailCtrl,
    required this.droneModelCtrl,
    required this.zipCtrl,
    required this.appliedRole,
    required this.submitted,
    required this.onSubmit,
  });

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
          // Auto-applied role badge — locked, not selectable.
          _RoleAppliedBadge(role: appliedRole),
          const SizedBox(height: BlackLightSpacing.md),
          LayoutBuilder(builder: (context, c) {
            final isWide = c.maxWidth > 540;
            final fullName = _FieldInput(
              label: DroneOpsContent.fieldFullNameLabel,
              hint: DroneOpsContent.fieldFullNameHint,
              controller: fullNameCtrl,
            );
            final email = _FieldInput(
              label: DroneOpsContent.fieldEmailLabel,
              hint: DroneOpsContent.fieldEmailHint,
              controller: emailCtrl,
              type: TextInputType.emailAddress,
            );
            final drone = _FieldInput(
              label: DroneOpsContent.fieldDroneLabel,
              hint: DroneOpsContent.fieldDroneHint,
              controller: droneModelCtrl,
            );
            final zip = _FieldInput(
              label: DroneOpsContent.fieldZipLabel,
              hint: DroneOpsContent.fieldZipHint,
              controller: zipCtrl,
              type: TextInputType.number,
            );
            if (isWide) {
              return Column(
                children: [
                  Row(children: [
                    Expanded(child: fullName),
                    const SizedBox(width: BlackLightSpacing.md),
                    Expanded(child: email),
                  ]),
                  const SizedBox(height: BlackLightSpacing.md),
                  Row(children: [
                    Expanded(child: drone),
                    const SizedBox(width: BlackLightSpacing.md),
                    Expanded(child: zip),
                  ]),
                ],
              );
            }
            return Column(
              children: [
                fullName,
                const SizedBox(height: BlackLightSpacing.md),
                email,
                const SizedBox(height: BlackLightSpacing.md),
                drone,
                const SizedBox(height: BlackLightSpacing.md),
                zip,
              ],
            );
          }),
          const SizedBox(height: BlackLightSpacing.md),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.sm),
          LayoutBuilder(builder: (context, c) {
            final isWide = c.maxWidth > 540;
            final disclaimer = Text(
              DroneOpsContent.submitDisclaimer,
              style: BlackLightTextStyles.caption(
                  color: BlackLightColors.textBody),
            );
            final cta = SizedBox(
              height: BlackLightSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: submitted ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: submitted
                      ? BlackLightColors.surface
                      : BlackLightColors.accent,
                  foregroundColor:
                      submitted ? BlackLightColors.textPrimary : Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (submitted) ...[
                      const Icon(Icons.check,
                          size: 18, color: BlackLightColors.accent),
                      const SizedBox(width: 8),
                    ],
                    Text(
                        submitted
                            ? DroneOpsContent.applicationSent
                            : DroneOpsContent.submitTelemetry,
                        style: BlackLightTextStyles.bodyBold(
                            color: submitted
                                ? BlackLightColors.textPrimary
                                : Colors.white)),
                  ],
                ),
              ),
            );
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: disclaimer),
                  const SizedBox(width: BlackLightSpacing.md),
                  cta,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                disclaimer,
                const SizedBox(height: BlackLightSpacing.md),
                cta,
              ],
            );
          }),
          if (submitted) ...[
            const SizedBox(height: BlackLightSpacing.md),
            Container(
              padding: const EdgeInsets.all(BlackLightSpacing.md),
              decoration: BoxDecoration(
                color: BlackLightColors.background,
                border: Border.all(color: BlackLightColors.border),
                borderRadius: BorderRadius.circular(BlackLightRadius.card),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.mark_email_read_outlined,
                      color: BlackLightColors.accent, size: 22),
                  const SizedBox(width: BlackLightSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DroneOpsContent.verificationPendingTitle,
                            style: BlackLightTextStyles.bodyBold()),
                        const SizedBox(height: 4),
                        Text(
                            DroneOpsContent.verificationPendingBody,
                            style: BlackLightTextStyles.body()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoleAppliedBadge extends StatelessWidget {
  final UserRole role;

  const _RoleAppliedBadge({required this.role});

  String get _label {
    switch (role) {
      case UserRole.droneOperator:
        return DroneOpsContent.roleLabelDroneOperator;
      default:
        return DroneOpsContent.roleLabelOperator;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.accent),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline,
              size: 14, color: BlackLightColors.accent),
          const SizedBox(width: 8),
          Text('${DroneOpsContent.applyingAsPrefix}$_label',
              style: BlackLightTextStyles.captionBold(
                  color: BlackLightColors.accent)),
        ],
      ),
    );
  }
}

class _FieldInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType type;

  const _FieldInput({
    required this.label,
    required this.hint,
    required this.controller,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: BlackLightTextStyles.captionBold(
                color: BlackLightColors.textBody)),
        const SizedBox(height: 6),
        SizedBox(
          height: BlackLightSpacing.inputHeight,
          child: TextField(
            controller: controller,
            keyboardType: type,
            style:
                BlackLightTextStyles.body(color: BlackLightColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: BlackLightTextStyles.body(
                  color: BlackLightColors.textCaption),
              filled: true,
              fillColor: BlackLightColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BlackLightRadius.input),
                borderSide:
                    const BorderSide(color: BlackLightColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BlackLightRadius.input),
                borderSide:
                    const BorderSide(color: BlackLightColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BlackLightRadius.input),
                borderSide: const BorderSide(
                    color: BlackLightColors.accent, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
