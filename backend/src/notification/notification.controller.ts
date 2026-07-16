import { Controller, Post, Get, Patch, Delete, Body, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { NotificationService } from './notification.service';

export class TriggerNotificationDto {
  title!: string;
  message!: string;
  type?: 'info' | 'warning' | 'success';
}

@Controller('notifications')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async triggerNotification(@Body() dto: TriggerNotificationDto) {
    return this.notificationService.trigger(dto.title, dto.message, dto.type);
  }

  @Get()
  async getNotifications() {
    return this.notificationService.findAll();
  }

  @Patch(':id/read')
  async markRead(@Param('id') id: string) {
    return this.notificationService.markAsRead(id);
  }

  @Patch('read-all')
  async markAllRead() {
    return this.notificationService.markAllAsRead();
  }

  @Delete(':id')
  async delete(@Param('id') id: string) {
    return this.notificationService.delete(id);
  }

  @Delete()
  async clearAll() {
    return this.notificationService.clearAll();
  }
}
