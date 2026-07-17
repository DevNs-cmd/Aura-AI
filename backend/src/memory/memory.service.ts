import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

export interface MemoryFact {
  id: string;
  category: string;
  fact: string;
  importance: number; // 1-5 scale
  createdAt: Date;
}

@Injectable()
export class MemoryService {
  constructor(private readonly databaseService: DatabaseService) {}

  async learn(userId: string, category: string, fact: string, importance: number = 3): Promise<MemoryFact> {
    const result = await this.databaseService.query(
      `
      INSERT INTO memories (user_id, key, value, source)
      VALUES ($1, $2, $3, 'manual')
      RETURNING id, key as category, value as fact, created_at as "createdAt"
      `,
      [userId, category, fact],
    );
    const row = result.rows[0];
    return {
      id: row.id,
      category: row.category,
      fact: row.fact,
      importance,
      createdAt: row.createdAt,
    };
  }

  async findAll(userId: string): Promise<MemoryFact[]> {
    const result = await this.databaseService.query(
      `
      SELECT id, key as category, value as fact, created_at as "createdAt"
      FROM memories
      WHERE user_id = $1
      ORDER BY created_at DESC
      `,
      [userId],
    );
    return result.rows.map((row) => ({
      id: row.id,
      category: row.category,
      fact: row.fact,
      importance: 3,
      createdAt: row.createdAt,
    }));
  }

  async findByCategory(userId: string, category: string): Promise<MemoryFact[]> {
    const result = await this.databaseService.query(
      `
      SELECT id, key as category, value as fact, created_at as "createdAt"
      FROM memories
      WHERE user_id = $1 AND LOWER(key) = LOWER($2)
      ORDER BY created_at DESC
      `,
      [userId, category],
    );
    return result.rows.map((row) => ({
      id: row.id,
      category: row.category,
      fact: row.fact,
      importance: 3,
      createdAt: row.createdAt,
    }));
  }

  async forget(userId: string, id: string): Promise<{ success: boolean; message: string }> {
    const result = await this.databaseService.query(
      `
      DELETE FROM memories
      WHERE user_id = $1 AND id = $2
      `,
      [userId, id],
    );
    if (result.rowCount === 0) {
      throw new NotFoundException(`Memory fact with ID ${id} not found.`);
    }
    return { success: true, message: 'Memory fact forgotten successfully.' };
  }
}
