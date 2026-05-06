import 'package:flutter/material.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/ui/app_feedback.dart';
import 'package:limye_app/theme/limye_theme.dart';

bool isPlausibleHomeownerEmail(String raw) {
  final s = raw.trim();
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
}

/// Returns trimmed email, or null if cancelled.
Future<String?> showSaveDesignEmailDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => const _SaveDesignEmailDialog(),
  );
}

class _SaveDesignEmailDialog extends StatefulWidget {
  const _SaveDesignEmailDialog();

  @override
  State<_SaveDesignEmailDialog> createState() => _SaveDesignEmailDialogState();
}

class _SaveDesignEmailDialogState extends State<_SaveDesignEmailDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onSend() {
    final e = _ctrl.text.trim();
    if (e.isEmpty) {
      AppFeedback.snack(context, FieldValidationContent.emailRequired);
      return;
    }
    if (!isPlausibleHomeownerEmail(e)) {
      AppFeedback.snack(context, FieldValidationContent.emailInvalidFormat);
      return;
    }
    Navigator.of(context).pop<String>(e);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        side: BorderSide(color: context.colors.outline),
      ),
      title: Text(
        DesignSaveEmailContent.modalTitle,
        style: LimyeTextStyles.cardHeading(color: context.colors.onSurface),
      ),
      content: TextField(
        controller: _ctrl,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        style: LimyeTextStyles.body(color: context.colors.onSurface),
        decoration: InputDecoration(
          labelText: AuthContent.labelEmail,
          hintText: AuthContent.hintEmail,
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? LimyeDarkColors.background
              : LimyeColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LimyeRadius.input),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => _onSend(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            ButtonsContent.cancel,
            style: LimyeTextStyles.bodyBold(color: context.colors.primary),
          ),
        ),
        FilledButton(
          onPressed: _onSend,
          style: FilledButton.styleFrom(
            elevation: 0,
            backgroundColor: LimyeColors.accent,
            foregroundColor: LimyeColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LimyeRadius.sm),
            ),
          ),
          child: Text(
            DesignSaveEmailContent.sendAction,
            style: LimyeTextStyles.bodyBold(color: LimyeColors.surface),
          ),
        ),
      ],
    );
  }
}
