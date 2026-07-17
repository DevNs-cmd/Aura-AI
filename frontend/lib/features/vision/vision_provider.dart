import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_client.dart';

class VisionState {
  final String? imagePath; // URL or name representing image
  final bool isScanning;
  final bool showResults;
  final List<Map<String, dynamic>> detectedObjects;
  final String? ocrText;
  final String? scene;
  final String? context;
  final bool isLoading;

  VisionState({
    this.imagePath,
    this.isScanning = false,
    this.showResults = false,
    this.detectedObjects = const [],
    this.ocrText,
    this.scene,
    this.context,
    this.isLoading = false,
  });

  VisionState copyWith({
    String? imagePath,
    bool? isScanning,
    bool? showResults,
    List<Map<String, dynamic>>? detectedObjects,
    String? ocrText,
    String? scene,
    String? context,
    bool? isLoading,
  }) {
    return VisionState(
      imagePath: imagePath ?? this.imagePath,
      isScanning: isScanning ?? this.isScanning,
      showResults: showResults ?? this.showResults,
      detectedObjects: detectedObjects ?? this.detectedObjects,
      ocrText: ocrText ?? this.ocrText,
      scene: scene ?? this.scene,
      context: context ?? this.context,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VisionNotifier extends StateNotifier<VisionState> {
  VisionNotifier() : super(VisionState());

  Future<void> selectImage(String source) async {
    try {
      final picker = ImagePicker();
      final XFile? picked;
      if (source == 'camera') {
        picked = await picker.pickImage(source: ImageSource.camera);
      } else {
        picked = await picker.pickImage(source: ImageSource.gallery);
      }
      if (picked != null) {
        setImage(picked.path);
        await startScan();
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        showResults: true,
        ocrText: 'Failed to pick image: $e',
      );
    }
  }

  void setImage(String path) {
    state = VisionState(
      imagePath: path,
      isScanning: false,
      showResults: false,
      detectedObjects: const [],
      ocrText: null,
      scene: null,
      context: null,
    );
  }

  Future<void> startScan() async {
    if (state.imagePath == null) return;

    state = state.copyWith(
      isScanning: true,
      showResults: false,
    );

    try {
      List<int> bytes;
      if (state.imagePath!.startsWith('http') || state.imagePath!.startsWith('blob')) {
        final response = await Dio().get<List<int>>(
          state.imagePath!,
          options: Options(responseType: ResponseType.bytes),
        );
        bytes = response.data!;
      } else {
        final file = File(state.imagePath!);
        if (!await file.exists()) {
          throw Exception('Image file not found locally');
        }
        bytes = await file.readAsBytes();
      }

      final base64Image = base64Encode(bytes);
      final dio = ApiClient().dio;
      final response = await dio.post<dynamic>(
        '/vision/analyze',
        data: {'image': base64Image},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response format from server.');
      }

      final ocrText = data['ocr_text']?.toString() ?? '';
      final rawObjects = data['detected_objects'] as List<dynamic>? ?? [];
      final detectedObjects = rawObjects.map((item) {
        if (item is Map) {
          return {
            'name': item['name']?.toString() ?? 'Unknown',
            'confidence': (item['confidence'] as num?)?.toDouble() ?? 0.0,
          };
        }
        return {'name': 'Unknown', 'confidence': 0.0};
      }).toList();
      final scene = data['scene']?.toString() ?? '';
      final contextText = data['context']?.toString() ?? '';

      if (!mounted) return;
      state = state.copyWith(
        isScanning: false,
        showResults: true,
        detectedObjects: detectedObjects,
        ocrText: ocrText.isNotEmpty ? ocrText : 'No text detected.',
        scene: scene,
        context: contextText,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isScanning: false,
        showResults: true,
        detectedObjects: [
          {'name': 'Scan Failed', 'confidence': 0.0}
        ],
        ocrText: 'Failed to analyze image: $e',
        scene: 'Scan failed to describe the scene.',
        context: 'Scan failed to analyze context.',
      );
    }
  }

  void clearImage() {
    state = VisionState();
  }
}

final visionProvider = StateNotifierProvider<VisionNotifier, VisionState>((
  ref,
) {
  return VisionNotifier();
});
