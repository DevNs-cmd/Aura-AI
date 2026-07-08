"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SessionService = void 0;
const common_1 = require("@nestjs/common");
const nestjs_redis_1 = require("@liaoliaots/nestjs-redis");
let SessionService = class SessionService {
    constructor(redisService) {
        this.redisService = redisService;
        try {
            this.redisClient = this.redisService.getOrThrow();
        }
        catch (error) {
            throw new common_1.InternalServerErrorException('Failed to initialize Redis client in SessionService');
        }
    }
    async createSession(userId, token) {
        const sessionKey = `session:${token}`;
        const ttlSeconds = 7 * 24 * 60 * 60;
        await this.redisClient.set(sessionKey, userId, 'EX', ttlSeconds);
    }
    async validateSession(token) {
        const sessionKey = `session:${token}`;
        const userId = await this.redisClient.get(sessionKey);
        return userId || null;
    }
    async destroySession(token) {
        const sessionKey = `session:${token}`;
        await this.redisClient.del(sessionKey);
    }
};
exports.SessionService = SessionService;
exports.SessionService = SessionService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [nestjs_redis_1.RedisService])
], SessionService);
//# sourceMappingURL=session.service.js.map