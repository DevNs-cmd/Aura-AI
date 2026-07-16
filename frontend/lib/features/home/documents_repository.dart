import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';

class DocumentListItem {
  final String id;
  final String filename;
  final String fileType;
  final int? sizeBytes;
  final String status;

  DocumentListItem({
    required this.id,
    required this.filename,
    required this.fileType,
    this.sizeBytes,
    required this.status,
  });

  factory DocumentListItem.fromJson(Map<String, dynamic> json) {
    return DocumentListItem(
      id: (json['id'] ?? '').toString(),
      filename: (json['filename'] ?? '').toString(),
      fileType: (json['file_type'] ?? json['fileType'] ?? '').toString(),
      sizeBytes: json['size_bytes'] == null
          ? null
          : int.tryParse(json['size_bytes'].toString()),
      status: (json['status'] ?? 'uploaded').toString(),
    );
  }
}

class DocumentsRepository {
  DocumentsRepository({Dio? dio}) : _dio = dio ?? _buildFastapiDio();

  final Dio _dio;

  /// Builds a Dio instance pre-configured for the FastAPI backend.
  /// The auth interceptor from ApiClient is replicated here so the Bearer
  /// token is still forwarded.
  static Dio _buildFastapiDio() {
    return ApiClient(
      dio: Dio(
        BaseOptions(
          baseUrl: ApiConfig.fastapiBaseUrl,
          // Indexing is synchronous and can take 60–90 s.
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 60),
          headers: const {'Content-Type': 'application/json'},
        ),
      ),
    ).dio;
  }

  Future<List<DocumentListItem>> listDocuments() async {
    final res = await _dio.get('/documents');
    final data = res.data;
    if (data is List) {
      return data
          .map((e) => DocumentListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map && data['documents'] is List) {
      return (data['documents'] as List)
          .map((e) => DocumentListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Upload a document from a file path (mobile / desktop).
  Future<DocumentListItem> uploadDocumentFromFile({
    required File file,
    required String fileName,
    required String contentType,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    return _postUpload(form);
  }

  /// Upload a document from raw bytes (web — dart:io File is unavailable).
  Future<DocumentListItem> uploadDocumentFromBytes({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    return _postUpload(form);
  }

  Future<DocumentListItem> _postUpload(FormData form) async {
    final res = await _dio.post(
      '/documents/upload',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return DocumentListItem.fromJson(data);
    }
    throw DioException(requestOptions: res.requestOptions, response: res);
  }
}

class RagQueryResult {
  final String answer;
  final String sessionId;

  RagQueryResult({required this.answer, required this.sessionId});
}

extension DocumentsRepositoryRag on DocumentsRepository {
  /// Ask a question against the user's indexed documents.
  /// Creates a throwaway chat session, sends the message, returns the reply.
  Future<RagQueryResult> queryDocuments(String question) async {
    // 1. Create a session
    final sessionRes = await _dio.post('/chat/sessions');
    final sessionId = (sessionRes.data['id'] ?? '').toString();
    if (sessionId.isEmpty) throw Exception('Failed to create chat session');

    // 2. Send the message
    final msgRes = await _dio.post(
      '/chat/sessions/$sessionId/messages',
      data: {'content': question},
    );
    final answer = (msgRes.data['content'] ?? '').toString();
    return RagQueryResult(answer: answer, sessionId: sessionId);
  }
}
