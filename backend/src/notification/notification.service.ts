import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

export interface AppNotification {
  id: string;
  title: string;
  message: string;
  read: boolean;
  type: 'info' | 'warning' | 'success';
  createdAt: Date;
}

@Injectable()
export class NotificationService {
  constructor(private readonly databaseService: DatabaseService) {}

  async trigger(title: string, message: string, type: 'info' | 'warning' | 'success' = 'info'): Promise<AppNotification> {
    const id = `notif_${Math.random().toString(36).substring(2, 9)}`;
    const result = await this.databaseService.query(
      `
      INSERT INTO notifications (id, title, message, read, type)
      VALUES ($1, $2, $3, FALSE, $4)
      RETURNING id, title, message, read, type, created_at as "createdAt"
      `,
      [id, title, message, type],
    );
    return result.rows[0];
  }

  async findAll(): Promise<AppNotification[]> {
    const result = await this.databaseService.query(
      `
      SELECT id, title, message, read, type, created_at as "createdAt"
      FROM notifications
      ORDER BY created_at DESC
      `,
    );
    return result.rows;
  }

  async markAsRead(id: string): Promise<AppNotification> {
    const result = await this.databaseService.query(
      `
      UPDATE notifications
      SET read = TRUE
      WHERE id = $1
      RETURNING id, title, message, read, type, created_at as "createdAt"
      `,
      [id],
    );
    if (result.rows.length === 0) {
      throw new NotFoundException(`Notification with ID ${id} not found.`);
    }
    return result.rows[0];
  }

  async markAllAsRead(): Promise<{ success: boolean; count: number }> {
    const result = await this.databaseService.query(
      `
      UPDATE notifications
      SET read = TRUE
      WHERE read = FALSE
      `,
    );
    return { success: true, count: result.rowCount || 0 };
  }

  async delete(id: string): Promise<{ success: boolean }> {
    const result = await this.databaseService.query(
      `
      DELETE FROM notifications
      WHERE id = $1
      `,
      [id],
    );
    if (result.rowCount === 0) {
      throw new NotFoundException(`Notification with ID ${id} not found.`);
    }
    return { success: true };
  }

  async clearAll(): Promise<{ success: boolean }> {
    await this.databaseService.query(
      `
      DELETE FROM notifications
      `,
    );
    return { success: true };
  }
}
