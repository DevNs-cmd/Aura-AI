import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/localized_button.dart';
import '../goals_provider.dart';
import 'widgets/productivity_chart.dart';
import 'widgets/category_focus_chart.dart';
import 'widgets/goal_tile.dart';
import 'goal_detail_screen.dart';
import 'create_goal_screen.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final String _statusFilter = 'All';
  final String _categoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final goalsState = ref.watch(goalsProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    // Filter Logic
    final filteredGoals = goalsState.goals.where((g) {
      if (_statusFilter == 'Active' && g.isCompleted) return false;
      if (_statusFilter == 'Completed' && !g.isCompleted) return false;
      if (_categoryFilter != 'All' && g.category != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.background
                : AppColors.lightBackground),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Goals',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics title block from design system
              Center(
                child: Column(
                  children: [
                    Text(
                      "You're making great progress!",
                      style: GoogleFonts.quicksand(
                        color: isDark
                            ? Colors.white60
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Productivity Score Chart
              const ProductivityChart(),
              const SizedBox(height: 24),

              // Goals List view containing large styled progress cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredGoals.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final goal = filteredGoals[index];
                  return GoalTile(
                    goal: goal,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GoalDetailScreen(goal: goal),
                        ),
                      );
                    },
                    onIncrement: () {
                      ref
                          .read(goalsProvider.notifier)
                          .setProgress(
                            goal.id,
                            (goal.progress + 0.1).clamp(0.0, 1.0),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Goal progress updated!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 28),

              // Friendly statistics row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(
                    context,
                    isDark,
                    accentColor,
                    themeState,
                    title: 'Completed',
                    value: '24',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    isDark,
                    accentColor,
                    themeState,
                    title: 'Focus Time',
                    value: '32h',
                    icon: Icons.timer_outlined,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    isDark,
                    accentColor,
                    themeState,
                    title: 'Streak',
                    value: '12d',
                    icon: Icons.local_fire_department_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Category Focus Chart
              const CategoryFocusChart(),
              const SizedBox(height: 100), // padding for wide floating CTA
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LocalizedButton(
          text: '+ Add New Goal',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateGoalScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark,
    Color accentColor,
    ThemeState themeState, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1C24)
              : (themeState.hasMoodSelected
                    ? themeState.moodTheme.cardColor
                    : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2C2834)
                : (themeState.hasMoodSelected
                      ? themeState.moodTheme.cardBorder
                      : AppColors.lightCardBorder),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
