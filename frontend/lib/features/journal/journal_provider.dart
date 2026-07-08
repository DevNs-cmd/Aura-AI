import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/journal_entry.dart';
import 'journal_repository.dart';

class JournalState {
  final List<JournalEntry> entries;
  final bool isLoading;
  final String? errorMessage;

  JournalState({
    required this.entries,
    this.isLoading = false,
    this.errorMessage,
  });

  JournalState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
    String? errorMessage,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return MockJournalRepository();
});

class JournalNotifier extends StateNotifier<JournalState> {
  final JournalRepository _repository;

  JournalNotifier(this._repository)
    : super(JournalState(entries: _repository.getEntries()));

  Future<void> createEntry(String title, String body, String mood) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newEntry = await _repository.addEntry(title, body, mood);
      state = state.copyWith(
        entries: [newEntry, ...state.entries],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, JournalState>((
  ref,
) {
  final repository = ref.watch(journalRepositoryProvider);
  return JournalNotifier(repository);
});
