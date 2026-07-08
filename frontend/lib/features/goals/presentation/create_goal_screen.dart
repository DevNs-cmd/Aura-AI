import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../goals_provider.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetValueController = TextEditingController(text: '10');
  final _unitController = TextEditingController(text: 'sessions');
  final _deadlineController = TextEditingController(text: 'Dec 31');

  String _selectedCategory = 'Health';
  final List<String> _categories = const ['Health', 'Work', 'Learning'];

  @override
  void dispose() {
    _titleController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final double targetVal =
          double.tryParse(_targetValueController.text) ?? 10.0;
      await ref
          .read(goalsProvider.notifier)
          .createGoal(
            _titleController.text.trim(),
            _selectedCategory,
            targetVal,
            _unitController.text.trim(),
            _deadlineController.text.trim(),
          );
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsState = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.lightTextPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New Goal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Picker
                Text(
                  'Category Focus',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: AppColors.lightCardBorder,
                                    width: 1,
                                  ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Goal Title
                CustomTextField(
                  label: 'Goal Title',
                  hintText: 'e.g. Master Flutter DSL',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Target Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Target Goal Value',
                        hintText: '10',
                        controller: _targetValueController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null) {
                            return 'Enter a number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Unit of Measure',
                        hintText: 'sessions',
                        controller: _unitController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unit is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Target Date
                CustomTextField(
                  label: 'Target Date / Deadline',
                  hintText: 'e.g. Oct 30',
                  controller: _deadlineController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A target date is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Save Goal Button
                PrimaryButton(
                  text: 'Save Goal',
                  isLoading: goalsState.isLoading,
                  onPressed: _saveGoal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
