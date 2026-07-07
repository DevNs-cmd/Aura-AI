import { Injectable, BadRequestException } from '@nestjs/common';

export interface ChatMessage {
  id: string;
  sender: 'user' | 'aura';
  text: string;
  timestamp: Date;
}

@Injectable()
export class ChatService {
  private chatHistories: Record<string, ChatMessage[]> = {
    'e44d7fc5-0720-4df2-817c-61e86052f50f': [
      { id: 'msg-1', sender: 'user', text: 'Hello Aura! Tell me about my schedule.', timestamp: new Date(Date.now() - 3600000) },
      { id: 'msg-2', sender: 'aura', text: 'Hi Sarah! You have a sync with DeepMind at 2 PM and a workspace optimization review at 4 PM.', timestamp: new Date(Date.now() - 3590000) }
    ]
  };

  async handleMessage(userId: string, text: string): Promise<ChatMessage[]> {
    if (!userId || !text) {
      throw new BadRequestException('userId and message text are required');
    }

    if (!this.chatHistories[userId]) {
      this.chatHistories[userId] = [];
    }

    const userMsg: ChatMessage = {
      id: `msg-${Date.now()}-u`,
      sender: 'user',
      text,
      timestamp: new Date(),
    };
    this.chatHistories[userId].push(userMsg);

    const auraReplies = [
      `I've noted that! Let me cross-reference this with your memory database.`,
      `Interesting point. I am analyzing your workspace configurations for any latency bottlenecks.`,
      `Got it. I will keep this context in mind for our future workflow recommendations.`,
      `Understood. I have updated my transient memory variables. Do you want me to write this permanently?`
    ];
    const randomReply = auraReplies[Math.floor(Math.random() * auraReplies.length)];

    const auraMsg: ChatMessage = {
      id: `msg-${Date.now()}-a`,
      sender: 'aura',
      text: randomReply,
      timestamp: new Date(),
    };

    await new Promise(resolve => setTimeout(resolve, 500));
    this.chatHistories[userId].push(auraMsg);

    return this.chatHistories[userId];
  }

  async getHistory(userId: string): Promise<ChatMessage[]> {
    if (!userId) {
      throw new BadRequestException('userId is required');
    }
    return this.chatHistories[userId] || [];
  }
}
