import { Injectable, BadRequestException } from '@nestjs/common';

export interface MemoryFact {
  id: string;
  fact: string;
  category: 'preference' | 'schedule' | 'relationship' | 'general';
  importance: number;
  createdAt: Date;
}

@Injectable()
export class MemoryService {
  private userMemories: Record<string, MemoryFact[]> = {
    'e44d7fc5-0720-4df2-817c-61e86052f50f': [
      { id: 'mem-1', fact: 'Sarah prefers dark theme and uses Aura-V1 voice model.', category: 'preference', importance: 4, createdAt: new Date(Date.now() - 86400000) },
      { id: 'mem-2', fact: 'Has an upcoming workspace review with DeepMind scheduled.', category: 'schedule', importance: 5, createdAt: new Date(Date.now() - 43200000) }
    ]
  };

  async rememberFact(userId: string, fact: string, category?: 'preference' | 'schedule' | 'relationship' | 'general', importance?: number): Promise<MemoryFact> {
    if (!userId || !fact) {
      throw new BadRequestException('userId and fact text are required');
    }

    if (!this.userMemories[userId]) {
      this.userMemories[userId] = [];
    }

    const newFact: MemoryFact = {
      id: `mem-${Date.now()}`,
      fact,
      category: category || 'general',
      importance: importance || 3,
      createdAt: new Date(),
    };

    this.userMemories[userId].push(newFact);
    return newFact;
  }

  async getMemories(userId: string): Promise<MemoryFact[]> {
    if (!userId) {
      throw new BadRequestException('userId is required');
    }
    return this.userMemories[userId] || [];
  }
}
