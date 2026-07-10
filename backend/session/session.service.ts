import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

export interface SessionState {
  sessionId: string;
  userId?: string;
  token?: string;
  metadata?: Record<string, unknown>;
}

@Injectable()
export class SessionService {
  private readonly fastApiBaseUrl = process.env.FASTAPI_URL || 'http://localhost:8000';

  async syncSession(payload: SessionState): Promise<SessionState> {
    try {
      const response = await fetch(`${this.fastApiBaseUrl}/session/sync`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Session sync failed', response.status || HttpStatus.BAD_GATEWAY);
      }

      return (await response.json()) as SessionState;
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException('Unable to sync session with FastAPI', HttpStatus.BAD_GATEWAY);
    }
  }
}
