import { Controller, Post, Body, Get, Param } from '@nestjs/common';
import { DocumentService, DocumentUploadResponse } from './document.service';

@Controller('document')
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @Post('upload')
  async uploadDocument(
    @Body()
    payload: {
      userId: string;
      name: string;
      type: string;
      size?: string;
    },
  ): Promise<{ success: boolean; document: DocumentUploadResponse }> {
    const document = await this.documentService.uploadDocument({
      userId: payload.userId,
      fileName: payload.name,
      mimeType: payload.type,
      contentBase64: payload.size || '',
    });

    return { success: true, document };
  }

  @Get(':userId')
  async getDocuments(
    @Param('userId') userId: string,
  ): Promise<{ success: boolean; documents: any[] }> {
    const documents = await this.documentService.getDocumentsByUserId(userId);
    return { success: true, documents };
  }
}
