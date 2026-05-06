import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kooyoh_app/core/app_state.dart';
import 'package:kooyoh_app/core/brand/blacklight_brand_logo.dart';
import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/providers/session_providers.dart';
import 'package:kooyoh_app/core/shell/web/homeowner_web_chrome.dart';
import 'package:kooyoh_app/core/ui/app_feedback.dart';
import 'package:kooyoh_app/services/auth_api.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

/// Solar org login / sign-up only (installer role preset).
class EnterpriseAuthPage extends ConsumerStatefulWidget {
  const EnterpriseAuthPage({
    super.key,
    this.onHomeTap,
    this.onBusinesses,
    this.onEnterprise,
  });

  final VoidCallback? onHomeTap;
  final VoidCallback? onBusinesses;
  final VoidCallback? onEnterprise;

  @override
  ConsumerState<EnterpriseAuthPage> createState() => _EnterpriseAuthPageState();
}

class _EnterpriseAuthPageState extends ConsumerState<EnterpriseAuthPage> {
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _signupMode = true;
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final company = _companyCtrl.text.trim();
    if (_signupMode) {
      if (name.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          company.isEmpty) {
        AppFeedback.snack(
          context,
          FieldValidationContent.enterOrgSignupFields,
        );
        return;
      }
    } else {
      if (email.isEmpty || password.isEmpty) {
        AppFeedback.snack(
          context,
          FieldValidationContent.enterEmailAndPassword,
        );
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
          role: apiRoleString(UserRole.organization),
          companyName: company,
        );
      } else {
        result = await authApi.login(email: email, password: password);
      }
      result = await authApi.enrichWithMe(result);
      if (!mounted) return;
      if (!apiRoleIsOrganization(result.role)) {
        await ref.read(sessionProvider.notifier).clear();
        if (!mounted) return;
        AppFeedback.snack(context, EnterpriseContent.orgAccessDenied);
        return;
      }
      await ref.read(sessionProvider.notifier).applyAuthResult(result);
      if (!mounted) return;
      final orgName = (result.companyName?.trim().isNotEmpty ?? false)
          ? result.companyName!.trim()
          : (_signupMode ? company : '');
      final displayName = (result.fullName?.trim().isNotEmpty ?? false)
          ? result.fullName!.trim()
          : (_signupMode ? name : (result.email?.split('@').first ?? ''));
      ref.read(blackLightAppStateProvider).signIn(
            role: UserRole.organization,
            name: displayName,
            companyName: orgName,
          );
    } on AuthApiException catch (e) {
      if (mounted) AppFeedback.snack(context, e.message);
    } catch (e, st) {
      developer.log(
        'Enterprise auth failed',
        name: 'EnterpriseAuthPage',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        AppFeedback.snack(context, ApiErrorsContent.couldNotSignIn);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeownerPublicChrome(
      onHomeTap: widget.onHomeTap,
      onBusinesses: widget.onBusinesses ?? () {},
      onEnterprise: widget.onEnterprise ?? () {},
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            KooyohSpacing.navbarHeight -
            KooyohSpacing.footerHeight,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KooyohSpacing.lg,
                    vertical: KooyohSpacing.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BlackLightLogo(height: 40, maxWidth: 240),
                        const SizedBox(height: KooyohSpacing.lg),
                        Text(
                          EnterpriseContent.accessTitle,
                          style: KooyohTextStyles.sectionHeading(),
                        ),
                        const SizedBox(height: KooyohSpacing.sm),
                        Text(
                          EnterpriseContent.accessSubtitle,
                          style: KooyohTextStyles.body(
                            color: KooyohColors.textCaption,
                          ),
                        ),
                        const SizedBox(height: KooyohSpacing.lg),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text(
                                EnterpriseContent.createTab,
                                style: KooyohTextStyles.caption(),
                              ),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(
                                EnterpriseContent.signInTab,
                                style: KooyohTextStyles.caption(),
                              ),
                            ),
                          ],
                          selected: {_signupMode},
                          onSelectionChanged: _submitting
                              ? null
                              : (s) {
                                  setState(() => _signupMode = s.first);
                                },
                        ),
                        const SizedBox(height: KooyohSpacing.lg),
                        if (_signupMode) ...[
                          TextField(
                            controller: _nameCtrl,
                            enabled: !_submitting,
                            decoration: InputDecoration(
                              labelText: AuthContent.labelFullName,
                              hintText: AuthContent.hintYourName,
                            ),
                          ),
                          const SizedBox(height: KooyohSpacing.sm),
                          TextField(
                            controller: _companyCtrl,
                            enabled: !_submitting,
                            decoration: InputDecoration(
                              labelText: EnterpriseContent.labelCompanyOrOrg,
                              hintText: EnterpriseContent.hintCompanyOrOrg,
                            ),
                          ),
                          const SizedBox(height: KooyohSpacing.sm),
                        ],
                        TextField(
                          controller: _emailCtrl,
                          enabled: !_submitting,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: AuthContent.labelEmail,
                            hintText: AuthContent.hintEmail,
                          ),
                        ),
                        const SizedBox(height: KooyohSpacing.sm),
                        TextField(
                          controller: _passwordCtrl,
                          enabled: !_submitting,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AuthContent.labelPassword,
                            hintText: AuthContent.hintPasswordObscured,
                            suffixIcon: GestureDetector(
                              onTap: _submitting
                                  ? null
                                  : () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: KooyohColors.textCaption,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: KooyohSpacing.lg),
                        SizedBox(
                          height: KooyohSpacing.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KooyohColors.accent,
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
                                    _signupMode
                                        ? EnterpriseContent.createTab
                                        : EnterpriseContent.signInTab,
                                    style: KooyohTextStyles.bodyBold(
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: KooyohSpacing.md),
                        OutlinedButton.icon(
                          onPressed: _submitting
                              ? null
                              : () => AppFeedback.socialSignInStub(
                                    context,
                                    AuthContent.oauthGoogle,
                                  ),
                          icon:
                              const Icon(Icons.g_mobiledata_rounded, size: 20),
                          label: Text(
                            AuthContent.oauthGoogle,
                            style: KooyohTextStyles.bodyBold(),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: KooyohColors.accent,
                            side: const BorderSide(color: KooyohColors.accent),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: KooyohColors.surface,
                  border: Border(left: BorderSide(color: KooyohColors.border)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KooyohSpacing.gutter,
                        ),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -20,
                                right: -20,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: KooyohColors.accent.withOpacity(0.06),
                                    border: Border.all(
                                      color: KooyohColors.accent.withOpacity(
                                        0.12,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: KooyohColors.outline,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Image.asset(
                                      'assets/images/enterprise_auth.png',
                                      fit: BoxFit.contain,
                                      semanticLabel: EnterpriseContent
                                          .authHeroIllustrationAccessibilityLabel,
                                      errorBuilder: (_, __, ___) => ColoredBox(
                                        color: context.colors.surfaceMuted,
                                        child: Center(
                                          child: Icon(
                                            Icons.solar_power_rounded,
                                            size: 96,
                                            color: KooyohColors.accent
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: KooyohSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          AuthContent.splitHeroTitle,
                          style: KooyohTextStyles.sectionHeading(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: KooyohSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          AuthContent.splitHeroBody,
                          style: KooyohTextStyles.body(),
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
