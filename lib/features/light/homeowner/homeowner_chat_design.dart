import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';
import 'package:kooyoh_app/core/models/chat_message.dart';
import 'package:kooyoh_app/core/illustrations/geometric_illustrations.dart';

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
                    horizontal: KooyohSpacing.md),
                decoration: const BoxDecoration(
                  color: KooyohColors.surface,
                  border: Border(
                      bottom: BorderSide(color: KooyohColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.solar_power_rounded,
                        size: 20, color: KooyohColors.accent),
                    const SizedBox(width: 8),
                    Text(HomeownerChatContent.designAiTitle,
                        style: KooyohTextStyles.cardHeading()),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: KooyohColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: KooyohColors.green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: KooyohColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(HomeownerChatContent.designLiveChip,
                              style: KooyohTextStyles.caption(
                                  color: KooyohColors.green)),
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
                        padding: const EdgeInsets.all(KooyohSpacing.md),
                        itemCount: widget.messages.length,
                        itemBuilder: (context, i) {
                          return _MessageBubble(message: widget.messages[i]);
                        },
                      ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.all(KooyohSpacing.sm),
                decoration: const BoxDecoration(
                  color: KooyohColors.surface,
                  border:
                      Border(top: BorderSide(color: KooyohColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        onSubmitted: (_) => _send(),
                        style: KooyohTextStyles.body(
                            color: KooyohColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: HomeownerChatContent.designInputPlaceholder,
                          hintStyle: KooyohTextStyles.body(
                              color: KooyohColors.textCaption),
                          filled: true,
                          fillColor: KooyohColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                                color: KooyohColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                                color: KooyohColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                                color: KooyohColors.accent, width: 1.5),
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
                          color: KooyohColors.accent,
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
                    horizontal: KooyohSpacing.md),
                decoration: const BoxDecoration(
                  color: KooyohColors.surface,
                  border: Border(
                      bottom: BorderSide(color: KooyohColors.border)),
                ),
                child: Row(
                  children: [
                    Text(HomeownerChatContent.designPreviewTitle,
                        style: KooyohTextStyles.cardHeading()),
                    const Spacer(),
                    if (widget.messages.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: widget.onViewSummary,
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: Text(HomeownerChatContent.designViewSummary,
                              style: KooyohTextStyles.caption(
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KooyohColors.accent,
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
                  color: KooyohColors.background,
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
        padding: const EdgeInsets.all(KooyohSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: KooyohColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: KooyohColors.border),
              ),
              child: const Icon(Icons.solar_power_outlined,
                  size: 26, color: KooyohColors.accent),
            ),
            const SizedBox(height: KooyohSpacing.md),
            Text(HomeownerChatContent.designStartTitle,
                style: KooyohTextStyles.cardHeading()),
            const SizedBox(height: 4),
            Text(
              HomeownerChatContent.designStartBody,
              style: KooyohTextStyles.body(),
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
        const SizedBox(height: KooyohSpacing.md),
        Text(HomeownerChatContent.designAwaitingInput,
            style:
                KooyohTextStyles.body(color: KooyohColors.textCaption)),
      ],
    );
  }
}

class _ActivePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(KooyohSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActiveRoofDesign(height: 320),
          const SizedBox(height: KooyohSpacing.md),
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
                  color: KooyohColors.surface,
                  borderRadius: BorderRadius.circular(KooyohRadius.md),
                  border: Border.all(color: KooyohColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.$1, size: 14, color: KooyohColors.textCaption),
                    const SizedBox(width: 6),
                    Text(s.$2,
                        style: KooyohTextStyles.caption(
                            color: KooyohColors.textCaption)),
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
      padding: const EdgeInsets.only(bottom: KooyohSpacing.sm),
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
                color: KooyohColors.accent,
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
                  horizontal: 14, vertical: KooyohSpacing.xs),
              decoration: BoxDecoration(
                color:
                    isUser ? KooyohColors.accent : KooyohColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? KooyohRadius.card : 4),
                  topRight: Radius.circular(isUser ? 4 : KooyohRadius.card),
                  bottomLeft: const Radius.circular(KooyohRadius.card),
                  bottomRight: const Radius.circular(KooyohRadius.card),
                ),
                border:
                    isUser ? null : Border.all(color: KooyohColors.border),
              ),
              child: Text(
                message.text,
                style: KooyohTextStyles.body(
                    color:
                        isUser ? Colors.white : KooyohColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
