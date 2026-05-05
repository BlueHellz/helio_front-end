import 'package:flutter/material.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/theme/limye_theme.dart';

/// Quick intake dialog; dismiss only via close control ([barrierDismissible]: false).
Future<void> showGuidedFormDialog(
  BuildContext context, {
  VoidCallback? onGenerate,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _GuidedFormDialog(onGenerate: onGenerate),
  );
}

class _GuidedFormDialog extends StatefulWidget {
  const _GuidedFormDialog({this.onGenerate});

  final VoidCallback? onGenerate;

  @override
  State<_GuidedFormDialog> createState() => _GuidedFormDialogState();
}

class _GuidedFormDialogState extends State<_GuidedFormDialog> {
  final _addressCtrl = TextEditingController(
    text: AiChatContent.headerAddressDemo,
  );
  final _billCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _roofAgeCtrl = TextEditingController();
  final _panelAmpsCtrl = TextEditingController();

  bool _goalSavings = true;
  bool _hoa = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _billCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _roofAgeCtrl.dispose();
    _panelAmpsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: LimyeSpacing.gutter,
        vertical: LimyeSpacing.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        side: BorderSide(color: context.colors.outline, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(LimyeSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AiChatContent.modalTitle,
                        style: LimyeTextStyles.cardHeading(
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: ButtonsContent.close,
                      style: IconButton.styleFrom(
                        foregroundColor: context.colors.onSurfaceMuted,
                      ),
                      icon: const Icon(Icons.close_rounded, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: LimyeSpacing.md),
                _labeledField(
                  context,
                  label: AiChatContent.modalAddressLabel,
                  controller: _addressCtrl,
                  keyboard: TextInputType.streetAddress,
                ),
                const SizedBox(height: LimyeSpacing.sm),
                _labeledField(
                  context,
                  label: AiChatContent.modalBillLabel,
                  controller: _billCtrl,
                  hint: AiChatContent.modalBillHint,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: LimyeSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _labeledField(
                        context,
                        label: AiChatContent.modalNameLabel,
                        controller: _nameCtrl,
                        hint: AiChatContent.modalNameHint,
                      ),
                    ),
                    const SizedBox(width: LimyeSpacing.sm),
                    Expanded(
                      child: _labeledField(
                        context,
                        label: AiChatContent.modalEmailLabel,
                        controller: _emailCtrl,
                        hint: AiChatContent.modalEmailHint,
                        keyboard: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LimyeSpacing.sm),
                _labeledField(
                  context,
                  label: AiChatContent.modalPhoneLabel,
                  controller: _phoneCtrl,
                  hint: AiChatContent.modalPhoneHint,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: LimyeSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _labeledField(
                        context,
                        label: AiChatContent.modalRoofAgeLabel,
                        controller: _roofAgeCtrl,
                        hint: AiChatContent.modalRoofAgeHint,
                        keyboard: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: LimyeSpacing.sm),
                    Expanded(
                      child: _labeledField(
                        context,
                        label: AiChatContent.modalPanelAmpsLabel,
                        controller: _panelAmpsCtrl,
                        hint: AiChatContent.modalPanelAmpsHint,
                        keyboard: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LimyeSpacing.md),
                Text(
                  AiChatContent.modalGoalSectionLabel,
                  style: LimyeTextStyles.captionBold(
                    color: context.colors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: LimyeSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _GoalCard(
                        selected: _goalSavings,
                        icon: Icons.savings_rounded,
                        title: AiChatContent.modalGoalSavingsTitle,
                        onTap: () => setState(() => _goalSavings = true),
                      ),
                    ),
                    const SizedBox(width: LimyeSpacing.sm),
                    Expanded(
                      child: _GoalCard(
                        selected: !_goalSavings,
                        icon: Icons.eco_rounded,
                        title: AiChatContent.modalGoalOffsetTitle,
                        onTap: () => setState(() => _goalSavings = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LimyeSpacing.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _hoa,
                  onChanged: (v) => setState(() => _hoa = v),
                  title: Text(
                    AiChatContent.modalHoaLabel,
                    style:
                        LimyeTextStyles.body(color: context.colors.onSurface),
                  ),
                  activeThumbColor: context.colors.primary,
                ),
                const SizedBox(height: LimyeSpacing.md),
                Divider(color: context.colors.outline, height: 1),
                const SizedBox(height: LimyeSpacing.md),
                SizedBox(
                  height: LimyeSpacing.buttonHeight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onGenerate?.call();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AiChatContent.modalSubmitCta,
                          style: LimyeTextStyles.bodyBold(
                            color: context.colors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: LimyeSpacing.xs),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: context.colors.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _labeledField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboard,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: LimyeTextStyles.captionBold(
            color: context.colors.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: LimyeSpacing.xs / 2),
        SizedBox(
          height: LimyeSpacing.inputHeight,
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: LimyeTextStyles.body(color: context.colors.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? context.colors.surface
                  : LimyeColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LimyeRadius.input),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LimyeRadius.input),
        child: Container(
          padding: const EdgeInsets.all(LimyeSpacing.sm),
          decoration: BoxDecoration(
            color:
                selected ? LimyeColors.background : context.colors.surface,
            borderRadius: BorderRadius.circular(LimyeRadius.input),
            border: Border.all(
              color: selected
                  ? context.colors.primary
                  : context.colors.outline,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected
                    ? context.colors.primary
                    : context.colors.onSurfaceMuted,
              ),
              const SizedBox(height: LimyeSpacing.xs),
              Text(
                title,
                style: LimyeTextStyles.bodyBold(
                  color: selected
                      ? context.colors.onSurface
                      : context.colors.onSurfaceMuted,
                ).copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
