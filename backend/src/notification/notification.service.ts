import { Injectable, NotFoundException } from '@nestjs/common';

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
  private notifications: AppNotification[] = [
    {
      id: 'notif_init',
      title: 'Welcome to Aura-AI',
      message: 'Your high-performance modular backend is active and running!',
      read: false,
      type: 'success',
      createdAt: new Date(),
    },
  ];

  async trigger(title: string, message: string, type: 'info' | 'warning' | 'success' = 'info'): Promise<AppNotification> {
    const notification: AppNotification = {
      id: `notif_${Math.random().toString(36).substring(2, 9)}`,
      title,
      message,
      read: false,
      type,
      createdAt: new Date(),
    };
    this.notifications.unshift(notification);
    return notification;
  }

  async findAll(): Promise<AppNotification[]> {
    return this.notifications;
  }

  async markAsRead(id: string): Promise<AppNotification> {
    const notif = this.notifications.find((n) => n.id === id);
    if (!notif) {
      throw new NotFoundException(`Notification with ID ${id} not found.`);
    }
    notif.read = true;
    return notif;
  }

  async markAllAsRead(): Promise<{ success: boolean; count: number }> {
    let count = 0;
    this.notifications.forEach((n) => {
      if (!n.read) {
        n.read = true;
        count++;
      }
    });
    return { success: true, count };
  }

  async delete(id: string): Promise<{ success: boolean }> {
    const index = this.notifications.findIndex((notification) => notification.id === id);
    if (index === -1) {
      throw new NotFoundException(`Notification with ID ${id} not found.`);
    }
    this.notifications.splice(index, 1);
    return { success: true };
  }

  async clearAll(): Promise<{ success: boolean }> {
    this.notifications = [];
    return { success: true };
  }
}
