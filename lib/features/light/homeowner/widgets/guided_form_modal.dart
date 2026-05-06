import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/data/us_state_postal_codes.dart';
import 'package:kooyoh_app/core/ui/app_feedback.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

/// Parsed guided intake submission for the homeowner AI chat.
class GuidedIntakePayload {
  const GuidedIntakePayload({
    required this.ownerName,
    this.email,
    this.phone,
    required this.streetAddress,
    required this.city,
    required this.stateCode,
    required this.zip,
    required this.monthlyBillDollars,
    required this.monthlyUsageKwh,
    required this.roofAgeLabel,
    required this.panelAmperageLabel,
    required this.maximizeSavings,
    required this.hasHoaRestrictions,
  });

  final String ownerName;
  final String? email;
  final String? phone;
  final String streetAddress;
  final String city;
  final String stateCode;
  final String zip;
  final double monthlyBillDollars;
  final double monthlyUsageKwh;
  final String roofAgeLabel;
  final String panelAmperageLabel;

  /// True = Maximum Savings goal; false = Maximum Energy Offset.
  final bool maximizeSavings;
  final bool hasHoaRestrictions;

  /// Single line for API `address` (e.g. `123 Main St, Austin, TX 78701`).
  String get mailingAddressOneLine =>
      '${streetAddress.trim()}, ${city.trim()}, ${stateCode.trim()} ${zip.trim()}';

  String toChatSummary() {
    final goal = maximizeSavings
        ? AiChatContent.modalGoalSavingsTitle
        : AiChatContent.modalGoalOffsetTitle;
    final hoa = hasHoaRestrictions
        ? AiChatContent.modalHoaYes
        : AiChatContent.modalHoaNo;
    final buffer = StringBuffer()
      ..writeln(
        '${AiChatContent.modalOwnerNameLabel}: $ownerName',
      );
    if (email != null && email!.trim().isNotEmpty) {
      buffer.writeln('${AiChatContent.modalEmailLabel}: ${email!.trim()}');
    }
    if (phone != null && phone!.trim().isNotEmpty) {
      buffer.writeln('${AiChatContent.modalPhoneLabel}: ${phone!.trim()}');
    }
    buffer
      ..writeln('${AiChatContent.modalAddressLabel}: $streetAddress')
      ..writeln('${AiChatContent.modalCityLabel}: $city')
      ..writeln('${AiChatContent.modalStateLabel}: $stateCode')
      ..writeln('${AiChatContent.modalZipLabel}: $zip')
      ..writeln(
        '${AiChatContent.modalBillLabel}: '
        '${monthlyBillDollars.toStringAsFixed(0)}',
      )
      ..writeln(
        '${AiChatContent.modalUsageKwhLabel}: '
        '${monthlyUsageKwh.toStringAsFixed(0)}',
      )
      ..writeln('${AiChatContent.modalRoofAgeLabel}: $roofAgeLabel')
      ..writeln(
        '${AiChatContent.modalPanelAmpsLabel}: $panelAmperageLabel',
      )
      ..writeln('${AiChatContent.modalGoalSectionLabel}: $goal')
      ..write('${AiChatContent.modalHoaSectionLabel}: $hoa');
    return buffer.toString();
  }
}

/// Opens the floating guided intake modal; dismissed only via the close icon.
///
/// Restores keyboard focus on [composerFocus] after dismiss or submit.
Future<void> showGuidedFormDialog(
  BuildContext context, {
  required FocusNode composerFocus,
  void Function(GuidedIntakePayload data)? onSubmitted,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: _GuidedFormBlurOverlay(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KooyohSpacing.gutter,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: KooyohSpacing.guidedFormModalMaxWidth,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: _GuidedFormSurface(
                          composerFocus: composerFocus,
                          onSubmitted: onSubmitted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _GuidedFormBlurOverlay extends StatelessWidget {
  const _GuidedFormBlurOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scrim = Theme.of(context).colorScheme.primary.withValues(alpha: 0.20);
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: ColoredBox(color: scrim),
          ),
        ),
        child,
      ],
    );
  }
}

class _GuidedFormSurface extends StatelessWidget {
  const _GuidedFormSurface({
    required this.composerFocus,
    this.onSubmitted,
  });

  final FocusNode composerFocus;
  final void Function(GuidedIntakePayload data)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KooyohColors.surface,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: KooyohColors.outline, width: 1),
      ),
      child: _GuidedFormBody(
        composerFocus: composerFocus,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _GuidedFormBody extends StatefulWidget {
  const _GuidedFormBody({
    required this.composerFocus,
    this.onSubmitted,
  });

  final FocusNode composerFocus;
  final void Function(GuidedIntakePayload data)? onSubmitted;

  @override
  State<_GuidedFormBody> createState() => _GuidedFormBodyState();
}

class _GuidedFormBodyState extends State<_GuidedFormBody> {
  static const List<String> _roofOptions = [
    AiChatContent.modalRoofAge05,
    AiChatContent.modalRoofAge510,
    AiChatContent.modalRoofAge1015,
    AiChatContent.modalRoofAge15Plus,
  ];

  static const List<String> _panelOptions = [
    AiChatContent.modalPanel100,
    AiChatContent.modalPanel150,
    AiChatContent.modalPanel200,
    AiChatContent.modalPanel400,
    AiChatContent.modalPanelUnknown,
  ];

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _billCtrl = TextEditingController();
  final _kwhCtrl = TextEditingController();

  String? _roofAgeValue;
  String? _panelValue;
  String? _stateCode;
  bool _maximizeSavings = true;
  bool? _hoaRestrictions;

  bool _attemptedSubmit = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _billCtrl.dispose();
    _kwhCtrl.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop();
    _refocusComposer();
  }

  void _refocusComposer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.composerFocus.canRequestFocus) {
        widget.composerFocus.requestFocus();
      }
    });
  }

  Color _fieldFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : KooyohColors.background;

  InputBorder _neutralBorder(BuildContext context) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(KooyohRadius.input),
        borderSide: BorderSide.none,
      );

  InputBorder _focusedBorder(BuildContext context) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(KooyohRadius.input),
        borderSide: BorderSide(color: context.colors.primary, width: 1),
      );

  InputBorder _errorBorder(BuildContext context) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(KooyohRadius.input),
        borderSide: BorderSide(color: context.colors.error, width: 1),
      );

  void _submit() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final zipRaw = _zipCtrl.text.trim();
    final billRaw = _billCtrl.text.trim();
    final kwhRaw = _kwhCtrl.text.trim();

    double? bill;
    double? kwh;

    bool emailOk = true;
    if (email.isNotEmpty) {
      emailOk = email.contains('@');
    }

    bill = billRaw.isEmpty ? null : double.tryParse(billRaw);
    kwh = kwhRaw.isEmpty ? null : double.tryParse(kwhRaw);

    final nameOk = name.isNotEmpty;
    final addrOk = address.isNotEmpty;
    final cityOk = city.isNotEmpty;
    final stateOk = (_stateCode?.isNotEmpty ?? false);
    final zipOk = RegExp(r'^\d{5}$').hasMatch(zipRaw);
    final billOk = billRaw.isNotEmpty && bill != null;
    final kwhOk = kwhRaw.isNotEmpty && kwh != null;
    final roofOk = (_roofAgeValue?.isNotEmpty ?? false);
    final panelOk = (_panelValue?.isNotEmpty ?? false);
    final hoaOk = _hoaRestrictions != null;

    final addrExtrasOk =
        !addrOk || (cityOk && stateOk && zipOk);

    setState(() => _attemptedSubmit = true);

    if (!(nameOk &&
        addrOk &&
        addrExtrasOk &&
        billOk &&
        kwhOk &&
        roofOk &&
        panelOk &&
        hoaOk &&
        emailOk)) {
      return;
    }

    final roofLabel = _roofAgeValue!;
    final panelLabel = _panelValue!;
    final hoaFlag = _hoaRestrictions!;
    final st = _stateCode!;

    final payload = GuidedIntakePayload(
      ownerName: name,
      email: email.isEmpty ? null : email,
      phone: phone.isEmpty ? null : phone,
      streetAddress: address,
      city: city,
      stateCode: st,
      zip: zipRaw,
      monthlyBillDollars: bill,
      monthlyUsageKwh: kwh,
      roofAgeLabel: roofLabel,
      panelAmperageLabel: panelLabel,
      maximizeSavings: _maximizeSavings,
      hasHoaRestrictions: hoaFlag,
    );

    Navigator.of(context).pop();
    widget.onSubmitted?.call(payload);
    _refocusComposer();
  }

  String? _zipError(String zipRaw, bool addrOk) {
    if (!_attemptedSubmit || !addrOk) return null;
    if (zipRaw.isEmpty) return AiChatContent.modalErrorRequired;
    if (!RegExp(r'^\d{5}$').hasMatch(zipRaw)) {
      return AiChatContent.modalErrorInvalidZip;
    }
    return null;
  }

  String? _requiredError(bool ok) {
    if (!_attemptedSubmit || ok) return null;
    return AiChatContent.modalErrorRequired;
  }

  String? _numberError(String raw, double? parsed) {
    if (!_attemptedSubmit) return null;
    if (raw.trim().isEmpty) return AiChatContent.modalErrorRequired;
    if (parsed == null) return AiChatContent.modalErrorInvalidNumber;
    return null;
  }

  String? _emailError(String email, bool emailOk) {
    if (!_attemptedSubmit || email.trim().isEmpty) return null;
    if (!emailOk) return AiChatContent.modalErrorInvalidEmail;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final email = _emailCtrl.text.trim();
    final emailOk = email.isEmpty || email.contains('@');
    final billRaw = _billCtrl.text.trim();
    final kwhRaw = _kwhCtrl.text.trim();
    final bill = billRaw.isEmpty ? null : double.tryParse(billRaw);
    final kwh = kwhRaw.isEmpty ? null : double.tryParse(kwhRaw);

    final nameOk = _nameCtrl.text.trim().isNotEmpty;
    final addrOk = _addressCtrl.text.trim().isNotEmpty;
    final cityOk = _cityCtrl.text.trim().isNotEmpty;
    final stateOk = (_stateCode?.isNotEmpty ?? false);
    final zipRaw = _zipCtrl.text.trim();
    final roofOk = (_roofAgeValue?.isNotEmpty ?? false);
    final panelOk = (_panelValue?.isNotEmpty ?? false);
    final hoaOk = _hoaRestrictions != null;

    return Padding(
      padding: EdgeInsets.all(KooyohSpacing.sm + KooyohSpacing.sm),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    AiChatContent.modalTitle,
                    style: KooyohTextStyles.cardHeading(
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  width: KooyohSpacing.inputHeightMobile,
                  height: KooyohSpacing.inputHeightMobile,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: _close,
                      tooltip: ButtonsContent.close,
                      style: IconButton.styleFrom(
                        foregroundColor: context.colors.onSurfaceMuted,
                      ),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: KooyohSpacing.md),
            _textField(
              context,
              label: AiChatContent.modalOwnerNameLabel,
              controller: _nameCtrl,
              hint: AiChatContent.modalOwnerNameHint,
              errorText: _requiredError(nameOk),
              keyboard: TextInputType.name,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: KooyohSpacing.sm),
            _textField(
              context,
              label: AiChatContent.modalEmailLabel,
              controller: _emailCtrl,
              hint: AiChatContent.modalEmailHint,
              errorText: _emailError(email, emailOk),
              keyboard: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: KooyohSpacing.sm),
            _textField(
              context,
              label: AiChatContent.modalPhoneLabel,
              controller: _phoneCtrl,
              hint: AiChatContent.modalPhoneHint,
              keyboard: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-()\s]')),
              ],
            ),
            SizedBox(height: KooyohSpacing.sm),
            _addressField(
              context,
              errorText: _requiredError(addrOk),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: KooyohSpacing.sm),
            _textField(
              context,
              label: AiChatContent.modalCityLabel,
              controller: _cityCtrl,
              hint: AiChatContent.modalCityHint,
              errorText: addrOk && _attemptedSubmit && !cityOk
                  ? AiChatContent.modalErrorRequired
                  : null,
              keyboard: TextInputType.text,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: KooyohSpacing.sm),
            _dropdownField(
              context,
              label: AiChatContent.modalStateLabel,
              value: _stateCode,
              items: kUsStatePostalCodes,
              errorText: addrOk &&
                      _attemptedSubmit &&
                      !stateOk
                  ? AiChatContent.modalErrorSelectDropdown
                  : null,
              onChanged: (v) => setState(() => _stateCode = v),
            ),
            SizedBox(height: KooyohSpacing.sm),
            _textField(
              context,
              label: AiChatContent.modalZipLabel,
              controller: _zipCtrl,
              hint: AiChatContent.modalZipHint,
              errorText: _zipError(zipRaw, addrOk),
              keyboard: TextInputType.number,
              onChanged: (_) => setState(() {}),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
            ),
            SizedBox(height: KooyohSpacing.sm),
            _textField(
              context,
              label: AiChatContent.modalBillLabel,
              controller: _billCtrl,
              hint: AiChatContent.modalBillHint,
              errorText: _numberError(billRaw, bill),
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: KooyohSpacing.sm),
            _textField(
              context,
              label: AiChatContent.modalUsageKwhLabel,
              controller: _kwhCtrl,
              hint: AiChatContent.modalUsageKwhHint,
              errorText: _numberError(kwhRaw, kwh),
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: KooyohSpacing.sm),
            _dropdownField(
              context,
              label: AiChatContent.modalRoofAgeLabel,
              value: _roofAgeValue,
              items: _roofOptions,
              errorText: !_attemptedSubmit || roofOk
                  ? null
                  : AiChatContent.modalErrorSelectDropdown,
              onChanged: (v) => setState(() => _roofAgeValue = v),
            ),
            SizedBox(height: KooyohSpacing.sm),
            _dropdownField(
              context,
              label: AiChatContent.modalPanelAmpsLabel,
              value: _panelValue,
              items: _panelOptions,
              errorText: !_attemptedSubmit || panelOk
                  ? null
                  : AiChatContent.modalErrorSelectDropdown,
              onChanged: (v) => setState(() => _panelValue = v),
            ),
            SizedBox(height: KooyohSpacing.md),
            Text(
              AiChatContent.modalGoalSectionLabel,
              style: KooyohTextStyles.caption(
                color: context.colors.onSurfaceMuted,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: KooyohSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _GoalCard(
                    selected: _maximizeSavings,
                    icon: Icons.savings_rounded,
                    title: AiChatContent.modalGoalSavingsTitle,
                    onTap: () => setState(() => _maximizeSavings = true),
                  ),
                ),
                SizedBox(width: KooyohSpacing.sm),
                Expanded(
                  child: _GoalCard(
                    selected: !_maximizeSavings,
                    icon: Icons.eco_rounded,
                    title: AiChatContent.modalGoalOffsetTitle,
                    onTap: () => setState(() => _maximizeSavings = false),
                  ),
                ),
              ],
            ),
            SizedBox(height: KooyohSpacing.md),
            Text(
              AiChatContent.modalHoaSectionLabel,
              style: KooyohTextStyles.caption(
                color: context.colors.onSurfaceMuted,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: KooyohSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _HoaChoiceChip(
                    label: AiChatContent.modalHoaYes,
                    selected: _hoaRestrictions == true,
                    onTap: () => setState(() => _hoaRestrictions = true),
                  ),
                ),
                SizedBox(width: KooyohSpacing.sm),
                Expanded(
                  child: _HoaChoiceChip(
                    label: AiChatContent.modalHoaNo,
                    selected: _hoaRestrictions == false,
                    onTap: () => setState(() => _hoaRestrictions = false),
                  ),
                ),
              ],
            ),
            if (_attemptedSubmit && !hoaOk) ...[
              SizedBox(height: KooyohSpacing.xs / 2),
              Text(
                AiChatContent.modalErrorHoa,
                style: KooyohTextStyles.caption(color: context.colors.error),
              ),
            ],
            SizedBox(height: KooyohSpacing.md),
            Divider(color: context.colors.outline, height: 1),
            SizedBox(height: KooyohSpacing.sm),
            SizedBox(
              height: KooyohSpacing.buttonHeight,
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AiChatContent.modalSubmitCta,
                      style: KooyohTextStyles.bodyBold(
                        color: context.colors.onPrimary,
                      ),
                    ),
                    SizedBox(width: KooyohSpacing.xs),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: context.colors.onPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeledTop(
    BuildContext context, {
    required String label,
    Widget? trailing,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: KooyohTextStyles.caption(
                  color: context.colors.onSurfaceMuted,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        SizedBox(height: KooyohSpacing.xs / 2),
        child,
      ],
    );
  }

  Widget _textField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    String? errorText,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    final hasErr = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _labeledTop(
          context,
          label: label,
          child: SizedBox(
            height: KooyohSpacing.inputHeight,
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              onChanged: onChanged,
              inputFormatters: inputFormatters,
              style: KooyohTextStyles.body(color: context.colors.onSurface),
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: _fieldFill(context),
                border:
                    hasErr ? _errorBorder(context) : _neutralBorder(context),
                enabledBorder:
                    hasErr ? _errorBorder(context) : _neutralBorder(context),
                focusedBorder:
                    hasErr ? _errorBorder(context) : _focusedBorder(context),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: KooyohSpacing.sm,
                ),
              ),
            ),
          ),
        ),
        if (hasErr) ...[
          SizedBox(height: KooyohSpacing.xs / 2),
          Text(
            errorText,
            style: KooyohTextStyles.caption(color: context.colors.error),
          ),
        ],
      ],
    );
  }

  Widget _addressField(
    BuildContext context, {
    required String? errorText,
    void Function(String)? onChanged,
  }) {
    final hasErr = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AiChatContent.modalAddressLabel,
          style: KooyohTextStyles.caption(
            color: context.colors.onSurfaceMuted,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: KooyohSpacing.xs / 2),
        SizedBox(
          height: KooyohSpacing.inputHeight,
          child: TextField(
            controller: _addressCtrl,
            onChanged: onChanged,
            keyboardType: TextInputType.streetAddress,
            style: KooyohTextStyles.body(color: context.colors.onSurface),
            decoration: InputDecoration(
              hintText: AiChatContent.modalAddressHint,
              filled: true,
              fillColor: _fieldFill(context),
              border:
                  hasErr ? _errorBorder(context) : _neutralBorder(context),
              enabledBorder:
                  hasErr ? _errorBorder(context) : _neutralBorder(context),
              focusedBorder:
                  hasErr ? _errorBorder(context) : _focusedBorder(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.sm,
              ),
              suffixIcon: IconButton(
                tooltip: AiChatContent.modalLocateMeHint,
                icon: Icon(
                  Icons.my_location_rounded,
                  size: 20,
                  color: context.colors.primary,
                ),
                onPressed: () => AppFeedback.comingSoon(
                  context,
                  feature: AiChatContent.modalLocateMeHint,
                ),
              ),
            ),
          ),
        ),
        if (hasErr) ...[
          SizedBox(height: KooyohSpacing.xs / 2),
          Text(
            errorText,
            style: KooyohTextStyles.caption(color: context.colors.error),
          ),
        ],
      ],
    );
  }

  Widget _dropdownField(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required String? errorText,
    required ValueChanged<String?> onChanged,
  }) {
    final hasErr = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: KooyohTextStyles.caption(
            color: context.colors.onSurfaceMuted,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: KooyohSpacing.xs / 2),
        DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            value: value != null && items.contains(value) ? value : null,
            decoration: InputDecoration(
              hintText: AiChatContent.modalSelectHint,
              filled: true,
              fillColor: _fieldFill(context),
              border: hasErr ? _errorBorder(context) : _neutralBorder(context),
              enabledBorder:
                  hasErr ? _errorBorder(context) : _neutralBorder(context),
              focusedBorder:
                  hasErr ? _errorBorder(context) : _focusedBorder(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: KooyohSpacing.sm,
                vertical: 0,
              ),
            ),
            items: items
                .map(
                  (v) => DropdownMenuItem<String>(value: v, child: Text(v)),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
        if (hasErr) ...[
          SizedBox(height: KooyohSpacing.xs / 2),
          Text(
            errorText,
            style: KooyohTextStyles.caption(color: context.colors.error),
          ),
        ],
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
        borderRadius: BorderRadius.circular(KooyohRadius.input),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(KooyohSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? KooyohAdaptive.background(context)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(KooyohRadius.input),
            border: Border.all(
              color: selected ? context.colors.primary : context.colors.outline,
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
                size: 24,
              ),
              SizedBox(height: KooyohSpacing.xs),
              Text(
                title,
                style: KooyohTextStyles.captionBold(
                  color: selected
                      ? context.colors.onSurface
                      : context.colors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoaChoiceChip extends StatelessWidget {
  const _HoaChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KooyohRadius.input),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: KooyohSpacing.inputHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KooyohRadius.input),
            border: Border.all(
              color: selected ? context.colors.primary : context.colors.outline,
              width: 1,
            ),
            color: selected ? KooyohAdaptive.background(context) : null,
          ),
          child: Text(
            label,
            style: KooyohTextStyles.bodyBold(
              color: selected
                  ? context.colors.onSurface
                  : context.colors.onSurfaceMuted,
            ),
          ),
        ),
      ),
    );
  }
}
