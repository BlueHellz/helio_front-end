import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/chat_message.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';

// Org chat+design uses same layout as homeowner chat, just different header
class OrgChatDesign extends StatefulWidget {
  final String projectAddress;
  final List<ChatMessage> messages;
  final void Function(String)? onSend;
  final VoidCallback? onViewDesign;

  const OrgChatDesign({
    super.key,
    this.projectAddress = '',
    required this.messages,
    this.onSend,
    this.onViewDesign,
  });

  @override
  State<OrgChatDesign> createState() => _OrgChatDesignState();
}

class _OrgChatDesignState extends State<OrgChatDesign> {
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
    widget.onSend?.call(text);
    _inputCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Chat
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(OrgOrgChatDesignContent.aiTitle,
                            style: BlackLightTextStyles.cardHeading()),
                        if (widget.projectAddress.isNotEmpty)
                          Text(widget.projectAddress,
                              style: BlackLightTextStyles.caption()
                                  .copyWith(fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BlackLightColors.surface,
                        borderRadius: BorderRadius.circular(999),
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
                          Text(OrgOrgChatDesignContent.onlineStatus,
                              style: BlackLightTextStyles.caption(
                                      color: BlackLightColors.green)
                                  .copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: widget.messages.isEmpty
                    ? _EmptyChat()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(BlackLightSpacing.md),
                        itemCount: widget.messages.length,
                        itemBuilder: (ctx, i) =>
                            _Bubble(message: widget.messages[i]),
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
                          hintText: OrgOrgChatDesignContent.siteInputHint,
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

        // Preview panel
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
                    Text(OrgOrgChatDesignContent.designPreview,
                        style: BlackLightTextStyles.cardHeading()),
                    const Spacer(),
                    if (widget.messages.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: widget.onViewDesign,
                          icon: const Icon(Icons.open_in_new_rounded, size: 14),
                          label: Text(OrgOrgChatDesignContent.fullDesign,
                              style: BlackLightTextStyles.caption(
                                      color: BlackLightColors.textPrimary)
                                  .copyWith(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: BlackLightColors.textPrimary,
                            side: const BorderSide(
                                color: BlackLightColors.border),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                        ? ActiveRoofDesign(height: 360, width: double.infinity)
                        : RoofPlaceholder(height: 300, width: double.infinity),
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

class _EmptyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BlackLightSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: BlackLightColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: BlackLightColors.border),
              ),
              child: const Icon(Icons.architecture_outlined,
                  size: 24, color: BlackLightColors.accent),
            ),
            const SizedBox(height: BlackLightSpacing.md),
            Text(OrgOrgChatDesignContent.readyTitle, style: BlackLightTextStyles.cardHeading()),
            const SizedBox(height: 4),
            Text(OrgOrgChatDesignContent.readyBody,
                style: BlackLightTextStyles.body(),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;

  const _Bubble({required this.message});

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
                  color: BlackLightColors.accent, shape: BoxShape.circle),
              child: const Icon(Icons.solar_power_rounded,
                  size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
