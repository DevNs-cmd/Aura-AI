import { Controller, Post, Body, Req, UseGuards } from '@nestjs/common';
import { ChatService } from './chat.service';

export class CreateMessageDto {
  message!: string;
}

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post()
  async sendMessage(@Body() createMessageDto: CreateMessageDto) {
    const { message } = createMessageDto;
    return this.chatService.generateResponse(message);
  }
}
