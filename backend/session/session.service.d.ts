import { RedisService } from '@liaoliaots/nestjs-redis';
export declare class SessionService {
    private readonly redisService;
    private redisClient;
    constructor(redisService: RedisService);
    createSession(userId: string, token: string): Promise<void>;
    validateSession(token: string): Promise<string | null>;
    destroySession(token: string): Promise<void>;
}
