export interface MemoryFact {
    id: string;
    fact: string;
    category: 'preference' | 'schedule' | 'relationship' | 'general';
    importance: number;
    createdAt: Date;
}
export declare class MemoryService {
    private userMemories;
    rememberFact(userId: string, fact: string, category?: 'preference' | 'schedule' | 'relationship' | 'general', importance?: number): Promise<MemoryFact>;
    getMemories(userId: string): Promise<MemoryFact[]>;
}
