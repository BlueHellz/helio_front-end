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
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        SizedBox(
          width: 420,
          child: Column(
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(
                    horizontal: BlackLightSpacing.md),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(
                      bottom: BorderSide(color: c.outline)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.solar_power_rounded,
                        size: 20, color: c.primary),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(OrgOrgChatDesignContent.aiTitle,
                            style: BlackLightTextStyles.cardHeading(
                                color: c.onSurface)),
                        if (widget.projectAddress.isNotEmpty)
                          Text(widget.projectAddress,
                              style: BlackLightTextStyles.caption(color: variant)
                                  .copyWith(fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.surfaceMuted,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: c.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(OrgOrgChatDesignContent.onlineStatus,
                              style: BlackLightTextStyles.caption(
                                      color: c.secondary)
                                  .copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
              Container(
                padding: const EdgeInsets.all(BlackLightSpacing.sm),
                decoration: BoxDecoration(
                  color: c.surface,
                  border:
                      Border(top: BorderSide(color: c.outline)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        onSubmitted: (_) => _send(),
                        style: BlackLightTextStyles.body(color: c.onSurface),
                        decoration: InputDecoration(
                          hintText: OrgOrgChatDesignContent.siteInputHint,
                          hintStyle: BlackLightTextStyles.body(color: variant),
                          filled: true,
                          fillColor: c.surfaceMuted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide:
                                BorderSide(color: c.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide:
                                BorderSide(color: c.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                                color: c.primary, width: 1.5),
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
                        decoration: BoxDecoration(
                          color: c.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.send_rounded,
                            size: 18, color: c.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: c.outline,
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(
                    horizontal: BlackLightSpacing.md),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(
                      bottom: BorderSide(color: c.outline)),
                ),
                child: Row(
                  children: [
                    Text(OrgOrgChatDesignContent.designPreview,
                        style: BlackLightTextStyles.cardHeading(
                            color: c.onSurface)),
                    const Spacer(),
                    if (widget.messages.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: widget.onViewDesign,
                          icon: Icon(Icons.open_in_new_rounded, size: 14, color: c.onSurface),
                          label: Text(OrgOrgChatDesignContent.fullDesign,
                              style: BlackLightTextStyles.caption(
                                      color: c.onSurface)
                                  .copyWith(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: c.onSurface,
                            side: BorderSide(color: c.outline),
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
                  color: c.scaffold,
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
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
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
                color: c.surface,
                shape: BoxShape.circle,
                border: Border.all(color: c.outline),
              ),
              child: Icon(Icons.architecture_outlined,
                  size: 24, color: c.primary),
            ),
            const SizedBox(height: BlackLightSpacing.md),
            Text(OrgOrgChatDesignContent.readyTitle,
                style: BlackLightTextStyles.cardHeading(color: c.onSurface)),
            const SizedBox(height: 4),
            Text(OrgOrgChatDesignContent.readyBody,
                style: BlackLightTextStyles.body(color: variant),
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
    final c = context.colors;
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
              decoration: BoxDecoration(
                  color: c.primary, shape: BoxShape.circle),
              child: Icon(Icons.solar_power_rounded,
                  size: 14, color: c.onPrimary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isUser ? c.primary : c.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? BlackLightRadius.card : 4),
                  topRight: Radius.circular(isUser ? 4 : BlackLightRadius.card),
                  bottomLeft: const Radius.circular(BlackLightRadius.card),
                  bottomRight: const Radius.circular(BlackLightRadius.card),
                ),
                border:
                    isUser ? null : Border.all(color: c.outline),
              ),
              child: Text(
                message.text,
                style: BlackLightTextStyles.body(
                    color:
                        isUser ? c.onPrimary : c.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
