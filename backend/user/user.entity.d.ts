export declare class User {
    id: string;
    email: string;
    passwordHash: string;
    name: string;
    preferences: Record<string, any>;
    createdAt: Date;
}
