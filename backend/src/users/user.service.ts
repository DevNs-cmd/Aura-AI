import { Injectable, ConflictException, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User } from './user.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async register(registerDto: { 
    email: string; 
    password?: string; 
    name: string; 
    preferences?: Record<string, any> 
  }): Promise<Omit<User, 'passwordHash'>> {
    const { email, password, name, preferences } = registerDto;

    if (!email || !password || !name) {
      throw new BadRequestException('Email, password, and name are required');
    }

    const existingUser = await this.userRepository.findOne({ where: { email: email.toLowerCase() } });
    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    const newUser = this.userRepository.create({
      email: email.toLowerCase(),
      passwordHash,
      name,
      preferences: preferences || {},
    });

    const savedUser = await this.userRepository.save(newUser);
    const { passwordHash: _, ...userWithoutPassword } = savedUser;
    return userWithoutPassword;
  }

  async findById(id: string): Promise<Omit<User, 'passwordHash'>> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('User profile not found');
    }
    const { passwordHash: _, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  async updateProfile(id: string, updateDto: { name?: string; preferences?: Record<string, any> }): Promise<Omit<User, 'passwordHash'>> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('User profile not found');
    }

    if (updateDto.name !== undefined) user.name = updateDto.name;
    if (updateDto.preferences !== undefined) {
      user.preferences = { ...user.preferences, ...updateDto.preferences };
    }

    const updatedUser = await this.userRepository.save(user);
    const { passwordHash: _, ...userWithoutPassword } = updatedUser;
    return userWithoutPassword;
  }
}
