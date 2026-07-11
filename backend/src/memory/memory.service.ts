import { Injectable, NotFoundException } from '@nestjs/common';

export interface MemoryFact {
  id: string;
  category: string;
  fact: string;
  importance: number; // 1-5 scale
  createdAt: Date;
}

@Injectable()
export class MemoryService {
  private memories: MemoryFact[] = [];

  async learn(category: string, fact: string, importance: number = 3): Promise<MemoryFact> {
    const memory: MemoryFact = {
      id: `mem_${Math.random().toString(36).substring(2, 9)}`,
      category,
      fact,
      importance,
      createdAt: new Date(),
    };
    this.memories.push(memory);
    return memory;
  }

  async findAll(): Promise<MemoryFact[]> {
    return this.memories;
  }

  async findByCategory(category: string): Promise<MemoryFact[]> {
    return this.memories.filter((m) => m.category.toLowerCase() === category.toLowerCase());
  }

  async forget(id: string): Promise<{ success: boolean; message: string }> {
    const idx = this.memories.findIndex((m) => m.id === id);
    if (idx === -1) {
      throw new NotFoundException(`Memory fact with ID ${id} not found.`);
    }
    this.memories.splice(idx, 1);
    return { success: true, message: 'Memory fact forgotten successfully.' };
  }
}
