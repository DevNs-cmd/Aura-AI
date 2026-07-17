import { Controller, Post, Body, UseGuards, Req, UnauthorizedException } from '@nestjs/common';
import { VisionService } from './vision.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('vision')
export class VisionController {
  constructor(private readonly visionService: VisionService) {}

  @UseGuards(JwtAuthGuard)
  @Post('analyze')
  async analyzeImage(@Req() req: any, @Body('image') base64Image: string) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('Authenticated user is required.');
    }
    return this.visionService.analyzeImage(String(userId), base64Image);
  }
}
