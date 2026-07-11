import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../models/memory.dart';
import '../memory_provider.dart';

class CreateMemoryScreen extends ConsumerStatefulWidget {
  const CreateMemoryScreen({super.key});

  @override
  ConsumerState<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends ConsumerState<CreateMemoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  MemoryCategory _selectedCategory = MemoryCategory.personal;
  String _selectedImportance = 'high';
  bool _isPinned = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveMemory() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(memoryProvider.notifier)
          .createMemory(
            _titleController.text.trim(),
            _descriptionController.text.trim(),
            _selectedCategory,
            _selectedImportance,
            _isPinned,
          );
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoryState = ref.watch(memoryProvider);

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
          'Add Memory Fact',
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
                // Category Selector
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: MemoryCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    String label =
                        cat.name[0].toUpperCase() + cat.name.substring(1);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: AppColors.lightCardBorder,
                                    width: 1,
                                  ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Memory Title
                CustomTextField(
                  label: 'Fact Title',
                  hintText: 'e.g. Favorite Coffee Order',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description Input
                Text(
                  'Description Details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Details are required';
                    }
                    return null;
                  },
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightTextPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What should Aura remember about you?',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.lightCardBorder,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.lightCardBorder,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Importance selector
                Text(
                  'Importance Level',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['low', 'medium', 'high'].map((imp) {
                    final isSelected = _selectedImportance == imp;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImportance = imp;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF59E0B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: AppColors.lightCardBorder,
                                    width: 1,
                                  ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            imp.toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Pin Fact toggle switch
                SwitchListTile(
                  title: const Text(
                    'Pin Fact to Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                      fontSize: 14,
                    ),
                  ),
                  value: _isPinned,
                  onChanged: (val) {
                    setState(() {
                      _isPinned = val;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 36),

                // Save Button
                PrimaryButton(
                  text: 'Save Memory Fact',
                  isLoading: memoryState.isLoading,
                  onPressed: _saveMemory,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
