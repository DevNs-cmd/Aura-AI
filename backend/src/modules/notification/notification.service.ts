import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

export interface NotificationPayload {
  userId: string;
  title: string;
  message: string;
  metadata?: Record<string, unknown>;
}

@Injectable()
export class NotificationService {
  private readonly fastApiBaseUrl = process.env.FASTAPI_URL || 'http://localhost:8000';

  async sendInsight(payload: NotificationPayload): Promise<any> {
    try {
      const response = await fetch(`${this.fastApiBaseUrl}/notification/insight`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Insight notification failed', response.status || HttpStatus.BAD_GATEWAY);
      }

      return await response.json();
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }
      // Fallback: return a stubbed success response when FastAPI is unreachable
      return { messageId: 'stub', message: 'FastAPI unavailable' };
    }
  }
}
