import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/providers/session_providers.dart';
import 'package:limye_app/core/providers/solar_design_provider.dart';
import 'package:limye_app/core/solar/solar_design_calculator.dart';
import 'package:limye_app/services/api.dart';
import 'package:limye_app/services/public_api.dart';

/// POST `/design/save-email` for anonymous AI-chat delivery.
class AiChatDesignEmailSaveNotifier extends StateNotifier<bool> {
  AiChatDesignEmailSaveNotifier(this.ref) : super(false);

  final Ref ref;

  Future<bool> send(String emailRaw) async {
    final email = emailRaw.trim();
    if (email.isEmpty) return false;

    final designVs = ref.read(designProvider);
    final data = designVs.data;
    final address = (designVs.intakeAddress ?? '').trim();
    if (data == null || address.isEmpty || data.roofSegments.isEmpty) {
      return false;
    }

    state = true;
    try {
      final live = ref.read(interactiveDesignLiveProvider);
      final panels = panelsForConfiguration(data: data, live: live);
      final financials = recalculateSolarFinancials(
        panels: panels,
        segments: data.roofSegments,
      );
      final custom = solarDesignAiChatCustomData(
        data: data,
        panels: panels,
        financials: financials,
      );
      custom['notification_email'] = email;

      final owner = (designVs.intakeOwnerName ?? '').trim();
      final body = <String, dynamic>{
        'email': email,
        ...projectCreateBody(
          address: address,
          projectType: 'residential',
          customData: custom,
          clientName: owner.isEmpty ? null : owner,
        ),
      };

      final public = ref.read(publicLimyeApiProvider);
      await public.postSaveDesignEmail(body);
      return true;
    } on PublicApiException {
      return false;
    } catch (_) {
      return false;
    } finally {
      state = false;
    }
  }
}

final aiChatDesignEmailSaveProvider =
    StateNotifierProvider<AiChatDesignEmailSaveNotifier, bool>(
  (ref) => AiChatDesignEmailSaveNotifier(ref),
);
