import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

export interface ChatMessage {
  id?: string;
  sender: 'user' | 'aura';
  text: string;
  timestamp?: Date;
}

export interface ChatRequest {
  userId: string;
  message: string;
  sessionId?: string;
  history?: ChatMessage[];
}

export interface ChatResponse {
  reply: string;
  conversationId?: string;
  history?: ChatMessage[];
}

@Injectable()
export class ChatService {
  private readonly fastApiBaseUrl = process.env.FASTAPI_URL || 'http://localhost:8000';

  async handleMessage(userId: string, text: string): Promise<ChatMessage[]> {
    if (!userId || !text) {
      throw new HttpException('userId and message text are required', HttpStatus.BAD_REQUEST);
    }

    try {
      const response = await fetch(`${this.fastApiBaseUrl}/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId, message: text } as ChatRequest),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'FastAPI chat request failed', response.status || HttpStatus.BAD_GATEWAY);
      }

      const data = (await response.json()) as ChatResponse;
      return data.history || [];
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException('Unable to connect to the FastAPI chat service', HttpStatus.BAD_GATEWAY);
    }
  }

  async getHistory(userId: string): Promise<ChatMessage[]> {
    if (!userId) {
      throw new HttpException('userId is required', HttpStatus.BAD_REQUEST);
    }

    try {
      const response = await fetch(`${this.fastApiBaseUrl}/chat/history/${userId}`);

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Unable to fetch chat history', response.status || HttpStatus.BAD_GATEWAY);
      }

      const data = (await response.json()) as { history?: ChatMessage[] };
      return data.history || [];
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException('Unable to fetch chat history from FastAPI', HttpStatus.BAD_GATEWAY);
    }
  }
}
