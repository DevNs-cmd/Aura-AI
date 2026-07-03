import { CanActivate, ExecutionContext, Injectable, UnauthorizedException, Inject, forwardRef } from '@nestjs/common';
import { SessionService } from './session.service';
import { UserService } from '../user/user.service';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly sessionService: SessionService,
    @Inject(forwardRef(() => UserService))
    private readonly userService: UserService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      throw new UnauthorizedException('Authentication token is missing.');
    }

    try {
      const userId = await this.sessionService.validateSession(token);
      if (!userId) {
        throw new UnauthorizedException('Session has expired or token is invalid.');
      }

      const user = await this.userService.findById(userId);
      request['user'] = user;
      request['token'] = token;

      return true;
    } catch (error) {
      if (error instanceof UnauthorizedException) throw error;
      throw new UnauthorizedException('Authentication failed.');
    }
  }

  private extractTokenFromHeader(request: any): string | undefined {
    const authHeader = request.headers.authorization;
    if (!authHeader) return undefined;
    const [type, token] = authHeader.split(' ');
    return type === 'Bearer' ? token : undefined;
  }
}
