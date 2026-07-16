import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { Pool, QueryResult } from 'pg';

@Injectable()
export class DatabaseService implements OnModuleDestroy {
  private readonly pool: Pool;

  constructor() {
    const useSsl = process.env.DB_SSL === 'true';
    const connectionString = process.env.DATABASE_URL || process.env.DATABASE_URL;

    this.pool = new Pool({
      connectionString: connectionString || undefined,
      host: connectionString ? undefined : process.env.POSTGRES_HOST || 'localhost',
      port: connectionString ? undefined : Number(process.env.POSTGRES_PORT || 5433),
      user: connectionString ? undefined : process.env.POSTGRES_USER || 'aura_user',
      password: connectionString ? undefined : process.env.POSTGRES_PASSWORD || 'aura_db_ai_pass',
      database: connectionString ? undefined : process.env.POSTGRES_DB || 'aura_ai',

      // Local Docker PostgreSQL does not support SSL.
      // For local testing: DB_SSL=false
      // For cloud database: DB_SSL=true
      ssl: useSsl
        ? {
            rejectUnauthorized: false,
          }
        : false,
    });
  }
  //     this.pool = new Pool({
  //     host: '127.0.0.1',
  //     port: 5433,
  //     user: 'aura_user',
  //     password: 'aura_password',
  //     database: 'aura_ai',
  //     ssl: false,
  //   });
  // }

  async query<T = any>(text: string, params?: any[]): Promise<QueryResult<T>> {
    return this.pool.query<T>(text, params);
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}