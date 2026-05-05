import 'package:limye_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';

import 'package:limye_app/core/models/chat_message.dart';
import 'package:limye_app/theme/limye_theme.dart';

class HomeownerChatPage extends StatelessWidget {
  const HomeownerChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(LimyeSpacing.gutter),
          child: Text(HomeownerChatContent.pageTitle,
              style: LimyeTextStyles.sectionHeading()),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: LimyeSpacing.gutter,
            ),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final m = messages[i];
              final isUser = m.sender == MessageSender.user;
              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: LimyeColors.surface,
                    borderRadius: BorderRadius.circular(LimyeRadius.md),
                    border: Border.all(color: LimyeColors.border),
                  ),
                  child: Text(m.text, style: LimyeTextStyles.body()),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
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
