"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const nestjs_redis_1 = require("@liaoliaots/nestjs-redis");
const user_module_1 = require("./user/user.module");
const session_module_1 = require("./session/session.module");
const notification_module_1 = require("./notification/notification.module");
const chat_module_1 = require("./chat/chat.module");
const memory_module_1 = require("./memory/memory.module");
const document_module_1 = require("./document/document.module");
const user_entity_1 = require("./user/user.entity");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            typeorm_1.TypeOrmModule.forRoot({
                type: 'postgres',
                host: process.env.DB_HOST || 'localhost',
                port: parseInt(process.env.DB_PORT, 10) || 5432,
                username: process.env.DB_USER || 'postgres',
                password: process.env.DB_PASSWORD || 'root',
                database: process.env.DB_NAME || 'aura_db',
                entities: [user_entity_1.User],
                synchronize: true,
            }),
            nestjs_redis_1.RedisModule.forRoot({
                config: {
                    host: process.env.REDIS_HOST || 'localhost',
                    port: parseInt(process.env.REDIS_PORT, 10) || 6379,
                },
            }),
            user_module_1.UserModule,
            session_module_1.SessionModule,
            notification_module_1.NotificationModule,
            chat_module_1.ChatModule,
            memory_module_1.MemoryModule,
            document_module_1.DocumentModule,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map