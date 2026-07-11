import { Injectable, NotFoundException } from '@nestjs/common';

export interface DocumentItem {
  id: string;
  filename: string;
  mimeType: string;
  size: number;
  uploadedAt: Date;
  status: 'processing' | 'indexed' | 'failed';
}

@Injectable()
export class DocumentService {
  private documents: DocumentItem[] = [];

  async upload(filename: string, mimeType: string, size: number): Promise<DocumentItem> {
    const doc: DocumentItem = {
      id: `doc_${Math.random().toString(36).substring(2, 9)}`,
      filename,
      mimeType,
      size,
      uploadedAt: new Date(),
      status: 'processing',
    };
    this.documents.push(doc);

    // Simulate vector parsing and indexing in the background
    setTimeout(() => {
      doc.status = 'indexed';
    }, 5000);

    return doc;
  }

  async findAll(): Promise<DocumentItem[]> {
    return this.documents;
  }

  async findOne(id: string): Promise<DocumentItem> {
    const doc = this.documents.find((d) => d.id === id);
    if (!doc) {
      throw new NotFoundException(`Document with ID ${id} not found.`);
    }
    return doc;
  }

  async delete(id: string): Promise<{ success: boolean; message: string }> {
    const index = this.documents.findIndex((d) => d.id === id);
    if (index === -1) {
      throw new NotFoundException(`Document with ID ${id} not found.`);
    }
    this.documents.splice(index, 1);
    return { success: true, message: 'Document deleted and removed from index.' };
  }
}
