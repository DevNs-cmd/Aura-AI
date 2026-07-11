import '../../../models/chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime lastActive;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.lastActive,
  });

  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? lastActive,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
