import {
  Injectable,
  Logger,
  BadGatewayException,
  BadRequestException,
  InternalServerErrorException,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class ChatService {
  private readonly logger = new Logger(ChatService.name);

  constructor(private readonly httpService: HttpService) {
  }

  async processAIMessage(userId: string, message: string, userEmail?: string, userName?: string) {
    const aiServiceBaseUrl = process.env.AI_SERVICE_URL || 'http://localhost:8000';

    const payload: Record<string, unknown> = {
      user_id: userId,
      message,
    };

    if (userEmail) {
      payload.user_email = userEmail;
    }
    if (userName) {
      payload.user_name = userName;
    }

    try {
      const aiServiceUrl = new URL('/ai/chat', aiServiceBaseUrl).toString();
      this.logger.log(`Forwarding chat request to ${aiServiceUrl} for user ${userId}`);
      const response = await firstValueFrom(
        this.httpService.post(aiServiceUrl, payload),
      );
      return response.data;
    } catch (error: any) {
      const status = error?.response?.status;
      const detail = error?.response?.data?.detail ?? error?.message ?? 'FastAPI AI service request failed.';

      this.logger.error(
        `FastAPI chat request failed: status=${status ?? 'unreachable'} detail=${String(detail)}`,
      );

      if (status) {
        if (status >= 500) {
          throw new BadGatewayException(detail);
        }
        if (status === 404) {
          throw new NotFoundException(detail);
        }
        if (status === 401) {
          throw new UnauthorizedException(detail);
        }
        if (status === 400) {
          throw new BadRequestException(detail);
        }
        throw new BadGatewayException(detail);
      }

      throw new BadGatewayException('FastAPI AI service is unreachable.');
    }
  }
}
