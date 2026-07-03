import { Injectable, Logger, InternalServerErrorException, BadRequestException } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor() {
    this.initializeFirebase();
  }

  private initializeFirebase(): void {
    if (admin.apps.length === 0) {
      try {
        admin.initializeApp({
          credential: admin.credential.applicationDefault(),
        });
        this.logger.log('Firebase Admin SDK successfully initialized.');
      } catch (error: any) {
        this.logger.warn('Firebase fallback mode enabled/sandbox active: ' + error.message);
      }
    }
  }

  async sendPushNotification(fcmToken: string, title: string, body: string): Promise<string> {
    if (!fcmToken || !title || !body) {
      throw new BadRequestException('FCM token, title, and body are required.');
    }

    const payload: admin.messaging.Message = {
      token: fcmToken,
      notification: { title, body },
      android: {
        priority: 'high',
        notification: { sound: 'default', clickAction: 'FLUTTER_NOTIFICATION_CLICK' },
      },
      apns: { payload: { aps: { badge: 1, sound: 'default' } } },
    };

    try {
      return await admin.messaging().send(payload);
    } catch (error: any) {
      throw new InternalServerErrorException(`FCM deliver failure: ${error.message}`);
    }
  }
}
