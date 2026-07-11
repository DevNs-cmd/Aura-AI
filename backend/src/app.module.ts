import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { ChatModule } from './chat/chat.module';
import { DocumentModule } from './document/document.module';
import { MemoryModule } from './memory/memory.module';
import { NotificationModule } from './notification/notification.module';
import { SessionModule } from './session/session.module';

@Module({
  imports: [
    AuthModule,
    UserModule,
    ChatModule,
    DocumentModule,
    MemoryModule,
    NotificationModule,
    SessionModule,
  ],
})
export class AppModule {}
