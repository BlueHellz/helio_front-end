import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/providers/ai_chat_design_email_save_provider.dart';
import 'package:kooyoh_app/core/providers/ai_design_estimate_provider.dart';
import 'package:kooyoh_app/core/providers/solar_design_provider.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/ai_chat_design_email_save_flow.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/design_display.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/solar_estimate_summary_view.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/solar_path_next_steps_modal.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

/// Desktop AI chat: design canvas, estimate CTA, and optional estimate panel.
class AiChatDesignRail extends ConsumerWidget {
  const AiChatDesignRail({super.key, this.onSolarPathNextSteps});

  final VoidCallback? onSolarPathNextSteps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designVs = ref.watch(designProvider);
    final estimate = ref.watch(aiDesignEstimateProvider);
    final saveSending = ref.watch(aiChatDesignEmailSaveProvider);

    final hasAddress =
        (designVs.intakeMailingAddressOneLine ?? '').trim().isNotEmpty;
    final designReady =
        designVs.data != null && designVs.data!.roofSegments.isNotEmpty;
    final estimateEnabled = hasAddress && designReady;

    Future<void> onRequest() async {
      await ref.read(aiDesignEstimateProvider.notifier).requestEstimate();
    }

    Widget wrapDisabledHint(Widget child) {
      if (estimateEnabled) return child;
      return Tooltip(
        message: DesignEstimateChatContent.needAddressFirst,
        child: child,
      );
    }

    Widget requestButton() {
      final inner = Padding(
        padding: const EdgeInsets.fromLTRB(
          KooyohSpacing.md,
          KooyohSpacing.sm,
          KooyohSpacing.md,
          KooyohSpacing.sm,
        ),
        child: SizedBox(
          width: double.infinity,
          height: KooyohSpacing.buttonHeight,
          child: FilledButton(
            onPressed:
                estimate.loading || saveSending || !estimateEnabled ? null : () => onRequest(),
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: KooyohColors.accent,
              foregroundColor: KooyohColors.surface,
              disabledBackgroundColor:
                  KooyohColors.surfaceMuted.withValues(alpha: 0.9),
              disabledForegroundColor: KooyohColors.textBody,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KooyohRadius.sm),
              ),
            ),
            child: estimate.loading
                ? SizedBox(
                    width: KooyohSpacing.md,
                    height: KooyohSpacing.md,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: KooyohColors.surface,
                    ),
                  )
                : Text(
                    DesignEstimateChatContent.requestEstimateCta,
                    style:
                        KooyohTextStyles.bodyBold(color: KooyohColors.surface),
                  ),
          ),
        ),
      );
      return wrapDisabledHint(inner);
    }

    Widget saveButton() {
      final inner = Padding(
        padding: const EdgeInsets.fromLTRB(
          KooyohSpacing.md,
          0,
          KooyohSpacing.md,
          KooyohSpacing.sm,
        ),
        child: SizedBox(
          width: double.infinity,
          height: KooyohSpacing.buttonHeight,
          child: OutlinedButton(
            onPressed: saveSending || !estimateEnabled
                ? null
                : () => runAiChatSaveDesignEmailFlow(context: context, ref: ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: KooyohColors.accent,
              side: const BorderSide(color: KooyohColors.border, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KooyohRadius.sm),
              ),
            ),
            child: saveSending
                ? SizedBox(
                    width: KooyohSpacing.md,
                    height: KooyohSpacing.md,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: KooyohColors.accent,
                    ),
                  )
                : Text(
                    DesignSaveEmailContent.saveEmailDesignCta,
                    style: KooyohTextStyles.bodyBold(color: KooyohColors.accent),
                  ),
          ),
        ),
      );
      return wrapDisabledHint(inner);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: estimate.presentation != null ? 3 : 1,
          child: const DesignDisplayWidget(),
        ),
        if (estimate.loading)
          LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: context.colors.surfaceMuted,
            color: KooyohColors.accent,
          ),
        requestButton(),
        saveButton(),
        if (estimate.showError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KooyohSpacing.md),
            child: Text(
              DesignEstimateChatContent.loadFailedFriendly,
              style: KooyohTextStyles.caption(color: KooyohColors.error),
            ),
          ),
        if (estimate.presentation != null) ...[
          Divider(height: 1, color: context.colors.outline),
          Expanded(
            flex: 2,
            child: ColoredBox(
              color: context.colors.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(KooyohSpacing.md),
                child: SolarEstimateSummaryView(
                  presentation: estimate.presentation!,
                ),
              ),
            ),
          ),
        ],
        if (estimate.presentation != null &&
            onSolarPathNextSteps != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KooyohSpacing.md,
              KooyohSpacing.sm,
              KooyohSpacing.md,
              KooyohSpacing.sm,
            ),
            child: SolarPathNextStepsCtaCard(onTap: onSolarPathNextSteps!),
          ),
        ],
      ],
    );
  }
}
