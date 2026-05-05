import 'package:flutter/material.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/ui/app_feedback.dart';
import 'package:limye_app/features/light/drone_ops/web/drone_ops_info_page.dart';
import 'package:limye_app/features/light/ev/ev_info_page.dart';
import 'package:limye_app/features/light/landing/landing_inline_program.dart';
import 'package:limye_app/features/light/pool_funding/web/pool_info_page.dart';
import 'package:limye_app/theme/limye_theme.dart';

/// Inline program detail on the landing page (navbar + footer stay visible).
class LandingProgramExpanded extends StatelessWidget {
  const LandingProgramExpanded({
    super.key,
    required this.program,
    required this.onBack,
  });

  final LandingInlineProgram program;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            LimyeSpacing.gutter,
            LimyeSpacing.md,
            LimyeSpacing.gutter,
            LimyeSpacing.sm,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: LimyeColors.accent,
              ),
              label: Text(
                ButtonsContent.back,
                style: LimyeTextStyles.bodyBold(color: LimyeColors.accent),
              ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: LimyeSpacing.containerMax),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LimyeSpacing.gutter,
              ),
              child: _ProgramBody(program: program),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgramBody extends StatelessWidget {
  const _ProgramBody({required this.program});

  final LandingInlineProgram program;

  @override
  Widget build(BuildContext context) {
    switch (program) {
      case LandingInlineProgram.drone:
        return DroneOpsProgramBody(
          onLaunchTerminal: () => AppFeedback.comingSoon(context),
        );
      case LandingInlineProgram.pool:
        return PoolProgramBody(
          onJoinWaitlist: () => AppFeedback.comingSoon(context),
        );
      case LandingInlineProgram.ev:
        return EvProgramBody(
          onApplyAsHost: () => AppFeedback.comingSoon(context),
        );
    }
  }
}
