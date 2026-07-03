import { Controller, Post, Get, Patch, Body, Request, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { UserService } from './user.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() registerDto: { email: string; password?: string; name: string; preferences?: Record<string, any> }) {
    return this.userService.register(registerDto);
  }

  @UseGuards(AuthGuard)
  @Get('profile')
  async getProfile(@Request() req: any) {
    return this.userService.findById(req.user.id);
  }

  @UseGuards(AuthGuard)
  @Patch('profile')
  async updateProfile(@Request() req: any, @Body() updateDto: { name?: string; preferences?: Record<string, any> }) {
    return this.userService.updateProfile(req.user.id, updateDto);
  }
}
