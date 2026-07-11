import { Controller, Post, Get, Delete, Body, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { DocumentService } from './document.service';

export class UploadDocDto {
  filename!: string;
  mimeType!: string;
  size!: number;
}

@Controller('documents')
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async uploadDocument(@Body() uploadDto: UploadDocDto) {
    return this.documentService.upload(uploadDto.filename, uploadDto.mimeType, uploadDto.size);
  }

  @Get()
  async getAllDocuments() {
    return this.documentService.findAll();
  }

  @Get(':id')
  async getDocument(@Param('id') id: string) {
    return this.documentService.findOne(id);
  }

  @Delete(':id')
  async deleteDocument(@Param('id') id: string) {
    return this.documentService.delete(id);
  }
}
