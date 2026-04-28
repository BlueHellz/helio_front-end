import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import '../../theme/blacklight_theme.dart';
import '../../core/models/project.dart';
import '../../core/widgets/status_badge.dart';

class HomeownerQuoteRequest extends StatefulWidget {
  final Project? project;
  final VoidCallback? onSubmit;
  final VoidCallback? onBack;

  const HomeownerQuoteRequest({
    super.key,
    this.project,
    this.onSubmit,
    this.onBack,
  });

  @override
  State<HomeownerQuoteRequest> createState() => _HomeownerQuoteRequestState();
}

class _HomeownerQuoteRequestState extends State<HomeownerQuoteRequest> {
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _installerCount = 3;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: _hasSubmitted
            ? _SuccessState(onBack: widget.onBack)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      if (widget.onBack != null)
                        GestureDetector(
                          onTap: widget.onBack,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 14, color: BlackLightColors.textBody),
                              const SizedBox(width: 4),
                              Text(HomeownerQuoteRequestContent.back,
                                  style: BlackLightTextStyles.body(
                                          color: BlackLightColors.textBody)
                                      .copyWith(fontSize: 14)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: BlackLightSpacing.md),
                  Text(HomeownerQuoteRequestContent.pageTitle,
                      style: BlackLightTextStyles.sectionHeading()),
                  const SizedBox(height: 4),
                  Text(
                    HomeownerQuoteRequestContent.pageSubtitle,
                    style: BlackLightTextStyles.body(),
                  ),
                  const SizedBox(height: BlackLightSpacing.lg),

                  // Design summary card
                  if (widget.project != null)
                    _DesignSummaryCard(project: widget.project!),
                  const SizedBox(height: BlackLightSpacing.md),

                  // Form
                  _FormCard(
                    phoneCtrl: _phoneCtrl,
                    notesCtrl: _notesCtrl,
                    installerCount: _installerCount,
                    onInstallerCountChanged: (v) =>
                        setState(() => _installerCount = v),
                  ),
                  const SizedBox(height: BlackLightSpacing.md),

                  // Installer count selector
                  _InstallerSelector(
                    selected: _installerCount,
                    onChanged: (v) => setState(() => _installerCount = v),
                  ),
                  const SizedBox(height: BlackLightSpacing.lg),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: BlackLightSpacing.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _hasSubmitted = true);
                        widget.onSubmit?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlackLightColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(HomeownerQuoteRequestContent.submitCta,
                          style: BlackLightTextStyles.bodyBold(
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: BlackLightSpacing.xs),
                  Center(
                    child: Text(
                      HomeownerQuoteRequestContent.submitFinePrint,
                      style: BlackLightTextStyles.caption(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DesignSummaryCard extends StatelessWidget {
  final Project project;

  const _DesignSummaryCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(HomeownerQuoteRequestContent.yourDesign,
                        style: BlackLightTextStyles.captionBold()
                            .copyWith(fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(project.address,
                        style: BlackLightTextStyles.cardHeading()),
                  ],
                ),
              ),
              StatusBadge(status: project.status),
            ],
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.sm),
          Row(
            children: [
              if (project.systemSizeKw != null)
                _MiniStat(
                  label: HomeownerQuoteRequestContent.miniSystem,
                  value: '${project.systemSizeKw!.toStringAsFixed(1)} kW',
                ),
              if (project.panelCount != null) ...[
                const SizedBox(width: BlackLightSpacing.lg),
                _MiniStat(
                    label: HomeownerQuoteRequestContent.miniPanels,
                    value: '${project.panelCount}'),
              ],
              if (project.yearOneSavings != null) ...[
                const SizedBox(width: BlackLightSpacing.lg),
                _MiniStat(
                  label: HomeownerQuoteRequestContent.miniYearOneSavings,
                  value: '\$${project.yearOneSavings!.toStringAsFixed(0)}',
                  valueColor: BlackLightColors.green,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MiniStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10)),
        Text(value,
            style: BlackLightTextStyles.data(
                color: valueColor ?? BlackLightColors.textPrimary)),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final TextEditingController notesCtrl;
  final int installerCount;
  final ValueChanged<int> onInstallerCountChanged;

  const _FormCard({
    required this.phoneCtrl,
    required this.notesCtrl,
    required this.installerCount,
    required this.onInstallerCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(HomeownerQuoteRequestContent.contactPreferences,
              style: BlackLightTextStyles.cardHeading()),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.md),
          _LabeledField(
            label: HomeownerQuoteRequestContent.phoneOptional,
            child: TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: BlackLightTextStyles.body(
                  color: BlackLightColors.textPrimary),
              decoration: _inputDeco(HomeownerQuoteRequestContent.phoneHint),
            ),
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          _LabeledField(
            label: HomeownerQuoteRequestContent.notesOptional,
            child: TextField(
              controller: notesCtrl,
              maxLines: 3,
              style: BlackLightTextStyles.body(
                  color: BlackLightColors.textPrimary),
              decoration: _inputDeco(HomeownerQuoteRequestContent.notesHint),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            BlackLightTextStyles.body(color: BlackLightColors.textCaption),
        filled: true,
        fillColor: BlackLightColors.background,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _InstallerSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _InstallerSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(HomeownerQuoteRequestContent.numberOfQuotesTitle,
              style: BlackLightTextStyles.cardHeading()),
          const SizedBox(height: 4),
          Text(HomeownerQuoteRequestContent.numberOfQuotesBody,
              style: BlackLightTextStyles.body()),
          const SizedBox(height: BlackLightSpacing.md),
          Row(
            children: [3, 5, 10].map((n) {
              final isSelected = selected == n;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(n),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    height: 52,
                    decoration: BoxDecoration(
                      color: BlackLightColors.surface,
                      borderRadius:
                          BorderRadius.circular(BlackLightRadius.input),
                      border: Border.all(
                        color: isSelected
                            ? BlackLightColors.accent
                            : BlackLightColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$n',
                          style: BlackLightTextStyles.dataLarge(
                            color: isSelected
                                ? BlackLightColors.accent
                                : BlackLightColors.textPrimary,
                          ).copyWith(fontSize: 20),
                        ),
                        Text(HomeownerQuoteRequestContent.quotesWord,
                            style: BlackLightTextStyles.caption(
                                color: isSelected
                                    ? BlackLightColors.accent
                                    : BlackLightColors.textCaption)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final VoidCallback? onBack;

  const _SuccessState({this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: BlackLightSpacing.xl),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: BlackLightColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: BlackLightColors.green),
              ),
              child: const Icon(Icons.check_rounded,
                  size: 32, color: BlackLightColors.green),
            ),
            const SizedBox(height: BlackLightSpacing.md),
            Text(HomeownerQuoteRequestContent.successTitle,
                style: BlackLightTextStyles.sectionHeading()),
            const SizedBox(height: 4),
            Text(
              HomeownerQuoteRequestContent.successBody,
              style: BlackLightTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BlackLightSpacing.lg),
            SizedBox(
              height: BlackLightSpacing.buttonHeight,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BlackLightColors.border),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: Text(HomeownerQuoteRequestContent.backToDashboard,
                    style: BlackLightTextStyles.body(
                            color: BlackLightColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
