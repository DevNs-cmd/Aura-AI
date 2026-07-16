import { Injectable, BadGatewayException, InternalServerErrorException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class ChatService {
  constructor(private readonly httpService: HttpService) {
  }

  async processAIMessage(userId: string, message: string) {
    const aiServiceBaseUrl = process.env.AI_SERVICE_URL;

    if (!aiServiceBaseUrl) {
      throw new InternalServerErrorException('AI_SERVICE_URL is not configured.');
    }

    const payload = {
      user_id: userId,
      message,
    };

    try {
      const aiServiceUrl = new URL('/ai/chat', aiServiceBaseUrl).toString();
      const response = await firstValueFrom(
        this.httpService.post(aiServiceUrl, payload),
      );
      return response.data;
    } catch (error: any) {
      const status = error?.response?.status;
      const detail = error?.response?.data?.detail ?? error?.message ?? 'FastAPI AI service request failed.';

      if (status && status >= 500) {
        throw new BadGatewayException(detail);
      }

      if (status) {
        throw new BadGatewayException(detail);
      }

      throw new BadGatewayException('FastAPI AI service is unreachable.');
    }
  }
}
