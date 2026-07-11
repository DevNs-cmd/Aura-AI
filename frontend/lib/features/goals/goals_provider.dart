import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal.dart';
import 'goals_repository.dart';

class GoalsState {
  final List<Goal> goals;
  final bool isLoading;
  final String? errorMessage;

  GoalsState({required this.goals, this.isLoading = false, this.errorMessage});

  GoalsState copyWith({
    List<Goal>? goals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GoalsState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return MockGoalsRepository();
});

class GoalsNotifier extends StateNotifier<GoalsState> {
  final GoalsRepository _repository;

  GoalsNotifier(this._repository)
    : super(GoalsState(goals: _repository.getGoals()));

  Future<void> createGoal(
    String title,
    String category,
    double targetVal,
    String unit,
    String deadline,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newGoal = await _repository.addGoal(
        title,
        category,
        targetVal,
        unit,
        deadline,
      );
      state = state.copyWith(
        goals: [...state.goals, newGoal],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> setProgress(String id, double progress) async {
    try {
      await _repository.updateGoalProgress(id, progress);
      state = state.copyWith(
        goals: state.goals
            .map(
              (g) => g.id == id
                  ? g.copyWith(progress: progress, isCompleted: progress >= 1.0)
                  : g,
            )
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteGoal(String id) async {
    state = state.copyWith(
      goals: state.goals.where((g) => g.id != id).toList(),
    );
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  return GoalsNotifier(repository);
});
