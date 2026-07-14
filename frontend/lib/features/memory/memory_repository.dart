import 'dart:async';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../models/memory.dart';

abstract class MemoryRepository {
  Future<List<Memory>> getMemories();
  Future<Memory> addMemory(
    String title,
    String description,
    MemoryCategory category,
    String importance,
    bool isPinned,
  );
  Future<void> deleteMemory(String id);
  Future<void> togglePin(String id);
}

class HttpMemoryRepository implements MemoryRepository {
  HttpMemoryRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  @override
  Future<List<Memory>> getMemories() async {
    final response = await _dio.get<dynamic>('/memory');
    final data = response.data;
    if (data is! List) throw const FormatException('Unexpected memory response shape.');
    return data
        .whereType<Map<String, dynamic>>()
        .map(_fromApi)
        .toList(growable: false);
  }

  @override
  Future<Memory> addMemory(
    String title,
    String description,
    MemoryCategory category,
    String importance,
    bool isPinned,
  ) async {
    final fact = title.trim().isEmpty ? description : '$title: $description';
    final response = await _dio.post<dynamic>(
      '/memory',
      data: {
        'category': category.name,
        'fact': fact,
        'importance': _importanceToNumber(importance),
      },
    );
    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected memory response shape.');
    }
    return _fromApi(response.data as Map<String, dynamic>, isPinned: isPinned);
  }

  @override
  Future<void> deleteMemory(String id) async {
    await _dio.delete<dynamic>('/memory/$id');
  }

  @override
  Future<void> togglePin(String id) {
    throw UnsupportedError('Memory pinning is not supported by the backend.');
  }

  Memory _fromApi(Map<String, dynamic> value, {bool isPinned = false}) {
    final fact = value['fact']?.toString() ?? '';
    final separator = fact.indexOf(': ');
    final category = MemoryCategory.values.firstWhere(
      (item) => item.name == value['category']?.toString(),
      orElse: () => MemoryCategory.fact,
    );
    return Memory(
      id: value['id']?.toString() ?? '',
      title: separator > 0 ? fact.substring(0, separator) : 'Memory',
      description: separator > 0 ? fact.substring(separator + 2) : fact,
      storedAt: DateTime.tryParse(value['createdAt']?.toString() ?? '') ?? DateTime.now(),
      category: category,
      importance: _numberToImportance(value['importance']),
      isPinned: isPinned,
    );
  }

  int _importanceToNumber(String value) => switch (value) {
        'high' => 5,
        'low' => 1,
        _ => 3,
      };

  String _numberToImportance(dynamic value) {
    final score = value is num ? value : int.tryParse(value?.toString() ?? '') ?? 3;
    return score >= 4 ? 'high' : score <= 2 ? 'low' : 'medium';
  }
}

class MockMemoryRepository implements MemoryRepository {
  final List<Memory> _memories = [
    Memory(
      id: 'mem-1',
      title: 'Favorite Coffee Order',
      description:
          'You prefer a Double Espresso with a dash of oat milk, not too hot.',
      storedAt: DateTime.now().subtract(const Duration(days: 80)),
      category: MemoryCategory.personal,
      importance: 'high',
      isPinned: true,
    ),
    Memory(
      id: 'mem-2',
      title: "Project 'Aegis' Deadline",
      description:
          'The final submission for Project Aegis is due on Friday, Nov 15th at 5 PM EST.',
      storedAt: DateTime.now().subtract(const Duration(days: 2)),
      category: MemoryCategory.work,
      importance: 'high',
      isPinned: false,
    ),
    Memory(
      id: 'mem-3',
      title: 'Interest: Brutalism',
      description:
          'You showed a strong interest in Brutalist architecture design styles and structural concrete aesthetics.',
      storedAt: DateTime.now().subtract(const Duration(days: 90)),
      category: MemoryCategory.personal,
      importance: 'medium',
      isPinned: false,
    ),
  ];

  @override
  Future<List<Memory>> getMemories() async {
    return List.from(_memories);
  }

  @override
  Future<Memory> addMemory(
    String title,
    String description,
    MemoryCategory category,
    String importance,
    bool isPinned,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Latency

    final newMem = Memory(
      id: 'mem-${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? 'Untitled Fact' : title,
      description: description,
      storedAt: DateTime.now(),
      category: category,
      importance: importance,
      isPinned: isPinned,
    );

    _memories.insert(0, newMem);
    return newMem;
  }

  @override
  Future<void> deleteMemory(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _memories.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> togglePin(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _memories.indexWhere((m) => m.id == id);
    if (index != -1) {
      final memory = _memories[index];
      _memories[index] = memory.copyWith(isPinned: !memory.isPinned);
    }
  }
}
