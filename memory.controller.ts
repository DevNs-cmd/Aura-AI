import { Controller, Post, Get, Body, Param, HttpCode, HttpStatus } from '@nestjs/common';
import { MemoryService, MemoryFact } from './memory.service';

@Controller('memory')
export class MemoryController {
  constructor(private readonly memoryService: MemoryService) {}

  @Post('remember')
  @HttpCode(HttpStatus.CREATED)
  async rememberFact(
    @Body() payload: { userId: string; fact: string; category?: 'preference' | 'schedule' | 'relationship' | 'general'; importance?: number }
  ): Promise<{ success: boolean; memory: MemoryFact }> {
    const { userId, fact, category, importance } = payload;
    const memory = await this.memoryService.rememberFact(userId, fact, category, importance);
    return {
      success: true,
      memory,
    };
  }

  @Get(':userId')
  async getMemories(@Param('userId') userId: string): Promise<{ success: boolean; memories: MemoryFact[] }> {
    const memories = await this.memoryService.getMemories(userId);
    return {
      success: true,
      memories,
    };
  }
}
