import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthModule } from './modules/auth/auth.module';
import { ChatModule } from './modules/chat/chat.module';
import { DocumentModule } from './modules/document/document.module';
import { NotificationModule } from './modules/notification/notification.module';
import { MemoryModule } from './modules/memory/memory.module';
import { UserModule } from './modules/user/user.module';
import { SessionModule } from './modules/session/session.module';

@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'aura-secret-key',
      signOptions: { expiresIn: '1h' },
    }),
    AuthModule,
    ChatModule,
    DocumentModule,
    NotificationModule,
    MemoryModule,
    UserModule,
    SessionModule,
  ],
})
export class AppModule {}
