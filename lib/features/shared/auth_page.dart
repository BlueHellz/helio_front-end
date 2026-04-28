import 'dart:developer' as developer;

import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import '../../core/ui/app_feedback.dart';
import '../../theme/blacklight_theme.dart';
import '../../core/brand/blacklight_brand_logo.dart';
import '../../core/app_state.dart';
import '../../core/illustrations/geometric_illustrations.dart';
import '../../core/shell/web/pre_auth_shell.dart';
import '../../core/providers/session_providers.dart';
import '../../services/auth_api.dart';

class AuthPage extends ConsumerStatefulWidget {
  final void Function(UserRole role)? onAuthenticated;
  final VoidCallback? onHomeTap;
  final VoidCallback? onNavbarSignIn;

  const AuthPage({
    super.key,
    this.onAuthenticated,
    this.onHomeTap,
    this.onNavbarSignIn,
  });

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isSignIn = true;
  UserRole _selectedRole = UserRole.homeowner;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      AppFeedback.snack(context, FieldValidationContent.enterEmailAndPassword);
      return;
    }

    if (!_isSignIn) {
      if (_selectedRole == UserRole.homeowner) {
        if (_nameCtrl.text.trim().isEmpty) {
          AppFeedback.snack(context, FieldValidationContent.enterFullName);
          return;
        }
      } else {
        if (_companyCtrl.text.trim().isEmpty) {
          AppFeedback.snack(context, FieldValidationContent.enterCompanyName);
          return;
        }
      }
    }

    setState(() => _submitting = true);
    try {
      final authApi = ref.read(authApiProvider);
      late AuthResult result;
      if (_isSignIn) {
        result = await authApi.login(email: email, password: password);
        result = await authApi.enrichWithMe(result);
      } else {
        final fullName = _selectedRole == UserRole.homeowner
            ? _nameCtrl.text.trim()
            : _companyCtrl.text.trim();
        // Signup response already includes tokens + user; no login, optional /me skipped.
        result = await authApi.signup(
          email: email,
          password: password,
          fullName: fullName,
          role: apiRoleString(_selectedRole),
        );
      }

      if (!mounted) return;
      await ref.read(sessionProvider.notifier).applyAuthResult(result);
      final apiRole = userRoleFromApiString(result.role);
      if (!mounted) return;
      final displayName = (result.fullName?.trim().isNotEmpty ?? false)
          ? result.fullName!.trim()
          : (result.email ?? '');
      final comp = result.companyName?.trim();
      final displayCompany = (comp != null && comp.isNotEmpty)
          ? comp
          : (apiRole == UserRole.organization ? displayName : '');
      context.read<BlackLightAppState>().signIn(
            role: apiRole,
            name: displayName,
            companyName: displayCompany,
          );
      widget.onAuthenticated?.call(apiRole);
    } on AuthApiException catch (e) {
      if (mounted) AppFeedback.snack(context, e.message);
    } catch (e, st) {
      developer.log(
        'AuthPage submit failed',
        name: 'AuthPage',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        final raw = e.toString().replaceFirst('Exception: ', '').trim();
        AppFeedback.snack(
          context,
          raw.isNotEmpty ? raw : ApiErrorsContent.couldNotSignIn,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreAuthShell(
      onSignIn: widget.onNavbarSignIn,
      onHomeTap: widget.onHomeTap,
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            BlackLightSpacing.navbarHeight -
            BlackLightSpacing.footerHeight,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: BlackLightSpacing.lg,
                      vertical: BlackLightSpacing.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _AuthForm(
                      isSignIn: _isSignIn,
                      selectedRole: _selectedRole,
                      emailCtrl: _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      nameCtrl: _nameCtrl,
                      companyCtrl: _companyCtrl,
                      obscurePassword: _obscurePassword,
                      isSubmitting: _submitting,
                      onToggleMode: () =>
                          setState(() => _isSignIn = !_isSignIn),
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onRoleChanged: (r) => setState(() => _selectedRole = r),
                      onContinue: _handleSubmit,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: BlackLightColors.surface,
                  border: Border(
                    left: BorderSide(color: BlackLightColors.border),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SunRingsIllustration(size: 380),
                      const SizedBox(height: BlackLightSpacing.lg),
                      Text(
                        AuthContent.splitHeroTitle,
                        style: BlackLightTextStyles.sectionHeading(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: BlackLightSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          AuthContent.splitHeroBody,
                          style: BlackLightTextStyles.body(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  final bool isSignIn;
  final UserRole selectedRole;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController companyCtrl;
  final bool obscurePassword;
  final bool isSubmitting;
  final VoidCallback onToggleMode;
  final VoidCallback onTogglePassword;
  final ValueChanged<UserRole> onRoleChanged;
  final Future<void> Function() onContinue;

  const _AuthForm({
    required this.isSignIn,
    required this.selectedRole,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.nameCtrl,
    required this.companyCtrl,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onToggleMode,
    required this.onTogglePassword,
    required this.onRoleChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BlackLightLogo(height: 40, maxWidth: 240),
        const SizedBox(height: BlackLightSpacing.xl),

        Text(
          isSignIn ? AuthContent.welcomeBack : AuthContent.createYourAccount,
          style: BlackLightTextStyles.sectionHeading(),
        ),
        const SizedBox(height: BlackLightSpacing.md),

        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: BlackLightColors.background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: BlackLightColors.border),
          ),
          child: Row(
            children: [
              _ToggleTab(
                  label: AuthContent.tabSignIn,
                  isActive: isSignIn,
                  onTap: () {
                    if (!isSignIn) onToggleMode();
                  }),
              _ToggleTab(
                  label: AuthContent.tabCreateAccount,
                  isActive: !isSignIn,
                  onTap: () {
                    if (isSignIn) onToggleMode();
                  }),
            ],
          ),
        ),
        const SizedBox(height: BlackLightSpacing.lg),

        if (!isSignIn) ...[
          Text(AuthContent.iamLabel, style: BlackLightTextStyles.captionBold()),
          const SizedBox(height: BlackLightSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _RoleCard(
                  label: AuthContent.roleHomeowner,
                  icon: Icons.home_outlined,
                  isSelected: selectedRole == UserRole.homeowner,
                  onTap: () => onRoleChanged(UserRole.homeowner),
                ),
              ),
              const SizedBox(width: BlackLightSpacing.sm),
              Expanded(
                child: _RoleCard(
                  label: AuthContent.roleSolarBusiness,
                  icon: Icons.domain_outlined,
                  isSelected: selectedRole == UserRole.organization,
                  onTap: () => onRoleChanged(UserRole.organization),
                ),
              ),
            ],
          ),
          const SizedBox(height: BlackLightSpacing.md),
        ],

        _LabeledInput(
          label: AuthContent.labelEmail,
          child: TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            enabled: !isSubmitting,
            style:
                BlackLightTextStyles.body(color: BlackLightColors.textPrimary),
            decoration: _inputDeco(AuthContent.hintEmail),
          ),
        ),
        const SizedBox(height: BlackLightSpacing.sm),

        _LabeledInput(
          label: AuthContent.labelPassword,
          child: TextField(
            controller: passwordCtrl,
            obscureText: obscurePassword,
            enabled: !isSubmitting,
            style:
                BlackLightTextStyles.body(color: BlackLightColors.textPrimary),
            decoration: _inputDeco(AuthContent.hintPasswordObscured).copyWith(
              suffixIcon: GestureDetector(
                onTap: isSubmitting ? null : onTogglePassword,
                child: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: BlackLightColors.textCaption,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        if (!isSignIn) ...[
          const SizedBox(height: BlackLightSpacing.sm),
          if (selectedRole == UserRole.homeowner)
            _LabeledInput(
              label: AuthContent.labelFullName,
              child: TextField(
                controller: nameCtrl,
                enabled: !isSubmitting,
                style: BlackLightTextStyles.body(
                    color: BlackLightColors.textPrimary),
                decoration: _inputDeco(AuthContent.hintYourName),
              ),
            )
          else
            _LabeledInput(
              label: AuthContent.labelCompanyName,
              child: TextField(
                controller: companyCtrl,
                enabled: !isSubmitting,
                style: BlackLightTextStyles.body(
                    color: BlackLightColors.textPrimary),
                decoration: _inputDeco(AuthContent.hintYourCompanyName),
              ),
            ),
        ],

        if (isSignIn) ...[
          const SizedBox(height: BlackLightSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(AuthContent.forgotPassword,
                style: BlackLightTextStyles.caption(
                    color: BlackLightColors.accent)),
          ),
        ],
        const SizedBox(height: BlackLightSpacing.md),

        SizedBox(
          width: double.infinity,
          height: BlackLightSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : () => onContinue(),
            style: ElevatedButton.styleFrom(
              backgroundColor: BlackLightColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(AuthContent.continue_,
                    style:
                        BlackLightTextStyles.bodyBold(color: Colors.white)),
          ),
        ),
        const SizedBox(height: BlackLightSpacing.lg),

        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(AuthContent.orContinueWith,
                  style: BlackLightTextStyles.caption()),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: BlackLightSpacing.md),

        _SocialButton(
          label: AuthContent.oauthGoogle,
          icon: Icons.g_mobiledata_rounded,
          onTap: isSubmitting
              ? null
              : () => AppFeedback.socialSignInStub(context, AuthContent.oauthGoogle),
        ),
        const SizedBox(height: BlackLightSpacing.xs),
        _SocialButton(
          label: AuthContent.oauthApple,
          icon: Icons.apple,
          onTap: isSubmitting
              ? null
              : () => AppFeedback.socialSignInStub(context, AuthContent.oauthApple),
        ),
        const SizedBox(height: BlackLightSpacing.lg),

        Center(
          child: Text.rich(
                TextSpan(
                  style: BlackLightTextStyles.caption(),
                  children: [
                    TextSpan(text: AuthContent.signupAgreementPrefix),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () {
                      AppFeedback.showInfoDialog(
                        context,
                        title: AuthContent.termsOfServiceTitle,
                        message: AuthContent.termsOfServiceStub,
                      );
                    },
                    child: Text(
                      AuthContent.termsOfServiceTitle,
                      style: BlackLightTextStyles.caption(
                        color: BlackLightColors.accent,
                      ),
                    ),
                  ),
                ),
                TextSpan(text: AuthContent.signupAgreementConjunction),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () {
                      AppFeedback.showInfoDialog(
                        context,
                        title: AuthContent.privacyPolicyTitle,
                        message: AuthContent.privacyPolicyStub,
                      );
                    },
                    child: Text(
                      AuthContent.privacyPolicyTitle,
                      style: BlackLightTextStyles.caption(
                        color: BlackLightColors.accent,
                      ),
                    ),
                  ),
                ),
                TextSpan(text: AuthContent.signupAgreementSuffix),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            BlackLightTextStyles.body(color: BlackLightColors.textCaption),
        filled: true,
        fillColor: BlackLightColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.input),
          borderSide: const BorderSide(color: BlackLightColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.input),
          borderSide: const BorderSide(color: BlackLightColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.input),
          borderSide:
              const BorderSide(color: BlackLightColors.accent, width: 1),
        ),
      );
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: double.infinity,
          decoration: BoxDecoration(
            color: isActive ? BlackLightColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border:
                isActive ? Border.all(color: BlackLightColors.border) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: BlackLightTextStyles.caption(
                color: isActive
                    ? BlackLightColors.textPrimary
                    : BlackLightColors.textCaption,
              ).copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(BlackLightSpacing.sm),
        decoration: BoxDecoration(
          color: BlackLightColors.surface,
          borderRadius: BorderRadius.circular(BlackLightRadius.card),
          border: Border.all(
            color:
                isSelected ? BlackLightColors.accent : BlackLightColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 24,
                color: isSelected
                    ? BlackLightColors.accent
                    : BlackLightColors.textBody),
            const SizedBox(height: 6),
            Text(label,
                style: BlackLightTextStyles.bodyBold(
                  color: isSelected
                      ? BlackLightColors.textPrimary
                      : BlackLightColors.textBody,
                )),
          ],
        ),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledInput({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: BlackLightTextStyles.captionBold(
                color: BlackLightColors.textCaption)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _SocialButton({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: BlackLightSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: BlackLightColors.accent),
        label: Text(label,
            style: BlackLightTextStyles.bodyBold(color: BlackLightColors.accent)
                .copyWith(fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          foregroundColor: BlackLightColors.accent,
          side: const BorderSide(color: BlackLightColors.accent),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
