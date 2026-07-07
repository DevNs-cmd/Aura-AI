import 'dart:async';
import '../../models/chat_message.dart';

abstract class ChatRepository {
  List<ChatMessage> getInitialMessages();
  Future<ChatMessage> sendUserMessage(String content, {String? imageUrl});
  Future<ChatMessage> getAIResponse(List<ChatMessage> conversationHistory);
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
