import { NotificationService } from './notification.service';
export declare class NotificationController {
    private readonly notificationService;
    constructor(notificationService: NotificationService);
    sendNotification(payload: {
        fcmToken: string;
        title: string;
        body: string;
    }): Promise<{
        success: boolean;
        messageId: string;
        message: string;
    }>;
}
