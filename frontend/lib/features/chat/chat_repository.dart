<<<<<<< HEAD
import '../../core/network/api_client.dart';
=======
import 'dart:async';
import 'package:dio/dio.dart';
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120
import '../../models/chat_message.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_session_store.dart';

class ChatRepository {
  ChatRepository(this._client);
  final ApiClient _client;

<<<<<<< HEAD
  // 1. Ye method add/check karo
=======
class HttpChatRepository implements ChatRepository {
  HttpChatRepository({Dio? dio, AuthSessionStore? sessionStore})
      : _sessionStore = sessionStore ?? AuthSessionStore(),
        _dio = dio ?? ApiClient(sessionStore: sessionStore).dio;

  final Dio _dio;
  final AuthSessionStore _sessionStore;

  @override
  List<ChatMessage> getInitialMessages() => <ChatMessage>[];

  @override
  Future<ChatMessage> sendUserMessage(
    String content, {
    String? imageUrl,
  }) async {
    return ChatMessage(
      id: 'msg-user-${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );
  }

  @override
  Future<ChatMessage> getAIResponse(
    List<ChatMessage> conversationHistory,
  ) async {
    final token = await _sessionStore.readAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('You must sign in again before sending chat messages.');
    }

    final message = _latestUserMessage(conversationHistory);

    try {
      final response = await _dio.post<dynamic>(
        '/chat',
        data: {'message': message},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected chat response shape.');
      }

      final reply = data['reply']?.toString();
      if (reply == null || reply.isEmpty) {
        throw const FormatException('Chat response did not include a reply.');
      }

      final timestamp = DateTime.tryParse(data['timestamp']?.toString() ?? '') ??
          DateTime.now();

      return ChatMessage(
        id: 'msg-ai-${DateTime.now().millisecondsSinceEpoch}',
        content: reply,
        isUser: false,
        timestamp: timestamp,
      );
    } on DioException catch (error) {
      throw Exception(_mapChatError(error));
    }
  }

  String _latestUserMessage(List<ChatMessage> conversationHistory) {
    for (final message in conversationHistory.reversed) {
      if (message.isUser) {
        return message.content;
      }
    }

    if (conversationHistory.isNotEmpty) {
      return conversationHistory.last.content;
    }

    throw Exception('Cannot send an empty chat message.');
  }

  String _mapChatError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The chat request timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Unable to reach the chat server. Check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Your session has expired. Please sign in again.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'The chat server is currently unavailable.';
        }
        return _extractServerMessage(error.response?.data) ?? 'Chat request failed.';
      default:
        return error.message ?? 'Chat request failed.';
    }
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail != null) {
        return detail.toString();
      }

      final message = data['message'];
      if (message != null) {
        return message.toString();
      }
    }

    return null;
  }
}

class MockChatRepository implements ChatRepository {
  final String localeCode;
  late final List<ChatMessage> _messages;

  MockChatRepository([this.localeCode = 'en']) {
    final isHindi = localeCode.toLowerCase() == 'hi';
    _messages = [
      ChatMessage(
        id: 'msg-1',
        content: isHindi
            ? "नमस्ते! मैंने आपकी हाल की जर्नल प्रविष्टियों का विश्लेषण किया है। ऐसा लगता है कि आप उत्पादकता पर ध्यान केंद्रित कर रहे हैं। क्या आप आज साप्ताहिक सारांश का मसौदा तैयार करना चाहेंगे या एक नए रचनात्मक विचार का पता लगाना चाहेंगे?"
            : "Hello! I've analyzed your recent journal entries. You seem to be focusing on productivity. Would you like to draft a weekly summary or explore a new creative idea today?",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        id: 'msg-2',
        content: isHindi
            ? "आइए मेरे कार्य ट्रैकिंग को स्वचालित करने के लिए आपके द्वारा सुझाए गए पायथन स्क्रिप्ट को देखें।"
            : "Let's look at the Python script you suggested for automating my task tracking.",
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        id: 'msg-3',
        content: isHindi
            ? "बिल्कुल! त्रुटि प्रबंधन और लॉगिंग के साथ एकीकृत स्क्रिप्ट का अनुकूलित संस्करण यहाँ दिया गया है।"
            : "Certainly! Here is the optimized version of the script with error handling and logging integrated.",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  @override
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120
  List<ChatMessage> getInitialMessages() {
    return []; 
  }

  // 2. Ye method add/check karo
  Future<ChatMessage> sendUserMessage(String content, {String? imageUrl}) async {
    // Yahan apna logic (API call ya local object creation) likho
    return ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}', 
      content: content,
      isUser: true, 
      timestamp: DateTime.now(),
    );
  }

  // 3. Ye method add/check karo
  Future<ChatMessage> getAIResponse(List<ChatMessage> conversationHistory) async {
    final response = await _client.post('/api/v1/chat/sessions/123/messages', 
      data: {'message': conversationHistory.last.content});
    
    return ChatMessage(
      id: 'ai-${DateTime.now().microsecondsSinceEpoch}',
      content: response.data['response'],
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}