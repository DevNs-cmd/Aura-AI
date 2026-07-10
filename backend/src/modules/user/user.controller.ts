import { Controller, Post, Body, Get, Req, Put } from '@nestjs/common';
import { UserService } from './user.service';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post('register')
  async register(
    @Body()
    registerDto: {
      email: string;
      password?: string;
      name: string;
      preferences?: Record<string, any>;
    },
  ) {
    return this.userService.syncProfile({
      userId: registerDto.email,
      fullName: registerDto.name,
      preferences: registerDto.preferences,
    });
  }

  @Get('profile')
  async getProfile(@Req() req: any) {
    const userId = req.headers['x-user-id'] || 'unknown';
    return this.userService.syncProfile({ userId, fullName: '', preferences: {} });
  }

  @Put('profile')
  async updateProfile(
    @Req() req: any,
    @Body()
    updateDto: {
      name?: string;
      preferences?: Record<string, any>;
    },
  ) {
    const userId = req.headers['x-user-id'] || 'unknown';
    return this.userService.syncProfile({
      userId,
      fullName: updateDto.name,
      preferences: updateDto.preferences,
    });
  }
}
