import { Injectable, BadGatewayException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class VisionService {
  constructor(private readonly httpService: HttpService) {}

  async analyzeImage(userId: string, base64Image: string) {
    const aiServiceBaseUrl = process.env.AI_SERVICE_URL || 'http://localhost:8000';
    const payload = {
      user_id: userId,
      image: base64Image,
    };

    try {
      const url = new URL('/ai/vision/analyze', aiServiceBaseUrl).toString();
      const response = await firstValueFrom(
        this.httpService.post(url, payload),
      );
      return response.data;
    } catch (error: any) {
      const detail = error?.response?.data?.detail ?? error?.message ?? 'FastAPI AI vision service request failed.';
      throw new BadGatewayException(detail);
    }
  }
}
