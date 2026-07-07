import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../journal_provider.dart';

class CreateJournalScreen extends ConsumerStatefulWidget {
  final String? initialText;
  const CreateJournalScreen({super.key, this.initialText});

  @override
  ConsumerState<CreateJournalScreen> createState() =>
      _CreateJournalScreenState();
}

class _CreateJournalScreenState extends ConsumerState<CreateJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late final _bodyController = TextEditingController(text: widget.initialText);
  String _selectedMood = 'Happy';

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(journalProvider.notifier)
          .createEntry(
            _titleController.text.trim(),
            _bodyController.text.trim(),
            _selectedMood,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  String _getLocalMoodName(BuildContext context, String mood) {
    switch (mood) {
      case 'Happy':
        return AppLocalizations.of(context)!.emotionHappy;
      case 'Sad':
        return AppLocalizations.of(context)!.emotionSad;
      case 'Calm':
        return AppLocalizations.of(context)!.emotionCalm;
      case 'Anxious':
        return AppLocalizations.of(context)!.emotionAnxious;
      default:
        return mood;
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.background
                : AppColors.background),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? Colors.white : AppColors.text,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.journalNewEntryTitle,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.text,
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
                // Mood Selection Row Cards
                Text(
                  AppLocalizations.of(context)!.journalFeelingQuestion,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMoodButton(
                      'Happy',
                      '😊',
                      AppColors.primary,
                      isDark,
                      themeState,
                    ),
                    _buildMoodButton(
                      'Sad',
                      '😔',
                      const Color(0xFFA58BFF),
                      isDark,
                      themeState,
                    ),
                    _buildMoodButton(
                      'Calm',
                      '☁️',
                      AppColors.success,
                      isDark,
                      themeState,
                    ),
                    _buildMoodButton(
                      'Anxious',
                      '😨',
                      const Color(0xFF6B7280),
                      isDark,
                      themeState,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Title Input
                CustomTextField(
                  label: AppLocalizations.of(context)!.journalTitleLabel,
                  hintText: AppLocalizations.of(context)!.journalTitleHint,
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.journalTitleError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Body Input
                Text(
                  AppLocalizations.of(context)!.journalThoughtsLabel,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.journalThoughtsError;
                    }
                    return null;
                  },
                  style: GoogleFonts.quicksand(
                    color: isDark ? Colors.white : AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.journalThoughtsHint,
                    hintStyle: GoogleFonts.quicksand(
                      color: isDark ? Colors.white30 : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E1C24)
                        : (themeState.hasMoodSelected
                              ? themeState.moodTheme.cardColor
                              : Colors.white),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF2C2834)
                            : (themeState.hasMoodSelected
                                  ? themeState.moodTheme.cardBorder
                                  : AppColors.lightCardBorder),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF2C2834)
                            : (themeState.hasMoodSelected
                                  ? themeState.moodTheme.cardBorder
                                  : AppColors.lightCardBorder),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: themeState.accentColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Save Button
                PrimaryButton(
                  text: AppLocalizations.of(context)!.journalSaveEntryBtn,
                  isLoading: journalState.isLoading,
                  onPressed: _saveEntry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodButton(
    String mood,
    String emoji,
    Color color,
    bool isDark,
    ThemeState themeState,
  ) {
    final isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark
                    ? const Color(0xFF1E1C24)
                    : (themeState.hasMoodSelected
                          ? themeState.moodTheme.cardColor
                          : Colors.white)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                      ? const Color(0xFF2C2834)
                      : (themeState.hasMoodSelected
                            ? themeState.moodTheme.cardBorder
                            : AppColors.lightCardBorder)),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              _getLocalMoodName(context, mood),
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
