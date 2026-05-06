import 'dart:developer' as developer;

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kooyoh_app/core/ui/app_feedback.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';
import 'package:kooyoh_app/core/brand/blacklight_brand_logo.dart';
import 'package:kooyoh_app/core/app_state.dart';
import 'package:kooyoh_app/core/illustrations/geometric_illustrations.dart';
import 'package:kooyoh_app/core/providers/session_providers.dart';
import 'package:kooyoh_app/services/auth_api.dart';

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
      backgroundColor: KooyohColors.background,
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
          padding: const EdgeInsets.all(KooyohSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: KooyohSpacing.md),
              const BlackLightLogo(height: 48, maxWidth: 300),
              const SizedBox(height: KooyohSpacing.lg),
              const SunRingsIllustration(size: 160),
              const SizedBox(height: 6),
              Text(
                AuthContent.platformTagline,
                style: KooyohTextStyles.mobileBody(
                    color: KooyohColors.textCaption),
              ),
              const SizedBox(height: KooyohSpacing.xl),
              Container(
                padding: const EdgeInsets.all(KooyohSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: KooyohColors.surface,
                  borderRadius: BorderRadius.circular(KooyohRadius.card),
                  border: Border.all(color: KooyohColors.border),
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
                            style: KooyohTextStyles.caption(),
                          ),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text(
                            AuthContent.tabCreateAccount,
                            style: KooyohTextStyles.caption(),
                          ),
                        ),
                      ],
                      selected: {_signupMode},
                      onSelectionChanged: _submitting
                          ? null
                          : (s) =>
                              setState(() => _signupMode = s.first),
                    ),
                    const SizedBox(height: KooyohSpacing.md),
                    Text(
                      _signupMode
                          ? AuthContent.createYourAccount
                          : AuthContent.welcomeBack,
                      style: KooyohTextStyles.mobileH2(),
                    ),
                    const SizedBox(height: KooyohSpacing.md),
                    if (_signupMode) ...[
                      Text(
                        AuthContent.labelFullName.toUpperCase(),
                        style: KooyohTextStyles.mobileLabelBold(),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: KooyohSpacing.inputHeightMobile,
                        child: TextField(
                          controller: _nameCtrl,
                          enabled: !_submitting,
                          style: KooyohTextStyles.mobileBody(
                              color: KooyohColors.textPrimary),
                          decoration:
                              _inputDeco(AuthContent.hintYourName),
                        ),
                      ),
                      const SizedBox(height: KooyohSpacing.sm),
                    ],
                    Text(
                      AuthContent.mobileLabelEmail.toUpperCase(),
                      style: KooyohTextStyles.mobileLabelBold(),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: KooyohSpacing.inputHeightMobile,
                      child: TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_submitting,
                        style: KooyohTextStyles.mobileBody(
                            color: KooyohColors.textPrimary),
                        decoration: _inputDeco(AuthContent.hintEmail),
                      ),
                    ),
                    const SizedBox(height: KooyohSpacing.sm),
                    Text(
                      AuthContent.passwordFieldCaption,
                      style: KooyohTextStyles.mobileLabelBold(),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: KooyohSpacing.inputHeightMobile,
                      child: TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        enabled: !_submitting,
                        style: KooyohTextStyles.mobileBody(
                            color: KooyohColors.textPrimary),
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
                              color: KooyohColors.textCaption,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: KooyohSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: KooyohSpacing.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KooyohColors.accent,
                          foregroundColor: KooyohColors.surface,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: KooyohColors.surface,
                                ),
                              )
                            : Text(
                                _signupMode
                                    ? AuthContent.mobileButtonCreateAccount
                                    : AuthContent.mobileTabSignIn,
                                style: KooyohTextStyles.mobileButton(
                                  color: KooyohColors.surface,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KooyohSpacing.md),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AuthContent.dividerOr,
                      style: KooyohTextStyles.mobileBody(
                          color: KooyohColors.textCaption),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: KooyohSpacing.md),
              SizedBox(
                width: double.infinity,
                height: KooyohSpacing.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () => AppFeedback.socialSignInStub(
                          context, AuthContent.oauthGoogle),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 20),
                  label: Text(AuthContent.mobileContinueGoogle),
                ),
              ),
              const SizedBox(height: KooyohSpacing.xs),
              SizedBox(
                width: double.infinity,
                height: KooyohSpacing.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () => AppFeedback.socialSignInStub(
                          context, AuthContent.oauthApple),
                  icon: const Icon(Icons.apple, size: 20),
                  label: Text(AuthContent.mobileContinueApple),
                ),
              ),
              const SizedBox(height: KooyohSpacing.xl),
              Text(
                AuthContent.mobileLegalFooterShort,
                style: KooyohTextStyles.mobileBody(
                        color: KooyohColors.textCaption)
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
        hintStyle: KooyohTextStyles.mobileBody(
            color: KooyohColors.textCaption),
        filled: true,
        fillColor: KooyohColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KooyohRadius.inputMobile),
          borderSide: const BorderSide(color: KooyohColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KooyohRadius.inputMobile),
          borderSide: const BorderSide(color: KooyohColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KooyohRadius.inputMobile),
          borderSide:
              const BorderSide(color: KooyohColors.accent, width: 1),
        ),
      );
}
