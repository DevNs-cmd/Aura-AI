"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DocumentService = void 0;
const common_1 = require("@nestjs/common");
let DocumentService = class DocumentService {
    constructor() {
        this.userDocuments = {
            'e44d7fc5-0720-4df2-817c-61e86052f50f': [
                {
                    id: 'doc-1',
                    name: 'deepmind_workspace_summary.pdf',
                    type: 'pdf',
                    size: '1.4 MB',
                    wordCount: 2450,
                    extractedKeypoints: [
                        'Agile sprint alignment scheduled for Q3',
                        'Primary compute resources localized in central-1 region',
                        'Token safety boundaries require server-side proxy headers'
                    ],
                    uploadedAt: new Date(Date.now() - 172800000)
                }
            ]
        };
    }
    async processDocument(userId, name, type, size) {
        if (!userId || !name || !type) {
            throw new common_1.BadRequestException('userId, document name, and document type are required');
        }
        if (!this.userDocuments[userId]) {
            this.userDocuments[userId] = [];
        }
        const mockKeypoints = [
            `Context file "${name}" was successfully vectorized.`,
            `Extracted entity tags matching mobile performance clusters.`,
            `Verified security boundaries of standard file configurations.`
        ];
        const newDoc = {
            id: `doc-${Date.now()}`,
            name,
            type: type.toLowerCase(),
            size: size || '120 KB',
            wordCount: Math.floor(Math.random() * 3000) + 200,
            extractedKeypoints: mockKeypoints,
            uploadedAt: new Date()
        };
        this.userDocuments[userId].push(newDoc);
        return newDoc;
    }
    async getDocumentsByUserId(userId) {
        if (!userId) {
            throw new common_1.BadRequestException('userId is required');
        }
        return this.userDocuments[userId] || [];
    }
};
exports.DocumentService = DocumentService;
exports.DocumentService = DocumentService = __decorate([
    (0, common_1.Injectable)()
], DocumentService);
//# sourceMappingURL=document.service.js.map