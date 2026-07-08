import { ChatService, ChatMessage } from './chat.service';
export declare class ChatController {
    private readonly chatService;
    constructor(chatService: ChatService);
    postMessage(payload: {
        userId: string;
        message: string;
    }): Promise<{
        success: boolean;
        history: ChatMessage[];
    }>;
    getChatHistory(userId: string): Promise<{
        success: boolean;
        history: ChatMessage[];
    }>;
}
