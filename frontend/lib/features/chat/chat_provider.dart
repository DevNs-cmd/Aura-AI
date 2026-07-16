import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/locale_controller.dart';
import '../../core/network/api_config.dart';
import '../../models/chat_message.dart';
import 'chat_repository.dart';

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

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  if (ApiConfig.useMockRepositories) {
    final locale = ref.watch(localeProvider);
    return MockChatRepository(locale.languageCode);
  }

  return HttpChatRepository();
});

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatNotifier(this._repository)
      : super(ChatState(messages: _repository.getInitialMessages()));

  Future<void> sendMessage(String content, {String? imageUrl}) async {
    if (content.trim().isEmpty && imageUrl == null) return;

    final userMsg = await _repository.sendUserMessage(content, imageUrl: imageUrl);

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    try {
      final aiMsg = await _repository.getAIResponse(state.messages);
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
    } catch (_) {
      state = state.copyWith(isTyping: false);
    }
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