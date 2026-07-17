import { Controller, Post, Body, UseGuards, Req, UnauthorizedException } from '@nestjs/common';
import { VoiceService } from './voice.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('voice')
export class VoiceController {
  constructor(private readonly voiceService: VoiceService) {}

  @UseGuards(JwtAuthGuard)
  @Post('transcribe')
  async transcribeAudio(
    @Req() req: any,
    @Body('audio') base64Audio: string,
    @Body('mime_type') mimeType: string,
  ) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('Authenticated user is required.');
    }
    return this.voiceService.transcribeAudio(String(userId), base64Audio, mimeType);
  }

  @UseGuards(JwtAuthGuard)
  @Post('synthesize')
  async synthesizeVoice(
    @Req() req: any,
    @Body('text') text: string,
    @Body('language') language?: string,
  ) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) {
      throw new UnauthorizedException('Authenticated user is required.');
    }
    return this.voiceService.synthesizeVoice(String(userId), text, language);
  }
}
