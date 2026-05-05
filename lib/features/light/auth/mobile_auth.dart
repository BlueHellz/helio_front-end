import 'dart:developer' as developer;

import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/brand/blacklight_brand_logo.dart';
import 'package:blacklight_app/core/app_state.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/services/auth_api.dart';

class MobileAuth extends ConsumerStatefulWidget {
  const MobileAuth({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  ConsumerState<MobileAuth> createState() => _MobileAuthState();
}

class _MobileAuthState extends ConsumerState<MobileAuth> {
  bool _obscurePassword = true;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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
      var result = await authApi.login(email: email, password: password);
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
          : (result.email ?? '');
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
      backgroundColor: BlackLightColors.background,
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
          padding: const EdgeInsets.all(BlackLightSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: BlackLightSpacing.md),
              const BlackLightLogo(height: 48, maxWidth: 300),
              const SizedBox(height: BlackLightSpacing.lg),
              const SunRingsIllustration(size: 160),
              const SizedBox(height: 6),
              Text(
                AuthContent.platformTagline,
                style: BlackLightTextStyles.mobileBody(
                    color: BlackLightColors.textCaption),
              ),
              const SizedBox(height: BlackLightSpacing.xl),
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
                      AuthContent.welcomeBack,
                      style: BlackLightTextStyles.mobileH2(),
                    ),
                    const SizedBox(height: BlackLightSpacing.md),
                    Text(
                      AuthContent.mobileLabelEmail.toUpperCase(),
                      style: BlackLightTextStyles.mobileLabelBold(),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: BlackLightSpacing.inputHeightMobile,
                      child: TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_submitting,
                        style: BlackLightTextStyles.mobileBody(
                            color: BlackLightColors.textPrimary),
                        decoration: _inputDeco(AuthContent.hintEmail),
                      ),
                    ),
                    const SizedBox(height: BlackLightSpacing.sm),
                    Text(
                      AuthContent.passwordFieldCaption,
                      style: BlackLightTextStyles.mobileLabelBold(),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: BlackLightSpacing.inputHeightMobile,
                      child: TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        enabled: !_submitting,
                        style: BlackLightTextStyles.mobileBody(
                            color: BlackLightColors.textPrimary),
                        decoration:
                            _inputDeco(AuthContent.hintPasswordObscured).copyWith(
                          suffixIcon: GestureDetector(
                            onTap: _submitting
                                ? null
                                : () => setState(
                                    () => _obscurePassword = !_obscurePassword),
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
                                AuthContent.mobileTabSignIn,
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
                    child: Text(
                      AuthContent.dividerOr,
                      style: BlackLightTextStyles.mobileBody(
                          color: BlackLightColors.textCaption),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: BlackLightSpacing.md),
              SizedBox(
                width: double.infinity,
                height: BlackLightSpacing.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () => AppFeedback.socialSignInStub(
                          context, AuthContent.oauthGoogle),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 20),
                  label: Text(AuthContent.mobileContinueGoogle),
                ),
              ),
              const SizedBox(height: BlackLightSpacing.xs),
              SizedBox(
                width: double.infinity,
                height: BlackLightSpacing.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () => AppFeedback.socialSignInStub(
                          context, AuthContent.oauthApple),
                  icon: const Icon(Icons.apple, size: 20),
                  label: Text(AuthContent.mobileContinueApple),
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
