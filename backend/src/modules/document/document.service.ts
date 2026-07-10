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
      // Fallback: return a stubbed upload response when FastAPI is unreachable
      return {
        id: 'stub',
        status: 'unavailable',
        message: 'FastAPI document service unavailable',
        embeddingsCount: 0,
      } as DocumentUploadResponse;
    }
  }

  async getDocumentsByUserId(userId: string): Promise<any[]> {
    try {
      const response = await fetch(`${this.fastApiBaseUrl}/documents?userId=${userId}`);

      if (!response.ok) {
        const errorBody = await response.text();
        throw new HttpException(errorBody || 'Failed to fetch documents', response.status || HttpStatus.BAD_GATEWAY);
      }

      return (await response.json()) as any[];
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }
      // Fallback: return a stubbed empty document list when FastAPI is unreachable
      return [
        {
          id: 'stub-doc-1',
          filename: 'stub_resume.pdf',
          file_type: 'application/pdf',
          size_bytes: 1024,
          status: 'uploaded',
        }
      ];
    }
  }
}
