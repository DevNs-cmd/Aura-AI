import '../../core/network/api_client.dart';
import '../../models/memory.dart';

abstract class MemoryRepository {
  Future<List<Memory>> getMemories();
  Future<Memory> addMemory(String title, String description, MemoryCategory category, String importance, bool isPinned);
  Future<void> deleteMemory(String id);
  Future<void> togglePin(String id);
}

class ApiMemoryRepository implements MemoryRepository {
  ApiMemoryRepository(this._client);
  final ApiClient _client;

  Memory _fromJson(Map<String, dynamic> json) {
    final category = MemoryCategory.values.where((c) => c.name == json['category']).firstOrNull ?? MemoryCategory.fact;
    final importance = (json['importance'] as num? ?? 3).toInt();
    return Memory(id: json['id'] as String, title: (json['fact'] as String).split('\n').first,
      description: json['fact'] as String, storedAt: DateTime.parse(json['createdAt'] as String),
      category: category, importance: importance >= 4 ? 'high' : importance <= 2 ? 'low' : 'medium');
  }
  @override Future<List<Memory>> getMemories() async {
    final response = await _client.get<List<dynamic>>('/api/memory');
    return response.data!.map((e) => _fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
  @override Future<Memory> addMemory(String title, String description, MemoryCategory category, String importance, bool isPinned) async {
    final level = importance == 'high' ? 5 : importance == 'low' ? 1 : 3;
    final response = await _client.post<Map<String, dynamic>>('/api/memory', data: {
      'category': category.name, 'fact': title.isEmpty ? description : '$title\n$description', 'importance': level,
    });
    return _fromJson(response.data!);
  }
  @override Future<void> deleteMemory(String id) async => _client.delete('/api/memory/$id');
  @override Future<void> togglePin(String id) => Future.error(UnsupportedError('The production memory API has no pin endpoint.'));
}
