enum MessageSender { user, ai, system }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<ChatAction>? actions;
  final ChatDataChip? dataChip;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.actions,
    this.dataChip,
  });
}

class ChatAction {
  final String label;
  final String icon;
  final bool isPrimary;

  const ChatAction({
    required this.label,
    required this.icon,
    this.isPrimary = false,
  });
}

class ChatDataChip {
  final String label;
  final String value;
  final String icon;

  const ChatDataChip({
    required this.label,
    required this.value,
    required this.icon,
  });
}
