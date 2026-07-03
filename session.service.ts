import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { RedisService } from '@liaoliaots/nestjs-redis';
import { Redis } from 'ioredis';

@Injectable()
export class SessionService {
  private redisClient: Redis;

  constructor(private readonly redisService: RedisService) {
    try {
      this.redisClient = this.redisService.getOrThrow();
    } catch (error) {
      throw new InternalServerErrorException('Failed to initialize Redis client in SessionService');
    }
  }

  async createSession(userId: string, token: string): Promise<void> {
    const sessionKey = `session:${token}`;
    const ttlSeconds = 7 * 24 * 60 * 60; // 7 days
    await this.redisClient.set(sessionKey, userId, 'EX', ttlSeconds);
  }

  async validateSession(token: string): Promise<string | null> {
    const sessionKey = `session:${token}`;
    const userId = await this.redisClient.get(sessionKey);
    return userId || null;
  }

  async destroySession(token: string): Promise<void> {
    const sessionKey = `session:${token}`;
    await this.redisClient.del(sessionKey);
  }
}
