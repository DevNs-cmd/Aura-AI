import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

export interface User {
  id: string;
  name: string;
  email: string;
  passwordHash: string;
  avatarUrl?: string | null;
  resetToken?: string | null;
  resetTokenExpiry?: Date | null;
  createdAt: Date;
}

@Injectable()
export class UserService {
  constructor(private readonly databaseService: DatabaseService) {}

  private mapUser(row: any): User {
    return {
      id: row.id,
      name: row.name,
      email: row.email,
      passwordHash: row.password_hash,
      avatarUrl: row.avatar_url,
      resetToken: row.reset_token,
      resetTokenExpiry: row.reset_token_expiry,
      createdAt: row.created_at,
    };
  }

  async findByEmail(email: string): Promise<User | undefined> {
    const result = await this.databaseService.query(
      `
      SELECT id, name, email, password_hash, avatar_url, reset_token, reset_token_expiry, created_at
      FROM users
      WHERE LOWER(email) = LOWER($1)
      LIMIT 1
      `,
      [email],
    );
    if (result.rows.length === 0) {
      return undefined;
    }
    return this.mapUser(result.rows[0]);
  }

  async findById(id: string): Promise<User | undefined> {
    const result = await this.databaseService.query(
      `
      SELECT id, name, email, password_hash, avatar_url, reset_token, reset_token_expiry, created_at
      FROM users
      WHERE id = $1
      LIMIT 1
      `,
      [id],
    );
    if (result.rows.length === 0) {
      return undefined;
    }
    return this.mapUser(result.rows[0]);
  }

  async create(name: string, email: string, passwordHash: string): Promise<User> {
    const result = await this.databaseService.query(
      `
      INSERT INTO users (name, email, password_hash)
      VALUES ($1, LOWER($2), $3)
      RETURNING id, name, email, password_hash, avatar_url, reset_token, reset_token_expiry, created_at
      `,
      [name, email, passwordHash],
    );
    return this.mapUser(result.rows[0]);
  }

  async updateResetToken(
    email: string,
    token: string,
    expiry: Date,
  ): Promise<void> {
    const result = await this.databaseService.query(
      `
      UPDATE users
      SET reset_token = $1,
          reset_token_expiry = $2,
          updated_at = CURRENT_TIMESTAMP
      WHERE LOWER(email) = LOWER($3)
      `,
      [token, expiry, email],
    );
    if (result.rowCount === 0) {
      throw new NotFoundException('User not found.');
    }
  }

  async updatePassword(email: string, newPasswordHash: string): Promise<void> {
    const result = await this.databaseService.query(
      `
      UPDATE users
      SET password_hash = $1,
          reset_token = NULL,
          reset_token_expiry = NULL,
          updated_at = CURRENT_TIMESTAMP
      WHERE LOWER(email) = LOWER($2)
      `,
      [newPasswordHash, email],
    );
    if (result.rowCount === 0) {
      throw new NotFoundException('User not found.');
    }
  }

  async findAll() {
    const result = await this.databaseService.query(
      `
      SELECT id, name, email, avatar_url, created_at
      FROM users
      ORDER BY create_at DESC
      `,
    );
    return result.rows.map((row) => ({
      id: row.id,
      name: row.name,
      email: row.email,
      avatarUrl: row.avatar_url,
      createdAt: row.created_at,
    }));
  }
}