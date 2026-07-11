import { Injectable, NotFoundException } from '@nestjs/common';

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

  async createSession(userId: string, device: string, ipAddress: string): Promise<UserSession> {
    const session: UserSession = {
      id: `sess_${Math.random().toString(36).substring(2, 9)}`,
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

  async findByUserId(userId: string): Promise<UserSession[]> {
    return this.sessions.filter((s) => s.userId === userId);
  }

  async findActiveSession(sessionId: string): Promise<UserSession> {
    const session = this.sessions.find((s) => s.id === sessionId);
    if (!session) {
      throw new NotFoundException(`Session with ID ${sessionId} not found.`);
    }
    return session;
  }

  async updateActivity(sessionId: string): Promise<void> {
    const session = await this.findActiveSession(sessionId);
    session.lastActiveAt = new Date();
  }

  async revoke(sessionId: string): Promise<{ success: boolean; message: string }> {
    const session = await this.findActiveSession(sessionId);
    session.isActive = false;
    return { success: true, message: `Session ${sessionId} has been successfully revoked.` };
  }

  async revokeAllExcept(userId: string, activeSessionId: string): Promise<{ revokedCount: number }> {
    let revokedCount = 0;
    this.sessions.forEach((s) => {
      if (s.userId === userId && s.id !== activeSessionId && s.isActive) {
        s.isActive = false;
        revokedCount++;
      }
    });
    return { revokedCount };
  }
}
