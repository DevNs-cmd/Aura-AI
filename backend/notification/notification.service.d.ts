export declare class NotificationService {
    private readonly logger;
    constructor();
    private initializeFirebase;
    sendPushNotification(fcmToken: string, title: string, body: string): Promise<string>;
}
