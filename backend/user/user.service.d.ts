import { Repository } from 'typeorm';
import { User } from './user.entity';
export declare class UserService {
    private readonly userRepository;
    constructor(userRepository: Repository<User>);
    register(registerDto: {
        email: string;
        password?: string;
        name: string;
        preferences?: Record<string, any>;
    }): Promise<Omit<User, 'passwordHash'>>;
    findById(id: string): Promise<Omit<User, 'passwordHash'>>;
    updateProfile(id: string, updateDto: {
        name?: string;
        preferences?: Record<string, any>;
    }): Promise<Omit<User, 'passwordHash'>>;
}
