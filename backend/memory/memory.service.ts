import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

export interface MemorySearchRequest {
  userId: string;
  query: string;
  topK?: number;
}

export interface MemoryCreateRequest {
  userId: string;
  content: string;
  source?: string;
}

@Injectable()
export class MemoryService {
  private readonly fastApiBaseUrl = process.env.FASTAPI_URL || 'http://localhost:8000';

  async search(payload: MemorySearchRequest): Promise<any> {
    try {
      const response = await fetch(`${this.fastApiBaseUrl}/memory/search`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Memory search failed', response.status || HttpStatus.BAD_GATEWAY);
      }

      return await response.json();
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException('Unable to reach FastAPI memory service', HttpStatus.BAD_GATEWAY);
    }
  }

  async create(payload: MemoryCreateRequest): Promise<any> {
    try {
      const response = await fetch(`${this.fastApiBaseUrl}/memory/create`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Memory creation failed', response.status || HttpStatus.BAD_GATEWAY);
      }

      return await response.json();
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException('Unable to create memory entry', HttpStatus.BAD_GATEWAY);
    }
  }
}
