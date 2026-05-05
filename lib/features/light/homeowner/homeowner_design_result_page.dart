import 'package:limye_app/core/app_state.dart';
import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/providers/homeowner_draft_provider.dart';
import 'package:limye_app/core/providers/session_providers.dart';
import 'package:limye_app/core/ui/app_feedback.dart';
import 'package:limye_app/features/light/homeowner/homeowner_design_summary.dart';
import 'package:limye_app/services/api.dart';
import 'package:limye_app/services/auth_api.dart';
import 'package:limye_app/services/public_api.dart';
import 'package:limye_app/theme/limye_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI design preview; estimate and funding actions.
class HomeownerDesignResultPage extends ConsumerStatefulWidget {
  const HomeownerDesignResultPage({super.key});

  @override
  ConsumerState<HomeownerDesignResultPage> createState() =>
      _HomeownerDesignResultPageState();
}

class _HomeownerDesignResultPageState
    extends ConsumerState<HomeownerDesignResultPage> {
  bool _loadingEstimate = false;

  Future<void> _onGetEstimate() async {
    final draft = ref.read(homeownerDraftProvider);
    if (draft == null) return;
    setState(() => _loadingEstimate = true);
    try {
      final body = projectCreateBody(
        address: draft.address,
        projectType: 'residential',
        customData: draft.intakeCustomData,
        clientName: draft.previewProject.clientName == CommonContent.emDash
            ? null
            : draft.previewProject.clientName,
      );
      final public = ref.read(publicLimyeApiProvider);
      final json = await public.postEstimate(body);
      if (json.isEmpty) {
        if (mounted) {
          AppFeedback.snack(context, ApiErrorsContent.couldNotLoadProposal);
        }
        return;
      }
      final merged =
          projectFromPublicDesignJson(draft.previewProject, json);
      ref.read(homeownerDraftProvider.notifier).updatePreview(
            merged,
            hasFullProposal: true,
          );
      if (mounted) {
        AppFeedback.snack(
          context,
          HomeownerDesignSummaryContent.proposalLoadedSnack,
        );
      }
    } on PublicApiException {
      if (mounted) {
        AppFeedback.snack(context, ApiErrorsContent.couldNotLoadProposal);
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.snack(
          context,
          ApiErrorsContent.couldNotLoadProposal,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingEstimate = false);
    }
  }

  Future<void> _onGetFunding() async {
    final draft = ref.read(homeownerDraftProvider);
    if (draft == null) return;
    final session = ref.read(sessionProvider);
    if (session.isLoggedIn) {
      await _persistDraftAsProject(
        ref,
        draft,
        context,
        signInIfNeeded: false,
        displayName: _displayNameForLoggedInUser(session, draft),
      );
      return;
    }
    await _FundingAuthDialog.show(context, draft);
  }

  static String? _displayNameForLoggedInUser(
    AuthSession session,
    HomeownerDesignDraft draft,
  ) {
    final fromSession = session.fullName?.trim();
    if (fromSession != null && fromSession.isNotEmpty) return fromSession;
    final fromDraft =
        draft.intakeCustomData['homeowner_name']?.toString().trim();
    if (fromDraft != null && fromDraft.isNotEmpty) return fromDraft;
    final client = draft.previewProject.clientName.trim();
    if (client.isNotEmpty && client != CommonContent.emDash) return client;
    return null;
  }

  static Future<void> _persistDraftAsProject(
    WidgetRef ref,
    HomeownerDesignDraft draft,
    BuildContext context, {
    required bool signInIfNeeded,
    String? displayName,
  }) async {
    try {
      final api = ref.read(apiProvider);
      final custom = Map<String, dynamic>.from(draft.intakeCustomData);
      final name = (displayName ?? '').trim();
      if (name.isNotEmpty) {
        custom['homeowner_name'] = name;
      }
      await api.createProject(
        projectCreateBody(
          address: draft.address,
          projectType: 'residential',
          customData: custom,
          clientName: name.isNotEmpty ? name : null,
        ),
      );
      ref.read(homeownerDraftProvider.notifier).clear();
      ref.read(homeownerProjectListTickProvider.notifier).state++;
      if (!context.mounted) return;
      if (signInIfNeeded) {
        ref.read(blackLightAppStateProvider).signIn(
              role: UserRole.homeowner,
              name: name,
            );
      }
      AppFeedback.snack(
        context,
        HomeownerDesignSummaryContent.projectSavedSnack,
      );
      _popDesignFlow(context);
    } on ApiException catch (_) {
      if (context.mounted) {
        AppFeedback.snack(
          context,
          ApiErrorsContent.couldNotLoadProjects,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppFeedback.snack(
          context,
          ApiErrorsContent.couldNotLoadProjects,
        );
      }
    }
  }

  static void _popDesignFlow(BuildContext context) {
    final nav = Navigator.of(context);
    var n = 0;
    while (nav.canPop() && n < 2) {
      nav.pop();
      n++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(homeownerDraftProvider);
    if (draft == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(LimyeSpacing.gutter),
          child: Text(
            HomeownerDashboardContent.emptyStateMessage,
            textAlign: TextAlign.center,
            style: LimyeTextStyles.body(),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeownerDesignSummary(
          project: draft.previewProject,
          showFullProposal: draft.hasFullProposal,
          onRequestQuote: () => AppFeedback.comingSoon(context),
          onDownload: () => AppFeedback.comingSoon(context),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            LimyeSpacing.gutter,
            0,
            LimyeSpacing.gutter,
            LimyeSpacing.gutter,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: LimyeSpacing.buttonHeight,
                    child: FilledButton(
                      onPressed:
                          _loadingEstimate ? null : () => _onGetEstimate(),
                      child: _loadingEstimate
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              HomeownerDesignSummaryContent.getEstimateProposal,
                              style:
                                  LimyeTextStyles.bodyBold(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: LimyeSpacing.sm),
                  SizedBox(
                    height: LimyeSpacing.buttonHeight,
                    child: OutlinedButton(
                      onPressed: _loadingEstimate ? null : () => _onGetFunding(),
                      child: Text(
                        HomeownerDesignSummaryContent.getFundingInstaller,
                        style: LimyeTextStyles.bodyBold(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FundingAuthDialog extends ConsumerStatefulWidget {
  const _FundingAuthDialog({
    required this.draft,
    required this.parentContext,
  });

  final HomeownerDesignDraft draft;
  final BuildContext parentContext;

  static Future<void> show(
    BuildContext parentContext,
    HomeownerDesignDraft draft,
  ) async {
    await showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (ctx) => _FundingAuthDialog(
        draft: draft,
        parentContext: parentContext,
      ),
    );
  }

  @override
  ConsumerState<_FundingAuthDialog> createState() => _FundingAuthDialogState();
}

class _FundingAuthDialogState extends ConsumerState<_FundingAuthDialog> {
  bool _signupMode = true;
  bool _submitting = false;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (_signupMode) {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        AppFeedback.snack(context, FieldValidationContent.enterNameEmailAndPassword);
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
      final displayName = (result.fullName?.trim().isNotEmpty ?? false)
          ? result.fullName!.trim()
          : (_signupMode
              ? name
              : (result.email?.split('@').first ?? ''));
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!widget.parentContext.mounted) return;
      await _HomeownerDesignResultPageState._persistDraftAsProject(
        ref,
        widget.draft,
        widget.parentContext,
        signInIfNeeded: true,
        displayName: displayName,
      );
    } on AuthApiException catch (e) {
      if (mounted) AppFeedback.snack(context, e.message);
    } catch (_) {
      if (mounted) {
        AppFeedback.snack(
          context,
          ApiErrorsContent.couldNotSignIn,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        HomeownerDesignSummaryContent.fundingDialogTitle,
        style: LimyeTextStyles.cardHeading(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              HomeownerDesignSummaryContent.fundingDialogBody,
              style: LimyeTextStyles.body(),
            ),
            const SizedBox(height: LimyeSpacing.md),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment<bool>(
                  value: true,
                  label: Text(
                    AuthContent.tabCreateAccount,
                    style: LimyeTextStyles.caption(),
                  ),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text(
                    AuthContent.tabSignIn,
                    style: LimyeTextStyles.caption(),
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
            const SizedBox(height: LimyeSpacing.md),
            if (_signupMode) ...[
              TextField(
                controller: _nameCtrl,
                enabled: !_submitting,
                decoration: InputDecoration(
                  labelText: AuthContent.labelFullName,
                  hintText: AuthContent.hintYourName,
                ),
              ),
              const SizedBox(height: LimyeSpacing.sm),
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
            const SizedBox(height: LimyeSpacing.sm),
            TextField(
              controller: _passwordCtrl,
              enabled: !_submitting,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AuthContent.labelPassword,
                hintText: AuthContent.hintPasswordObscured,
              ),
            ),
            const SizedBox(height: LimyeSpacing.md),
            SizedBox(
              height: LimyeSpacing.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: _submitting
                    ? null
                    : () => AppFeedback.socialSignInStub(
                          context,
                          HomeownerDesignSummaryContent.fundingUseGoogle,
                        ),
                icon: const Icon(Icons.g_mobiledata_rounded, size: 20),
                label: Text(
                  HomeownerDesignSummaryContent.fundingUseGoogle,
                  style: LimyeTextStyles.bodyBold(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(ButtonsContent.cancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
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
                      ? HomeownerDesignSummaryContent.fundingDialogSubmitSignup
                      : HomeownerDesignSummaryContent.fundingDialogSubmitSignin,
                  style: LimyeTextStyles.bodyBold(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
