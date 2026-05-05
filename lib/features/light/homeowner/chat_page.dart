import 'package:limye_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/models/chat_message.dart';
import 'package:limye_app/theme/limye_theme.dart';

class HomeownerChatPage extends ConsumerStatefulWidget {
  const HomeownerChatPage({
    super.key,
    this.designFlowMode = false,
    this.onFallbackToForm,
  });

  /// When true (public design entry), the composer is live with guided copy.
  final bool designFlowMode;

  /// Optional link to the legacy intake form.
  final VoidCallback? onFallbackToForm;

  @override
  ConsumerState<HomeownerChatPage> createState() => _HomeownerChatPageState();
}

class _HomeownerChatPageState extends ConsumerState<HomeownerChatPage> {
  final _scrollCtrl = ScrollController();
  final _composerCtrl = TextEditingController();
  final List<ChatMessage> _messages = [];
  int _userTurnCount = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.designFlowMode) {
      _messages.add(ChatMessage(
        id: 'sys_design',
        text: HomeownerChatContent.welcomeSystemDesign,
        sender: MessageSender.system,
        timestamp: DateTime.now(),
      ));
    } else {
      _messages.addAll([
        ChatMessage(
          id: '1',
          text: HomeownerChatContent.placeholderSystemMessage,
          sender: MessageSender.system,
          timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        ChatMessage(
          id: '2',
          text: HomeownerChatContent.placeholderAiMessage,
          sender: MessageSender.ai,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _composerCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _composerCtrl.text.trim();
    if (text.isEmpty || !widget.designFlowMode || _sending) return;
    setState(() {
      _sending = true;
      _messages.add(ChatMessage(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ));
      _composerCtrl.clear();
    });
    _userTurnCount++;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final reply = _aiReplyForTurn(_userTurnCount);
    setState(() {
      _messages.add(ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: reply,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
      _sending = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  String _aiReplyForTurn(int turn) {
    if (turn <= 1) return HomeownerChatContent.aiReplyAfterAddress;
    if (turn == 2) return HomeownerChatContent.aiReplyAfterBill;
    return HomeownerChatContent.aiReplyContinue;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.designFlowMode
        ? HomeownerChatContent.pageTitleDesign
        : HomeownerChatContent.pageTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(LimyeSpacing.gutter),
          child: Text(title, style: LimyeTextStyles.sectionHeading()),
        ),
        Expanded(
          child: ListView.separated(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(
              horizontal: LimyeSpacing.gutter,
            ),
            itemCount: _messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final m = _messages[i];
              final isUser = m.sender == MessageSender.user;
              Color border = LimyeColors.border;
              if (m.sender == MessageSender.ai) {
                border = LimyeColors.accent.withValues(alpha: 0.35);
              }
              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: LimyeColors.surface,
                    borderRadius: BorderRadius.circular(LimyeRadius.md),
                    border: Border.all(color: border),
                  ),
                  child: Text(m.text, style: LimyeTextStyles.body()),
                ),
              );
            },
          ),
        ),
        if (widget.designFlowMode && widget.onFallbackToForm != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LimyeSpacing.gutter),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: widget.onFallbackToForm,
                style: TextButton.styleFrom(
                  foregroundColor: LimyeColors.accent,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  HomeownerChatContent.fallbackToFormLabel,
                  style: LimyeTextStyles.bodyBold(color: LimyeColors.accent),
                ),
              ),
            ),
          ),
        const Divider(height: 1),
        if (widget.designFlowMode)
          Padding(
            padding: const EdgeInsets.all(LimyeSpacing.gutter),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _composerCtrl,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: HomeownerChatContent.composerHint,
                    ),
                  ),
                ),
                const SizedBox(width: LimyeSpacing.sm),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(LimyeSpacing.gutter),
            child: Text(
              HomeownerChatContent.composerDisabledHint,
              style: LimyeTextStyles.caption(),
            ),
          ),
      ],
    );
  }
}
