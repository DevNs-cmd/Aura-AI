import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  // Bootstrap NestJS application
  const app = await NestFactory.create(AppModule);

  // Set standard global prefix for endpoints
  app.setGlobalPrefix('api');

  // Enable Cross-Origin Resource Sharing (CORS) for frontend integrations
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`[Aura-AI] Production backend successfully bootstrapped on http://0.0.0.0:${port}`);
}

bootstrap();
