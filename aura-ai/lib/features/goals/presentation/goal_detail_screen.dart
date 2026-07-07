import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../models/goal.dart';
import '../goals_provider.dart';

class GoalDetailScreen extends ConsumerWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Milestones list mockups
    final List<Map<String, dynamic>> milestones = [
      {'title': 'Establish baseline sessions', 'completed': true},
      {'title': 'Maintain a 5-day session streak', 'completed': true},
      {'title': 'Log 15 sessions in total', 'completed': goal.progress >= 0.75},
      {
        'title': 'Reach final target (20 sessions)',
        'completed': goal.progress >= 1.0,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.lightTextPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Goal Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Goal'),
                  content: const Text(
                    'Are you sure you want to delete this goal? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Goal deleted')),
                        );
                        context.pop();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Core Progress Card displaying circular progress
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.lightCardBorder,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      goal.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      goal.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightTextPrimary,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Circular Progress Ring Indicator
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: goal.progress,
                              strokeWidth: 10,
                              backgroundColor: AppColors.lightBackground,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            '${(goal.progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      goal.statusText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Milestones Section
              Text(
                'Milestones',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.lightCardBorder,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: milestones.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: AppColors.lightCardBorder,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = milestones[index];
                    final bool done = item['completed'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            done
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_off_rounded,
                            color: done
                                ? AppColors.success
                                : AppColors.lightTextTertiary,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: done
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                color: done
                                    ? AppColors.lightTextPrimary
                                    : AppColors.lightTextSecondary,
                                decoration: done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),

              // Simulated Progress Incrementor Button
              if (goal.progress < 1.0)
                PrimaryButton(
                  text: 'Log Session Progress',
                  onPressed: () {
                    final newProg = (goal.progress + 0.1).clamp(0.0, 1.0);
                    ref
                        .read(goalsProvider.notifier)
                        .setProgress(goal.id, newProg);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goal progress updated!')),
                    );
                    context.pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
