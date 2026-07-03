import { Module, forwardRef } from '@nestjs/common';
import { SessionService } from './session.service';
import { AuthGuard } from './auth.guard';
import { UserModule } from '../user/user.module';

@Module({
  imports: [forwardRef(() => UserModule)],
  providers: [SessionService, AuthGuard],
  exports: [SessionService, AuthGuard],
})
export class SessionModule {}
