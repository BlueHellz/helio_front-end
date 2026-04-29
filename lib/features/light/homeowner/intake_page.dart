import 'dart:async';

import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/secrets/app_secrets.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/services/api.dart';
import 'package:blacklight_app/services/mapbox_geocoding_service.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

class HomeownerIntakePage extends ConsumerStatefulWidget {
  const HomeownerIntakePage({super.key});

  @override
  ConsumerState<HomeownerIntakePage> createState() => _HomeownerIntakePageState();
}

class _HomeownerIntakePageState extends ConsumerState<HomeownerIntakePage> {
  final _addressCtrl = TextEditingController();
  final _billCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _roofAge = HomeownerIntakeContent.roofAge0to5;
  String _panelAmps = HomeownerIntakeContent.panel200;
  String _goal = 'max_savings';
  bool _hoa = false;

  MapboxGeocodingService? _geo;
  List<MapboxPlaceSuggestion> _suggestions = const [];
  Timer? _debounce;
  bool _showSuggestions = false;
  bool _submitting = false;
  final _addressFocus = FocusNode();

  static final _roofOptions = [
    HomeownerIntakeContent.roofAge0to5,
    HomeownerIntakeContent.roofAge5to10,
    HomeownerIntakeContent.roofAge10to15,
    HomeownerIntakeContent.roofAge15plus,
  ];
  static final _ampOptions = [
    HomeownerIntakeContent.panel100,
    HomeownerIntakeContent.panel150,
    HomeownerIntakeContent.panel200,
    HomeownerIntakeContent.panel400,
    HomeownerIntakeContent.panelUnknown,
  ];

  @override
  void initState() {
    super.initState();
    _addressFocus.addListener(_onAddrFocus);
    _bootstrapGeo();
  }

  Future<void> _bootstrapGeo() async {
    final secrets = await AppSecrets.load();
    if (!mounted) return;
    setState(() {
      _geo = secrets.mapboxAccessToken.isEmpty
          ? null
          : MapboxGeocodingService(accessToken: secrets.mapboxAccessToken);
    });
  }

  void _onAddrFocus() {
    if (!_addressFocus.hasFocus) {
      setState(() => _showSuggestions = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressFocus.removeListener(_onAddrFocus);
    _addressFocus.dispose();
    _addressCtrl.dispose();
    _billCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _geo?.dispose();
    super.dispose();
  }

  void _onAddressChanged(String q) {
    _debounce?.cancel();
    final svc = _geo;
    if (svc == null) return;
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final list = await svc.forwardAutocomplete(query: q);
      if (!mounted) return;
      setState(() {
        _suggestions = list;
        _showSuggestions = q.trim().isNotEmpty && list.isNotEmpty;
      });
    });
  }

  Future<void> _submit() async {
    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      AppFeedback.snack(context, FieldValidationContent.addressRequired);
      return;
    }
    setState(() => _submitting = true);
    try {
      final api = ref.read(apiProvider);
      final custom = <String, dynamic>{
        'monthly_electricity_bill': _billCtrl.text.trim(),
        'homeowner_name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'roof_age': _roofAge,
        'main_panel_amperage': _panelAmps,
        'homeowner_goal': _goal,
        'hoa_restrictions': _hoa,
      };
      await api.createProject(
        projectCreateBody(
          address: address,
          projectType: 'residential',
          customData: custom,
          clientName: _nameCtrl.text.trim().isEmpty
              ? null
              : _nameCtrl.text.trim(),
        ),
      );
      if (!mounted) return;
      AppFeedback.snack(context, HomeownerIntakeContent.projectSubmittedSnack);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppFeedback.snack(
          context, '${ApiErrorsContent.couldNotSubmitPrefix}$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      appBar: AppBar(
        title: Text(HomeownerIntakeContent.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BlackLightSpacing.gutter),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_geo == null)
                  Text(
                    HomeownerIntakeContent.mapboxSetupHint,
                    style: BlackLightTextStyles.caption(),
                  ),
                Text(HomeownerIntakeContent.addressLabel,
                    style: BlackLightTextStyles.caption()),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _addressCtrl,
                      focusNode: _addressFocus,
                      onChanged: _onAddressChanged,
                      decoration: InputDecoration(
                        hintText: HomeownerIntakeContent.addressPlaceholder,
                      ),
                    ),
                    if (_showSuggestions)
                      Material(
                        color: BlackLightColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            BlackLightRadius.input,
                          ),
                          side: const BorderSide(color: BlackLightColors.border),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _suggestions.length.clamp(0, 5),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final s = _suggestions[i];
                            return ListTile(
                              dense: true,
                              title: Text(
                                s.placeName,
                                style: BlackLightTextStyles.body(),
                              ),
                              onTap: () {
                                _addressCtrl.text = s.placeName;
                                setState(() {
                                  _showSuggestions = false;
                                  _suggestions = const [];
                                });
                                _addressFocus.unfocus();
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                Text(
                  HomeownerIntakeContent.monthlyBillLabel,
                  style: BlackLightTextStyles.caption(),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _billCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: HomeownerIntakeContent.monthlyBillPrefix,
                  ),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                Text(HomeownerIntakeContent.homeownerNameLabel,
                    style: BlackLightTextStyles.caption()),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                Text(HomeownerIntakeContent.emailLabel,
                    style: BlackLightTextStyles.caption()),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                Text(HomeownerIntakeContent.phoneLabel,
                    style: BlackLightTextStyles.caption()),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                Text(HomeownerIntakeContent.roofAgeLabel,
                    style: BlackLightTextStyles.caption()),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _roofAge,
                  items: [
                    for (final o in _roofOptions)
                      DropdownMenuItem(
                        value: o,
                        child: Text(o, style: BlackLightTextStyles.body()),
                      ),
                  ],
                  onChanged: (v) => setState(() => _roofAge = v ?? _roofAge),
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                Text(
                  HomeownerIntakeContent.panelAmpsLabel,
                  style: BlackLightTextStyles.caption(),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _panelAmps,
                  items: [
                    for (final o in _ampOptions)
                      DropdownMenuItem(
                        value: o,
                        child: Text(o, style: BlackLightTextStyles.body()),
                      ),
                  ],
                  onChanged: (v) => setState(() => _panelAmps = v ?? _panelAmps),
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                Text(HomeownerIntakeContent.goalLabel,
                    style: BlackLightTextStyles.caption()),
                const SizedBox(height: 6),
                ..._goalTiles(),
                const SizedBox(height: BlackLightSpacing.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    HomeownerIntakeContent.hoaLabel,
                    style: BlackLightTextStyles.body(),
                  ),
                  value: _hoa,
                  onChanged: (v) => setState(() => _hoa = v),
                ),
                const SizedBox(height: BlackLightSpacing.md),
                SizedBox(
                  height: BlackLightSpacing.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(HomeownerIntakeContent.submitButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _goalTiles() {
    Widget tile(String value, String label) {
      return RadioListTile<String>(
        value: value,
        groupValue: _goal,
        title: Text(label, style: BlackLightTextStyles.body()),
        onChanged: (v) => setState(() => _goal = v ?? _goal),
      );
    }

    return [
      tile('max_savings', HomeownerIntakeContent.goalMaxSavings),
      tile('max_offset', HomeownerIntakeContent.goalMaxOffset),
      tile('battery_backup', HomeownerIntakeContent.goalBatteryBackup),
    ];
  }
}
