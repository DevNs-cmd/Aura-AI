import { Controller, Post, Body, UseGuards, Req } from '@nestjs/common';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard'; // Guard import kiya

@Controller('api/chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @UseGuards(JwtAuthGuard) // <--- Yeh line is route ko lock kar degi
  @Post()
  async handleChat(@Req() req: any, @Body('message') message: string) {
    // Ab token se automatic userId mil jayegi, Flutter ko body mein bhejney ki zaroorat nahi!
    const userId = req.user.id; 
    
    // Hamari integrated service ko userId aur message forward kar diya
    return this.chatService.processAIMessage(userId, message);
  }
}