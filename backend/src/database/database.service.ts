import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { Pool, QueryResult } from 'pg';

@Injectable()
export class DatabaseService implements OnModuleDestroy {
  private readonly pool: Pool;

  constructor() {
    this.pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      host: process.env.POSTGRES_HOST || 'localhost',
      port: Number(process.env.POSTGRES_PORT || 5432),
      user: process.env.POSTGRES_USER || 'aura_user',
      password: process.env.POSTGRES_PASSWORD || 'aura_password',
      database: process.env.POSTGRES_DB || 'aura_ai',
      // Cloud database connection ke liye SSL hamesha true rakha hai takki team ka error na aaye
      ssl: {
        rejectUnauthorized: false,
      },
    });
  }

  async query<T = any>(text: string, params?: any[]): Promise<QueryResult<T>> {
    return this.pool.query<T>(text, params);
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}