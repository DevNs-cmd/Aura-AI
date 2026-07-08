"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChatService = void 0;
const common_1 = require("@nestjs/common");
let ChatService = class ChatService {
    constructor() {
        this.chatHistories = {
            'e44d7fc5-0720-4df2-817c-61e86052f50f': [
                { id: 'msg-1', sender: 'user', text: 'Hello Aura! Tell me about my schedule.', timestamp: new Date(Date.now() - 3600000) },
                { id: 'msg-2', sender: 'aura', text: 'Hi Sarah! You have a sync with DeepMind at 2 PM and a workspace optimization review at 4 PM.', timestamp: new Date(Date.now() - 3590000) }
            ]
        };
    }
    async handleMessage(userId, text) {
        if (!userId || !text) {
            throw new common_1.BadRequestException('userId and message text are required');
        }
        if (!this.chatHistories[userId]) {
            this.chatHistories[userId] = [];
        }
        const userMsg = {
            id: `msg-${Date.now()}-u`,
            sender: 'user',
            text,
            timestamp: new Date(),
        };
        this.chatHistories[userId].push(userMsg);
        const auraReplies = [
            `I've noted that! Let me cross-reference this with your memory database.`,
            `Interesting point. I am analyzing your workspace configurations for any latency bottlenecks.`,
            `Got it. I will keep this context in mind for our future workflow recommendations.`,
            `Understood. I have updated my transient memory variables. Do you want me to write this permanently?`
        ];
        const randomReply = auraReplies[Math.floor(Math.random() * auraReplies.length)];
        const auraMsg = {
            id: `msg-${Date.now()}-a`,
            sender: 'aura',
            text: randomReply,
            timestamp: new Date(),
        };
        await new Promise(resolve => setTimeout(resolve, 500));
        this.chatHistories[userId].push(auraMsg);
        return this.chatHistories[userId];
    }
    async getHistory(userId) {
        if (!userId) {
            throw new common_1.BadRequestException('userId is required');
        }
        return this.chatHistories[userId] || [];
    }
};
exports.ChatService = ChatService;
exports.ChatService = ChatService = __decorate([
    (0, common_1.Injectable)()
], ChatService);
//# sourceMappingURL=chat.service.js.map