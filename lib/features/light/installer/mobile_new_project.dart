import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/project.dart';

class MobileNewProject extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onSubmit;
  final VoidCallback? onCancel;

  const MobileNewProject({super.key, this.onSubmit, this.onCancel});

  @override
  State<MobileNewProject> createState() => _MobileNewProjectState();
}

class _MobileNewProjectState extends State<MobileNewProject> {
  final _clientNameCtrl = TextEditingController();
  final _clientPhoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  ProjectType _type = ProjectType.residential;

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Scaffold(
      backgroundColor: c.scaffold,
      appBar: AppBar(
        title: Text(OrgMobileInstallerContent.newProjectTitle,
            style: BlackLightTextStyles.mobileH2(color: c.onSurface)),
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: widget.onCancel ?? () => Navigator.maybePop(context),
          child: Icon(Icons.close, color: variant),
        ),
        shape: Border(
            bottom: BorderSide(color: c.outline, width: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BlackLightSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: BlackLightSpacing.xs),
            _MobileCard(
              title: OrgMobileInstallerContent.mobileClientCardTitle,
              child: Column(
                children: [
                  _MobileLF(
                      label: OrgMobileInstallerContent.clientName,
                      ctrl: _clientNameCtrl,
                      hint: OrgMobileInstallerContent.clientNameHint),
                  const SizedBox(height: BlackLightSpacing.sm),
                  _MobileLF(
                      label: OrgMobileInstallerContent.phone,
                      ctrl: _clientPhoneCtrl,
                      hint: OrgMobileInstallerContent.phoneHint,
                      type: TextInputType.phone),
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.sm),
            _MobileCard(
              title: OrgMobileInstallerContent.mobileProjectDetailsCardTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MobileLF(
                      label: OrgMobileInstallerContent.installationAddress,
                      ctrl: _addressCtrl,
                      hint: OrgMobileInstallerContent.addressHint),
                  const SizedBox(height: BlackLightSpacing.md),
                  Text(OrgMobileInstallerContent.projectTypeHeading,
                      style: BlackLightTextStyles.mobileLabelBold(color: variant)
                          .copyWith(fontSize: 11)),
                  const SizedBox(height: 8),
                  Row(
                    children: ProjectType.values.map((t) {
                      final isSelected = t == _type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            height: 40,
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(
                                  BlackLightRadius.inputMobile),
                              border: Border.all(
                                color: isSelected ? c.primary : c.outline,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(t.label,
                                  style: BlackLightTextStyles.mobileBody(
                                    color: isSelected ? c.primary : variant,
                                  ).copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 12)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: BlackLightSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: () => widget.onSubmit?.call({
                  'clientName': _clientNameCtrl.text,
                  'phone': _clientPhoneCtrl.text,
                  'address': _addressCtrl.text,
                  'type': _type,
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: Text(OrgMobileInstallerContent.createProject,
                    style: BlackLightTextStyles.mobileButton(
                        color: c.onPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _MobileCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BlackLightSpacing.sm),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: BlackLightTextStyles.mobileH3(color: c.onSurface)),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _MobileLF extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final TextInputType type;

  const _MobileLF({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: BlackLightTextStyles.mobileLabelBold(color: variant)
                .copyWith(fontSize: 11)),
        const SizedBox(height: 6),
        SizedBox(
          height: BlackLightSpacing.inputHeightMobile,
          child: TextField(
            controller: ctrl,
            keyboardType: type,
            style: BlackLightTextStyles.mobileBody(color: c.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: BlackLightTextStyles.mobileBody(color: variant),
              filled: true,
              fillColor: c.surfaceMuted,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BlackLightRadius.inputMobile),
                borderSide: BorderSide(color: c.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BlackLightRadius.inputMobile),
                borderSide: BorderSide(color: c.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BlackLightRadius.inputMobile),
                borderSide: BorderSide(color: c.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
