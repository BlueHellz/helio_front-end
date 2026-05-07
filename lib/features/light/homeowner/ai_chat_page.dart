import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/models/solar_design_data.dart';
import 'package:kooyoh_app/core/providers/ai_chat_design_email_save_provider.dart';
import 'package:kooyoh_app/core/providers/ai_design_estimate_provider.dart';
import 'package:kooyoh_app/core/providers/session_providers.dart';
import 'package:kooyoh_app/core/providers/solar_design_provider.dart';
import 'package:kooyoh_app/core/solar/solar_design_from_public_json.dart';
import 'package:kooyoh_app/core/ui/app_feedback.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/ai_chat_design_email_save_flow.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/ai_chat_design_rail.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/guided_form_modal.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/interactive_design_canvas.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/solar_estimate_summary_view.dart';
import 'package:kooyoh_app/features/light/homeowner/widgets/solar_path_next_steps_modal.dart';
import 'package:kooyoh_app/core/brand/blacklight_brand_logo.dart';
import 'package:kooyoh_app/services/api.dart';
import 'package:kooyoh_app/services/public_api.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

const double _splitBreakpointWidth = 960;

enum _BubbleRole { user, ai, system }

class _LayoutOpt {
  const _LayoutOpt({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon;
}

class _ChatEntry {
  _ChatEntry({
    required this.id,
    required this.role,
    required this.text,
    this.designAccentLeft = false,
    this.layouts,
  });

  final String id;
  final _BubbleRole role;
  final String text;
  final bool designAccentLeft;
  final List<_LayoutOpt>? layouts;
}

/// Homeowner AI design chat — no navbar/footer/sidebar (host provides chrome).
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({
    super.key,
    this.designFlowMode = false,
    this.onOpenHomeownerLogin,
    this.onOpenHomeownerSignup,
  });

  final bool designFlowMode;
  final VoidCallback? onOpenHomeownerLogin;
  final VoidCallback? onOpenHomeownerSignup;

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _scrollCtrl = ScrollController();
  final _composerCtrl = TextEditingController();
  final _composerFocus = FocusNode();
  final List<_ChatEntry> _messages = [];
  int _userTurnCount = 0;
  bool _sending = false;
  bool _showTyping = false;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _composerFocus.addListener(_onComposerFocus);
    _composerCtrl.addListener(_onComposerTextChanged);
  }

  void _onComposerFocus() {
    if (!_composerFocus.hasFocus || !widget.designFlowMode) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onComposerTextChanged() {
    if (!_composerFocus.hasFocus || !widget.designFlowMode) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    if (widget.designFlowMode) {
      final wide = MediaQuery.sizeOf(context).width >= _splitBreakpointWidth;
      if (wide) {
        _messages.addAll([
          _ChatEntry(
            id: 'seed_ai_d',
            role: _BubbleRole.ai,
            text: AiChatContent.seedAiWelcomeDesktop,
            designAccentLeft: true,
          ),
          _ChatEntry(
            id: 'seed_u_d',
            role: _BubbleRole.user,
            text: AiChatContent.seedUserQuestionDesktop,
          ),
        ]);
      } else {
        _messages.addAll([
          _ChatEntry(
            id: 'seed_ai_m1',
            role: _BubbleRole.ai,
            text: AiChatContent.seedAiWelcomeMobile,
          ),
          _ChatEntry(
            id: 'seed_u_m',
            role: _BubbleRole.user,
            text: AiChatContent.seedUserConfirmMobile,
          ),
          _ChatEntry(
            id: 'seed_ai_m2',
            role: _BubbleRole.ai,
            text: AiChatContent.seedAiLayoutsLeadMobile,
            layouts: const [
              _LayoutOpt(
                title: AiChatContent.layoutOptionMaxProductionTitle,
                subtitle: AiChatContent.layoutOptionMaxProductionSubtitle,
                icon: Icons.grid_view_rounded,
              ),
              _LayoutOpt(
                title: AiChatContent.layoutOptionAestheticTitle,
                subtitle: AiChatContent.layoutOptionAestheticSubtitle,
                icon: Icons.eco_rounded,
              ),
            ],
          ),
        ]);
      }
    } else {
      _messages.addAll([
        _ChatEntry(
          id: 'sys',
          role: _BubbleRole.system,
          text: AiChatContent.messagesTabSystem,
        ),
        _ChatEntry(
          id: 'ai_ph',
          role: _BubbleRole.ai,
          text: AiChatContent.messagesTabAiPlaceholder,
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _composerFocus.removeListener(_onComposerFocus);
    _composerCtrl.removeListener(_onComposerTextChanged);
    if (widget.designFlowMode) {
      ref.read(aiDesignEstimateProvider.notifier).reset();
      ref.read(designProvider.notifier).clear();
    }
    _scrollCtrl.dispose();
    _composerCtrl.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  bool get _split =>
      widget.designFlowMode &&
      MediaQuery.sizeOf(context).width >= _splitBreakpointWidth;

  void _openSolarPathExplainer() {
    final login = widget.onOpenHomeownerLogin;
    final signup = widget.onOpenHomeownerSignup;
    if (login == null || signup == null) return;
    showSolarPathNextStepsModal(
      context,
      onCreateAccount: signup,
      onSignIn: login,
    );
  }

  Future<void> _loadDesignAfterGuidedIntake(GuidedIntakePayload payload) async {
    final custom = <String, dynamic>{
      'monthly_electricity_bill': payload.monthlyBillDollars.toStringAsFixed(0),
      'homeowner_name': payload.ownerName.trim(),
      'intake_city': payload.city.trim(),
      'intake_state': payload.stateCode.trim(),
      'intake_zip': payload.zip.trim(),
      if (payload.email != null && payload.email!.trim().isNotEmpty)
        'email': payload.email!.trim(),
      if (payload.phone != null && payload.phone!.trim().isNotEmpty)
        'phone': payload.phone!.trim(),
      'roof_age': payload.roofAgeLabel,
      'main_panel_amperage': payload.panelAmperageLabel,
      'homeowner_goal': payload.maximizeSavings ? 'max_savings' : 'max_offset',
      'hoa_restrictions': payload.hasHoaRestrictions,
      'monthly_usage_kwh': payload.monthlyUsageKwh.toStringAsFixed(0),
    };
    final body = projectCreateBody(
      address: payload.mailingAddressOneLine,
      projectType: 'residential',
      customData: custom,
      clientName: payload.ownerName.trim().isEmpty
          ? null
          : payload.ownerName.trim(),
    );
    try {
      ref.read(designProvider.notifier).setBackendError(value: false);
      final json = await ref.read(publicKooyohApiProvider).postDesign(body);
      if (!mounted) return;
      if (json.isEmpty) {
        ref.read(designProvider.notifier).setBackendError();
        AppFeedback.snack(context, ApiErrorsContent.couldNotGenerateDesign);
        return;
      }
      final design = solarDesignDataFromPublicDesignJson(json);
      if (design == null) {
        ref.read(designProvider.notifier).setDesign(null);
        AppFeedback.snack(context, InteractiveCanvasContent.designPayloadIncomplete);
        return;
      }
      ref.read(interactiveDesignLiveProvider.notifier).state = null;
      ref.read(designProvider.notifier).setDesign(design);
    } on PublicApiException {
      if (!mounted) return;
      ref.read(designProvider.notifier).setBackendError();
      AppFeedback.snack(context, ApiErrorsContent.couldNotGenerateDesign);
    } catch (_) {
      if (!mounted) return;
      ref.read(designProvider.notifier).setBackendError();
      AppFeedback.snack(context, ApiErrorsContent.couldNotGenerateDesign);
    }
  }

  String _commaThousands(int n) {
    final raw = n.abs().toString();
    final buf = StringBuffer();
    if (n < 0) buf.write('-');
    final len = raw.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write(',');
      buf.write(raw[i]);
    }
    return buf.toString();
  }

  void _onInteractiveDesignChanged(
    RecalculatedFinancials financials,
    List<CanvasSolarPanel> updatedPanels,
    String configurationId,
  ) {
    ref.read(interactiveDesignLiveProvider.notifier).state =
        InteractiveDesignLiveState(
      financials: financials,
      panels: [...updatedPanels.map((p) => p.copyWith())],
      activeConfigIndex:
          ref.read(designProvider).data?.activeConfigIndex ?? 0,
      configId: configurationId,
    );
    setState(() {
      _messages.add(
        _ChatEntry(
          id: 'design_${DateTime.now().millisecondsSinceEpoch}',
          role: _BubbleRole.system,
          text: InteractiveCanvasContent.designChangeSummary(
            panelCount: financials.panelCount,
            systemKw: financials.systemSizeKw.toStringAsFixed(1),
            savings25Usd: _commaThousands(financials.savings25YearUsd.round()),
            annualKwh: _commaThousands(financials.annualProductionKwh.round()),
          ),
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    if (!widget.designFlowMode) return;
    final text = _composerCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _messages.add(_ChatEntry(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        role: _BubbleRole.user,
        text: text,
      ));
      _composerCtrl.clear();
    });
    _userTurnCount++;
    if (_userTurnCount == 1) {
      ref.read(designProvider.notifier).setIntakeFromChatReply(text);
    }
    setState(() => _showTyping = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showTyping = false);
    final reply = _aiReplyForTurn(_userTurnCount);
    setState(() {
      _messages.add(_ChatEntry(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        role: _BubbleRole.ai,
        text: reply,
        designAccentLeft: _userTurnCount == 1,
      ));
      _sending = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  String _aiReplyForTurn(int turn) {
    if (turn <= 1) return AiChatContent.aiReplyAfterAddress;
    if (turn == 2) return AiChatContent.aiReplyAfterBill;
    return AiChatContent.aiReplyContinue;
  }

  void _openGuidedForm() {
    showGuidedFormDialog(
      context,
      composerFocus: _composerFocus,
      onSubmitted: _applyGuidedIntake,
    );
  }

  void _applyGuidedIntake(GuidedIntakePayload payload) {
    setState(() {
      final ts = DateTime.now().millisecondsSinceEpoch;
      _messages.add(
        _ChatEntry(
          id: 'u_guided_$ts',
          role: _BubbleRole.user,
          text: payload.toChatSummary(),
        ),
      );
      _messages.add(
        _ChatEntry(
          id: 'ai_guided_$ts',
          role: _BubbleRole.ai,
          text: AiChatContent.aiReplyAfterGuidedForm,
        ),
      );
    });
    ref.read(designProvider.notifier).setIntakeContext(
          streetLine: payload.streetAddress,
          city: payload.city,
          stateCode: payload.stateCode,
          zip: payload.zip,
          ownerName: payload.ownerName,
          email: payload.email,
        );
    unawaited(_loadDesignAfterGuidedIntake(payload));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  Future<void> _onMobileRequestEstimate() async {
    final d = ref.read(designProvider);
    final addr = (d.intakeMailingAddressOneLine ?? '').trim();
    if (addr.isEmpty ||
        d.data == null ||
        d.data!.roofSegments.isEmpty) {
      if (!mounted) return;
      AppFeedback.snack(
        context,
        DesignEstimateChatContent.needAddressFirst,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final ok =
        await ref.read(aiDesignEstimateProvider.notifier).requestEstimate();
    if (!mounted) return;
    if (!ok) {
      AppFeedback.snack(
        context,
        DesignEstimateChatContent.loadFailedFriendly,
      );
      return;
    }
    final pres = ref.read(aiDesignEstimateProvider).presentation;
    if (!mounted || pres == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          minChildSize: 0.45,
          maxChildSize: 0.98,
          builder: (scrollContext, scrollCtrl) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(scrollContext).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(KooyohRadius.card),
                ),
                border: Border.all(
                  color: scrollContext.colors.outline,
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  KooyohSpacing.md,
                  KooyohSpacing.md,
                  KooyohSpacing.md,
                  MediaQuery.paddingOf(scrollContext).bottom + KooyohSpacing.md,
                ),
                child: SolarEstimateSummaryView(presentation: pres),
              ),
            );
          },
        );
      },
    );
  }

  void _openVisualizationSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.94,
        minChildSize: 0.5,
        maxChildSize: 0.98,
        builder: (context, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(KooyohRadius.card),
            ),
            border: Border.all(color: context.colors.outline, width: 1),
          ),
          child: Column(
            children: [
              const SizedBox(height: KooyohSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: InteractiveDesignCanvas(
                  compact: true,
                  onDesignChanged: _onInteractiveDesignChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final designVs = ref.watch(designProvider);
    final estimateLoading =
        ref.watch(aiDesignEstimateProvider.select((s) => s.loading));
    final saveSending = ref.watch(aiChatDesignEmailSaveProvider);
    final mobileSolarPathEligible = widget.designFlowMode &&
        ref.watch(aiDesignEstimateProvider.select((s) => s.presentation != null)) &&
        widget.onOpenHomeownerLogin != null &&
        widget.onOpenHomeownerSignup != null;
    final mobileEstimateReady = widget.designFlowMode &&
        (designVs.intakeMailingAddressOneLine ?? '').trim().isNotEmpty &&
        designVs.data != null &&
        designVs.data!.roofSegments.isNotEmpty;

    if (_split) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 9,
            child: _ChatPanel(
              designFlowMode: widget.designFlowMode,
              split: true,
              scrollCtrl: _scrollCtrl,
              composerCtrl: _composerCtrl,
              composerFocus: _composerFocus,
              messages: _messages,
              showTyping: _showTyping,
              sending: _sending,
              onSend: _send,
              onQuickIntake: _openGuidedForm,
            ),
          ),
          Expanded(
            flex: 11,
            child: AiChatDesignRail(
              onSolarPathNextSteps:
                  widget.onOpenHomeownerLogin != null &&
                          widget.onOpenHomeownerSignup != null
                      ? () => _openSolarPathExplainer()
                      : null,
            ),
          ),
        ],
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.designFlowMode)
              _MobileChatHeader(onQuickIntake: _openGuidedForm)
            else
              _MessagesTabHeader(),
            Expanded(
              child: _ChatMessageList(
                scrollCtrl: _scrollCtrl,
                messages: _messages,
                showTyping: _showTyping && widget.designFlowMode,
              ),
            ),
            if (widget.designFlowMode)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.colors.outline,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: _MobileComposerBar(
                      controller: _composerCtrl,
                      focusNode: _composerFocus,
                      onSend: _send,
                      sending: _sending,
                      onAttach: () => AppFeedback.comingSoon(context),
                      onRequestEstimate: _onMobileRequestEstimate,
                      estimateLoading: estimateLoading,
                      estimateEnabled: mobileEstimateReady,
                      onSaveDesignEmail: () => runAiChatSaveDesignEmailFlow(
                        context: context,
                        ref: ref,
                      ),
                      saveDesignSending: saveSending,
                      showSolarPathNextSteps: mobileSolarPathEligible,
                      onSolarPathNextSteps: mobileSolarPathEligible
                          ? _openSolarPathExplainer
                          : null,
                    ),
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.all(KooyohSpacing.gutter),
                child: Text(
                  AiChatContent.composerDisabledHint,
                  style: KooyohTextStyles.caption(
                    color: context.colors.onSurfaceMuted,
                  ),
                ),
              ),
          ],
        ),
        if (widget.designFlowMode)
          Positioned(
            right: KooyohSpacing.gutter,
            bottom: KooyohSpacing.footerHeight + KooyohSpacing.md,
            child: Semantics(
              button: true,
              label: AiChatContent.openVisualizationHint,
              child: Material(
                color: context.colors.primary,
                elevation: 0,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _openVisualizationSheet,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: Icon(
                        Icons.roofing_rounded,
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Mobile chrome ───────────────────────────────────────────────────────────

class _MobileChatHeader extends ConsumerWidget {
  const _MobileChatHeader({required this.onQuickIntake});

  final VoidCallback onQuickIntake;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(
      designProvider.select((s) => s.intakeFormattedDisplay),
    );
    final subtitle = (display != null && display.trim().isNotEmpty)
        ? display.trim()
        : AiChatContent.headerSubtitlePending;

    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final warmEnd = Color.lerp(
      scaffoldBg,
      KooyohColors.kooyohTerracotta,
      Theme.of(context).brightness == Brightness.dark ? 0.045 : 0.065,
    )!;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        KooyohSpacing.sm,
        KooyohSpacing.md,
        KooyohSpacing.sm,
        KooyohSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scaffoldBg, warmEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: BlackLightLogo(
                    height: 46,
                    maxWidth: MediaQuery.sizeOf(context).width * 0.5,
                  ),
                ),
              ),
              _QuickIntakePillButton(onTap: onQuickIntake),
            ],
          ),
          const SizedBox(height: KooyohSpacing.xs / 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: KooyohTextStyles.body(
              color: context.colors.onSurfaceMuted,
            ).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MessagesTabHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KooyohSpacing.gutter,
        KooyohSpacing.sm,
        KooyohSpacing.gutter,
        KooyohSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AiChatContent.messagesTabTitle,
          style: KooyohTextStyles.sectionHeading(
            color: context.colors.onSurface,
          ),
        ),
      ),
    );
  }
}

// ─── Chat panel (desktop split left) ────────────────────────────────────────

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.designFlowMode,
    required this.split,
    required this.scrollCtrl,
    required this.composerCtrl,
    required this.composerFocus,
    required this.messages,
    required this.showTyping,
    required this.sending,
    required this.onSend,
    required this.onQuickIntake,
  });

  final bool designFlowMode;
  final bool split;
  final ScrollController scrollCtrl;
  final TextEditingController composerCtrl;
  final FocusNode composerFocus;
  final List<_ChatEntry> messages;
  final bool showTyping;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onQuickIntake;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          right: BorderSide(color: context.colors.outline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DesktopChatHeader(onQuickIntake: onQuickIntake),
          Expanded(
            child: _ChatMessageList(
              scrollCtrl: scrollCtrl,
              messages: messages,
              showTyping: showTyping && designFlowMode,
              padding: const EdgeInsets.fromLTRB(
                KooyohSpacing.md,
                KooyohSpacing.sm,
                KooyohSpacing.md,
                KooyohSpacing.md,
              ),
            ),
          ),
          if (designFlowMode) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: context.colors.outline,
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: _DesktopComposer(
                controller: composerCtrl,
                focusNode: composerFocus,
                onSend: onSend,
                sending: sending,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DesktopChatHeader extends ConsumerWidget {
  const _DesktopChatHeader({required this.onQuickIntake});

  final VoidCallback onQuickIntake;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(
      designProvider.select((s) => s.intakeFormattedDisplay),
    );
    final subtitle = (display != null && display.trim().isNotEmpty)
        ? display.trim()
        : AiChatContent.headerSubtitlePending;

    final panelSurface = Theme.of(context).colorScheme.surface;
    final warmEnd = Color.lerp(
      panelSurface,
      KooyohColors.kooyohTerracotta,
      Theme.of(context).brightness == Brightness.dark ? 0.045 : 0.065,
    )!;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        KooyohSpacing.md,
        KooyohSpacing.sm,
        KooyohSpacing.sm,
        KooyohSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [panelSurface, warmEnd],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: const BlackLightLogo(
                    height: 46,
                    maxWidth: 280,
                  ),
                ),
              ),
              _QuickIntakePillButton(onTap: onQuickIntake),
            ],
          ),
          const SizedBox(height: KooyohSpacing.xs / 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: KooyohTextStyles.body(
              color: context.colors.onSurfaceMuted,
            ).copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageList extends StatelessWidget {
  const _ChatMessageList({
    required this.scrollCtrl,
    required this.messages,
    required this.showTyping,
    this.padding = const EdgeInsets.symmetric(
      horizontal: KooyohSpacing.gutter,
    ),
  });

  final ScrollController scrollCtrl;
  final List<_ChatEntry> messages;
  final bool showTyping;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: padding,
      itemCount: messages.length + (showTyping ? 1 : 0),
      itemBuilder: (context, i) {
        if (showTyping && i == messages.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: KooyohSpacing.md),
            child: _TypingIndicator(),
          );
        }
        final m = messages[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: KooyohSpacing.md),
          child: _MessageBubble(entry: m),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.entry});

  final _ChatEntry entry;

  @override
  Widget build(BuildContext context) {
    final isUser = entry.role == _BubbleRole.user;
    if (entry.role == _BubbleRole.system) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: KooyohSpacing.sm,
              horizontal: KooyohSpacing.cardGap,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(KooyohRadius.md),
              border: Border.all(color: context.colors.outline, width: 1),
            ),
            child: Text(
              entry.text,
              style: KooyohTextStyles.caption(
                color: context.colors.onSurfaceMuted,
              ),
            ),
          ),
        ),
      );
    }

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.9,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: KooyohSpacing.sm,
                    horizontal: KooyohSpacing.cardGap,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius:
                        BorderRadius.circular(KooyohRadius.md).copyWith(
                      topRight: const Radius.circular(4),
                    ),
                    border: Border.all(
                      color: context.colors.primary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.text,
                    style: KooyohTextStyles.body(
                      color: context.colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: KooyohSpacing.sm),
            _UserAvatar(),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AiAvatar(),
          const SizedBox(width: KooyohSpacing.sm),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.9,
              ),
              child: _AiBubbleCard(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBubbleCard extends StatelessWidget {
  const _AiBubbleCard({required this.entry});

  final _ChatEntry entry;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(KooyohRadius.md).copyWith(
      topLeft: const Radius.circular(4),
    );
    return ClipRRect(
      borderRadius: radius,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (entry.designAccentLeft)
            Container(
              width: 3,
              color: context.colors.primary,
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: KooyohSpacing.sm,
                horizontal: KooyohSpacing.cardGap,
              ),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border.all(color: context.colors.outline, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AiChatContent.aiBubbleLabel,
                    style: KooyohTextStyles.captionBold(
                      color: context.colors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: KooyohSpacing.xs / 2),
                  Text(
                    entry.text,
                    style: KooyohTextStyles.body(
                      color: context.colors.onSurface,
                    ),
                  ),
                  if (entry.layouts != null) ...[
                    const SizedBox(height: KooyohSpacing.sm),
                    ...entry.layouts!.map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(top: KooyohSpacing.xs),
                        child: _LayoutOptionTile(option: o),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutOptionTile extends StatelessWidget {
  const _LayoutOptionTile({required this.option});

  final _LayoutOpt option;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppFeedback.snack(context, AiChatContent.aiReplyContinue),
        borderRadius: BorderRadius.circular(KooyohRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(KooyohSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KooyohRadius.sm),
            border: Border.all(color: context.colors.outline, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: KooyohColors.background,
                  borderRadius: BorderRadius.circular(KooyohRadius.sm),
                ),
                child: Icon(option.icon, color: context.colors.onSurface),
              ),
              const SizedBox(width: KooyohSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: KooyohTextStyles.bodyBold(
                        color: context.colors.onSurface,
                      ),
                    ),
                    Text(
                      option.subtitle,
                      style: KooyohTextStyles.data(
                        color: context.colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < _splitBreakpointWidth;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        narrow ? Icons.wb_sunny_rounded : Icons.bolt_rounded,
        size: 18,
        color: context.colors.onPrimary,
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < _splitBreakpointWidth;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: narrow
            ? KooyohColors.background
            : context.colors.outline.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.outline, width: 1),
      ),
      child: narrow
          ? Icon(Icons.person_rounded,
              size: 18, color: context.colors.onSurfaceMuted)
          : Text(
              'S',
              style: KooyohTextStyles.captionBold(
                color: context.colors.onSurfaceMuted,
              ).copyWith(fontSize: 12),
            ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AiAvatar(),
        const SizedBox(width: KooyohSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KooyohSpacing.cardGap,
            vertical: KooyohSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(KooyohRadius.md),
            border: Border.all(color: context.colors.outline, width: 1),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final v = ((_c.value + i * 0.2) % 1.0);
                  final o =
                      0.35 + 0.65 * (1 - (v - 0.5).abs() * 2).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: o),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Secondary outline pill — opens guided intake from the AI chat composer.
class _QuickIntakePillButton extends StatelessWidget {
  const _QuickIntakePillButton({required this.onTap});

  final VoidCallback onTap;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AiChatContent.quickIntakeFormButtonLabel,
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: KooyohColors.accent, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: _height,
              maxHeight: _height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: KooyohSpacing.cardGap),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  AiChatContent.quickIntakeFormButtonLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KooyohTextStyles.bodyBold(color: KooyohColors.accent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accent pill send control (48px height) for AI chat composers.
class _ComposerSendPill extends StatelessWidget {
  const _ComposerSendPill({required this.onTap, required this.enabled});

  final VoidCallback onTap;
  final bool enabled;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AiChatContent.sendButtonLabel,
      child: Material(
        color:
            enabled ? KooyohColors.accent : KooyohColors.accent.withValues(alpha: 0.45),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: _height,
              maxHeight: _height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: KooyohSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AiChatContent.sendButtonLabel,
                    style: KooyohTextStyles.bodyBold(color: KooyohColors.surface),
                  ),
                  const SizedBox(width: KooyohSpacing.xs / 2),
                  Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: KooyohColors.surface,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopComposer extends StatelessWidget {
  const _DesktopComposer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.sending,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        KooyohSpacing.md,
        KooyohSpacing.md,
        KooyohSpacing.md,
        KooyohSpacing.md,
      ),
      color: context.colors.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 3,
              maxLines: 6,
              style: KooyohTextStyles.body(color: context.colors.onSurface),
              scrollPadding: const EdgeInsets.all(KooyohSpacing.xl),
              decoration: InputDecoration(
                hintText: AiChatContent.inputPlaceholderDesktop,
                hintStyle: KooyohTextStyles.body(
                  color: context.colors.onSurfaceMuted,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? KooyohDarkColors.background
                    : KooyohColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KooyohRadius.lg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: KooyohSpacing.md,
                  vertical: KooyohSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(width: KooyohSpacing.sm),
          _ComposerSendPill(
            enabled: !sending,
            onTap: onSend,
          ),
        ],
      ),
    );
  }
}

class _MobileComposerBar extends StatelessWidget {
  const _MobileComposerBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.sending,
    required this.onAttach,
    required this.onRequestEstimate,
    required this.estimateLoading,
    required this.estimateEnabled,
    required this.onSaveDesignEmail,
    required this.saveDesignSending,
    this.showSolarPathNextSteps = false,
    this.onSolarPathNextSteps,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool sending;
  final VoidCallback onAttach;
  final VoidCallback onRequestEstimate;
  final bool estimateLoading;
  final bool estimateEnabled;
  final VoidCallback onSaveDesignEmail;
  final bool saveDesignSending;
  final bool showSolarPathNextSteps;
  final VoidCallback? onSolarPathNextSteps;

  @override
  Widget build(BuildContext context) {
    final attachH = KooyohSpacing.tapTarget;
    return Container(
      padding: const EdgeInsets.all(KooyohSpacing.sm),
      color: context.colors.surface,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  color: context.colors.surface,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(color: context.colors.outline, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onAttach,
                    child: SizedBox(
                      width: attachH,
                      height: attachH,
                      child: Icon(
                        Icons.add_rounded,
                        color: context.colors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: KooyohSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 3,
                    maxLines: 6,
                    style: KooyohTextStyles.body(
                      color: context.colors.onSurface,
                    ),
                    scrollPadding: const EdgeInsets.all(KooyohSpacing.xl),
                    decoration: InputDecoration(
                      hintText: AiChatContent.inputPlaceholderMobile,
                      hintStyle: KooyohTextStyles.body(
                        color: context.colors.onSurfaceMuted,
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? KooyohDarkColors.background
                              : KooyohColors.background,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(KooyohRadius.lg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: KooyohSpacing.md,
                        vertical: KooyohSpacing.sm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: KooyohSpacing.sm),
                _ComposerSendPill(
                  enabled: !sending,
                  onTap: onSend,
                ),
              ],
            ),
            const SizedBox(height: KooyohSpacing.sm),
            Builder(builder: (context) {
              Widget btn = SizedBox(
                width: double.infinity,
                height: KooyohSpacing.buttonHeight,
                child: FilledButton(
                  onPressed: estimateLoading ||
                          saveDesignSending ||
                          !estimateEnabled
                      ? null
                      : onRequestEstimate,
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: KooyohColors.accent,
                    foregroundColor: KooyohColors.surface,
                    disabledBackgroundColor:
                        KooyohColors.surfaceMuted.withValues(alpha: 0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KooyohRadius.sm),
                    ),
                  ),
                  child: estimateLoading
                      ? SizedBox(
                          width: KooyohSpacing.md,
                          height: KooyohSpacing.md,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: KooyohColors.surface,
                          ),
                        )
                      : Text(
                          DesignEstimateChatContent.requestEstimateCta,
                          style: KooyohTextStyles.bodyBold(
                            color: KooyohColors.surface,
                          ),
                        ),
                ),
              );
              if (!estimateEnabled) {
                btn = Tooltip(
                  message: DesignEstimateChatContent.needAddressFirst,
                  child: btn,
                );
              }
              return btn;
            }),
            const SizedBox(height: KooyohSpacing.sm),
            Builder(builder: (context) {
              Widget btn = SizedBox(
                width: double.infinity,
                height: KooyohSpacing.buttonHeight,
                child: OutlinedButton(
                  onPressed: estimateLoading ||
                          saveDesignSending ||
                          !estimateEnabled
                      ? null
                      : onSaveDesignEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KooyohColors.accent,
                    side: const BorderSide(color: KooyohColors.border, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KooyohRadius.sm),
                    ),
                  ),
                  child: saveDesignSending
                      ? SizedBox(
                          width: KooyohSpacing.md,
                          height: KooyohSpacing.md,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: KooyohColors.accent,
                          ),
                        )
                      : Text(
                          DesignSaveEmailContent.saveEmailDesignCta,
                          style:
                              KooyohTextStyles.bodyBold(color: KooyohColors.accent),
                        ),
                ),
              );
              if (!estimateEnabled) {
                btn = Tooltip(
                  message: DesignEstimateChatContent.needAddressFirst,
                  child: btn,
                );
              }
              return btn;
            }),
            if (showSolarPathNextSteps && onSolarPathNextSteps != null) ...[
              const SizedBox(height: KooyohSpacing.sm),
              SolarPathNextStepsCtaCard(onTap: onSolarPathNextSteps!),
            ],
          ],
        ),
      ),
    );
  }
}
