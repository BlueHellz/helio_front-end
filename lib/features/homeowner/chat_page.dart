import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';

import '../../core/models/chat_message.dart';
import '../../theme/blacklight_theme.dart';

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
          padding: const EdgeInsets.all(BlackLightSpacing.gutter),
          child: Text(HomeownerChatContent.pageTitle,
              style: BlackLightTextStyles.sectionHeading()),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: BlackLightSpacing.gutter,
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
                    color: BlackLightColors.surface,
                    borderRadius: BorderRadius.circular(BlackLightRadius.md),
                    border: Border.all(color: BlackLightColors.border),
                  ),
                  child: Text(m.text, style: BlackLightTextStyles.body()),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(BlackLightSpacing.gutter),
          child: Text(
            HomeownerChatContent.composerDisabledHint,
            style: BlackLightTextStyles.caption(),
          ),
        ),
      ],
    );
  }
}
