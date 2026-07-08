import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class JournalMoodItem {
  final String label;
  final String emoji;
  const JournalMoodItem({required this.label, required this.emoji});
}

class JournalMoodSelector extends StatefulWidget {
  final ValueChanged<String>? onMoodSelected;
  const JournalMoodSelector({super.key, this.onMoodSelected});

  @override
  State<JournalMoodSelector> createState() => _JournalMoodSelectorState();
}

class _JournalMoodSelectorState extends State<JournalMoodSelector> {
  int _selectedIndex = 1; // Default to 'Good' as in the UI reference

  final List<JournalMoodItem> _moods = const [
    JournalMoodItem(label: 'Great', emoji: '🤩'),
    JournalMoodItem(label: 'Good', emoji: '😊'),
    JournalMoodItem(label: 'Okay', emoji: '😐'),
    JournalMoodItem(label: 'Sad', emoji: '😔'),
  ];

  String _getLocalMoodLabel(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context)!;
    switch (label) {
      case 'Great':
        return l10n.emotionGreat;
      case 'Good':
        return l10n.emotionGood;
      case 'Okay':
        return l10n.emotionOkay;
      case 'Sad':
        return l10n.emotionSad;
      default:
        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.journalFeelingQuestion,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_moods.length, (index) {
            final isSelected = _selectedIndex == index;
            final mood = _moods[index];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onMoodSelected?.call(mood.label);
              },
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 86,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: AppColors.lightCardBorder,
                              width: 1,
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 8),
                        Text(
                          _getLocalMoodLabel(context, mood.label),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
