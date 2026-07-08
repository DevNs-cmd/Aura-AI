import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

export interface DocumentUploadPayload {
  userId: string;
  fileName: string;
  mimeType: string;
  contentBase64: string;
  metadata?: Record<string, unknown>;
}

export interface DocumentUploadResponse {
  id: string;
  status: string;
  message: string;
  embeddingsCount?: number;
}

@Injectable()
export class DocumentService {
  private readonly fastApiBaseUrl = process.env.FASTAPI_URL || 'http://localhost:8000';

  async uploadDocument(payload: DocumentUploadPayload): Promise<DocumentUploadResponse> {
    try {
      const response = await fetch(`${this.fastApiBaseUrl}/document/upload`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Document upload failed', response.status || HttpStatus.BAD_GATEWAY);
      }

      return (await response.json()) as DocumentUploadResponse;
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException('Unable to reach FastAPI document service', HttpStatus.BAD_GATEWAY);
    }
  }
}
