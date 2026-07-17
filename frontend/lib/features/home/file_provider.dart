import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'documents_repository.dart';

class UploadedFile {
  final String id;
  final String name;
  final String size;
  final String type;
  final double uploadProgress;
  final bool isUploading;
  final bool isError;

  UploadedFile({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    this.uploadProgress = 0.0,
    this.isUploading = false,
    this.isError = false,
  });

  UploadedFile copyWith({
    String? id,
    String? name,
    String? size,
    String? type,
    double? uploadProgress,
    bool? isUploading,
    bool? isError,
  }) {
    return UploadedFile(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      type: type ?? this.type,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isUploading: isUploading ?? this.isUploading,
      isError: isError ?? this.isError,
    );
  }
}

class FileState {
  final List<UploadedFile> files;
  final bool isLoading;
  final bool isUploading;

  FileState({
    required this.files,
    this.isLoading = false,
    this.isUploading = false,
  });

  FileState copyWith({
    List<UploadedFile>? files,
    bool? isLoading,
    bool? isUploading,
  }) {
    return FileState(
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class FileNotifier extends StateNotifier<FileState> {
  FileNotifier({DocumentsRepository? repository})
      : _repository = repository ?? DocumentsRepository(),
        super(FileState(files: [])) {
    // Initial fetch.
    fetchDocuments();
  }

  final DocumentsRepository _repository;

  Future<void> fetchDocuments() async {
    state = state.copyWith(isLoading: true);
    try {
      final docs = await _repository.listDocuments();
      state = state.copyWith(
        isLoading: false,
        files: docs
            .map(
              (d) => UploadedFile(
                id: d.id,
                name: d.filename,
                size: d.sizeBytes == null ? '' : _formatBytes(d.sizeBytes!),
                type: d.fileType.isEmpty ? (d.fileType.isEmpty ? '' : d.fileType) : d.fileType,
              ),
            )
            .toList(),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> uploadFile({
    required File file,
    required String fileName,
    required String contentType,
  }) async {
    state = state.copyWith(isUploading: true);
    try {
      await _repository.uploadDocumentFromFile(
        file: file,
        fileName: fileName,
        contentType: contentType,
      );
      await fetchDocuments();
      state = state.copyWith(isUploading: false);
    } catch (e) {
      state = state.copyWith(isUploading: false);
      rethrow;
    }
  }

  Future<void> uploadFileFromBytes({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    state = state.copyWith(isUploading: true);
    try {
      await _repository.uploadDocumentFromBytes(
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
      );
      await fetchDocuments();
      state = state.copyWith(isUploading: false);
    } catch (e) {
      state = state.copyWith(isUploading: false);
      rethrow;
    }
  }

  void removeFile(String id) {
    // Backend delete endpoint not present in current requirements; keep local-only remove to preserve UI.
    state = state.copyWith(
      files: state.files.where((f) => f.id != id).toList(),
    );
  }

  void removeMultipleFiles(List<String> ids) {
    state = state.copyWith(
      files: state.files.where((f) => !ids.contains(f.id)).toList(),
    );
  }

  String _formatBytes(int bytes) {
    final mb = bytes / 1024 / 1024;
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }
}

final fileProvider = StateNotifierProvider<FileNotifier, FileState>((ref) {
  return FileNotifier();
});


// ---------------------------------------------------------------------------
// RAG query state
// ---------------------------------------------------------------------------

class RagQueryState {
  final bool isLoading;
  final String? answer;
  final String? error;
  final String? question;

  const RagQueryState({
    this.isLoading = false,
    this.answer,
    this.error,
    this.question,
  });

  RagQueryState copyWith({
    bool? isLoading,
    String? answer,
    String? error,
    String? question,
  }) {
    return RagQueryState(
      isLoading: isLoading ?? this.isLoading,
      answer: answer ?? this.answer,
      error: error ?? this.error,
      question: question ?? this.question,
    );
  }
}

class RagQueryNotifier extends StateNotifier<RagQueryState> {
  RagQueryNotifier({DocumentsRepository? repository})
      : _repository = repository ?? DocumentsRepository(),
        super(const RagQueryState());

  final DocumentsRepository _repository;

  Future<void> ask(String question) async {
    state = RagQueryState(isLoading: true, question: question);
    try {
      final result = await _repository.queryDocuments(question);
      state = RagQueryState(
        isLoading: false,
        question: question,
        answer: result.answer,
      );
    } catch (e) {
      state = RagQueryState(
        isLoading: false,
        question: question,
        error: e.toString(),
      );
    }
  }

  void clear() => state = const RagQueryState();
}

final ragQueryProvider =
    StateNotifierProvider<RagQueryNotifier, RagQueryState>((ref) {
  return RagQueryNotifier();
});
