import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

export interface UserProfilePayload {
  userId: string;
  fullName?: string;
  bio?: string;
  preferences?: Record<string, unknown>;
}

@Injectable()
export class UserService {
  private readonly fastApiBaseUrl = process.env.FASTAPI_URL || 'http://localhost:8000';

  async syncProfile(payload: UserProfilePayload): Promise<any> {
    try {
      const response = await fetch(`${this.fastApiBaseUrl}/personality/sync`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Personality sync failed', response.status || HttpStatus.BAD_GATEWAY);
      }

      return await response.json();
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }
      // Fallback: return a minimal echo profile when FastAPI is unreachable
      return {
        userId: payload.userId,
        fullName: payload.fullName || '',
        preferences: payload.preferences || {},
      };
    }
  }
}
