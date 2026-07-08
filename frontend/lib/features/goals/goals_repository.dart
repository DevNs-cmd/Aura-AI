import 'dart:async';
import '../../models/goal.dart';

abstract class GoalsRepository {
  List<Goal> getGoals();
  Future<Goal> addGoal(
    String title,
    String category,
    double targetVal,
    String unit,
    String deadline,
  );
  Future<void> updateGoalProgress(String id, double newProgress);
}

class MockGoalsRepository implements GoalsRepository {
  final List<Goal> _goals = [
    const Goal(
      id: 'goal-1',
      title: 'Morning Yoga Routine',
      category: 'Health',
      progress: 0.75,
      statusText: '15 of 20 sessions',
      deadline: 'Oct 30',
    ),
    const Goal(
      id: 'goal-2',
      title: 'Master Flutter DSL',
      category: 'Learning',
      progress: 0.40,
      statusText: '8 of 20 modules',
      deadline: 'Nov 12',
    ),
    const Goal(
      id: 'goal-3',
      title: 'Q4 Strategy Deck',
      category: 'Work',
      progress: 0.90,
      statusText: 'Almost there!',
      deadline: 'Oct 25',
    ),
  ];

  @override
  List<Goal> getGoals() {
    return List.from(_goals);
  }

  @override
  Future<Goal> addGoal(
    String title,
    String category,
    double targetVal,
    String unit,
    String deadline,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 1000),
    ); // Simulated network latency

    final newGoal = Goal(
      id: 'goal-${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? 'New Goal' : title,
      category: category,
      progress: 0.0,
      statusText: '0 of ${targetVal.toInt()} $unit',
      deadline: deadline.isEmpty ? 'Dec 31' : deadline,
    );

    _goals.add(newGoal);
    return newGoal;
  }

  @override
  Future<void> updateGoalProgress(String id, double newProgress) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = goal.copyWith(
        progress: newProgress,
        isCompleted: newProgress >= 1.0,
      );
    }
  }
}
