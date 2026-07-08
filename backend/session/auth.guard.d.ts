import { CanActivate, ExecutionContext } from '@nestjs/common';
import { SessionService } from './session.service';
import { UserService } from '../user/user.service';
export declare class AuthGuard implements CanActivate {
    private readonly sessionService;
    private readonly userService;
    constructor(sessionService: SessionService, userService: UserService);
    canActivate(context: ExecutionContext): Promise<boolean>;
    private extractTokenFromHeader;
}
