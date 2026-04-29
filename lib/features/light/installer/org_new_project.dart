import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/project.dart';

class OrgNewProject extends StatefulWidget {
  final void Function(Map<String, dynamic> data)? onSubmit;
  final VoidCallback? onCancel;

  const OrgNewProject({super.key, this.onSubmit, this.onCancel});

  @override
  State<OrgNewProject> createState() => _OrgNewProjectState();
}

class _OrgNewProjectState extends State<OrgNewProject> {
  int _step = 0;
  ProjectType _projectType = ProjectType.residential;
  final _addressCtrl = TextEditingController();
  final _clientNameCtrl = TextEditingController();
  final _clientEmailCtrl = TextEditingController();
  final _clientPhoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _clientNameCtrl.dispose();
    _clientEmailCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(OrgInstallerNewProjectWizardContent.pageTitle,
                      style: BlackLightTextStyles.sectionHeading()),
                  const Spacer(),
                  if (widget.onCancel != null)
                    GestureDetector(
                      onTap: widget.onCancel,
                      child: Text(OrgInstallerNewProjectWizardContent.cancel,
                          style: BlackLightTextStyles.body(
                              color: BlackLightColors.textBody)),
                    ),
                ],
              ),
              const SizedBox(height: BlackLightSpacing.lg),

              // Stepper progress
              _StepProgress(currentStep: _step, totalSteps: 3),
              const SizedBox(height: BlackLightSpacing.lg),

              // Step content
              if (_step == 0)
                _Step1ClientInfo(
                  nameCtrl: _clientNameCtrl,
                  emailCtrl: _clientEmailCtrl,
                  phoneCtrl: _clientPhoneCtrl,
                )
              else if (_step == 1)
                _Step2ProjectDetails(
                  addressCtrl: _addressCtrl,
                  selectedType: _projectType,
                  onTypeChanged: (t) => setState(() => _projectType = t),
                )
              else
                _Step3Notes(notesCtrl: _notesCtrl),

              const SizedBox(height: BlackLightSpacing.lg),

              Row(
                children: [
                  if (_step > 0) ...[
                    SizedBox(
                      height: BlackLightSpacing.buttonHeight,
                      child: OutlinedButton(
                        onPressed: _back,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BlackLightColors.textPrimary,
                          side:
                              const BorderSide(color: BlackLightColors.border),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                        ),
                        child: Text(OrgInstallerNewProjectWizardContent.back,
                            style: BlackLightTextStyles.body(
                                    color: BlackLightColors.textPrimary)
                                .copyWith(fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: BlackLightSpacing.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _step < 2
                            ? _next
                            : () => widget.onSubmit?.call({
                                  'clientName': _clientNameCtrl.text,
                                  'clientEmail': _clientEmailCtrl.text,
                                  'address': _addressCtrl.text,
                                  'type': _projectType,
                                  'notes': _notesCtrl.text,
                                }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BlackLightColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          _step < 2
                              ? OrgInstallerNewProjectWizardContent.continue_
                              : OrgInstallerNewProjectWizardContent.createProject,
                          style: BlackLightTextStyles.bodyBold(
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgress({required this.currentStep, required this.totalSteps});

  static const _labels = [
    OrgInstallerNewProjectWizardContent.stepLabelClientInfo,
    OrgInstallerNewProjectWizardContent.stepLabelProjectDetails,
    OrgInstallerNewProjectWizardContent.stepLabelNotes,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return Expanded(
          child: Row(
            children: [
              _StepDot(
                  index: i,
                  isActive: isActive,
                  isDone: isDone,
                  label: _labels[i]),
              if (i < totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 1,
                    color: isDone
                        ? BlackLightColors.accent
                        : BlackLightColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isDone;
  final String label;

  const _StepDot({
    required this.index,
    required this.isActive,
    required this.isDone,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = (isActive || isDone)
        ? BlackLightColors.accent
        : BlackLightColors.border;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: (isActive || isDone)
                ? BlackLightColors.accent
                : BlackLightColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text('${index + 1}',
                    style: BlackLightTextStyles.caption(
                            color: isActive
                                ? Colors.white
                                : BlackLightColors.textCaption)
                        .copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: BlackLightTextStyles.caption(
                    color: isActive
                        ? BlackLightColors.accent
                        : BlackLightColors.textCaption)
                .copyWith(fontSize: 10)),
      ],
    );
  }
}

class _Step1ClientInfo extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;

  const _Step1ClientInfo({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
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
          Text(OrgInstallerNewProjectWizardContent.clientInformation,
              style: BlackLightTextStyles.cardHeading()),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.md),
          _LF(
              label: OrgInstallerNewProjectWizardContent.fullName,
              ctrl: nameCtrl,
              hint: OrgInstallerNewProjectWizardContent.fullNameHint),
          const SizedBox(height: BlackLightSpacing.sm),
          _LF(
              label: OrgInstallerNewProjectWizardContent.emailAddress,
              ctrl: emailCtrl,
              hint: OrgInstallerNewProjectWizardContent.emailHint,
              type: TextInputType.emailAddress),
          const SizedBox(height: BlackLightSpacing.sm),
          _LF(
              label: OrgInstallerNewProjectWizardContent.phoneNumber,
              ctrl: phoneCtrl,
              hint: OrgInstallerNewProjectWizardContent.phoneHint,
              type: TextInputType.phone),
        ],
      ),
    );
  }
}

class _Step2ProjectDetails extends StatelessWidget {
  final TextEditingController addressCtrl;
  final ProjectType selectedType;
  final ValueChanged<ProjectType> onTypeChanged;

  const _Step2ProjectDetails({
    required this.addressCtrl,
    required this.selectedType,
    required this.onTypeChanged,
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
          Text(OrgInstallerNewProjectWizardContent.projectDetails,
              style: BlackLightTextStyles.cardHeading()),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.md),
          _LF(
              label: OrgInstallerNewProjectWizardContent.installationAddress,
              ctrl: addressCtrl,
              hint: OrgInstallerNewProjectWizardContent.addressHint),
          const SizedBox(height: BlackLightSpacing.md),
          Text(OrgInstallerNewProjectWizardContent.projectTypeHeading,
              style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10)),
          const SizedBox(height: 8),
          Row(
            children: ProjectType.values.map((t) {
              final isSelected = t == selectedType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged(t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 44,
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
                    child: Center(
                      child: Text(t.label,
                          style: BlackLightTextStyles.body(
                                  color: isSelected
                                      ? BlackLightColors.accent
                                      : BlackLightColors.textBody)
                              .copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 14)),
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

class _Step3Notes extends StatelessWidget {
  final TextEditingController notesCtrl;

  const _Step3Notes({required this.notesCtrl});

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
          Text(OrgInstallerNewProjectWizardContent.additionalNotes,
              style: BlackLightTextStyles.cardHeading()),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.md),
          Text(OrgInstallerNewProjectWizardContent.notesFieldCaption,
              style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10)),
          const SizedBox(height: 6),
          TextField(
            controller: notesCtrl,
            maxLines: 5,
            style:
                BlackLightTextStyles.body(color: BlackLightColors.textPrimary),
            decoration: InputDecoration(
              hintText: OrgInstallerNewProjectWizardContent.notesHint,
              hintStyle: BlackLightTextStyles.body(
                  color: BlackLightColors.textCaption),
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
                borderSide: const BorderSide(
                    color: BlackLightColors.accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

class _LF extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final TextInputType type;

  const _LF({
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
            style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: BlackLightTextStyles.body(color: BlackLightColors.textPrimary),
          decoration: InputDecoration(
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
          ),
        ),
      ],
    );
  }
}
