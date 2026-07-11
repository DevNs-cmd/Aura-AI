import { Injectable, ConflictException, UnauthorizedException, BadRequestException, NotFoundException } from '@nestjs/common';
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

    // Generate a secure 6-character numeric OTP or short hex token
    const token = Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit OTP
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + 15); // Expire in 15 minutes

    await this.userService.updateResetToken(email, token, expiry);

    // In a production backend, this is where you would call an email service (e.g. SendGrid, SES)
    // to send the reset link/OTP. For this backend, we return it in the response for sandbox usability.
    return {
      message: 'Password reset OTP generated successfully. An email would be sent in production.',
      resetToken: token, // Returned for easy API playtesting
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
}
