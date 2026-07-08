import { UserService } from './user.service';
import { User } from './user.entity';
export declare class UserController {
    private readonly userService;
    constructor(userService: UserService);
    register(registerDto: {
        email: string;
        password?: string;
        name: string;
        preferences?: Record<string, any>;
    }): Promise<Omit<User, "passwordHash">>;
    getProfile(req: any): Promise<Omit<User, "passwordHash">>;
    updateProfile(req: any, updateDto: {
        name?: string;
        preferences?: Record<string, any>;
    }): Promise<Omit<User, "passwordHash">>;
}
