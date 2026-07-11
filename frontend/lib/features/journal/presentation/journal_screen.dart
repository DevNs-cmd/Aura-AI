import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/localized_button.dart';
import '../../../../core/widgets/localized_action_row.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../journal_provider.dart';
import 'widgets/writing_prompt_card.dart';
import 'widgets/journal_card.dart';
import 'journal_detail_screen.dart';
import 'create_journal_screen.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  // Filters state
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  bool _isCalendarFilterActive = false;

  // AI Prompts state
  int _currentPromptIndex = 0;

  void _cyclePrompt() {
    setState(() {
      _currentPromptIndex = (_currentPromptIndex + 1) % 6;
    });
  }

  String _getLocalPrompt(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return l10n.journalPrompt1;
      case 1:
        return l10n.journalPrompt2;
      case 2:
        return l10n.journalPrompt3;
      case 3:
        return l10n.journalPrompt4;
      case 4:
        return l10n.journalPrompt5;
      case 5:
        return l10n.journalPrompt6;
      default:
        return '';
    }
  }

  Widget _buildSearchBox(bool isDark, ThemeState themeState) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1C24)
            : (themeState.hasMoodSelected
                  ? themeState.moodTheme.cardColor
                  : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2C2834)
              : (themeState.hasMoodSelected
                    ? themeState.moodTheme.cardBorder
                    : AppColors.lightCardBorder),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white38 : AppColors.lightTextSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(
                  context,
                )!.journalSearchPlaceholder,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false,
                hintStyle: GoogleFonts.quicksand(
                  color: isDark ? Colors.white30 : AppColors.lightTextTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip(
    bool isDark,
    Color accentColor,
    ThemeState themeState,
  ) {
    final now = DateTime.now();
    final dates = List.generate(
      7,
      (index) => now.subtract(Duration(days: 3 - index)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isCalendarFilterActive)
          LocalizedActionRow(
            title: AppLocalizations.of(context)!.journalReflectionCalendar,
            titleStyle: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
            ),
            actionLabel: AppLocalizations.of(context)!.journalClearFilter,
            actionStyle: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
            onActionPressed: () {
              setState(() {
                _isCalendarFilterActive = false;
              });
            },
          )
        else
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.journalReflectionCalendar,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white70
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates.map((date) {
              final isSelected =
                  _isCalendarFilterActive &&
                  date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;
              final dayOfWeek = DateFormat(
                'E',
                Localizations.localeOf(context).toString(),
              ).format(date);
              final dayOfMonth = DateFormat(
                'd',
                Localizations.localeOf(context).toString(),
              ).format(date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _isCalendarFilterActive = false;
                    } else {
                      _selectedDate = date;
                      _isCalendarFilterActive = true;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 12),
                  width: 52,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor
                        : (isDark
                              ? const Color(0xFF1E1C24)
                              : (themeState.hasMoodSelected
                                    ? themeState.moodTheme.cardColor
                                    : Colors.white)),
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Large soft rounded corner
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : (isDark
                                ? const Color(0xFF2C2834)
                                : (themeState.hasMoodSelected
                                      ? themeState.moodTheme.cardBorder
                                      : AppColors.lightCardBorder)),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayOfWeek,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white70
                              : (isDark
                                    ? Colors.white38
                                    : AppColors.lightTextSecondary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayOfMonth,
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white
                                    : AppColors.lightTextPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    // Filter logic
    final filteredEntries = journalState.entries.where((entry) {
      if (_searchQuery.isNotEmpty) {
        final titleMatch = entry.title.toLowerCase().contains(_searchQuery);
        final bodyMatch = entry.body.toLowerCase().contains(_searchQuery);
        if (!titleMatch && !bodyMatch) return false;
      }

      if (_isCalendarFilterActive) {
        if (entry.createdAt.day != _selectedDate.day ||
            entry.createdAt.month != _selectedDate.month ||
            entry.createdAt.year != _selectedDate.year) {
          return false;
        }
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
          AppLocalizations.of(context)!.journalTitle,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1C24)
                  : (themeState.hasMoodSelected
                        ? themeState.moodTheme.cardColor
                        : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2C2834)
                    : (themeState.hasMoodSelected
                          ? themeState.moodTheme.cardBorder
                          : AppColors.lightCardBorder),
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: Icon(
                _isCalendarFilterActive
                    ? Icons.calendar_today_rounded
                    : Icons.calendar_today_outlined,
                color: _isCalendarFilterActive
                    ? accentColor
                    : (isDark ? Colors.white : AppColors.lightTextPrimary),
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _isCalendarFilterActive = !_isCalendarFilterActive;
                });
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Words counter card from reference layout
              Center(
                child: Column(
                  children: [
                    Text(
                      '420',
                      style: GoogleFonts.outfit(
                        fontSize: 58,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.text,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.journalCelebrateSmile,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white60
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // History of Previous Journals horizontal list/carousel
              if (journalState.entries.isNotEmpty) ...[
                Text(
                  (() {
                    final lang = Localizations.localeOf(context).languageCode;
                    switch (lang) {
                      case 'es':
                        return 'Historial de diarios anteriores';
                      case 'hi':
                        return 'पिछले जर्नल का इतिहास';
                      case 'fr':
                        return 'Historique des journaux précédents';
                      case 'de':
                        return 'Verlauf früherer Journale';
                      default:
                        return 'History of Previous Journals';
                    }
                  })(),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: journalState.entries.length,
                    itemBuilder: (context, index) {
                      final entry = journalState.entries[index];
                      final dateStr = DateFormat(
                        'MMM d, yyyy',
                      ).format(entry.createdAt);
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  JournalDetailScreen(entry: entry),
                            ),
                          );
                        },
                        child: Container(
                          width: 240,
                          margin: const EdgeInsets.only(right: 12, bottom: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1C24)
                                : (themeState.hasMoodSelected
                                      ? themeState.moodTheme.cardColor
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(20),
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
                                color: Colors.black.withValues(alpha: 0.015),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      entry.mood,
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white38
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  entry.body,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.lightTextSecondary,
                                    height: 1.25,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Search Bar
              _buildSearchBox(isDark, themeState),
              const SizedBox(height: 20),

              // Calendar Strip
              if (_isCalendarFilterActive) ...[
                _buildCalendarStrip(isDark, accentColor, themeState),
                const SizedBox(height: 24),
              ],

              // AI Reflection Prompt Card
              WritingPromptCard(
                promptText: _getLocalPrompt(context, _currentPromptIndex),
                onRefresh: _cyclePrompt,
                onStartWriting: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateJournalScreen(
                        initialText: AppLocalizations.of(context)!
                            .journalRegardingPrompt(
                              _getLocalPrompt(context, _currentPromptIndex),
                            ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Recent Entries Header
              Text(
                AppLocalizations.of(context)!.journalRecentReflections,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Entries List
              if (filteredEntries.isEmpty)
                _buildEmptyState(isDark)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredEntries.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    return JournalCard(
                      entry: entry,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                JournalDetailScreen(entry: entry),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 80), // Offset for floating button
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LocalizedButton(
          text: AppLocalizations.of(context)!.journalCreateNew,
          onPressed: () => context.push('/create-journal'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.notes_rounded,
            size: 48,
            color: isDark ? Colors.white24 : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.journalNoReflections,
            style: GoogleFonts.quicksand(
              color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
