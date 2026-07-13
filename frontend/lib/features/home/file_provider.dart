import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  FileState({required this.files});

  FileState copyWith({List<UploadedFile>? files}) {
    return FileState(files: files ?? this.files);
  }
}

class FileNotifier extends StateNotifier<FileState> {
  FileNotifier() : super(_initialState());

  static FileState _initialState() {
    return FileState(
      files: [
        UploadedFile(id: '1', name: 'Project Roadmap.pdf', size: '2.4 MB', type: 'PDF'),
        UploadedFile(id: '2', name: 'Flutter Guide.docx', size: '1.1 MB', type: 'DOCX'),
        UploadedFile(id: '3', name: 'Notes.txt', size: '320 KB', type: 'TXT'),
        UploadedFile(id: '4', name: 'Design Ideas.pdf', size: '1.8 MB', type: 'PDF'),
      ],
    );
  }

  void addFile(UploadedFile file) {
    state = state.copyWith(files: [...state.files, file]);
    if (file.isUploading) {
      _startUploadSimulation(file.id);
    }
  }

  void removeFile(String id) {
    state = state.copyWith(
      files: state.files.where((f) => f.id != id).toList(),
    );
  }

  void removeMultipleFiles(List<String> ids) {
    state = state.copyWith(
      files: state.files.where((f) => !ids.contains(f.id)).toList(),
    );
  }

  void _startUploadSimulation(String id) {
    double progress = 0.0;
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      final fileIndex = state.files.indexWhere((f) => f.id == id);
      if (fileIndex == -1) {
        timer.cancel();
        return;
      }

      progress += 0.15;
      if (progress >= 1.0) {
        progress = 1.0;
        timer.cancel();
        state = state.copyWith(
          files: state.files.map((f) {
            if (f.id == id) {
              return f.copyWith(uploadProgress: 1.0, isUploading: false);
            }
            return f;
          }).toList(),
        );
      } else {
        state = state.copyWith(
          files: state.files.map((f) {
            if (f.id == id) {
              return f.copyWith(uploadProgress: progress);
            }
            return f;
          }).toList(),
        );
      }
    });
  }
}

final fileProvider = StateNotifierProvider<FileNotifier, FileState>((ref) {
  return FileNotifier();
});
