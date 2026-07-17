import { Injectable, BadGatewayException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class VoiceService {
  constructor(private readonly httpService: HttpService) {}

  async transcribeAudio(userId: string, base64Audio: string, mimeType: string) {
    const aiServiceBaseUrl = process.env.AI_SERVICE_URL || 'http://localhost:8000';
    const payload = {
      user_id: userId,
      audio: base64Audio,
      mime_type: mimeType,
    };

    try {
      const url = new URL('/ai/voice/transcribe', aiServiceBaseUrl).toString();
      const response = await firstValueFrom(
        this.httpService.post(url, payload),
      );
      return response.data;
    } catch (error: any) {
      const detail = error?.response?.data?.detail ?? error?.message ?? 'FastAPI AI voice transcribe request failed.';
      throw new BadGatewayException(detail);
    }
  }

  async synthesizeVoice(userId: string, text: string, language?: string) {
    const aiServiceBaseUrl = process.env.AI_SERVICE_URL || 'http://localhost:8000';
    const payload = {
      user_id: userId,
      text: text,
      language: language,
    };

    try {
      const url = new URL('/ai/voice/synthesize', aiServiceBaseUrl).toString();
      const response = await firstValueFrom(
        this.httpService.post(url, payload),
      );
      return response.data;
    } catch (error: any) {
      const detail = error?.response?.data?.detail ?? error?.message ?? 'FastAPI AI voice synthesize request failed.';
      throw new BadGatewayException(detail);
    }
  }
}
