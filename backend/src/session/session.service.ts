import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

export interface UserSession {
  id: string;
  userId: string;
  device: string;
  ipAddress: string;
  isActive: boolean;
  lastActiveAt: Date;
  loginAt: Date;
}

@Injectable()
export class SessionService {
  constructor(private readonly databaseService: DatabaseService) {}

  async createSession(userId: string, device: string, ipAddress: string): Promise<UserSession> {
    const id = `sess_${Math.random().toString(36).substring(2, 9)}`;
    const result = await this.databaseService.query(
      `
      INSERT INTO user_sessions (id, user_id, device, ip_address, is_active)
      VALUES ($1, $2, $3, $4, TRUE)
      RETURNING id, user_id as "userId", device, ip_address as "ipAddress", is_active as "isActive", last_active_at as "lastActiveAt", login_at as "loginAt"
      `,
      [id, userId, device, ipAddress],
    );
    return result.rows[0];
  }

  async findByUserId(userId: string): Promise<UserSession[]> {
    const result = await this.databaseService.query(
      `
      SELECT id, user_id as "userId", device, ip_address as "ipAddress", is_active as "isActive", last_active_at as "lastActiveAt", login_at as "loginAt"
      FROM user_sessions
      WHERE user_id = $1
      ORDER BY login_at DESC
      `,
      [userId],
    );
    return result.rows;
  }

  async findActiveSession(sessionId: string): Promise<UserSession> {
    const result = await this.databaseService.query(
      `
      SELECT id, user_id as "userId", device, ip_address as "ipAddress", is_active as "isActive", last_active_at as "lastActiveAt", login_at as "loginAt"
      FROM user_sessions
      WHERE id = $1
      LIMIT 1
      `,
      [sessionId],
    );
    if (result.rows.length === 0) {
      throw new NotFoundException(`Session with ID ${sessionId} not found.`);
    }
    return result.rows[0];
  }

  async updateActivity(sessionId: string): Promise<void> {
    const result = await this.databaseService.query(
      `
      UPDATE user_sessions
      SET last_active_at = CURRENT_TIMESTAMP
      WHERE id = $1
      `,
      [sessionId],
    );
    if (result.rowCount === 0) {
      throw new NotFoundException(`Session with ID ${sessionId} not found.`);
    }
  }

  async revoke(sessionId: string): Promise<{ success: boolean; message: string }> {
    const result = await this.databaseService.query(
      `
      UPDATE user_sessions
      SET is_active = FALSE
      WHERE id = $1
      `,
      [sessionId],
    );
    if (result.rowCount === 0) {
      throw new NotFoundException(`Session with ID ${sessionId} not found.`);
    }
    return { success: true, message: `Session ${sessionId} has been successfully revoked.` };
  }

  async revokeAllExcept(userId: string, activeSessionId: string): Promise<{ revokedCount: number }> {
    const result = await this.databaseService.query(
      `
      UPDATE user_sessions
      SET is_active = FALSE
      WHERE user_id = $1 AND id != $2 AND is_active = TRUE
      `,
      [userId, activeSessionId],
    );
    return { revokedCount: result.rowCount || 0 };
  }
}
