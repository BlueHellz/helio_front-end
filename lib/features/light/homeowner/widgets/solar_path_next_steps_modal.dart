import 'package:flutter/material.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

/// Outline CTA (“next steps”) used in the AI design rail / mobile composer.
class SolarPathNextStepsCtaCard extends StatelessWidget {
  const SolarPathNextStepsCtaCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KooyohColors.surface,
        borderRadius: BorderRadius.circular(KooyohRadius.card),
        border: Border.all(color: KooyohColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KooyohSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: KooyohSpacing.buttonHeight,
              child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: KooyohColors.accent,
                  foregroundColor: KooyohColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KooyohRadius.sm),
                  ),
                ),
                child: Text(
                  SolarPathNextStepsContent.railCta,
                  textAlign: TextAlign.center,
                  style: KooyohTextStyles.bodyBold(color: KooyohColors.surface),
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
    barrierColor: KooyohColors.textPrimary.withValues(alpha: 0.08),
    builder: (ctx) {
      final narrow = MediaQuery.sizeOf(ctx).width <
          KooyohSpacing.guidedFormModalMaxWidth + KooyohSpacing.sm * 2;
      return Dialog(
        insetPadding: narrow
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.lg,
                vertical: KooyohSpacing.lg,
              ),
        backgroundColor:
            narrow ? KooyohColors.background : Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            narrow ? 0 : KooyohRadius.card,
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
                  maxWidth: KooyohSpacing.guidedFormModalMaxWidth,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: KooyohColors.background,
                    border: Border.all(color: KooyohColors.border),
                    borderRadius: BorderRadius.circular(KooyohRadius.card),
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
      padding: const EdgeInsets.all(KooyohSpacing.md),
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
                color: KooyohColors.textCaption,
              ),
            ),
          ),
          Text(
            SolarPathNextStepsContent.modalTitle,
            style: KooyohTextStyles.sectionHeading(),
          ),
          const SizedBox(height: KooyohSpacing.md),
          _StepLine(
            icon: Icons.storefront_outlined,
            title: SolarPathNextStepsContent.step1Title,
            body: SolarPathNextStepsContent.step1Body,
          ),
          const SizedBox(height: KooyohSpacing.sm),
          _StepLine(
            icon: Icons.fact_check_outlined,
            title: SolarPathNextStepsContent.step2Title,
            body: SolarPathNextStepsContent.step2Body,
          ),
          const SizedBox(height: KooyohSpacing.sm),
          _StepLine(
            icon: Icons.bolt_outlined,
            title: SolarPathNextStepsContent.step3Title,
            body: SolarPathNextStepsContent.step3Body,
          ),
          const SizedBox(height: KooyohSpacing.md),
          Text(
            SolarPathNextStepsContent.accountExplanation,
            style: KooyohTextStyles.body(),
          ),
          const SizedBox(height: KooyohSpacing.md),
          SizedBox(
            height: KooyohSpacing.buttonHeight,
            child: FilledButton(
              onPressed: onCreateAccount,
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor: KooyohColors.accent,
                foregroundColor: KooyohColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KooyohRadius.sm),
                ),
              ),
              child: Text(
                SolarPathNextStepsContent.createFreeAccount,
                style: KooyohTextStyles.bodyBold(color: KooyohColors.surface),
              ),
            ),
          ),
          const SizedBox(height: KooyohSpacing.sm),
          Center(
            child: TextButton(
              onPressed: onSignIn,
              child: Text(
                SolarPathNextStepsContent.alreadyHaveAccount,
                style: KooyohTextStyles.bodyBold(color: KooyohColors.accent),
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
            color: KooyohColors.surface,
            borderRadius: BorderRadius.circular(KooyohRadius.sm),
            border: Border.all(color: KooyohColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(KooyohSpacing.xs),
            child: Icon(
              icon,
              size: KooyohSpacing.tapTarget / 2,
              color: KooyohColors.accent,
            ),
          ),
        ),
        const SizedBox(width: KooyohSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: KooyohTextStyles.bodyBold(),
              ),
              const SizedBox(height: KooyohSpacing.xs),
              Text(
                body,
                style: KooyohTextStyles.body(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
