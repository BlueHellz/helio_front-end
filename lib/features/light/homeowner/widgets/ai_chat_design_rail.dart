import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/providers/ai_design_estimate_provider.dart';
import 'package:limye_app/core/providers/solar_design_provider.dart';
import 'package:limye_app/features/light/homeowner/widgets/design_display.dart';
import 'package:limye_app/features/light/homeowner/widgets/solar_estimate_summary_view.dart';
import 'package:limye_app/theme/limye_theme.dart';

/// Desktop AI chat: design canvas, estimate CTA, and optional estimate panel.
class AiChatDesignRail extends ConsumerWidget {
  const AiChatDesignRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designVs = ref.watch(designProvider);
    final estimate = ref.watch(aiDesignEstimateProvider);

    final hasAddress =
        (designVs.intakeAddress ?? '').trim().isNotEmpty;
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
          LimyeSpacing.md,
          LimyeSpacing.sm,
          LimyeSpacing.md,
          LimyeSpacing.sm,
        ),
        child: SizedBox(
          width: double.infinity,
          height: LimyeSpacing.buttonHeight,
          child: FilledButton(
            onPressed:
                estimate.loading || !estimateEnabled ? null : () => onRequest(),
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: LimyeColors.accent,
              foregroundColor: LimyeColors.surface,
              disabledBackgroundColor:
                  LimyeColors.surfaceMuted.withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LimyeRadius.sm),
              ),
            ),
            child: estimate.loading
                ? SizedBox(
                    width: LimyeSpacing.md,
                    height: LimyeSpacing.md,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: LimyeColors.surface,
                    ),
                  )
                : Text(
                    DesignEstimateChatContent.requestEstimateCta,
                    style:
                        LimyeTextStyles.bodyBold(color: LimyeColors.surface),
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
            color: LimyeColors.accent,
          ),
        requestButton(),
        if (estimate.showError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LimyeSpacing.md),
            child: Text(
              DesignEstimateChatContent.loadFailedFriendly,
              style: LimyeTextStyles.caption(color: LimyeColors.error),
            ),
          ),
        if (estimate.presentation != null) ...[
          Divider(height: 1, color: context.colors.outline),
          Expanded(
            flex: 2,
            child: ColoredBox(
              color: context.colors.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(LimyeSpacing.md),
                child: SolarEstimateSummaryView(
                  presentation: estimate.presentation!,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
