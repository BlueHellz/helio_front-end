import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/providers/ai_chat_design_email_save_provider.dart';
import 'package:limye_app/core/providers/solar_design_provider.dart';
import 'package:limye_app/core/ui/app_feedback.dart';
import 'package:limye_app/features/light/homeowner/widgets/save_design_email_dialog.dart';

/// Save & email the current AI-chat design (intake address + optional estimate).
Future<void> runAiChatSaveDesignEmailFlow({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final designVs = ref.read(designProvider);
  final address = (designVs.intakeMailingAddressOneLine ?? '').trim();
  final data = designVs.data;
  if (address.isEmpty ||
      data == null ||
      data.roofSegments.isEmpty) {
    if (!context.mounted) return;
    AppFeedback.snack(
      context,
      DesignEstimateChatContent.needAddressFirst,
    );
    return;
  }

  var email = (designVs.intakeEmail ?? '').trim();
  if (email.isEmpty) {
    email = await showSaveDesignEmailDialog(context) ?? '';
    if (!context.mounted) return;
    if (email.isEmpty) return;
  }

  if (!isPlausibleHomeownerEmail(email)) {
    if (!context.mounted) return;
    AppFeedback.snack(context, FieldValidationContent.emailInvalidFormat);
    return;
  }

  final ok =
      await ref.read(aiChatDesignEmailSaveProvider.notifier).send(email);
  if (!context.mounted) return;
  if (ok) {
    AppFeedback.snack(context, DesignSaveEmailContent.successSnack);
  } else {
    AppFeedback.snack(context, DesignSaveEmailContent.sendFailed);
  }
}
