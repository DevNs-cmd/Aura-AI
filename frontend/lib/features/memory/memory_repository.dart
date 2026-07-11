import 'dart:async';
import '../../models/memory.dart';

abstract class MemoryRepository {
  List<Memory> getMemories();
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
  List<Memory> getMemories() {
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
