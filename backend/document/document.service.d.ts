export interface ProcessedDocument {
    id: string;
    name: string;
    type: string;
    size: string;
    wordCount: number;
    extractedKeypoints: string[];
    uploadedAt: Date;
}
export declare class DocumentService {
    private userDocuments;
    processDocument(userId: string, name: string, type: string, size: string): Promise<ProcessedDocument>;
    getDocumentsByUserId(userId: string): Promise<ProcessedDocument[]>;
}
