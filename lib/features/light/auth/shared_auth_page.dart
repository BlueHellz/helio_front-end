import 'dart:developer' as developer;

import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/brand/blacklight_brand_logo.dart';
import 'package:blacklight_app/core/app_state.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';
import 'package:blacklight_app/core/shell/web/homeowner_web_chrome.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/services/auth_api.dart';

class AuthPage extends ConsumerStatefulWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onNavbarSignIn;

  const AuthPage({
    super.key,
    this.onHomeTap,
    this.onNavbarSignIn,
  });

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
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
    return HomeownerPublicChrome(
      activeNavIndex: 2,
      onSignIn: widget.onNavbarSignIn,
      onHomeTap: widget.onHomeTap,
      onMyProjects: widget.onNavbarSignIn,
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
                    child: _LoginForm(
                      emailCtrl: _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      obscurePassword: _obscurePassword,
                      isSubmitting: _submitting,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.onTogglePassword,
    required this.onContinue,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final bool isSubmitting;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BlackLightLogo(height: 40, maxWidth: 240),
        const SizedBox(height: BlackLightSpacing.xl),
        Text(
          AuthContent.welcomeBack,
          style: BlackLightTextStyles.sectionHeading(),
        ),
        const SizedBox(height: BlackLightSpacing.md),
        Text(
          HomeownerDashboardContent.myProjectsPageTitle,
          style: BlackLightTextStyles.caption(
            color: BlackLightColors.textCaption,
          ),
        ),
        const SizedBox(height: BlackLightSpacing.lg),
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
        const SizedBox(height: BlackLightSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            AuthContent.forgotPassword,
            style:
                BlackLightTextStyles.caption(color: BlackLightColors.accent),
          ),
        ),
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
                : Text(
                    AuthContent.tabSignIn,
                    style: BlackLightTextStyles.bodyBold(color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: BlackLightSpacing.lg),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                AuthContent.orContinueWith,
                style: BlackLightTextStyles.caption(),
              ),
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
              : () =>
                  AppFeedback.socialSignInStub(context, AuthContent.oauthGoogle),
        ),
        const SizedBox(height: BlackLightSpacing.xs),
        _SocialButton(
          label: AuthContent.oauthApple,
          icon: Icons.apple,
          onTap: isSubmitting
              ? null
              : () => AppFeedback.socialSignInStub(context, AuthContent.oauthApple),
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

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: BlackLightTextStyles.captionBold(
            color: BlackLightColors.textCaption,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: BlackLightSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: BlackLightColors.accent),
        label: Text(
          label,
          style: BlackLightTextStyles.bodyBold(color: BlackLightColors.accent)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: BlackLightColors.accent,
          side: const BorderSide(color: BlackLightColors.accent),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
