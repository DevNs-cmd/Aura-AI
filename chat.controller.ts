import { Controller, Post, Get, Body, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { ChatService, ChatMessage } from './chat.service';

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  /**
   * Accepts a user message and returns the updated chat history with the AI response.
   */
  @Post('message')
  @HttpCode(HttpStatus.OK)
  async postMessage(
    @Body() payload: { userId: string; message: string }
  ): Promise<{ success: boolean; history: ChatMessage[] }> {
    const { userId, message } = payload;
    const updatedHistory = await this.chatService.handleMessage(userId, message);
    return {
      success: true,
      history: updatedHistory,
    };
  }

  /**
   * Fetches the complete chat history for a specific user ID.
   */
  @Get('history/:userId')
  async getChatHistory(@Param('userId') userId: string): Promise<{ success: boolean; history: ChatMessage[] }> {
    const history = await this.chatService.getHistory(userId);
    return {
      success: true,
      history,
    };
  }
}
