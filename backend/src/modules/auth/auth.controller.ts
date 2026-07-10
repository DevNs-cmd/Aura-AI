import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(
    @Body()
    payload: {
      email: string;
      password?: string;
      name: string;
    },
  ) {
    return this.authService.register(payload.email, payload.password || '', payload.name);
  }

  @Post('login')
  async login(
    @Body()
    payload: {
      email: string;
      password?: string;
    },
  ) {
    const user = await this.authService.validateUser(payload.email, payload.password || '');
    return this.authService.login(user);
  }

  @Post('forgot-password')
  async forgotPassword(
    @Body()
    payload: {
      email: string;
    },
  ) {
    return this.authService.forgotPassword(payload.email);
  }
}
