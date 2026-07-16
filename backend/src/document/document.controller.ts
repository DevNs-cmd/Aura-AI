import { Controller, Post, Get, Delete, Body, Param, HttpCode, HttpStatus, UseGuards, Req, UnauthorizedException } from '@nestjs/common';
import { DocumentService } from './document.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

export class UploadDocDto {
  filename!: string;
  mimeType!: string;
  size!: number;
}

@UseGuards(JwtAuthGuard)
@Controller('documents')
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async uploadDocument(@Req() req: any, @Body() uploadDto: UploadDocDto) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('User ID not found in token.');
    }
    return this.documentService.upload(String(userId), uploadDto.filename, uploadDto.mimeType, uploadDto.size);
  }

  @Get()
  async getAllDocuments(@Req() req: any) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('User ID not found in token.');
    }
    return this.documentService.findAll(String(userId));
  }

  @Get(':id')
  async getDocument(@Req() req: any, @Param('id') id: string) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('User ID not found in token.');
    }
    return this.documentService.findOne(String(userId), id);
  }

  @Delete(':id')
  async deleteDocument(@Req() req: any, @Param('id') id: string) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('User ID not found in token.');
    }
    return this.documentService.delete(String(userId), id);
  }
}
