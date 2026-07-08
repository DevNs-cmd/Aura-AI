export interface ChatMessage {
    id: string;
    sender: 'user' | 'aura';
    text: string;
    timestamp: Date;
}
export declare class ChatService {
    private chatHistories;
    handleMessage(userId: string, text: string): Promise<ChatMessage[]>;
    getHistory(userId: string): Promise<ChatMessage[]>;
}
