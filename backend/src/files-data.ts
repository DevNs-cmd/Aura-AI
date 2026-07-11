export interface SourceFile {
  name: string;
  path: string;
  language: string;
  content: string;
}

export const sourceFiles: Record<string, SourceFile> = {
  // TSCONFIG
  'tsconfig': {
    name: 'tsconfig.json',
    path: '/tsconfig.json',
    language: 'json',
    content: `{
  "compilerOptions": {
    "target": "ES2022",
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "useDefineForClassFields": false,
    "module": "ESNext",
    "lib": [
      "ES2022",
      "DOM",
      "DOM.Iterable"
    ],
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "isolatedModules": true,
    "moduleDetection": "force",
    "allowJs": true,
    "jsx": "react-jsx",
    "rootDir": "./",
    "outDir": "./dist",
    "paths": {
      "@/*": [
        "./*"
      ]
    },
    "allowImportingTsExtensions": true,
    "noEmit": true
  }
}`
  },
  // APP MODULE
  'app-module': {
    name: 'app.module.ts',
    path: '/src/app.module.ts',
    language: 'typescript',
    content: `import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { ChatModule } from './chat/chat.module';
import { DocumentModule } from './document/document.module';
import { MemoryModule } from './memory/memory.module';
import { NotificationModule } from './notification/notification.module';
import { SessionModule } from './session/session.module';

@Module({
  imports: [
    AuthModule,
    UserModule,
    ChatModule,
    DocumentModule,
    MemoryModule,
    NotificationModule,
    SessionModule,
  ],
})
export class AppModule {}`
  },
  // MAIN TS
  'main-ts': {
    name: 'main.ts',
    path: '/src/main.ts',
    language: 'typescript',
    content: `import { NestFactory } from '@nestjs/core';
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
  console.log(\`[Aura-AI] Production backend successfully bootstrapped on http://0.0.0.0:\${port}\`);
}

bootstrap();`
  },
  // SIGNUP DTO
  'signup-dto': {
    name: 'signup.dto.ts',
    path: '/src/auth/dto/signup.dto.ts',
    language: 'typescript',
    content: `export class SignupDto {
  name?: string;
  email!: string;
  password!: string;
}`
  },
  // LOGIN DTO
  'login-dto': {
    name: 'login.dto.ts',
    path: '/src/auth/dto/login.dto.ts',
    language: 'typescript',
    content: `export class LoginDto {
  email!: string;
  password!: string;
}`
  },
  // FORGET PASSWORD DTO
  'forget-password-dto': {
    name: 'forget-password.dto.ts',
    path: '/src/auth/dto/forget-password.dto.ts',
    language: 'typescript',
    content: `export class ForgotPasswordDto {
  email!: string;
}

export class ResetPasswordDto {
  email!: string;
  token!: string;
  newPassword!: string;
}`
  },
  // AUTH SERVICE
  'auth-service': {
    name: 'auth.service.ts',
    path: '/src/auth/auth.service.ts',
    language: 'typescript',
    content: `import { Injectable, ConflictException, UnauthorizedException, BadRequestException, NotFoundException } from '@nestjs/common';
import { UserService } from '../user/user.service';
import { SignupDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';
import { ForgotPasswordDto, ResetPasswordDto } from './dto/forget-password.dto';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthService {
  private readonly jwtSecret = process.env.JWT_SECRET || 'aura_ai_secret_key_123';

  constructor(private readonly userService: UserService) {}

  async signup(signupDto: SignupDto) {
    const { name, email, password } = signupDto;

    const existingUser = await this.userService.findByEmail(email);
    if (existingUser) {
      throw new ConflictException('A user with this email already exists.');
    }

    // Hash password with bcrypt
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await this.userService.create(name, email, passwordHash);

    // Generate JWT Token
    const token = this.generateToken(user.id, user.email);

    return {
      message: 'User registered successfully',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        createdAt: user.createdAt,
      },
      accessToken: token,
    };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    const user = await this.userService.findByEmail(email);
    if (!user) {
      throw new UnauthorizedException('Invalid email or password.');
    }

    // Verify password match
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid email or password.');
    }

    // Generate JWT Token
    const token = this.generateToken(user.id, user.email);

    return {
      message: 'Login successful',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
      accessToken: token,
    };
  }

  async forgotPassword(forgotPasswordDto: ForgotPasswordDto) {
    const { email } = forgotPasswordDto;

    const user = await this.userService.findByEmail(email);
    if (!user) {
      throw new NotFoundException('User with this email was not found.');
    }

    // Generate a secure 6-character numeric OTP
    const token = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + 15); // Expire in 15 minutes

    await this.userService.updateResetToken(email, token, expiry);

    return {
      message: 'Password reset OTP generated successfully. An email would be sent in production.',
      resetToken: token,
      expiresAt: expiry,
    };
  }

  async resetPassword(resetPasswordDto: ResetPasswordDto) {
    const { email, token, newPassword } = resetPasswordDto;

    const user = await this.userService.findByEmail(email);
    if (!user) {
      throw new NotFoundException('User with this email was not found.');
    }

    // Verify token matches and has not expired
    if (!user.resetToken || user.resetToken !== token) {
      throw new BadRequestException('Invalid or expired password reset token.');
    }

    if (user.resetTokenExpiry && new Date() > user.resetTokenExpiry) {
      throw new BadRequestException('Password reset token has expired.');
    }

    // Hash the new password with bcrypt
    const salt = await bcrypt.genSalt(10);
    const newPasswordHash = await bcrypt.hash(newPassword, salt);

    // Update password
    await this.userService.updatePassword(email, newPasswordHash);

    return {
      message: 'Password has been securely reset successfully. You can now login with your new password.',
    };
  }

  private generateToken(userId: string, email: string): string {
    return jwt.sign(
      { sub: userId, email },
      this.jwtSecret,
      { expiresIn: '1h' }
    );
  }

  verifyJwt(token: string): any {
    try {
      return jwt.verify(token, this.jwtSecret);
    } catch (e) {
      throw new UnauthorizedException('Invalid or expired access token.');
    }
  }
}`
  },
  // AUTH CONTROLLER
  'auth-controller': {
    name: 'auth.controller.ts',
    path: '/src/auth/auth.controller.ts',
    language: 'typescript',
    content: `import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';
import { SignupDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';
import { ForgotPasswordDto, ResetPasswordDto } from './dto/forget-password.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signup')
  @HttpCode(HttpStatus.CREATED)
  async signup(@Body() signupDto: SignupDto) {
    return this.authService.signup(signupDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  async forgotPassword(@Body() forgotPasswordDto: ForgotPasswordDto) {
    return this.authService.forgotPassword(forgotPasswordDto);
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.authService.resetPassword(resetPasswordDto);
  }
}`
  },
  // AUTH MODULE
  'auth-module': {
    name: 'auth.module.ts',
    path: '/src/auth/auth.module.ts',
    language: 'typescript',
    content: `import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UserModule } from '../user/user.module';

@Module({
  imports: [UserModule],
  controllers: [AuthController],
  providers: [AuthService],
  exports: [AuthService],
})
export class AuthModule {}`
  },
  // USER SERVICE
  'user-service': {
    name: 'user.service.ts',
    path: '/src/user/user.service.ts',
    language: 'typescript',
    content: `import { Injectable, NotFoundException } from '@nestjs/common';

export interface User {
  id: string;
  name?: string;
  email: string;
  passwordHash: string;
  resetToken?: string;
  resetTokenExpiry?: Date;
  createdAt: Date;
}

@Injectable()
export class UserService {
  private users: User[] = [];

  async findByEmail(email: string): Promise<User | undefined> {
    return this.users.find((u) => u.email.toLowerCase() === email.toLowerCase());
  }

  async findById(id: string): Promise<User | undefined> {
    return this.users.find((u) => u.id === id);
  }

  async create(name: string | undefined, email: string, passwordHash: string): Promise<User> {
    const newUser: User = {
      id: Math.random().toString(36).substring(2, 11),
      name,
      email: email.toLowerCase(),
      passwordHash,
      createdAt: new Date(),
    };
    this.users.push(newUser);
    return newUser;
  }

  async updateResetToken(email: string, token: string, expiry: Date): Promise<void> {
    const user = await this.findByEmail(email);
    if (!user) {
      throw new NotFoundException('User with this email does not exist.');
    }
    user.resetToken = token;
    user.resetTokenExpiry = expiry;
  }

  async updatePassword(email: string, newPasswordHash: string): Promise<void> {
    const user = await this.findByEmail(email);
    if (!user) {
      throw new NotFoundException('User not found.');
    }
    user.passwordHash = newPasswordHash;
    user.resetToken = undefined;
    user.resetTokenExpiry = undefined;
  }

  async findAll(): Promise<Omit<User, 'passwordHash'>[]> {
    return this.users.map(({ passwordHash, ...rest }) => rest);
  }
}`
  },
  // USER CONTROLLER
  'user-controller': {
    name: 'user.controller.ts',
    path: '/src/user/user.controller.ts',
    language: 'typescript',
    content: `import { Controller, Get, Param, NotFoundException } from '@nestjs/common';
import { UserService } from './user.service';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  async getAllUsers() {
    return this.userService.findAll();
  }

  @Get(':email')
  async getUserByEmail(@Param('email') email: string) {
    const user = await this.userService.findByEmail(email);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    const { passwordHash, ...safeUser } = user;
    return safeUser;
  }
}`
  },
  // USER MODULE
  'user-module': {
    name: 'user.module.ts',
    path: '/src/user/user.module.ts',
    language: 'typescript',
    content: `import { Module } from '@nestjs/common';
import { UserController } from './user.controller';
import { UserService } from './user.service';

@Module({
  controllers: [UserController],
  providers: [UserService],
  exports: [UserService],
})
export class UserModule {}`
  },
  // CHAT SERVICE
  'chat-service': {
    name: 'chat.service.ts',
    path: '/src/chat/chat.service.ts',
    language: 'typescript',
    content: `import { Injectable, InternalServerErrorException } from '@nestjs/common';
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
    
    if (this.ai) {
      try {
        const result = await this.ai.models.generateContent({
          model: 'gemini-2.5-flash',
          contents: message,
          config: {
            systemInstruction: 'You are Aura AI, a wise, calming, and supportive AI built inside Aura-AI. Keep replies warm and concise.',
          },
        });

        return {
          reply: result.text || 'No response text received from Aura AI.',
          modelUsed: 'gemini-2.5-flash (live)',
          timestamp,
        };
      } catch (error: any) {
        throw new InternalServerErrorException(\`Aura AI inference failed: \${error.message}\`);
      }
    }

    return {
      reply: "Greetings! Provide a GEMINI_API_KEY to activate live AI answers. Currently running in offline mode.",
      modelUsed: 'aura-mock-engine (offline)',
      timestamp,
    };
  }
}`
  },
  // CHAT CONTROLLER
  'chat-controller': {
    name: 'chat.controller.ts',
    path: '/src/chat/chat.controller.ts',
    language: 'typescript',
    content: `import { Controller, Post, Body } from '@nestjs/common';
import { ChatService } from './chat.service';

export class CreateMessageDto {
  message!: string;
}

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post()
  async sendMessage(@Body() createMessageDto: CreateMessageDto) {
    return this.chatService.generateResponse(createMessageDto.message);
  }
}`
  },
  // CHAT MODULE
  'chat-module': {
    name: 'chat.module.ts',
    path: '/src/chat/chat.module.ts',
    language: 'typescript',
    content: `import { Module } from '@nestjs/common';
import { ChatController } from './chat.controller';
import { ChatService } from './chat.service';

@Module({
  controllers: [ChatController],
  providers: [ChatService],
  exports: [ChatService],
})
export class ChatModule {}`
  },
  // DOCUMENT SERVICE
  'document-service': {
    name: 'document.service.ts',
    path: '/src/document/document.service.ts',
    language: 'typescript',
    content: `import { Injectable, NotFoundException } from '@nestjs/common';

export interface DocumentItem {
  id: string;
  filename: string;
  mimeType: string;
  size: number;
  uploadedAt: Date;
  status: 'processing' | 'indexed' | 'failed';
}

@Injectable()
export class DocumentService {
  private documents: DocumentItem[] = [];

  async upload(filename: string, mimeType: string, size: number): Promise<DocumentItem> {
    const doc: DocumentItem = {
      id: \`doc_\${Math.random().toString(36).substring(2, 9)}\`,
      filename,
      mimeType,
      size,
      uploadedAt: new Date(),
      status: 'processing',
    };
    this.documents.push(doc);

    setTimeout(() => {
      doc.status = 'indexed';
    }, 5000);

    return doc;
  }

  async findAll(): Promise<DocumentItem[]> {
    return this.documents;
  }

  async findOne(id: string): Promise<DocumentItem> {
    const doc = this.documents.find((d) => d.id === id);
    if (!doc) throw new NotFoundException('Document not found');
    return doc;
  }

  async delete(id: string) {
    const idx = this.documents.findIndex((d) => d.id === id);
    if (idx === -1) throw new NotFoundException('Document not found');
    this.documents.splice(idx, 1);
    return { success: true, message: 'Document deleted successfully.' };
  }
}`
  },
  // DOCUMENT CONTROLLER
  'document-controller': {
    name: 'document.controller.ts',
    path: '/src/document/document.controller.ts',
    language: 'typescript',
    content: `import { Controller, Post, Get, Delete, Body, Param } from '@nestjs/common';
import { DocumentService } from './document.service';

@Controller('documents')
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @Post()
  async uploadDocument(@Body() dto: { filename: string; mimeType: string; size: number }) {
    return this.documentService.upload(dto.filename, dto.mimeType, dto.size);
  }

  @Get()
  async getAll() {
    return this.documentService.findAll();
  }

  @Delete(':id')
  async delete(@Param('id') id: string) {
    return this.documentService.delete(id);
  }
}`
  },
  // DOCUMENT MODULE
  'document-module': {
    name: 'document.module.ts',
    path: '/src/document/document.module.ts',
    language: 'typescript',
    content: `import { Module } from '@nestjs/common';
import { DocumentController } from './document.controller';
import { DocumentService } from './document.service';

@Module({
  controllers: [DocumentController],
  providers: [DocumentService],
  exports: [DocumentService],
})
export class DocumentModule {}`
  },
  // MEMORY SERVICE
  'memory-service': {
    name: 'memory.service.ts',
    path: '/src/memory/memory.service.ts',
    language: 'typescript',
    content: `import { Injectable, NotFoundException } from '@nestjs/common';

export interface MemoryFact {
  id: string;
  category: string;
  fact: string;
  importance: number;
  createdAt: Date;
}

@Injectable()
export class MemoryService {
  private memories: MemoryFact[] = [];

  async learn(category: string, fact: string, importance: number = 3): Promise<MemoryFact> {
    const memory = {
      id: \`mem_\${Math.random().toString(36).substring(2, 9)}\`,
      category,
      fact,
      importance,
      createdAt: new Date(),
    };
    this.memories.push(memory);
    return memory;
  }

  async findAll() {
    return this.memories;
  }

  async forget(id: string) {
    const idx = this.memories.findIndex((m) => m.id === id);
    if (idx === -1) throw new NotFoundException('Memory fact not found');
    this.memories.splice(idx, 1);
    return { success: true };
  }
}`
  },
  // MEMORY CONTROLLER
  'memory-controller': {
    name: 'memory.controller.ts',
    path: '/src/memory/memory.controller.ts',
    language: 'typescript',
    content: `import { Controller, Post, Get, Delete, Body, Param } from '@nestjs/common';
import { MemoryService } from './memory.service';

@Controller('memory')
export class MemoryController {
  constructor(private readonly memoryService: MemoryService) {}

  @Post()
  async learn(@Body() dto: { category: string; fact: string; importance: number }) {
    return this.memoryService.learn(dto.category, dto.fact, dto.importance);
  }

  @Get()
  async getAll() {
    return this.memoryService.findAll();
  }

  @Delete(':id')
  async forget(@Param('id') id: string) {
    return this.memoryService.forget(id);
  }
}`
  },
  // MEMORY MODULE
  'memory-module': {
    name: 'memory.module.ts',
    path: '/src/memory/memory.module.ts',
    language: 'typescript',
    content: `import { Module } from '@nestjs/common';
import { MemoryController } from './memory.controller';
import { MemoryService } from './memory.service';

@Module({
  controllers: [MemoryController],
  providers: [MemoryService],
  exports: [MemoryService],
})
export class MemoryModule {}`
  },
  // NOTIFICATION SERVICE
  'notification-service': {
    name: 'notification.service.ts',
    path: '/src/notification/notification.service.ts',
    language: 'typescript',
    content: `import { Injectable, NotFoundException } from '@nestjs/common';

export interface AppNotification {
  id: string;
  title: string;
  message: string;
  read: boolean;
  type: 'info' | 'warning' | 'success';
  createdAt: Date;
}

@Injectable()
export class NotificationService {
  private notifications: AppNotification[] = [];

  async trigger(title: string, message: string, type: 'info' | 'warning' | 'success' = 'info') {
    const notif: AppNotification = {
      id: \`notif_\${Math.random().toString(36).substring(2, 9)}\`,
      title,
      message,
      read: false,
      type,
      createdAt: new Date(),
    };
    this.notifications.unshift(notif);
    return notif;
  }

  async findAll() {
    return this.notifications;
  }

  async markAsRead(id: string) {
    const notif = this.notifications.find((n) => n.id === id);
    if (!notif) throw new NotFoundException('Notification not found');
    notif.read = true;
    return notif;
  }
}`
  },
  // NOTIFICATION CONTROLLER
  'notification-controller': {
    name: 'notification.controller.ts',
    path: '/src/notification/notification.controller.ts',
    language: 'typescript',
    content: `import { Controller, Post, Get, Patch, Body, Param } from '@nestjs/common';
import { NotificationService } from './notification.service';

@Controller('notifications')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post()
  async trigger(@Body() dto: { title: string; message: string; type?: 'info' | 'warning' | 'success' }) {
    return this.notificationService.trigger(dto.title, dto.message, dto.type);
  }

  @Get()
  async getAll() {
    return this.notificationService.findAll();
  }

  @Patch(':id/read')
  async markRead(@Param('id') id: string) {
    return this.notificationService.markAsRead(id);
  }
}`
  },
  // NOTIFICATION MODULE
  'notification-module': {
    name: 'notification.module.ts',
    path: '/src/notification/notification.module.ts',
    language: 'typescript',
    content: `import { Module } from '@nestjs/common';
import { NotificationController } from './notification.controller';
import { NotificationService } from './notification.service';

@Module({
  controllers: [NotificationController],
  providers: [NotificationService],
  exports: [NotificationService],
})
export class NotificationModule {}`
  },
  // SESSION SERVICE
  'session-service': {
    name: 'session.service.ts',
    path: '/src/session/session.service.ts',
    language: 'typescript',
    content: `import { Injectable, NotFoundException } from '@nestjs/common';

export interface UserSession {
  id: string;
  userId: string;
  device: string;
  ipAddress: string;
  isActive: boolean;
  lastActiveAt: Date;
  loginAt: Date;
}

@Injectable()
export class SessionService {
  private sessions: UserSession[] = [];

  async createSession(userId: string, device: string, ipAddress: string) {
    const session = {
      id: \`sess_\${Math.random().toString(36).substring(2, 9)}\`,
      userId,
      device,
      ipAddress,
      isActive: true,
      lastActiveAt: new Date(),
      loginAt: new Date(),
    };
    this.sessions.push(session);
    return session;
  }

  async findByUserId(userId: string) {
    return this.sessions.filter((s) => s.userId === userId);
  }

  async revoke(sessionId: string) {
    const session = this.sessions.find((s) => s.id === sessionId);
    if (!session) throw new NotFoundException('Session not found');
    session.isActive = false;
    return { success: true };
  }
}`
  },
  // SESSION CONTROLLER
  'session-controller': {
    name: 'session.controller.ts',
    path: '/src/session/session.controller.ts',
    language: 'typescript',
    content: `import { Controller, Post, Get, Delete, Body, Param } from '@nestjs/common';
import { SessionService } from './session.service';

@Controller('sessions')
export class SessionController {
  constructor(private readonly sessionService: SessionService) {}

  @Post()
  async create(@Body() dto: { userId: string; device: string; ipAddress: string }) {
    return this.sessionService.createSession(dto.userId, dto.device, dto.ipAddress);
  }

  @Get('user/:userId')
  async getByUserId(@Param('userId') userId: string) {
    return this.sessionService.findByUserId(userId);
  }

  @Delete(':id')
  async revoke(@Param('id') id: string) {
    return this.sessionService.revoke(id);
  }
}`
  },
  // SESSION MODULE
  'session-module': {
    name: 'session.module.ts',
    path: '/src/session/session.module.ts',
    language: 'typescript',
    content: `import { Module } from '@nestjs/common';
import { SessionController } from './session.controller';
import { SessionService } from './session.service';

@Module({
  controllers: [SessionController],
  providers: [SessionService],
  exports: [SessionService],
})
export class SessionModule {}`
  },
};
