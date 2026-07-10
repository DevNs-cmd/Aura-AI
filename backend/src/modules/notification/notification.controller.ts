import { Controller, Post, Body } from '@nestjs/common';
import { NotificationService, NotificationPayload } from './notification.service';

@Controller('notification')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post('insight')
  async sendNotification(
    @Body() payload: NotificationPayload,
  ): Promise<{ success: boolean; messageId: string; message: string }> {
    const result = await this.notificationService.sendInsight(payload);
    return { success: true, messageId: result.messageId ?? '', message: result.message ?? 'Sent' };
  }
}
