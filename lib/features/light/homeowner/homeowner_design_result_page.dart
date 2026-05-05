import 'dart:developer' as developer;

import 'package:blacklight_app/core/app_state.dart';
import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:blacklight_app/core/providers/homeowner_draft_provider.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/features/light/homeowner/homeowner_design_summary.dart';
import 'package:blacklight_app/services/api.dart';
import 'package:blacklight_app/services/auth_api.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Anonymous AI design preview; signup saves the project to the API.
class HomeownerDesignResultPage extends ConsumerWidget {
  const HomeownerDesignResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(homeownerDraftProvider);
    if (draft == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(BlackLightSpacing.gutter),
          child: Text(
            HomeownerDashboardContent.emptyStateMessage,
            textAlign: TextAlign.center,
            style: BlackLightTextStyles.body(),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeownerDesignSummary(
          project: draft.previewProject,
          onRequestQuote: () => AppFeedback.comingSoon(context),
          onDownload: () => AppFeedback.comingSoon(context),
        ),
        Padding(
          padding: const EdgeInsets.all(BlackLightSpacing.gutter),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: FilledButton(
                onPressed: () => _SaveAndTrackDialog.show(context, ref),
                child: Text(HomeownerDesignSummaryContent.saveTrackProject),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveAndTrackDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final draft = ref.read(homeownerDraftProvider);
    if (draft == null) return;

    final nameCtrl = TextEditingController(
      text: draft.previewProject.clientName == CommonContent.emDash
          ? ''
          : draft.previewProject.clientName,
    );
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(HomeownerDesignSummaryContent.saveTrackDialogTitle,
              style: BlackLightTextStyles.cardHeading()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(HomeownerDesignSummaryContent.saveTrackDialogBody,
                    style: BlackLightTextStyles.body()),
                const SizedBox(height: BlackLightSpacing.md),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: AuthContent.labelFullName,
                    hintText: AuthContent.hintYourName,
                  ),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AuthContent.labelEmail,
                    hintText: AuthContent.hintEmail,
                  ),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AuthContent.labelPassword,
                    hintText: AuthContent.hintPasswordObscured,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(ButtonsContent.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(HomeownerDesignSummaryContent.saveTrackSubmit),
            ),
          ],
        ),
      );

      if (ok != true || !context.mounted) return;

      final name = nameCtrl.text.trim();
      final email = emailCtrl.text.trim();
      final password = passwordCtrl.text.trim();
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        AppFeedback.snack(context, FieldValidationContent.enterEmailAndPassword);
        return;
      }

      final authApi = ref.read(authApiProvider);
      var result = await authApi.signup(
        email: email,
        password: password,
        fullName: name,
        role: apiRoleString(UserRole.homeowner),
      );
      result = await authApi.enrichWithMe(result);
      if (!context.mounted) return;
      await ref.read(sessionProvider.notifier).applyAuthResult(result);
      final api = ref.read(apiProvider);
      final custom = Map<String, dynamic>.from(draft.intakeCustomData);
      custom['homeowner_name'] = name;
      custom['email'] = email;
      await api.createProject(
        projectCreateBody(
          address: draft.address,
          projectType: 'residential',
          customData: custom,
          clientName: name,
        ),
      );
      ref.read(homeownerDraftProvider.notifier).clear();
      if (!context.mounted) return;
      ref.read(blackLightAppStateProvider).signIn(
            role: UserRole.homeowner,
            name: name,
          );
      AppFeedback.snack(context, HomeownerDesignSummaryContent.projectSavedSnack);
    } on AuthApiException catch (e) {
      if (context.mounted) AppFeedback.snack(context, e.message);
    } catch (e, st) {
      developer.log('Save project signup failed', error: e, stackTrace: st);
      if (context.mounted) {
        AppFeedback.snack(
          context,
          '${ApiErrorsContent.couldNotSubmitPrefix}$e',
        );
      }
    } finally {
      nameCtrl.dispose();
      emailCtrl.dispose();
      passwordCtrl.dispose();
    }
  }
}
