import { DocumentService, ProcessedDocument } from './document.service';
export declare class DocumentController {
    private readonly documentService;
    constructor(documentService: DocumentService);
    uploadDocument(payload: {
        userId: string;
        name: string;
        type: string;
        size?: string;
    }): Promise<{
        success: boolean;
        document: ProcessedDocument;
    }>;
    getDocuments(userId: string): Promise<{
        success: boolean;
        documents: ProcessedDocument[];
    }>;
}
