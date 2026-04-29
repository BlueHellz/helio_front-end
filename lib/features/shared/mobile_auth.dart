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
import '../../core/providers/session_providers.dart';
import '../../services/auth_api.dart';

class MobileAuth extends ConsumerStatefulWidget {
  final void Function(UserRole role)? onAuthenticated;

  const MobileAuth({super.key, this.onAuthenticated});

  @override
  ConsumerState<MobileAuth> createState() => _MobileAuthState();
}

class _MobileAuthState extends ConsumerState<MobileAuth> {
  bool _isSignIn = true;
  bool _obscurePassword = true;
  static const UserRole _installerRole = UserRole.organization;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Mobile register has no separate name field; use the email local-part for `full_name`.
  String _signupFullNameFallback(String email) {
    final local = email.split('@').first.trim();
    return local.isEmpty ? AuthContent.installerSignupNameFallback : local;
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      AppFeedback.snack(context, FieldValidationContent.enterEmailAndPassword);
      return;
    }

    setState(() => _submitting = true);
    try {
      final authApi = ref.read(authApiProvider);
      late AuthResult result;
      if (_isSignIn) {
        result = await authApi.login(email: email, password: password);
        result = await authApi.enrichWithMe(result);
      } else {
        result = await authApi.signup(
          email: email,
          password: password,
          fullName: _signupFullNameFallback(email),
          role: apiRoleString(_installerRole),
        );
      }

      if (!mounted) return;
      await ref.read(sessionProvider.notifier).applyAuthResult(result);
      final session = ref.read(sessionProvider);
      final apiRole = userRoleFromApiString(session.userRole);
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
        'MobileAuth submit failed',
        name: 'MobileAuth',
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
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BlackLightSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: BlackLightSpacing.lg),

              const BlackLightLogo(height: 48, maxWidth: 300),
              const SizedBox(height: BlackLightSpacing.lg),
              const SunRingsIllustration(size: 160),
              const SizedBox(height: 6),
              Text(AuthContent.platformTagline,
                  style: BlackLightTextStyles.mobileBody(
                      color: BlackLightColors.textCaption)),
              const SizedBox(height: BlackLightSpacing.xl),

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
                    _Tab(
                        label: AuthContent.mobileTabSignIn,
                        isActive: _isSignIn,
                        onTap: _submitting
                            ? () {}
                            : () => setState(() => _isSignIn = true)),
                    _Tab(
                        label: AuthContent.mobileTabRegister,
                        isActive: !_isSignIn,
                        onTap: _submitting
                            ? () {}
                            : () => setState(() => _isSignIn = false)),
                  ],
                ),
              ),
              const SizedBox(height: BlackLightSpacing.lg),

              Container(
                padding: const EdgeInsets.all(BlackLightSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: BlackLightColors.surface,
                  borderRadius: BorderRadius.circular(BlackLightRadius.card),
                  border: Border.all(color: BlackLightColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignIn ? AuthContent.welcomeBack : AuthContent.createYourAccount,
                      style: BlackLightTextStyles.mobileH2(),
                    ),
                    const SizedBox(height: BlackLightSpacing.md),

                    _LF(
                        label: AuthContent.mobileLabelEmail,
                        ctrl: _emailCtrl,
                        hint: AuthContent.hintEmail,
                        type: TextInputType.emailAddress,
                        enabled: !_submitting),
                    const SizedBox(height: BlackLightSpacing.sm),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AuthContent.passwordFieldCaption,
                            style: BlackLightTextStyles.mobileLabelBold()),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: BlackLightSpacing.inputHeightMobile,
                          child: TextField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            enabled: !_submitting,
                            style: BlackLightTextStyles.mobileBody(
                                color: BlackLightColors.textPrimary),
                            decoration: _inputDeco(AuthContent.hintPasswordObscured).copyWith(
                              suffixIcon: GestureDetector(
                                onTap: _submitting
                                    ? null
                                    : () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: BlackLightColors.textCaption,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: BlackLightSpacing.md),

                    SizedBox(
                      width: double.infinity,
                      height: BlackLightSpacing.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BlackLightColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isSignIn ? AuthContent.mobileTabSignIn : AuthContent.mobileButtonCreateAccount,
                                style: BlackLightTextStyles.mobileButton(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BlackLightSpacing.md),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(AuthContent.dividerOr,
                        style: BlackLightTextStyles.mobileBody(
                            color: BlackLightColors.textCaption)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: BlackLightSpacing.md),

              _SocialBtn(
                label: AuthContent.mobileContinueGoogle,
                icon: Icons.g_mobiledata_rounded,
                onPressed: _submitting
                    ? null
                    : () =>
                        AppFeedback.socialSignInStub(context, AuthContent.oauthGoogle),
              ),
              const SizedBox(height: BlackLightSpacing.xs),
              _SocialBtn(
                label: AuthContent.mobileContinueApple,
                icon: Icons.apple,
                onPressed: _submitting
                    ? null
                    : () => AppFeedback.socialSignInStub(context, AuthContent.oauthApple),
              ),

              const SizedBox(height: BlackLightSpacing.lg),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: BlackLightSpacing.md,
                    vertical: BlackLightSpacing.sm),
                decoration: BoxDecoration(
                  color: BlackLightColors.surface,
                  border: Border.all(color: BlackLightColors.border),
                  borderRadius:
                      BorderRadius.circular(BlackLightRadius.card),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flight_takeoff_outlined,
                        size: 18, color: BlackLightColors.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AuthContent.mobileApprovedDroneCue,
                        style: BlackLightTextStyles.mobileBody(
                                color: BlackLightColors.textPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    GestureDetector(
                      onTap: _submitting
                          ? null
                          : () async {
                              await ref
                                  .read(sessionProvider.notifier)
                                  .clear();
                              if (!context.mounted) return;
                              context.read<BlackLightAppState>().signIn(
                                    role: UserRole.droneOperator,
                                  );
                              widget.onAuthenticated
                                  ?.call(UserRole.droneOperator);
                            },
                      child: Text(
                        AuthContent.mobileDroneSignInCta,
                        style: BlackLightTextStyles.mobileBody(
                                color: BlackLightColors.accent)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: BlackLightSpacing.xl),
              Text(
                AuthContent.mobileLegalFooterShort,
                style: BlackLightTextStyles.mobileBody(
                        color: BlackLightColors.textCaption)
                    .copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: BlackLightTextStyles.mobileBody(
            color: BlackLightColors.textCaption),
        filled: true,
        fillColor: BlackLightColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.inputMobile),
          borderSide: const BorderSide(color: BlackLightColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.inputMobile),
          borderSide: const BorderSide(color: BlackLightColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.inputMobile),
          borderSide:
              const BorderSide(color: BlackLightColors.accent, width: 1),
        ),
      );
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab(
      {required this.label, required this.isActive, required this.onTap});

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
              style: BlackLightTextStyles.mobileLabelBold(
                color: isActive
                    ? BlackLightColors.textPrimary
                    : BlackLightColors.textCaption,
              ).copyWith(fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}

class _LF extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final TextInputType type;
  final bool enabled;

  const _LF({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.type = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: BlackLightTextStyles.mobileLabelBold()),
        const SizedBox(height: 6),
        SizedBox(
          height: BlackLightSpacing.inputHeightMobile,
          child: TextField(
            controller: ctrl,
            keyboardType: type,
            enabled: enabled,
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
                borderSide:
                    const BorderSide(color: BlackLightColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BlackLightRadius.inputMobile),
                borderSide:
                    const BorderSide(color: BlackLightColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BlackLightRadius.inputMobile),
                borderSide: const BorderSide(
                    color: BlackLightColors.accent, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: BlackLightSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
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
