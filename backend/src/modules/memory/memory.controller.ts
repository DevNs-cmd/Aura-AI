import { Controller, Post, Body } from '@nestjs/common';
import { MemoryService, MemoryCreateRequest, MemorySearchRequest } from './memory.service';

@Controller('memory')
export class MemoryController {
  constructor(private readonly memoryService: MemoryService) {}

  @Post('create')
  async rememberFact(
    @Body() payload: MemoryCreateRequest,
  ): Promise<{ success: boolean; memory: any }> {
    const memory = await this.memoryService.create(payload);
    return { success: true, memory };
  }

  @Post('search')
  async getMemories(
    @Body() payload: MemorySearchRequest,
  ): Promise<{ success: boolean; memories: any[] }> {
    const memories = await this.memoryService.search(payload);
    return { success: true, memories };
  }
}
