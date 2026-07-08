import { Injectable, UnauthorizedException, HttpException, HttpStatus } from '@nestjs/common';

export interface AuthPayload {
  email: string;
  sub: number;
}

export interface AuthUser {
  id: number;
  email: string;
}

@Injectable()
export class AuthService {
  private readonly fastApiBaseUrl = process.env.FASTAPI_URL || 'http://localhost:8000';

  async validateUser(email: string, pass: string): Promise<AuthUser> {
    try {
      const response = await fetch(`${this.fastApiBaseUrl}/auth/validate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password: pass }),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Invalid credentials', response.status || HttpStatus.UNAUTHORIZED);
      }

      const data = (await response.json()) as { user?: AuthUser };
      return data.user || { id: 1, email };
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException('Unable to validate credentials with FastAPI', HttpStatus.BAD_GATEWAY);
    }
  }

  async login(user: AuthUser) {
    try {
      const response = await fetch(`${this.fastApiBaseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: user.email, userId: user.id }),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Login failed', response.status || HttpStatus.UNAUTHORIZED);
      }

      return (await response.json()) as { access_token: string };
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException('Unable to reach FastAPI auth service', HttpStatus.BAD_GATEWAY);
    }
  }
}
