import { Injectable, InternalServerErrorException, HttpException, HttpStatus } from '@nestjs/common';
import { GoogleGenAI } from '@google/genai';
import { HttpService } from '@nestjs/axios'; // <--- FastAPI integration ke liye naya import
import { firstValueFrom } from 'rxjs'; // <--- RxJS pipeline handle karne ke liye naya import

@Injectable()
export class ChatService {
  private ai: GoogleGenAI | null = null;

  // Constructor mein HttpService ko inject kar diya
  constructor(private readonly httpService: HttpService) {
    const apiKey = process.env.GEMINI_API_KEY;
    if (apiKey && apiKey !== 'MY_GEMINI_API_KEY') {
      this.ai = new GoogleGenAI({ apiKey });
    }
  }

  /**
   * Primary Method: Hit Atharva's FastAPI AI Service (PostgreSQL + Redis + ChromaDB)
   */
  async processAIMessage(userId: string, message: string) {
    const aiServiceUrl = `${process.env.AI_SERVICE_URL}/ai/chat`;
    
    const payload = {
      user_id: userId,
      message: message
    };

    try {
      // NestJS acts as gateway and hits FastAPI AI Service
      const response = await firstValueFrom(
        this.httpService.post(aiServiceUrl, payload)
      );
      return response.data; // FastAPI processed data (with ChromaDB context)
    } catch (error: any) {
      console.error('FastAPI AI Service call failed, falling back to local inference...', error.message);
      
      // Agar FastAPI down hai, toh gracefully local Gemini inference par shift ho jao
      return this.generateResponse(message, userId);
    }
  }

  /**
   * Fallback Method: Backup local Gemini API inference
   */
  async generateResponse(message: string, userId?: string): Promise<{ reply: string; modelUsed: string; timestamp: Date }> {
    const timestamp = new Date();

    if (this.ai) {
      try {
        const result = await this.ai.models.generateContent({
          model: 'gemini-2.5-flash',
          contents: message,
          config: {
            systemInstruction: 'You are Aura AI, a wise, calming, and exceptionally supportive assistant.',
          },
        });

        return {
          reply: result.text || 'No response text received from Aura AI.',
          modelUsed: 'gemini-2.5-flash (live)',
          timestamp,
        };
      } catch (error: any) {
        console.error('Gemini API call failed:', error);
        throw new InternalServerErrorException(`Aura AI inference failed: ${error.message || error}`);
      }
    }

    // Agar na FastAPI mili na Gemini key
    throw new HttpException(
      'AI Services are currently unavailable',
      HttpStatus.BAD_GATEWAY
    );
  }
}