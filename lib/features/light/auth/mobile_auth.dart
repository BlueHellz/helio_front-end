import 'dart:developer' as developer;

import 'package:limye_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/ui/app_feedback.dart';
import 'package:limye_app/theme/limye_theme.dart';
import 'package:limye_app/core/brand/blacklight_brand_logo.dart';
import 'package:limye_app/core/app_state.dart';
import 'package:limye_app/core/illustrations/geometric_illustrations.dart';
import 'package:limye_app/core/providers/session_providers.dart';
import 'package:limye_app/services/auth_api.dart';

class MobileAuth extends ConsumerStatefulWidget {
  const MobileAuth({
    super.key,
    this.onBack,
    this.initialSignupMode = false,
  });

  final VoidCallback? onBack;
  final bool initialSignupMode;

  @override
  ConsumerState<MobileAuth> createState() => _MobileAuthState();
}

class _MobileAuthState extends ConsumerState<MobileAuth> {
  bool _obscurePassword = true;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _submitting = false;
  late bool _signupMode;

  @override
  void initState() {
    super.initState();
    _signupMode = widget.initialSignupMode;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (_signupMode) {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        AppFeedback.snack(
          context,
          FieldValidationContent.enterNameEmailAndPassword,
        );
        return;
      }
    } else {
      if (email.isEmpty || password.isEmpty) {
        AppFeedback.snack(context, FieldValidationContent.enterEmailAndPassword);
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final authApi = ref.read(authApiProvider);
      AuthResult result;
      if (_signupMode) {
        result = await authApi.signup(
          email: email,
          password: password,
          fullName: name,
          role: apiRoleString(UserRole.homeowner),
        );
      } else {
        result = await authApi.login(email: email, password: password);
      }
      result = await authApi.enrichWithMe(result);
      if (!mounted) return;
      if (!apiRoleIsHomeowner(result.role)) {
        await ref.read(sessionProvider.notifier).clear();
        if (!mounted) return;
        AppFeedback.snack(context, AuthContent.homeownerLoginOnly);
        return;
      }
      await ref.read(sessionProvider.notifier).applyAuthResult(result);
      if (!mounted) return;
      final displayName = (result.fullName?.trim().isNotEmpty ?? false)
          ? result.fullName!.trim()
          : (_signupMode
              ? name
              : (result.email ?? ''));
      ref.read(blackLightAppStateProvider).signIn(
            role: UserRole.homeowner,
            name: displayName,
          );
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
      backgroundColor: LimyeColors.background,
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(HomeownerDashboardContent.myProjectsPageTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LimyeSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: LimyeSpacing.md),
              const BlackLightLogo(height: 48, maxWidth: 300),
              const SizedBox(height: LimyeSpacing.lg),
              const SunRingsIllustration(size: 160),
              const SizedBox(height: 6),
              Text(
                AuthContent.platformTagline,
                style: LimyeTextStyles.mobileBody(
                    color: LimyeColors.textCaption),
              ),
              const SizedBox(height: LimyeSpacing.xl),
              Container(
                padding: const EdgeInsets.all(LimyeSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: LimyeColors.surface,
                  borderRadius: BorderRadius.circular(LimyeRadius.card),
                  border: Border.all(color: LimyeColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text(
                            AuthContent.tabSignIn,
                            style: LimyeTextStyles.caption(),
                          ),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text(
                            AuthContent.tabCreateAccount,
                            style: LimyeTextStyles.caption(),
                          ),
                        ),
                      ],
                      selected: {_signupMode},
                      onSelectionChanged: _submitting
                          ? null
                          : (s) =>
                              setState(() => _signupMode = s.first),
                    ),
                    const SizedBox(height: LimyeSpacing.md),
                    Text(
                      _signupMode
                          ? AuthContent.createYourAccount
                          : AuthContent.welcomeBack,
                      style: LimyeTextStyles.mobileH2(),
                    ),
                    const SizedBox(height: LimyeSpacing.md),
                    if (_signupMode) ...[
                      Text(
                        AuthContent.labelFullName.toUpperCase(),
                        style: LimyeTextStyles.mobileLabelBold(),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: LimyeSpacing.inputHeightMobile,
                        child: TextField(
                          controller: _nameCtrl,
                          enabled: !_submitting,
                          style: LimyeTextStyles.mobileBody(
                              color: LimyeColors.textPrimary),
                          decoration:
                              _inputDeco(AuthContent.hintYourName),
                        ),
                      ),
                      const SizedBox(height: LimyeSpacing.sm),
                    ],
                    Text(
                      AuthContent.mobileLabelEmail.toUpperCase(),
                      style: LimyeTextStyles.mobileLabelBold(),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: LimyeSpacing.inputHeightMobile,
                      child: TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_submitting,
                        style: LimyeTextStyles.mobileBody(
                            color: LimyeColors.textPrimary),
                        decoration: _inputDeco(AuthContent.hintEmail),
                      ),
                    ),
                    const SizedBox(height: LimyeSpacing.sm),
                    Text(
                      AuthContent.passwordFieldCaption,
                      style: LimyeTextStyles.mobileLabelBold(),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: LimyeSpacing.inputHeightMobile,
                      child: TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        enabled: !_submitting,
                        style: LimyeTextStyles.mobileBody(
                            color: LimyeColors.textPrimary),
                        decoration:
                            _inputDeco(AuthContent.hintPasswordObscured).copyWith(
                          suffixIcon: GestureDetector(
                            onTap: _submitting
                                ? null
                                : () => setState(
                                    () =>
                                        _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: LimyeColors.textCaption,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: LimyeSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: LimyeSpacing.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LimyeColors.accent,
                          foregroundColor: LimyeColors.surface,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: LimyeColors.surface,
                                ),
                              )
                            : Text(
                                _signupMode
                                    ? AuthContent.mobileButtonCreateAccount
                                    : AuthContent.mobileTabSignIn,
                                style: LimyeTextStyles.mobileButton(
                                  color: LimyeColors.surface,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LimyeSpacing.md),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AuthContent.dividerOr,
                      style: LimyeTextStyles.mobileBody(
                          color: LimyeColors.textCaption),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: LimyeSpacing.md),
              SizedBox(
                width: double.infinity,
                height: LimyeSpacing.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () => AppFeedback.socialSignInStub(
                          context, AuthContent.oauthGoogle),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 20),
                  label: Text(AuthContent.mobileContinueGoogle),
                ),
              ),
              const SizedBox(height: LimyeSpacing.xs),
              SizedBox(
                width: double.infinity,
                height: LimyeSpacing.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () => AppFeedback.socialSignInStub(
                          context, AuthContent.oauthApple),
                  icon: const Icon(Icons.apple, size: 20),
                  label: Text(AuthContent.mobileContinueApple),
                ),
              ),
              const SizedBox(height: LimyeSpacing.xl),
              Text(
                AuthContent.mobileLegalFooterShort,
                style: LimyeTextStyles.mobileBody(
                        color: LimyeColors.textCaption)
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
        hintStyle: LimyeTextStyles.mobileBody(
            color: LimyeColors.textCaption),
        filled: true,
        fillColor: LimyeColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LimyeRadius.inputMobile),
          borderSide: const BorderSide(color: LimyeColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LimyeRadius.inputMobile),
          borderSide: const BorderSide(color: LimyeColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LimyeRadius.inputMobile),
          borderSide:
              const BorderSide(color: LimyeColors.accent, width: 1),
        ),
      );
}
