import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/chat_message.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';

class HomeownerChatDesign extends StatefulWidget {
  final List<ChatMessage> messages;
  final void Function(String text)? onSendMessage;
  final VoidCallback? onViewSummary;

  const HomeownerChatDesign({
    super.key,
    required this.messages,
    this.onSendMessage,
    this.onViewSummary,
  });

  @override
  State<HomeownerChatDesign> createState() => _HomeownerChatDesignState();
}

class _HomeownerChatDesignState extends State<HomeownerChatDesign> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage?.call(text);
    _inputCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Chat panel
        SizedBox(
          width: 420,
          child: Column(
            children: [
              // Header
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(
                    horizontal: BlackLightSpacing.md),
                decoration: const BoxDecoration(
                  color: BlackLightColors.surface,
                  border: Border(
                      bottom: BorderSide(color: BlackLightColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.solar_power_rounded,
                        size: 20, color: BlackLightColors.accent),
                    const SizedBox(width: 8),
                    Text(HomeownerChatContent.designAiTitle,
                        style: BlackLightTextStyles.cardHeading()),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BlackLightColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: BlackLightColors.green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: BlackLightColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(HomeownerChatContent.designLiveChip,
                              style: BlackLightTextStyles.caption(
                                  color: BlackLightColors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: widget.messages.isEmpty
                    ? const _EmptyChatState()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(BlackLightSpacing.md),
                        itemCount: widget.messages.length,
                        itemBuilder: (context, i) {
                          return _MessageBubble(message: widget.messages[i]);
                        },
                      ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.all(BlackLightSpacing.sm),
                decoration: const BoxDecoration(
                  color: BlackLightColors.surface,
                  border:
                      Border(top: BorderSide(color: BlackLightColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        onSubmitted: (_) => _send(),
                        style: BlackLightTextStyles.body(
                            color: BlackLightColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: HomeownerChatContent.designInputPlaceholder,
                          hintStyle: BlackLightTextStyles.body(
                              color: BlackLightColors.textCaption),
                          filled: true,
                          fillColor: BlackLightColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                                color: BlackLightColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                                color: BlackLightColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                                color: BlackLightColors.accent, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: BlackLightColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // Design preview
        Expanded(
          child: Column(
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(
                    horizontal: BlackLightSpacing.md),
                decoration: const BoxDecoration(
                  color: BlackLightColors.surface,
                  border: Border(
                      bottom: BorderSide(color: BlackLightColors.border)),
                ),
                child: Row(
                  children: [
                    Text(HomeownerChatContent.designPreviewTitle,
                        style: BlackLightTextStyles.cardHeading()),
                    const Spacer(),
                    if (widget.messages.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: widget.onViewSummary,
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: Text(HomeownerChatContent.designViewSummary,
                              style: BlackLightTextStyles.caption(
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BlackLightColors.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: BlackLightColors.background,
                  child: Center(
                    child: widget.messages.isNotEmpty
                        ? _ActivePreview()
                        : _IdlePreview(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BlackLightSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: BlackLightColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: BlackLightColors.border),
              ),
              child: const Icon(Icons.solar_power_outlined,
                  size: 26, color: BlackLightColors.accent),
            ),
            const SizedBox(height: BlackLightSpacing.md),
            Text(HomeownerChatContent.designStartTitle,
                style: BlackLightTextStyles.cardHeading()),
            const SizedBox(height: 4),
            Text(
              HomeownerChatContent.designStartBody,
              style: BlackLightTextStyles.body(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IdlePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoofPlaceholder(height: 300, width: 480),
        const SizedBox(height: BlackLightSpacing.md),
        Text(HomeownerChatContent.designAwaitingInput,
            style:
                BlackLightTextStyles.body(color: BlackLightColors.textCaption)),
      ],
    );
  }
}

class _ActivePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActiveRoofDesign(height: 320),
          const SizedBox(height: BlackLightSpacing.md),
          _SpecChipsRow(),
        ],
      ),
    );
  }
}

class _SpecChipsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = [
      (Icons.solar_power_outlined, HomeownerChatContent.metricSystemSize, ''),
      (Icons.bolt_outlined, HomeownerChatContent.metricAnnualProduction, ''),
      (Icons.savings_outlined, HomeownerChatContent.metricYearOneSavings, ''),
      (Icons.layers_outlined, HomeownerChatContent.metricPanels, ''),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: specs
          .map((s) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: BlackLightColors.surface,
                  borderRadius: BorderRadius.circular(BlackLightRadius.md),
                  border: Border.all(color: BlackLightColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.$1, size: 14, color: BlackLightColors.textCaption),
                    const SizedBox(width: 6),
                    Text(s.$2,
                        style: BlackLightTextStyles.caption(
                            color: BlackLightColors.textCaption)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: BlackLightSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: BlackLightColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.solar_power_rounded,
                  size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: BlackLightSpacing.xs),
              decoration: BoxDecoration(
                color:
                    isUser ? BlackLightColors.accent : BlackLightColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? BlackLightRadius.card : 4),
                  topRight: Radius.circular(isUser ? 4 : BlackLightRadius.card),
                  bottomLeft: const Radius.circular(BlackLightRadius.card),
                  bottomRight: const Radius.circular(BlackLightRadius.card),
                ),
                border:
                    isUser ? null : Border.all(color: BlackLightColors.border),
              ),
              child: Text(
                message.text,
                style: BlackLightTextStyles.body(
                    color:
                        isUser ? Colors.white : BlackLightColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
