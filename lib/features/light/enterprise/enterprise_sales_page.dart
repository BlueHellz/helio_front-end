import 'package:flutter/material.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/shell/web/homeowner_web_chrome.dart';
import 'package:limye_app/theme/limye_theme.dart';

/// Enterprise conversion landing (installers / solar orgs).
class EnterpriseSalesPage extends StatelessWidget {
  const EnterpriseSalesPage({
    super.key,
    this.onHomeTap,
    this.onForBusiness,
    this.onMyProjects,
    this.onEnterprise,
  });

  final VoidCallback? onHomeTap;
  final VoidCallback? onForBusiness;
  final VoidCallback? onMyProjects;
  final VoidCallback? onEnterprise;

  @override
  Widget build(BuildContext context) {
    return HomeownerPublicChrome(
      activeNavIndex: 1,
      onHomeTap: onHomeTap,
      onForBusiness: onForBusiness ?? onHomeTap,
      onMyProjects: onMyProjects,
      onEnterprise: onEnterprise,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: LimyeSpacing.gutter),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: LimyeSpacing.xl),
                Text(
                  EnterpriseContent.salesMetaEyebrow,
                  style: LimyeTextStyles.captionBold(
                    color: LimyeColors.textCaption,
                  ),
                ),
                const SizedBox(height: LimyeSpacing.xs),
                Text(
                  EnterpriseContent.salesHeroTitle,
                  style: LimyeTextStyles.sectionHeading(),
                ),
                const SizedBox(height: LimyeSpacing.md),
                Text(
                  EnterpriseContent.salesHeroBody,
                  style: LimyeTextStyles.body(),
                ),
                const SizedBox(height: LimyeSpacing.lg),
                Text(
                  EnterpriseContent.salesProofLine,
                  style: LimyeTextStyles.body(color: LimyeColors.textCaption),
                ),
                const SizedBox(height: LimyeSpacing.lg),
                SizedBox(
                  height: LimyeSpacing.buttonHeight,
                  child: FilledButton(
                    onPressed: onEnterprise,
                    child: Text(
                      EnterpriseContent.salesHeroCta,
                      style: LimyeTextStyles.bodyBold(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: LimyeSpacing.sm),
                SizedBox(
                  height: LimyeSpacing.buttonHeight,
                  child: OutlinedButton(
                    onPressed: onEnterprise,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LimyeColors.accent,
                      side: const BorderSide(color: LimyeColors.accent),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      EnterpriseContent.salesHeroSecondaryCta,
                      style: LimyeTextStyles.bodyBold(),
                    ),
                  ),
                ),
                const SizedBox(height: LimyeSpacing.xs),
                Text(
                  EnterpriseContent.salesHeroRiskLine,
                  style: LimyeTextStyles.caption(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LimyeSpacing.sectionPaddingVertical / 2),
                Text(
                  EnterpriseContent.salesSectionValueTitle,
                  style: LimyeTextStyles.cardHeading(),
                ),
                const SizedBox(height: LimyeSpacing.md),
                _ValueCard(
                  title: EnterpriseContent.salesValueCrmTitle,
                  body: EnterpriseContent.salesValueCrmBody,
                ),
                const SizedBox(height: LimyeSpacing.md),
                _ValueCard(
                  title: EnterpriseContent.salesValueAiTitle,
                  body: EnterpriseContent.salesValueAiBody,
                ),
                const SizedBox(height: LimyeSpacing.md),
                _ValueCard(
                  title: EnterpriseContent.salesValueTrackTitle,
                  body: EnterpriseContent.salesValueTrackBody,
                ),
                const SizedBox(height: LimyeSpacing.sectionPaddingVertical / 2),
                Text(
                  EnterpriseContent.salesPlansTitle,
                  style: LimyeTextStyles.sectionHeading(),
                ),
                const SizedBox(height: LimyeSpacing.sm),
                Text(
                  EnterpriseContent.salesPlansSubtitle,
                  style: LimyeTextStyles.body(),
                ),
                const SizedBox(height: LimyeSpacing.lg),
                LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth > 560;
                    final free = _PlanColumn(
                      title: EnterpriseContent.salesPlanFreeName,
                      bullets: const [
                        EnterpriseContent.salesPlanFreeBullet1,
                        EnterpriseContent.salesPlanFreeBullet2,
                        EnterpriseContent.salesPlanFreeBullet3,
                      ],
                    );
                    final noir = _PlanColumn(
                      title: EnterpriseContent.salesPlanNoirName,
                      bullets: const [
                        EnterpriseContent.salesPlanNoirBullet1,
                        EnterpriseContent.salesPlanNoirBullet2,
                        EnterpriseContent.salesPlanNoirBullet3,
                      ],
                      footnote: EnterpriseContent.salesPlanNoirFootnote,
                    );
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: free),
                          SizedBox(width: LimyeSpacing.md),
                          Expanded(child: noir),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        free,
                        const SizedBox(height: LimyeSpacing.md),
                        noir,
                      ],
                    );
                  },
                ),
                const SizedBox(height: LimyeSpacing.sectionPaddingVertical / 2),
                Text(
                  EnterpriseContent.salesTestimonialsTitle,
                  style: LimyeTextStyles.cardHeading(),
                ),
                const SizedBox(height: LimyeSpacing.md),
                _QuoteCard(
                  quote: EnterpriseContent.salesTestimonial1Quote,
                  attr: EnterpriseContent.salesTestimonial1Attr,
                ),
                const SizedBox(height: LimyeSpacing.md),
                _QuoteCard(
                  quote: EnterpriseContent.salesTestimonial2Quote,
                  attr: EnterpriseContent.salesTestimonial2Attr,
                ),
                const SizedBox(height: LimyeSpacing.md),
                _QuoteCard(
                  quote: EnterpriseContent.salesTestimonial3Quote,
                  attr: EnterpriseContent.salesTestimonial3Attr,
                ),
                const SizedBox(height: LimyeSpacing.sectionPaddingVertical / 2),
                Text(
                  EnterpriseContent.salesClosingTitle,
                  style: LimyeTextStyles.sectionHeading(),
                ),
                const SizedBox(height: LimyeSpacing.md),
                Text(
                  EnterpriseContent.salesClosingBody,
                  style: LimyeTextStyles.body(),
                ),
                const SizedBox(height: LimyeSpacing.lg),
                SizedBox(
                  height: LimyeSpacing.buttonHeight,
                  child: FilledButton(
                    onPressed: onEnterprise,
                    child: Text(
                      EnterpriseContent.salesClosingCta,
                      style: LimyeTextStyles.bodyBold(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: LimyeSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LimyeSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: LimyeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: LimyeTextStyles.cardHeading()),
          const SizedBox(height: LimyeSpacing.sm),
          Text(body, style: LimyeTextStyles.body()),
        ],
      ),
    );
  }
}

class _PlanColumn extends StatelessWidget {
  const _PlanColumn({
    required this.title,
    required this.bullets,
    this.footnote,
  });

  final String title;
  final List<String> bullets;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LimyeSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: LimyeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: LimyeTextStyles.cardHeading()),
          const SizedBox(height: LimyeSpacing.sm),
          for (final b in bullets) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, size: 18, color: LimyeColors.accent),
                const SizedBox(width: LimyeSpacing.xs),
                Expanded(child: Text(b, style: LimyeTextStyles.body())),
              ],
            ),
            const SizedBox(height: LimyeSpacing.xs),
          ],
          if (footnote != null) ...[
            const SizedBox(height: LimyeSpacing.sm),
            Text(
              footnote!,
              style: LimyeTextStyles.caption(),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.attr});

  final String quote;
  final String attr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LimyeSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: LimyeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('"$quote"', style: LimyeTextStyles.body()),
          const SizedBox(height: LimyeSpacing.sm),
          Text(attr, style: LimyeTextStyles.caption()),
        ],
      ),
    );
  }
}
