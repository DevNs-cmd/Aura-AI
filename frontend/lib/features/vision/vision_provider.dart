import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisionState {
  final String? imagePath; // URL or name representing image
  final bool isScanning;
  final bool showResults;
  final List<Map<String, dynamic>> detectedObjects;
  final String? ocrText;
  final bool isLoading;

  VisionState({
    this.imagePath,
    this.isScanning = false,
    this.showResults = false,
    this.detectedObjects = const [],
    this.ocrText,
    this.isLoading = false,
  });

  VisionState copyWith({
    String? imagePath,
    bool? isScanning,
    bool? showResults,
    List<Map<String, dynamic>>? detectedObjects,
    String? ocrText,
    bool? isLoading,
  }) {
    return VisionState(
      imagePath: imagePath ?? this.imagePath,
      isScanning: isScanning ?? this.isScanning,
      showResults: showResults ?? this.showResults,
      detectedObjects: detectedObjects ?? this.detectedObjects,
      ocrText: ocrText ?? this.ocrText,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VisionNotifier extends StateNotifier<VisionState> {
  VisionNotifier() : super(VisionState());

  void selectImage(String source) {
    state = VisionState(
      imagePath: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=600&fit=crop',
      isScanning: true,
      showResults: false,
      detectedObjects: const [],
      ocrText: null,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      state = state.copyWith(
        isScanning: false,
        showResults: true,
        detectedObjects: [
          {'name': 'Laptop', 'confidence': 0.98},
          {'name': 'Keyboard', 'confidence': 0.95},
          {'name': 'Coffee Mug', 'confidence': 0.89},
        ],
        ocrText:
            'PLAN:\n- Launch v1.0 by Friday morning!\n- Schedule Team Sync at 10 AM\n- Buy coffee beans',
      );
    });
  }

  void setImage(String path) {
    state = VisionState(
      imagePath: path,
      isScanning: false,
      showResults: false,
      detectedObjects: const [],
      ocrText: null,
    );
  }

  void startScan() {
    state = state.copyWith(
      isScanning: true,
      showResults: false,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      state = state.copyWith(
        isScanning: false,
        showResults: true,
        detectedObjects: [
          {'name': 'Laptop', 'confidence': 0.98},
          {'name': 'Keyboard', 'confidence': 0.95},
          {'name': 'Coffee Mug', 'confidence': 0.89},
        ],
        ocrText:
            'PLAN:\n- Launch v1.0 by Friday morning!\n- Schedule Team Sync at 10 AM\n- Buy coffee beans',
      );
    });
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
