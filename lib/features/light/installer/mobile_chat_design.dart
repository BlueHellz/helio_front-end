import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/chat_message.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';

class MobileChatDesign extends StatefulWidget {
  final String projectAddress;
  final List<ChatMessage> messages;
  final void Function(String)? onSend;
  final VoidCallback? onViewDesign;
  final VoidCallback? onBack;

  const MobileChatDesign({
    super.key,
    this.projectAddress = '',
    required this.messages,
    this.onSend,
    this.onViewDesign,
    this.onBack,
  });

  @override
  State<MobileChatDesign> createState() => _MobileChatDesignState();
}

class _MobileChatDesignState extends State<MobileChatDesign>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _inputCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        automaticallyImplyLeading: widget.onBack != null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(OrgMobileInstallerContent.chatTitle,
                style: BlackLightTextStyles.mobileH2()),
            if (widget.projectAddress.isNotEmpty)
              Text(widget.projectAddress,
                  style: BlackLightTextStyles.mobileBody(
                          color: BlackLightColors.textCaption)
                      .copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis),
          ],
        ),
        backgroundColor: BlackLightColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
            bottom: BorderSide(color: BlackLightColors.border, width: 1)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelStyle:
              BlackLightTextStyles.mobileLabelBold().copyWith(fontSize: 13),
          unselectedLabelStyle: BlackLightTextStyles.mobileLabelBold(
                  color: BlackLightColors.textCaption)
              .copyWith(fontSize: 13),
          labelColor: BlackLightColors.accent,
          unselectedLabelColor: BlackLightColors.textBody,
          indicatorColor: BlackLightColors.accent,
          indicatorWeight: 2,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: OrgMobileInstallerContent.tabChat),
            Tab(text: OrgMobileInstallerContent.tabPreview),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Chat tab
          Column(
            children: [
              Expanded(
                child: widget.messages.isEmpty
                    ? _EmptyChat()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(BlackLightSpacing.sm),
                        itemCount: widget.messages.length,
                        itemBuilder: (ctx, i) =>
                            _Bubble(message: widget.messages[i]),
                      ),
              ),
              _ChatInput(ctrl: _inputCtrl, onSend: _send),
            ],
          ),

          // Preview tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(BlackLightSpacing.sm),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    color: BlackLightColors.surface,
                    borderRadius: BorderRadius.circular(BlackLightRadius.card),
                    border: Border.all(color: BlackLightColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(BlackLightRadius.card),
                    child: widget.messages.isNotEmpty
                        ? ActiveRoofDesign(height: 240, width: double.infinity)
                        : RoofPlaceholder(height: 240, width: double.infinity),
                  ),
                ),
                if (widget.messages.isNotEmpty) ...[
                  const SizedBox(height: BlackLightSpacing.md),
                  _SpecGrid(),
                  const SizedBox(height: BlackLightSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: BlackLightSpacing.buttonHeight,
                    child: ElevatedButton(
                      onPressed: widget.onViewDesign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlackLightColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(OrgMobileInstallerContent.viewFullDesign,
                          style: BlackLightTextStyles.mobileButton()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
              child: const Icon(Icons.solar_power_outlined,
                  size: 26, color: BlackLightColors.accent),
            ),
            const SizedBox(height: BlackLightSpacing.md),
            Text(OrgMobileInstallerContent.startDesignTitle,
                style: BlackLightTextStyles.mobileH3()),
            const SizedBox(height: 4),
            Text(
              OrgMobileInstallerContent.startDesignBodyMobile,
              style: BlackLightTextStyles.mobileBody(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSend;

  const _ChatInput({required this.ctrl, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: BlackLightSpacing.sm,
        right: BlackLightSpacing.sm,
        top: BlackLightSpacing.xs,
        bottom: BlackLightSpacing.xs + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: BlackLightColors.surface,
        border: Border(top: BorderSide(color: BlackLightColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              onSubmitted: (_) => onSend(),
              style: BlackLightTextStyles.mobileBody(
                  color: BlackLightColors.textPrimary),
              decoration: InputDecoration(
                hintText: OrgMobileInstallerContent.messageHint,
                hintStyle: BlackLightTextStyles.mobileBody(
                    color: BlackLightColors.textCaption),
                filled: true,
                fillColor: BlackLightColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: BlackLightColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: BlackLightColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(
                      color: BlackLightColors.accent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: BlackLightColors.accent,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.send_rounded, size: 18, color: Colors.white),
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: BlackLightSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                  color: BlackLightColors.accent, shape: BoxShape.circle),
              child: const Icon(Icons.solar_power_rounded,
                  size: 12, color: Colors.white),
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
                style: BlackLightTextStyles.mobileBody(
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

class _SpecGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final specs = [
      (Icons.bolt_outlined, OrgProjectDetailContent.specLabelSystemSize, CommonContent.emDash),
      (Icons.solar_power_outlined, OrgProjectDetailContent.specLabelPanels, CommonContent.emDash),
      (Icons.savings_outlined, OrgProjectDetailContent.specLabelYearOneSavings, CommonContent.emDash),
      (Icons.memory_outlined, OrgProjectDetailContent.specAnnualOutput, CommonContent.emDash),
    ];
    return Wrap(
      spacing: BlackLightSpacing.sm,
      runSpacing: BlackLightSpacing.sm,
      children: specs.map((s) {
        return Container(
          width: (MediaQuery.of(context).size.width -
                  BlackLightSpacing.sm * 2 -
                  BlackLightSpacing.sm) /
              2,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BlackLightColors.surface,
            borderRadius: BorderRadius.circular(BlackLightRadius.md),
            border: Border.all(color: BlackLightColors.border),
          ),
          child: Row(
            children: [
              Icon(s.$1, size: 16, color: BlackLightColors.textCaption),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$2,
                      style: BlackLightTextStyles.mobileBody(
                              color: BlackLightColors.textCaption)
                          .copyWith(fontSize: 11)),
                  Text(s.$3,
                      style: BlackLightTextStyles.data(
                          color: BlackLightColors.textPrimary)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
