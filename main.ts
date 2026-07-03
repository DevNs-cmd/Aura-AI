import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe, Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  
  // 1. AppModule ko load karke Nest application create karna
  const app = await NestFactory.create(AppModule);

  // 2. Global Route Prefix (Optional: isse aapki saari APIs /api/v1/ se shuru hongi)
  app.setGlobalPrefix('api/v1');

  // 3. Global Validation Pipe (DTO validation automatic chalane ke liye)
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Jo fields DTO me nahi hain, unhe automatic remove kar dega (Security)
      transform: true, // Query/Body params ko automatic sahi data type me convert karega
    }),
  );

  // 4. CORS Enable Karna (Taaki aapki Flutter mobile app is backend se connect ho sake)
  app.enableCors({
    origin: '*', // Development me sab allow karne ke liye
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });

  // 5. Server kis port par chalega
  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  logger.log(`🚀 Aura AI Core Backend is running on: http://localhost:${port}/api/v1`);
}
bootstrap();