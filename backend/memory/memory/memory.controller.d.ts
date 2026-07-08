import { MemoryService, MemoryFact } from './memory.service';
export declare class MemoryController {
    private readonly memoryService;
    constructor(memoryService: MemoryService);
    rememberFact(payload: {
        userId: string;
        fact: string;
        category?: 'preference' | 'schedule' | 'relationship' | 'general';
        importance?: number;
    }): Promise<{
        success: boolean;
        memory: MemoryFact;
    }>;
    getMemories(userId: string): Promise<{
        success: boolean;
        memories: MemoryFact[];
    }>;
}
