import { Controller, Post, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { NotificationService } from './notification.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('notifications')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @UseGuards(AuthGuard)
  @Post('send')
  @HttpCode(HttpStatus.OK)
  async sendNotification(@Body() payload: { fcmToken: string; title: string; body: string }) {
    const messageId = await this.notificationService.sendPushNotification(payload.fcmToken, payload.title, payload.body);
    return { success: true, messageId, message: 'Notification dispatched.' };
  }
}
