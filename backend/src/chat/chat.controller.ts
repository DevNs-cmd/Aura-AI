import { Controller, Post, Body, UseGuards, Req, Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ChatService } from './chat.service';

// 🛠️ Guard ko humne yahin par local define kar diya taaki path ka koi error na aaye!
@Injectable()
class LocalJwtAuthGuard extends AuthGuard('jwt') {}

@Controller('api/chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @UseGuards(LocalJwtAuthGuard) // <--- Local guard se route lock ho gaya
  @Post()
  async handleChat(@Req() req: any, @Body('message') message: string) {
    // Token se automatic userId mil jayegi
    const userId = req.user?.id || req.user?.sub; 
    
    // Hamari integrated service ko forward kar diya
    return this.chatService.processAIMessage(userId, message);
  }
}