"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MemoryService = void 0;
const common_1 = require("@nestjs/common");
let MemoryService = class MemoryService {
    constructor() {
        this.userMemories = {
            'e44d7fc5-0720-4df2-817c-61e86052f50f': [
                { id: 'mem-1', fact: 'Sarah prefers dark theme and uses Aura-V1 voice model.', category: 'preference', importance: 4, createdAt: new Date(Date.now() - 86400000) },
                { id: 'mem-2', fact: 'Has an upcoming workspace review with DeepMind scheduled.', category: 'schedule', importance: 5, createdAt: new Date(Date.now() - 43200000) }
            ]
        };
    }
    async rememberFact(userId, fact, category, importance) {
        if (!userId || !fact) {
            throw new common_1.BadRequestException('userId and fact text are required');
        }
        if (!this.userMemories[userId]) {
            this.userMemories[userId] = [];
        }
        const newFact = {
            id: `mem-${Date.now()}`,
            fact,
            category: category || 'general',
            importance: importance || 3,
            createdAt: new Date()
        };
        this.userMemories[userId].push(newFact);
        return newFact;
    }
    async getMemories(userId) {
        if (!userId) {
            throw new common_1.BadRequestException('userId is required');
        }
        return this.userMemories[userId] || [];
    }
};
exports.MemoryService = MemoryService;
exports.MemoryService = MemoryService = __decorate([
    (0, common_1.Injectable)()
], MemoryService);
//# sourceMappingURL=memory.servies.js.map