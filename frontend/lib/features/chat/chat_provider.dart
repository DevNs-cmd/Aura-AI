import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message.dart';
import 'chat_repository.dart';
import '../../core/network/api_client.dart';

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

// 1. Sahi Provider (ApiChatRepository hata kar ChatRepository use karo)
final chatRepositoryProvider = FutureProvider<ChatRepository>((ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return ChatRepository(client); 
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

// 2. FutureProvider ke status ko 'when' se handle karo
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repositoryAsync = ref.watch(chatRepositoryProvider);
  
  return repositoryAsync.when(
    data: (repo) => ChatNotifier(repo),
    error: (err, stack) => ChatNotifier(_UnavailableChatRepository()),
    loading: () => ChatNotifier(_UnavailableChatRepository()),
  );
});

class _UnavailableChatRepository implements ChatRepository {
  Never _unavailable() => throw StateError('The API client is not configured.');
  @override List<ChatMessage> getInitialMessages() => const [];
  @override Future<ChatMessage> getAIResponse(List<ChatMessage> history) async => _unavailable();
  @override Future<ChatMessage> sendUserMessage(String content, {String? imageUrl}) async => _unavailable();
}