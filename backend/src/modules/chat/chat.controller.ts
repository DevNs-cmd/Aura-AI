import { Controller, Post, Body, Get, Param } from '@nestjs/common';
import { ChatService, ChatMessage } from './chat.service';

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post('message')
  async postMessage(
    @Body()
    payload: {
      userId: string;
      message: string;
    },
  ): Promise<{ success: boolean; history: ChatMessage[] }> {
    const history = await this.chatService.handleMessage(payload.userId, payload.message);
    return { success: true, history };
  }

  @Get('history/:userId')
  async getChatHistory(
    @Param('userId') userId: string,
  ): Promise<{ success: boolean; history: ChatMessage[] }> {
    const history = await this.chatService.getHistory(userId);
    return { success: true, history };
  }
}
