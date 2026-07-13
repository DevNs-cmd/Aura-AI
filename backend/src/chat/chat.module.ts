import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios'; // <--- FastAPI integration ke liye naya import
import { AuthModule } from '../auth/auth.module';
import { ChatController } from './chat.controller';
import { ChatService } from './chat.service';

@Module({
  imports: [HttpModule, AuthModule],
  controllers: [ChatController],
  providers: [ChatService],
})
export class ChatModule {}
