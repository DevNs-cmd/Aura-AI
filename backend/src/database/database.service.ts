import { Injectable, OnModuleDestroy, OnModuleInit, Logger } from '@nestjs/common';
import { Pool, QueryResult } from 'pg';

@Injectable()
export class DatabaseService implements OnModuleDestroy, OnModuleInit {
  private readonly pool: Pool;
  private readonly logger = new Logger(DatabaseService.name);

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

  async onModuleInit() {
    try {
      this.logger.log('Initializing database schema...');
      
      // Create user_sessions table
      await this.query(`
        CREATE TABLE IF NOT EXISTS user_sessions (
          id VARCHAR(255) PRIMARY KEY,
          user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          device VARCHAR(255) NOT NULL,
          ip_address VARCHAR(255) NOT NULL,
          is_active BOOLEAN DEFAULT TRUE NOT NULL,
          last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);

      // Create notifications table
      await this.query(`
        CREATE TABLE IF NOT EXISTS notifications (
          id VARCHAR(255) PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          message TEXT NOT NULL,
          read BOOLEAN DEFAULT FALSE NOT NULL,
          type VARCHAR(50) DEFAULT 'info' NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);

      // Seed the welcome notification
      await this.query(`
        INSERT INTO notifications (id, title, message, read, type)
        VALUES (
          'notif_init', 
          'Welcome to Aura-AI', 
          'Your high-performance modular backend is active and running!', 
          FALSE, 
          'success'
        )
        ON CONFLICT (id) DO NOTHING;
      `);

      this.logger.log('Database schema initialized successfully.');
    } catch (error) {
      this.logger.error('Failed to initialize database schema:', error);
    }
  }

  async query<T = any>(text: string, params?: any[]): Promise<QueryResult<T>> {
    return this.pool.query<T>(text, params);
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}