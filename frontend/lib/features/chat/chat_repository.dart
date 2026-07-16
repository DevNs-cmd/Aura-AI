import '../../core/network/api_client.dart';
import '../../models/chat_message.dart';

class ChatRepository {
  ChatRepository(this._client);
  final ApiClient _client;

  // 1. Ye method add/check karo
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