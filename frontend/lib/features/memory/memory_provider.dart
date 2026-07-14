import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_config.dart';
import '../../models/memory.dart';
import 'memory_repository.dart';

class MemoryState {
  final List<Memory> memories;
  final bool isLoading;
  final String? errorMessage;

  MemoryState({
    required this.memories,
    this.isLoading = false,
    this.errorMessage,
  });

  MemoryState copyWith({
    List<Memory>? memories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MemoryState(
      memories: memories ?? this.memories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return ApiConfig.useMockRepositories
      ? MockMemoryRepository()
      : HttpMemoryRepository();
});

class MemoryNotifier extends StateNotifier<MemoryState> {
  final MemoryRepository _repository;

  MemoryNotifier(this._repository) : super(MemoryState(memories: [])) {
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final memories = await _repository.getMemories();
      if (mounted) state = state.copyWith(memories: memories, isLoading: false);
    } catch (error) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: error.toString());
      }
    }
  }

  Future<void> createMemory(
    String title,
    String description,
    MemoryCategory category,
    String importance,
    bool isPinned,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newMem = await _repository.addMemory(
        title,
        description,
        category,
        importance,
        isPinned,
      );
      state = state.copyWith(
        memories: [newMem, ...state.memories],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> togglePinState(String id) async {
    try {
      await _repository.togglePin(id);
      state = state.copyWith(
        memories: state.memories
            .map((m) => m.id == id ? m.copyWith(isPinned: !m.isPinned) : m)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> removeMemory(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteMemory(id);
      state = state.copyWith(
        memories: state.memories.where((m) => m.id != id).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final memoryProvider = StateNotifierProvider<MemoryNotifier, MemoryState>((
  ref,
) {
  final repository = ref.watch(memoryRepositoryProvider);
  return MemoryNotifier(repository);
});
