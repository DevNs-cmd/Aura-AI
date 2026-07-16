import { Controller, Post, Get, Delete, Body, Param, Query, HttpCode, HttpStatus, UseGuards, Req, UnauthorizedException } from '@nestjs/common';
import { MemoryService } from './memory.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

export class LearnFactDto {
  category!: string;
  fact!: string;
  importance?: number;
}

@UseGuards(JwtAuthGuard)
@Controller('memory')
export class MemoryController {
  constructor(private readonly memoryService: MemoryService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async learnFact(@Req() req: any, @Body() dto: LearnFactDto) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('User ID not found in token.');
    }
    return this.memoryService.learn(String(userId), dto.category, dto.fact, dto.importance);
  }

  @Get()
  async getMemories(@Req() req: any, @Query('category') category?: string) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('User ID not found in token.');
    }
    if (category) {
      return this.memoryService.findByCategory(String(userId), category);
    }
    return this.memoryService.findAll(String(userId));
  }

  @Delete(':id')
  async forgetFact(@Req() req: any, @Param('id') id: string) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('User ID not found in token.');
    }
    return this.memoryService.forget(String(userId), id);
  }
}
