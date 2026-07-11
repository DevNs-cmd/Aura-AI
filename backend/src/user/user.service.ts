import { Injectable, NotFoundException } from '@nestjs/common';

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
}
