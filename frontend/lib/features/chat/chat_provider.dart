import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message.dart';
import 'chat_repository.dart';
import '../../core/localization/locale_controller.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatState({required this.messages, this.isTyping = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isTyping}) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

// Provider for ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final locale = ref.watch(localeProvider);
  return MockChatRepository(locale.languageCode);
});

// StateNotifierProvider for ChatState
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatNotifier(this._repository)
    : super(ChatState(messages: _repository.getInitialMessages()));

  Future<void> sendMessage(String content, {String? imageUrl}) async {
    if (content.trim().isEmpty && imageUrl == null) return;

    // Send user message
    final userMsg = await _repository.sendUserMessage(
      content,
      imageUrl: imageUrl,
    );

    // Update local state list
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true, // Trigger typing animation
    );

    try {
      // Get AI response
      final aiMsg = await _repository.getAIResponse(state.messages);

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
    } catch (_) {
      state = state.copyWith(isTyping: false);
    }
  }

  void simulateSuggestionClick(String text) {
    sendMessage(text);
  }

  void deleteMessage(String messageId) {
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != messageId).toList(),
    );
  }

  void clearChat() {
    state = ChatState(messages: _repository.getInitialMessages());
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository);
});
