import { Controller, Post, Get, Delete, Body, Param, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { MemoryService } from './memory.service';

export class LearnFactDto {
  category!: string;
  fact!: string;
  importance?: number;
}

@Controller('memory')
export class MemoryController {
  constructor(private readonly memoryService: MemoryService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async learnFact(@Body() dto: LearnFactDto) {
    return this.memoryService.learn(dto.category, dto.fact, dto.importance);
  }

  @Get()
  async getMemories(@Query('category') category?: string) {
    if (category) {
      return this.memoryService.findByCategory(category);
    }
    return this.memoryService.findAll();
  }

  @Delete(':id')
  async forgetFact(@Param('id') id: string) {
    return this.memoryService.forget(id);
  }
}
