import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/models/solar_design_data.dart';
import 'package:limye_app/core/providers/ai_design_estimate_provider.dart';
import 'package:limye_app/core/providers/solar_design_provider.dart';
import 'package:limye_app/core/ui/app_feedback.dart';
import 'package:limye_app/features/light/homeowner/widgets/ai_chat_design_rail.dart';
import 'package:limye_app/features/light/homeowner/widgets/guided_form_modal.dart';
import 'package:limye_app/features/light/homeowner/widgets/interactive_design_canvas.dart';
import 'package:limye_app/features/light/homeowner/widgets/solar_estimate_summary_view.dart';
import 'package:limye_app/theme/limye_theme.dart';

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
    this.onFallbackToForm,
  });

  final bool designFlowMode;
  final VoidCallback? onFallbackToForm;

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
  bool _vizReady = false;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
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
        _vizReady = true;
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
        _vizReady = true;
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
    _maybeSeedInteractiveDesignCanvas();
  }

  @override
  void dispose() {
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

  void _maybeSeedInteractiveDesignCanvas() {
    if (!widget.designFlowMode || !_vizReady) return;
    ref.read(designProvider.notifier).seedDemoDesign();
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
      if (_userTurnCount >= 2) _vizReady = true;
    });
    _maybeSeedInteractiveDesignCanvas();
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
      _vizReady = true;
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
          address: payload.address,
          ownerName: payload.ownerName,
        );
    _maybeSeedInteractiveDesignCanvas();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  Future<void> _onMobileRequestEstimate() async {
    final d = ref.read(designProvider);
    final addr = (d.intakeAddress ?? '').trim();
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
                  top: Radius.circular(LimyeRadius.card),
                ),
                border: Border.all(
                  color: scrollContext.colors.outline,
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  LimyeSpacing.md,
                  LimyeSpacing.md,
                  LimyeSpacing.md,
                  MediaQuery.paddingOf(scrollContext).bottom + LimyeSpacing.md,
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
              top: Radius.circular(LimyeRadius.card),
            ),
            border: Border.all(color: context.colors.outline, width: 1),
          ),
          child: Column(
            children: [
              const SizedBox(height: LimyeSpacing.sm),
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
    final mobileEstimateReady = widget.designFlowMode &&
        (designVs.intakeAddress ?? '').trim().isNotEmpty &&
        designVs.data != null &&
        designVs.data!.roofSegments.isNotEmpty;

    if (_split) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
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
              onGuidedForm: widget.onFallbackToForm ?? _openGuidedForm,
              onMore: _onMore,
            ),
          ),
          Expanded(
            flex: 3,
            child: const AiChatDesignRail(),
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
              _MobileChatHeader(onMore: _onMore)
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
              _MobileComposerBar(
                controller: _composerCtrl,
                focusNode: _composerFocus,
                onSend: _send,
                sending: _sending,
                onAttach: () => AppFeedback.comingSoon(context),
                onGuidedForm: widget.onFallbackToForm ?? _openGuidedForm,
                onRequestEstimate: _onMobileRequestEstimate,
                estimateLoading: estimateLoading,
                estimateEnabled: mobileEstimateReady,
              )
            else
              Padding(
                padding: const EdgeInsets.all(LimyeSpacing.gutter),
                child: Text(
                  AiChatContent.composerDisabledHint,
                  style: LimyeTextStyles.caption(
                    color: context.colors.onSurfaceMuted,
                  ),
                ),
              ),
          ],
        ),
        if (widget.designFlowMode)
          Positioned(
            right: LimyeSpacing.gutter,
            bottom: LimyeSpacing.footerHeight + LimyeSpacing.md,
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

  void _onMore() {
    AppFeedback.comingSoon(context);
  }
}

// ─── Mobile chrome ───────────────────────────────────────────────────────────

class _MobileChatHeader extends StatelessWidget {
  const _MobileChatHeader({required this.onMore});

  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LimyeSpacing.footerHeight,
      padding: const EdgeInsets.symmetric(horizontal: LimyeSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: context.colors.outline, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            AiChatContent.headerBrand,
            style: LimyeTextStyles.cardHeading(
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(width: LimyeSpacing.xs),
          Container(
            width: LimyeSpacing.xs,
            height: LimyeSpacing.xs,
            decoration: BoxDecoration(
              color: context.colors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onMore,
            tooltip: AiChatContent.moreOptionsHint,
            icon: Icon(Icons.more_vert_rounded,
                color: context.colors.onSurfaceMuted),
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
        LimyeSpacing.gutter,
        LimyeSpacing.sm,
        LimyeSpacing.gutter,
        LimyeSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AiChatContent.messagesTabTitle,
          style: LimyeTextStyles.sectionHeading(
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
    required this.onGuidedForm,
    required this.onMore,
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
  final VoidCallback onGuidedForm;
  final VoidCallback onMore;

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
          _DesktopChatHeader(onMore: onMore),
          Expanded(
            child: _ChatMessageList(
              scrollCtrl: scrollCtrl,
              messages: messages,
              showTyping: showTyping && designFlowMode,
              padding: const EdgeInsets.all(LimyeSpacing.md),
            ),
          ),
          if (designFlowMode)
            _DesktopComposer(
              controller: composerCtrl,
              focusNode: composerFocus,
              onSend: onSend,
              sending: sending,
              onGuidedForm: onGuidedForm,
            ),
        ],
      ),
    );
  }
}

class _DesktopChatHeader extends StatelessWidget {
  const _DesktopChatHeader({required this.onMore});

  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LimyeSpacing.footerHeight,
      padding: const EdgeInsets.symmetric(horizontal: LimyeSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.outline, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AiChatContent.headerBrand,
                      style: LimyeTextStyles.bodyBold(
                        color: context.colors.onSurface,
                      ).copyWith(fontSize: 18),
                    ),
                    const SizedBox(width: LimyeSpacing.xs / 2),
                    Container(
                      width: LimyeSpacing.xs,
                      height: LimyeSpacing.xs,
                      decoration: BoxDecoration(
                        color: context.colors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Text(
                  AiChatContent.headerAddressDemo,
                  style: LimyeTextStyles.body(
                    color: context.colors.onSurfaceMuted,
                  ).copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMore,
            tooltip: AiChatContent.moreOptionsHint,
            icon: Icon(Icons.more_vert_rounded,
                color: context.colors.onSurfaceMuted, size: 22),
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
      horizontal: LimyeSpacing.gutter,
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
            padding: EdgeInsets.only(bottom: LimyeSpacing.md),
            child: _TypingIndicator(),
          );
        }
        final m = messages[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: LimyeSpacing.md),
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
            padding: const EdgeInsets.all(LimyeSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(LimyeRadius.md),
              border: Border.all(color: context.colors.outline, width: 1),
            ),
            child: Text(
              entry.text,
              style: LimyeTextStyles.caption(
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
                  padding: const EdgeInsets.all(LimyeSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius:
                        BorderRadius.circular(LimyeRadius.md).copyWith(
                      topRight: const Radius.circular(4),
                    ),
                    border: Border.all(
                      color: context.colors.primary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.text,
                    style: LimyeTextStyles.body(
                      color: context.colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: LimyeSpacing.sm),
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
          const SizedBox(width: LimyeSpacing.sm),
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
    final radius = BorderRadius.circular(LimyeRadius.md).copyWith(
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
              padding: const EdgeInsets.all(LimyeSpacing.sm),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border.all(color: context.colors.outline, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AiChatContent.aiBubbleLabel,
                    style: LimyeTextStyles.captionBold(
                      color: context.colors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: LimyeSpacing.xs / 2),
                  Text(
                    entry.text,
                    style: LimyeTextStyles.body(
                      color: context.colors.onSurface,
                    ),
                  ),
                  if (entry.layouts != null) ...[
                    const SizedBox(height: LimyeSpacing.sm),
                    ...entry.layouts!.map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(top: LimyeSpacing.xs),
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
        borderRadius: BorderRadius.circular(LimyeRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(LimyeSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LimyeRadius.sm),
            border: Border.all(color: context.colors.outline, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: LimyeColors.background,
                  borderRadius: BorderRadius.circular(LimyeRadius.sm),
                ),
                child: Icon(option.icon, color: context.colors.onSurface),
              ),
              const SizedBox(width: LimyeSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: LimyeTextStyles.bodyBold(
                        color: context.colors.onSurface,
                      ),
                    ),
                    Text(
                      option.subtitle,
                      style: LimyeTextStyles.data(
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
            ? LimyeColors.background
            : context.colors.outline.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.outline, width: 1),
      ),
      child: narrow
          ? Icon(Icons.person_rounded,
              size: 18, color: context.colors.onSurfaceMuted)
          : Text(
              'S',
              style: LimyeTextStyles.captionBold(
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
        const SizedBox(width: LimyeSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LimyeSpacing.md,
            vertical: LimyeSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(LimyeRadius.md),
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

class _DesktopComposer extends StatelessWidget {
  const _DesktopComposer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.sending,
    required this.onGuidedForm,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool sending;
  final VoidCallback onGuidedForm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LimyeSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: context.colors.outline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: LimyeSpacing.inputHeight,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (_) => onSend(),
                  textInputAction: TextInputAction.send,
                  style: LimyeTextStyles.body(color: context.colors.onSurface),
                  decoration: InputDecoration(
                    hintText: AiChatContent.inputPlaceholderDesktop,
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? LimyeDarkColors.background
                        : LimyeColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(LimyeRadius.input),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.only(
                      left: LimyeSpacing.md,
                      right: 52,
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  child: Material(
                    color: context.colors.primary,
                    elevation: 0,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: sending ? null : onSend,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: context.colors.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: LimyeSpacing.sm),
          Center(
            child: TextButton(
              onPressed: onGuidedForm,
              child: Text(
                AiChatContent.preferGuidedFormCta,
                style: LimyeTextStyles.body(
                  color: context.colors.onSurfaceMuted,
                ).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: context.colors.primary,
                ),
              ),
            ),
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
    required this.onGuidedForm,
    required this.onRequestEstimate,
    required this.estimateLoading,
    required this.estimateEnabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool sending;
  final VoidCallback onAttach;
  final VoidCallback onGuidedForm;
  final VoidCallback onRequestEstimate;
  final bool estimateLoading;
  final bool estimateEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LimyeSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: context.colors.outline, width: 1),
        ),
      ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(color: context.colors.outline, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onAttach,
                    child: SizedBox(
                      width: LimyeSpacing.tapTarget,
                      height: LimyeSpacing.inputHeight,
                      child: Icon(
                        Icons.add_rounded,
                        color: context.colors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: LimyeSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: LimyeSpacing.inputHeight,
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onSubmitted: (_) => onSend(),
                      textInputAction: TextInputAction.send,
                      style: LimyeTextStyles.body(
                        color: context.colors.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: AiChatContent.inputPlaceholderMobile,
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? LimyeDarkColors.background
                                : LimyeColors.background,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(LimyeRadius.input),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: LimyeSpacing.sm),
                Material(
                  color: context.colors.primary,
                  elevation: 0,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: sending ? null : onSend,
                    child: SizedBox(
                      width: LimyeSpacing.inputHeight,
                      height: LimyeSpacing.inputHeight,
                      child: Icon(
                        Icons.send_rounded,
                        color: context.colors.onPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: LimyeSpacing.sm),
            Builder(builder: (context) {
              Widget btn = SizedBox(
                width: double.infinity,
                height: LimyeSpacing.buttonHeight,
                child: FilledButton(
                  onPressed: estimateLoading || !estimateEnabled
                      ? null
                      : onRequestEstimate,
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: LimyeColors.accent,
                    foregroundColor: LimyeColors.surface,
                    disabledBackgroundColor:
                        LimyeColors.surfaceMuted.withValues(alpha: 0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LimyeRadius.sm),
                    ),
                  ),
                  child: estimateLoading
                      ? SizedBox(
                          width: LimyeSpacing.md,
                          height: LimyeSpacing.md,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: LimyeColors.surface,
                          ),
                        )
                      : Text(
                          DesignEstimateChatContent.requestEstimateCta,
                          style: LimyeTextStyles.bodyBold(
                            color: LimyeColors.surface,
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
            TextButton(
              onPressed: onGuidedForm,
              child: Text(
                AiChatContent.preferGuidedFormCta,
                style: LimyeTextStyles.caption(
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
