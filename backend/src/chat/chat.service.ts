import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { GoogleGenAI } from '@google/genai';

@Injectable()
export class ChatService {
  private ai: GoogleGenAI | null = null;

  constructor() {
    const apiKey = process.env.GEMINI_API_KEY;
    if (apiKey && apiKey !== 'MY_GEMINI_API_KEY') {
      this.ai = new GoogleGenAI({ apiKey });
    }
  }

  async generateResponse(message: string, userId?: string): Promise<{ reply: string; modelUsed: string; timestamp: Date }> {
    const timestamp = new Date();
    
    // If we have a configured API key, run real live Gemini inference
    if (this.ai) {
      try {
        const result = await this.ai.models.generateContent({
          model: 'gemini-2.5-flash',
          contents: message,
          config: {
            systemInstruction: 'You are Aura AI, a wise, calming, and exceptionally supportive backend AI agent built inside the Aura-AI platform. Keep your replies concise, warm, helpful, and developer-oriented.',
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

    // Elegant, smart mock response if no GEMINI_API_KEY is found (with a developer prompt suggestion)
    let reply = `Greetings! I am Aura AI. I noticed that the GEMINI_API_KEY is not configured in your environment yet. 

Once you add your API key in the secrets panel, I will respond with live Gemini answers! 

For now, here is a helpful design tip for Aura-AI:
Keep your API routes microservice-ready by maintaining separate DTOs for every incoming payload structure, just like we did with SignupDto and ResetPasswordDto!`;

    if (message.toLowerCase().includes('hello') || message.toLowerCase().includes('hi')) {
      reply = `Hello! I am Aura AI, the wisdom layer of your modular NestJS architecture. 

Currently, we are running in local-sandbox mode because a Gemini API Key is not set in secrets. If you configure GEMINI_API_KEY, I can connect to live LLM intelligence to answer your queries in real-time. How can I assist you with your Aura-AI architecture design today?`;
    }

    return {
      reply,
      modelUsed: 'aura-mock-engine (offline)',
      timestamp,
    };
  }
}
