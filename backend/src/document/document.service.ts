import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

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
  constructor(private readonly databaseService: DatabaseService) {}

  async upload(userId: string, filename: string, mimeType: string, size: number): Promise<DocumentItem> {
    const fileUrl = `uploads/${filename}`;
    const result = await this.databaseService.query(
      `
      INSERT INTO documents (user_id, file_name, file_url, file_type, file_size)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, file_name as filename, file_type as "mimeType", file_size as size, created_at as "uploadedAt"
      `,
      [userId, filename, fileUrl, mimeType, size],
    );
    const row = result.rows[0];
    return {
      id: row.id,
      filename: row.filename,
      mimeType: row.mimeType || 'application/octet-stream',
      size: Number(row.size),
      uploadedAt: row.uploadedAt,
      status: 'indexed',
    };
  }

  async findAll(userId: string): Promise<DocumentItem[]> {
    const result = await this.databaseService.query(
      `
      SELECT id, file_name as filename, file_type as "mimeType", file_size as size, created_at as "uploadedAt"
      FROM documents
      WHERE user_id = $1
      ORDER BY created_at DESC
      `,
      [userId],
    );
    return result.rows.map((row) => ({
      id: row.id,
      filename: row.filename,
      mimeType: row.mimeType || 'application/octet-stream',
      size: Number(row.size),
      uploadedAt: row.uploadedAt,
      status: 'indexed',
    }));
  }

  async findOne(userId: string, id: string): Promise<DocumentItem> {
    const result = await this.databaseService.query(
      `
      SELECT id, file_name as filename, file_type as "mimeType", file_size as size, created_at as "uploadedAt"
      FROM documents
      WHERE user_id = $1 AND id = $2
      LIMIT 1
      `,
      [userId, id],
    );
    if (result.rows.length === 0) {
      throw new NotFoundException(`Document with ID ${id} not found.`);
    }
    const row = result.rows[0];
    return {
      id: row.id,
      filename: row.filename,
      mimeType: row.mimeType || 'application/octet-stream',
      size: Number(row.size),
      uploadedAt: row.uploadedAt,
      status: 'indexed',
    };
  }

  async delete(userId: string, id: string): Promise<{ success: boolean; message: string }> {
    const result = await this.databaseService.query(
      `
      DELETE FROM documents
      WHERE user_id = $1 AND id = $2
      `,
      [userId, id],
    );
    if (result.rowCount === 0) {
      throw new NotFoundException(`Document with ID ${id} not found.`);
    }
    return { success: true, message: 'Document deleted and removed from index.' };
  }
}
