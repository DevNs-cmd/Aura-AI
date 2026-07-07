import { Injectable, BadRequestException } from '@nestjs/common';

export interface ProcessedDocument {
  id: string;
  name: string;
  type: string; // 'pdf' | 'txt' | 'doc'
  size: string;
  wordCount: number;
  extractedKeypoints: string[];
  uploadedAt: Date;
}

@Injectable()
export class DocumentService {
  // Simple in-memory mock map of processed files by userId
  private userDocuments: Record<string, ProcessedDocument[]> = {
    'e44d7fc5-0720-4df2-817c-61e86052f50f': [
      {
        id: 'doc-1',
        name: 'deepmind_workspace_summary.pdf',
        type: 'pdf',
        size: '1.4 MB',
        wordCount: 2450,
        extractedKeypoints: [
          'Agile sprint alignment scheduled for Q3',
          'Primary compute resources localized in central-1 region',
          'Token safety boundaries require server-side proxy headers'
        ],
        uploadedAt: new Date(Date.now() - 172800000)
      }
    ]
  };

  /**
   * Processes a newly uploaded document, performing mock keypoint extraction.
   */
  async processDocument(userId: string, name: string, type: string, size: string): Promise<ProcessedDocument> {
    if (!userId || !name || !type) {
      throw new BadRequestException('userId, document name, and document type are required');
    }

    if (!this.userDocuments[userId]) {
      this.userDocuments[userId] = [];
    }

    // Dynamic mock keypoints based on filename
    const mockKeypoints = [
      `Context file "${name}" was successfully vectorized.`,
      `Extracted entity tags matching mobile performance clusters.`,
      `Verified security boundaries of standard file configurations.`
    ];

    const newDoc: ProcessedDocument = {
      id: `doc-${Date.now()}`,
      name,
      type: type.toLowerCase(),
      size: size || '120 KB',
      wordCount: Math.floor(Math.random() * 3000) + 200,
      extractedKeypoints: mockKeypoints,
      uploadedAt: new Date()
    };

    this.userDocuments[userId].push(newDoc);
    return newDoc;
  }

  /**
   * Returns complete catalog of processed vectors/documents for a specific user ID.
   */
  async getDocumentsByUserId(userId: string): Promise<ProcessedDocument[]> {
    if (!userId) {
      throw new BadRequestException('userId is required');
    }
    return this.userDocuments[userId] || [];
  }
}
