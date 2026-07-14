import 'dart:async';
import 'package:dio/dio.dart';
import '../../models/chat_message.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_session_store.dart';

abstract class ChatRepository {
  List<ChatMessage> getInitialMessages();
  Future<ChatMessage> sendUserMessage(String content, {String? imageUrl});
  Future<ChatMessage> getAIResponse(List<ChatMessage> conversationHistory);
}

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
  List<ChatMessage> getInitialMessages() {
    return List.from(_messages);
  }

  @override
  Future<ChatMessage> sendUserMessage(
    String content, {
    String? imageUrl,
  }) async {
    // Add user message to history
    final userMessage = ChatMessage(
      id: 'msg-user-${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );
    _messages.add(userMessage);
    return userMessage;
  }

  @override
  Future<ChatMessage> getAIResponse(
    List<ChatMessage> conversationHistory,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 2000),
    ); // Simulated typing delay

    final lastUserMessage = conversationHistory.last.content.toLowerCase();
    final isHindi = localeCode.toLowerCase() == 'hi';
    String responseContent = isHindi
        ? "मुझे आपका अनुरोध प्राप्त हो गया है! मुझे बताएं कि क्या आप गहराई से जांच करना चाहते हैं या अन्य लक्ष्यों का पता लगाना चाहते हैं।"
        : "I've received your request! Let know if you'd like to dive deeper or explore other goals.";

    if (lastUserMessage.contains('explain') ||
        lastUserMessage.contains('code') ||
        lastUserMessage.contains('समझाएं')) {
      responseContent = isHindi
          ? "यहाँ स्पष्टीकरण दिया गया है:\n\n"
                "```python\n"
                "import logging\n\n"
                "# त्रुटि लॉगिंग कॉन्फ़िगर करें\n"
                "logging.basicConfig(level=logging.INFO)\n\n"
                "def track_task(task_id):\n"
                "    try:\n"
                "        logging.info(f'Task {task_id} successfully started')\n"
                "        # ट्रैकिंग तर्क यहाँ जाता है...\n"
                "    except Exception as e:\n"
                "        logging.error(f'Failure: {e}')\n"
                "```\n\n"
                "यह स्क्रिप्ट लॉगिंग को प्रारंभ करती है और एक मजबूत ट्राई-एक्सेप्ट रैपर में टास्क ट्रैकिंग को समाहित करती है।"
          : "Here's the explanation:\n\n"
                "```python\n"
                "import logging\n\n"
                "# Configure error logging\n"
                "logging.basicConfig(level=logging.INFO)\n\n"
                "def track_task(task_id):\n"
                "    try:\n"
                "        logging.info(f'Task {task_id} successfully started')\n"
                "        # Tracking logic goes here...\n"
                "    except Exception as e:\n"
                "        logging.error(f'Failure: {e}')\n"
                "```\n\n"
                "This script initializes logging and encapsulates task tracking in a robust try-except wrapper.";
    } else if (lastUserMessage.contains('optimize') ||
        lastUserMessage.contains('script') ||
        lastUserMessage.contains('अनुकूलित')) {
      responseContent = isHindi
          ? "मैंने प्रदर्शन के लिए पायथन स्क्रिप्ट को अनुकूलित किया है। संचालन अब बैच में हैं और समानांतर में निष्पादित होते हैं:\n\n"
                "```python\n"
                "import asyncio\n\n"
                "async def process_batch(tasks):\n"
                "    # समानांतर में कई कार्यों को निष्पादित करना\n"
                "    results = await asyncio.gather(*[track_task(t) for t in tasks])\n"
                "    return results\n"
                "```"
          : "I have optimized the Python script for performance. The operations are now batched and execute in parallel:\n\n"
                "```python\n"
                "import asyncio\n\n"
                "async def process_batch(tasks):\n"
                "    # Executing multiple tasks asynchronously\n"
                "    results = await asyncio.gather(*[track_task(t) for t in tasks])\n"
                "    return results\n"
                "```";
    }

    final aiMessage = ChatMessage(
      id: 'msg-ai-${DateTime.now().millisecondsSinceEpoch}',
      content: responseContent,
      isUser: false,
      timestamp: DateTime.now(),
    );

    _messages.add(aiMessage);
    return aiMessage;
  }
}
