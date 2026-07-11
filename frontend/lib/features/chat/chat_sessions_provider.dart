import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message.dart';
import 'models/chat_session.dart';
import 'chat_repository.dart';
import 'chat_provider.dart';

class ChatSessionsState {
  final List<ChatSession> sessions;
  final String? activeSessionId;
  final String searchQuery;
  final bool isTyping;

  ChatSessionsState({
    required this.sessions,
    this.activeSessionId,
    this.searchQuery = '',
    this.isTyping = false,
  });

  ChatSessionsState copyWith({
    List<ChatSession>? sessions,
    String? activeSessionId,
    String? searchQuery,
    bool? isTyping,
  }) {
    return ChatSessionsState(
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      searchQuery: searchQuery ?? this.searchQuery,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  ChatSession? get activeSession {
    if (activeSessionId == null) return null;
    return sessions.firstWhere(
      (s) => s.id == activeSessionId,
      orElse: () => sessions.first,
    );
  }

  List<ChatSession> get filteredSessions {
    if (searchQuery.trim().isEmpty) return sessions;
    final query = searchQuery.toLowerCase();
    return sessions
        .where((s) => s.title.toLowerCase().contains(query))
        .toList();
  }
}

class ChatSessionsNotifier extends StateNotifier<ChatSessionsState> {
  final ChatRepository _repository;

  ChatSessionsNotifier(this._repository)
    : super(ChatSessionsState(sessions: [])) {
    _initDefaultSessions();
  }

  void _initDefaultSessions() {
    final initialMsgs = _repository.getInitialMessages();
    final firstSession = ChatSession(
      id: 'session-1',
      title: 'Productivity Planning',
      messages: initialMsgs,
      lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
    );
    final secondSession = ChatSession(
      id: 'session-2',
      title: 'Creative Idea Sandbox',
      messages: [
        ChatMessage(
          id: 'sandbox-1',
          content:
              "Hello! This is your creative sandbox. Let's build something beautiful together.",
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
    );

    state = ChatSessionsState(
      sessions: [firstSession, secondSession],
      activeSessionId: 'session-1',
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectSession(String id) {
    state = state.copyWith(activeSessionId: id);
  }

  void createSession(String title) {
    final newSession = ChatSession(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      messages: [
        ChatMessage(
          id: 'welcome-${DateTime.now().millisecondsSinceEpoch}',
          content: "Hello! How can Aura assist you in this conversation today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      lastActive: DateTime.now(),
    );

    state = state.copyWith(
      sessions: [newSession, ...state.sessions],
      activeSessionId: newSession.id,
    );
  }

  void renameSession(String id, String newTitle) {
    state = state.copyWith(
      sessions: state.sessions.map((s) {
        if (s.id == id) {
          return s.copyWith(title: newTitle);
        }
        return s;
      }).toList(),
    );
  }

  void deleteSession(String id) {
    final updatedSessions = state.sessions.where((s) => s.id != id).toList();
    String? newActiveId = state.activeSessionId;

    if (state.activeSessionId == id) {
      newActiveId = updatedSessions.isNotEmpty
          ? updatedSessions.first.id
          : null;
    }

    state = state.copyWith(
      sessions: updatedSessions,
      activeSessionId: newActiveId,
    );
  }

  Future<void> sendMessage(String content, {String? imageUrl}) async {
    final activeId = state.activeSessionId;
    if (activeId == null) return;
    if (content.trim().isEmpty && imageUrl == null) return;

    final userMsg = await _repository.sendUserMessage(
      content,
      imageUrl: imageUrl,
    );

    // Update active session messages
    final updatedSessions = state.sessions.map((s) {
      if (s.id == activeId) {
        return s.copyWith(
          messages: [...s.messages, userMsg],
          lastActive: DateTime.now(),
        );
      }
      return s;
    }).toList();

    state = state.copyWith(sessions: updatedSessions, isTyping: true);

    try {
      final activeSess = state.sessions.firstWhere((s) => s.id == activeId);
      final aiMsg = await _repository.getAIResponse(activeSess.messages);

      final postAiSessions = state.sessions.map((s) {
        if (s.id == activeId) {
          return s.copyWith(
            messages: [...s.messages, aiMsg],
            lastActive: DateTime.now(),
          );
        }
        return s;
      }).toList();

      state = state.copyWith(sessions: postAiSessions, isTyping: false);
    } catch (_) {
      state = state.copyWith(isTyping: false);
    }
  }

  void clearActiveSession() {
    final activeId = state.activeSessionId;
    if (activeId == null) return;

    state = state.copyWith(
      sessions: state.sessions.map((s) {
        if (s.id == activeId) {
          return s.copyWith(
            messages: [
              ChatMessage(
                id: 'reset-${DateTime.now().millisecondsSinceEpoch}',
                content: "Conversation history cleared. Let's start fresh!",
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
            lastActive: DateTime.now(),
          );
        }
        return s;
      }).toList(),
    );
  }
}

final chatSessionsProvider =
    StateNotifierProvider<ChatSessionsNotifier, ChatSessionsState>((ref) {
      final repository = ref.watch(chatRepositoryProvider);
      return ChatSessionsNotifier(repository);
    });
