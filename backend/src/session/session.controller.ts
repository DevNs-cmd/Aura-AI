import { Controller, Post, Get, Delete, Body, Param, Patch, HttpCode, HttpStatus } from '@nestjs/common';
import { SessionService } from './session.service';

export class CreateSessionDto {
  userId!: string;
  device!: string;
  ipAddress!: string;
}

@Controller('sessions')
export class SessionController {
  constructor(private readonly sessionService: SessionService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createSession(@Body() dto: CreateSessionDto) {
    return this.sessionService.createSession(dto.userId, dto.device, dto.ipAddress);
  }

  @Get('user/:userId')
  async getSessionsByUser(@Param('userId') userId: string) {
    return this.sessionService.findByUserId(userId);
  }

  @Patch(':id/ping')
  async pingSession(@Param('id') id: string) {
    await this.sessionService.updateActivity(id);
    return { success: true, message: 'Session keepalive timestamp updated.' };
  }

  @Delete(':id')
  async revokeSession(@Param('id') id: string) {
    return this.sessionService.revoke(id);
  }
}
