import 'package:flutter/material.dart';
import '../content/content_registry.dart';
import '../../theme/limye_theme.dart';

/// User-visible feedback for actions that will be fully implemented with the
/// backend, or to confirm local/demo interactions.
class AppFeedback {
  AppFeedback._();

  static void snack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      // Web / overlay without a Scaffold: use root overlay dialog fallback.
      showInfoDialog(context,
          title: CommonContent.appName, message: message);
      return;
    }
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: LimyeTextStyles.body()),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        width: 420,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: LimyeTextStyles.cardHeading()),
        content: Text(message, style: LimyeTextStyles.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ButtonsContent.ok, style: LimyeTextStyles.bodyBold()),
          ),
        ],
      ),
    );
  }

  /// Shown when a feature is not wired to the API yet.
  static void comingSoon(
    BuildContext context, {
    String feature = FeedbackStrings.comingSoonDefaultFeature,
  }) {
    showInfoDialog(
      context,
      title: FeedbackStrings.comingSoonTitle,
      message: '$feature${FeedbackStrings.comingSoonTail}',
    );
  }

  /// OAuth / social sign-in (replace with real provider when ready).
  static Future<String?> showEditStringDialog(
    BuildContext context, {
    required String title,
    String initial = '',
    String? hint,
  }) async {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: LimyeTextStyles.cardHeading()),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ButtonsContent.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text(ButtonsContent.save),
          ),
        ],
      ),
    );
  }

  static void socialSignInStub(BuildContext context, String provider) {
    final title = provider == AuthContent.oauthGoogle
        ? AuthContent.signInWithGoogleDialogTitle
        : AuthContent.signInWithAppleDialogTitle;
    showInfoDialog(
      context,
      title: title,
      message: FeedbackStrings.socialStubTail,
    );
  }

  static void whitepaperStub(BuildContext context) {
    showInfoDialog(
      context,
      title: WhitepaperContent.pageTitle,
      message: FeedbackStrings.whitepaperBody,
    );
  }

  static void showWalletConnectDialog(
    BuildContext context, {
    required void Function(String address) onAddress,
  }) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(WalletContent.dialogConnectWalletTitle,
            style: LimyeTextStyles.cardHeading()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              WalletContent.dialogConnectWalletBody,
              style: LimyeTextStyles.caption(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: LimyeTextStyles.data(),
              decoration: InputDecoration(
                hintText: WalletContent.dialogWalletAddressHint,
                hintStyle: LimyeTextStyles.caption(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ButtonsContent.cancel),
          ),
          FilledButton(
            onPressed: () {
              final a = ctrl.text.trim();
              Navigator.of(ctx).pop();
              if (a.isNotEmpty) onAddress(a);
            },
            child: Text(ButtonsContent.save),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: LimyeTextStyles.cardHeading()),
        content: Text(message, style: LimyeTextStyles.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ButtonsContent.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ButtonsContent.confirm),
          ),
        ],
      ),
    );
  }
}
