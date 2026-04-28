import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import '../../theme/blacklight_theme.dart';
import '../../core/models/project.dart';

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
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      appBar: AppBar(
        title: Text(OrgMobileInstallerContent.newProjectTitle,
            style: BlackLightTextStyles.mobileH2()),
        backgroundColor: BlackLightColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: widget.onCancel ?? () => Navigator.maybePop(context),
          child: const Icon(Icons.close, color: BlackLightColors.textBody),
        ),
        shape: const Border(
            bottom: BorderSide(color: BlackLightColors.border, width: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BlackLightSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: BlackLightSpacing.xs),

            // Client info card
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

            // Project details card
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
                      style: BlackLightTextStyles.mobileLabelBold()
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
                              color: BlackLightColors.surface,
                              borderRadius: BorderRadius.circular(
                                  BlackLightRadius.inputMobile),
                              border: Border.all(
                                color: isSelected
                                    ? BlackLightColors.accent
                                    : BlackLightColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(t.label,
                                  style: BlackLightTextStyles.mobileBody(
                                    color: isSelected
                                        ? BlackLightColors.accent
                                        : BlackLightColors.textBody,
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

            // Submit button
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
                  backgroundColor: BlackLightColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: Text(OrgMobileInstallerContent.createProject,
                    style: BlackLightTextStyles.mobileButton()),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BlackLightSpacing.sm),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BlackLightTextStyles.mobileH3()),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style:
                BlackLightTextStyles.mobileLabelBold().copyWith(fontSize: 11)),
        const SizedBox(height: 6),
        SizedBox(
          height: BlackLightSpacing.inputHeightMobile,
          child: TextField(
            controller: ctrl,
            keyboardType: type,
            style: BlackLightTextStyles.mobileBody(
                color: BlackLightColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: BlackLightTextStyles.mobileBody(
                  color: BlackLightColors.textCaption),
              filled: true,
              fillColor: BlackLightColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BlackLightRadius.inputMobile),
                borderSide: const BorderSide(color: BlackLightColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BlackLightRadius.inputMobile),
                borderSide: const BorderSide(color: BlackLightColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BlackLightRadius.inputMobile),
                borderSide: const BorderSide(
                    color: BlackLightColors.accent, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
