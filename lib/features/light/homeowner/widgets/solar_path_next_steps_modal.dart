import 'package:flutter/material.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/theme/limye_theme.dart';

/// Outline CTA (“next steps”) used in the AI design rail / mobile composer.
class SolarPathNextStepsCtaCard extends StatelessWidget {
  const SolarPathNextStepsCtaCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: LimyeColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LimyeSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: LimyeSpacing.buttonHeight,
              child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: LimyeColors.accent,
                  foregroundColor: LimyeColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LimyeRadius.sm),
                  ),
                ),
                child: Text(
                  SolarPathNextStepsContent.railCta,
                  textAlign: TextAlign.center,
                  style: LimyeTextStyles.bodyBold(color: LimyeColors.surface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showSolarPathNextStepsModal(
  BuildContext context, {
  required VoidCallback onCreateAccount,
  required VoidCallback onSignIn,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: LimyeColors.textPrimary.withValues(alpha: 0.08),
    builder: (ctx) {
      final narrow = MediaQuery.sizeOf(ctx).width <
          LimyeSpacing.guidedFormModalMaxWidth + LimyeSpacing.sm * 2;
      return Dialog(
        insetPadding: narrow
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(
                horizontal: LimyeSpacing.lg,
                vertical: LimyeSpacing.lg,
              ),
        backgroundColor:
            narrow ? LimyeColors.background : Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            narrow ? 0 : LimyeRadius.card,
          ),
        ),
        child: narrow
            ? SafeArea(
                child: _SolarPathNextStepsPanel(
                  onCreateAccount: () {
                    Navigator.of(ctx).pop();
                    onCreateAccount();
                  },
                  onSignIn: () {
                    Navigator.of(ctx).pop();
                    onSignIn();
                  },
                ),
              )
            : ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: LimyeSpacing.guidedFormModalMaxWidth,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: LimyeColors.background,
                    border: Border.all(color: LimyeColors.border),
                    borderRadius: BorderRadius.circular(LimyeRadius.card),
                  ),
                  child: _SolarPathNextStepsPanel(
                    onCreateAccount: () {
                      Navigator.of(ctx).pop();
                      onCreateAccount();
                    },
                    onSignIn: () {
                      Navigator.of(ctx).pop();
                      onSignIn();
                    },
                  ),
                ),
              ),
      );
    },
  );
}

class _SolarPathNextStepsPanel extends StatelessWidget {
  const _SolarPathNextStepsPanel({
    required this.onCreateAccount,
    required this.onSignIn,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LimyeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: IconButton(
              tooltip: ButtonsContent.close,
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close_rounded,
                color: LimyeColors.textCaption,
              ),
            ),
          ),
          Text(
            SolarPathNextStepsContent.modalTitle,
            style: LimyeTextStyles.sectionHeading(),
          ),
          const SizedBox(height: LimyeSpacing.md),
          _StepLine(
            icon: Icons.storefront_outlined,
            title: SolarPathNextStepsContent.step1Title,
            body: SolarPathNextStepsContent.step1Body,
          ),
          const SizedBox(height: LimyeSpacing.sm),
          _StepLine(
            icon: Icons.fact_check_outlined,
            title: SolarPathNextStepsContent.step2Title,
            body: SolarPathNextStepsContent.step2Body,
          ),
          const SizedBox(height: LimyeSpacing.sm),
          _StepLine(
            icon: Icons.bolt_outlined,
            title: SolarPathNextStepsContent.step3Title,
            body: SolarPathNextStepsContent.step3Body,
          ),
          const SizedBox(height: LimyeSpacing.md),
          Text(
            SolarPathNextStepsContent.accountExplanation,
            style: LimyeTextStyles.body(),
          ),
          const SizedBox(height: LimyeSpacing.md),
          SizedBox(
            height: LimyeSpacing.buttonHeight,
            child: FilledButton(
              onPressed: onCreateAccount,
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor: LimyeColors.accent,
                foregroundColor: LimyeColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LimyeRadius.sm),
                ),
              ),
              child: Text(
                SolarPathNextStepsContent.createFreeAccount,
                style: LimyeTextStyles.bodyBold(color: LimyeColors.surface),
              ),
            ),
          ),
          const SizedBox(height: LimyeSpacing.sm),
          Center(
            child: TextButton(
              onPressed: onSignIn,
              child: Text(
                SolarPathNextStepsContent.alreadyHaveAccount,
                style: LimyeTextStyles.bodyBold(color: LimyeColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: LimyeColors.surface,
            borderRadius: BorderRadius.circular(LimyeRadius.sm),
            border: Border.all(color: LimyeColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(LimyeSpacing.xs),
            child: Icon(
              icon,
              size: LimyeSpacing.tapTarget / 2,
              color: LimyeColors.accent,
            ),
          ),
        ),
        const SizedBox(width: LimyeSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: LimyeTextStyles.bodyBold(),
              ),
              const SizedBox(height: LimyeSpacing.xs),
              Text(
                body,
                style: LimyeTextStyles.body(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
