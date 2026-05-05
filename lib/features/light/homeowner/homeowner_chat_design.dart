import 'package:limye_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:limye_app/theme/limye_theme.dart';
import 'package:limye_app/core/models/chat_message.dart';
import 'package:limye_app/core/illustrations/geometric_illustrations.dart';

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
                    horizontal: LimyeSpacing.md),
                decoration: const BoxDecoration(
                  color: LimyeColors.surface,
                  border: Border(
                      bottom: BorderSide(color: LimyeColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.solar_power_rounded,
                        size: 20, color: LimyeColors.accent),
                    const SizedBox(width: 8),
                    Text(HomeownerChatContent.designAiTitle,
                        style: LimyeTextStyles.cardHeading()),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: LimyeColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: LimyeColors.green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: LimyeColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(HomeownerChatContent.designLiveChip,
                              style: LimyeTextStyles.caption(
                                  color: LimyeColors.green)),
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
                        padding: const EdgeInsets.all(LimyeSpacing.md),
                        itemCount: widget.messages.length,
                        itemBuilder: (context, i) {
                          return _MessageBubble(message: widget.messages[i]);
                        },
                      ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.all(LimyeSpacing.sm),
                decoration: const BoxDecoration(
                  color: LimyeColors.surface,
                  border:
                      Border(top: BorderSide(color: LimyeColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        onSubmitted: (_) => _send(),
                        style: LimyeTextStyles.body(
                            color: LimyeColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: HomeownerChatContent.designInputPlaceholder,
                          hintStyle: LimyeTextStyles.body(
                              color: LimyeColors.textCaption),
                          filled: true,
                          fillColor: LimyeColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                                color: LimyeColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                                color: LimyeColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                                color: LimyeColors.accent, width: 1.5),
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
                          color: LimyeColors.accent,
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
                    horizontal: LimyeSpacing.md),
                decoration: const BoxDecoration(
                  color: LimyeColors.surface,
                  border: Border(
                      bottom: BorderSide(color: LimyeColors.border)),
                ),
                child: Row(
                  children: [
                    Text(HomeownerChatContent.designPreviewTitle,
                        style: LimyeTextStyles.cardHeading()),
                    const Spacer(),
                    if (widget.messages.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: widget.onViewSummary,
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: Text(HomeownerChatContent.designViewSummary,
                              style: LimyeTextStyles.caption(
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LimyeColors.accent,
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
                  color: LimyeColors.background,
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
        padding: const EdgeInsets.all(LimyeSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: LimyeColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: LimyeColors.border),
              ),
              child: const Icon(Icons.solar_power_outlined,
                  size: 26, color: LimyeColors.accent),
            ),
            const SizedBox(height: LimyeSpacing.md),
            Text(HomeownerChatContent.designStartTitle,
                style: LimyeTextStyles.cardHeading()),
            const SizedBox(height: 4),
            Text(
              HomeownerChatContent.designStartBody,
              style: LimyeTextStyles.body(),
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
        const SizedBox(height: LimyeSpacing.md),
        Text(HomeownerChatContent.designAwaitingInput,
            style:
                LimyeTextStyles.body(color: LimyeColors.textCaption)),
      ],
    );
  }
}

class _ActivePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LimyeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActiveRoofDesign(height: 320),
          const SizedBox(height: LimyeSpacing.md),
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
                  color: LimyeColors.surface,
                  borderRadius: BorderRadius.circular(LimyeRadius.md),
                  border: Border.all(color: LimyeColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.$1, size: 14, color: LimyeColors.textCaption),
                    const SizedBox(width: 6),
                    Text(s.$2,
                        style: LimyeTextStyles.caption(
                            color: LimyeColors.textCaption)),
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
      padding: const EdgeInsets.only(bottom: LimyeSpacing.sm),
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
                color: LimyeColors.accent,
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
                  horizontal: 14, vertical: LimyeSpacing.xs),
              decoration: BoxDecoration(
                color:
                    isUser ? LimyeColors.accent : LimyeColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? LimyeRadius.card : 4),
                  topRight: Radius.circular(isUser ? 4 : LimyeRadius.card),
                  bottomLeft: const Radius.circular(LimyeRadius.card),
                  bottomRight: const Radius.circular(LimyeRadius.card),
                ),
                border:
                    isUser ? null : Border.all(color: LimyeColors.border),
              ),
              child: Text(
                message.text,
                style: LimyeTextStyles.body(
                    color:
                        isUser ? Colors.white : LimyeColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
