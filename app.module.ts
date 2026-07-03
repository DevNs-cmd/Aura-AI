import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RedisModule } from '@liaoliaots/nestjs-redis';
import { UserModule } from './user/user.module';
import { SessionModule } from './session/session.module';
import { NotificationModule } from './notification/notification.module';
import { User } from './user/user.entity';

@Module({
  imports: [
    // Global Database Connections
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT, 10) || 5432,
      username: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'root',
      database: process.env.DB_NAME || 'aura_db',
      entities: [User],
      synchronize: true, // Auto sync structural updates in dev mode
    }),
    RedisModule.forRoot({
      config: {
        host: process.env.REDIS_HOST || 'localhost',
        port: parseInt(process.env.REDIS_PORT, 10) || 6379,
      },
    }),
    // Microservices
    UserModule,
    SessionModule,
    NotificationModule,
  ],
})
export class AppModule {}
