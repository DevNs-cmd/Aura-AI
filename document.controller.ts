import { Controller, Post, Get, Body, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { DocumentService, ProcessedDocument } from './document.service';

@Controller('documents')
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @Post('upload')
  @HttpCode(HttpStatus.CREATED)
  async uploadDocument(
    @Body() payload: { userId: string; name: string; type: string; size?: string }
  ): Promise<{ success: boolean; document: ProcessedDocument }> {
    const { userId, name, type, size } = payload;
    const document = await this.documentService.processDocument(userId, name, type, size || '150 KB');
    return {
      success: true,
      document,
    };
  }

  @Get('user/:userId')
  async getDocuments(@Param('userId') userId: string): Promise<{ success: boolean; documents: ProcessedDocument[] }> {
    const documents = await this.documentService.getDocumentsByUserId(userId);
    return {
      success: true,
      documents,
    };
  }
}
