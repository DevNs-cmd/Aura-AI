import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/localization/generated/app_localizations.dart';

class CalendarEvent {
  final String title;
  final String time;
  final IconData icon;
  final Color iconColor;
  bool isCompleted;

  CalendarEvent({
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isCompleted = false,
  });
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int _selectedDay = 10;
  final Map<int, List<CalendarEvent>> _eventsByDay = {};
  bool _defaultEventsInitialized = false;

  void _ensureDefaultEvents(BuildContext context) {
    if (_defaultEventsInitialized) return;
    _defaultEventsInitialized = true;
    final l10n = AppLocalizations.of(context)!;
    _eventsByDay[10] = [
      CalendarEvent(
        title: l10n.calendarMorningJournal,
        time: '08:00 AM',
        icon: Icons.edit_note_rounded,
        iconColor: const Color(0xFF7ED957),
        isCompleted: true,
      ),
      CalendarEvent(
        title: l10n.calendarWorkout,
        time: '07:00 PM',
        icon: Icons.fitness_center_rounded,
        iconColor: const Color(0xFFA58BFF),
        isCompleted: false,
      ),
    ];
  }

  void _showAddEventDialog(
    BuildContext context,
    Color accentColor,
    bool isDark,
  ) {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedCategory = 'Journal';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                AppLocalizations.of(
                  context,
                )!.calendarAddEventTitle(_selectedDay.toString()),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.text,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.quicksand(
                      color: isDark ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      )!.calendarEventTitleHint,
                      hintStyle: GoogleFonts.quicksand(
                        color: isDark ? Colors.white30 : AppColors.textTertiary,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : AppColors.lightCardBorder,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accentColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.calendarTimeLabel(selectedTime.format(context)),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.calendarSelectTime,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.calendarCategory,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: isDark
                        ? const Color(0xFF1E1C24)
                        : Colors.white,
                    style: GoogleFonts.quicksand(
                      color: isDark ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                    underline: Container(height: 1, color: accentColor),
                    items: () {
                      final catLabels = <String, String>{
                        'Journal': AppLocalizations.of(
                          context,
                        )!.calendarCatJournal,
                        'Workout': AppLocalizations.of(
                          context,
                        )!.calendarCatWorkout,
                        'Reflection': AppLocalizations.of(
                          context,
                        )!.calendarCatReflection,
                        'Other': AppLocalizations.of(context)!.calendarCatOther,
                      };
                      return catLabels.entries.map((e) {
                        return DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList();
                    }(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCategory = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.calendarCancel,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      IconData icon = Icons.event_note_rounded;
                      Color iconColor = accentColor;
                      if (selectedCategory == 'Journal') {
                        icon = Icons.edit_note_rounded;
                        iconColor = const Color(0xFF7ED957);
                      } else if (selectedCategory == 'Workout') {
                        icon = Icons.fitness_center_rounded;
                        iconColor = const Color(0xFFA58BFF);
                      } else if (selectedCategory == 'Reflection') {
                        icon = Icons.psychology_rounded;
                        iconColor = const Color(0xFF57C7D4);
                      }

                      setState(() {
                        if (!_eventsByDay.containsKey(_selectedDay)) {
                          _eventsByDay[_selectedDay] = [];
                        }
                        _eventsByDay[_selectedDay]!.add(
                          CalendarEvent(
                            title: title,
                            time: selectedTime.format(context),
                            icon: icon,
                            iconColor: iconColor,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.calendarAdd,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;
    _ensureDefaultEvents(context);

    final l10n = AppLocalizations.of(context)!;
    final daysOfWeek = [
      l10n.calendarMon,
      l10n.calendarTue,
      l10n.calendarWed,
      l10n.calendarThu,
      l10n.calendarFri,
      l10n.calendarSat,
      l10n.calendarSun,
    ];

    // Simple mock June 2024 grid
    // June 1st starts on a Saturday, so 5 empty spots
    final gridDays = [
      ...List.generate(5, (index) => 0),
      ...List.generate(30, (index) => index + 1),
    ];

    final currentEvents = _eventsByDay[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.background
                : AppColors.lightBackground),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.text,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.calendarTitle,
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
              // Calendar Grid Container Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1C24)
                      : (themeState.hasMoodSelected
                            ? themeState.moodTheme.cardColor
                            : Colors.white),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C2834)
                        : (themeState.hasMoodSelected
                              ? themeState.moodTheme.cardBorder
                              : AppColors.lightCardBorder),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Days of week header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: daysOfWeek.map((day) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white30
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Grid days
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gridDays.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        final dayValue = gridDays[index];
                        if (dayValue == 0) return const SizedBox.shrink();

                        final isSelected = dayValue == _selectedDay;

                        return Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDay = dayValue;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accentColor
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                dayValue.toString(),
                                style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white
                                            : AppColors.text),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Events Section Title
              Text(
                l10n.calendarTodayLabel(_selectedDay.toString()),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.text,
                ),
              ),
              const SizedBox(height: 14),

              // Events list tiles inside outline card
              if (currentEvents.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1C24)
                        : (themeState.hasMoodSelected
                              ? themeState.moodTheme.cardColor
                              : Colors.white),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C2834)
                          : (themeState.hasMoodSelected
                                ? themeState.moodTheme.cardBorder
                                : AppColors.lightCardBorder),
                      width: 1.5,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentEvents.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1.5,
                      color: isDark
                          ? const Color(0xFF2C2834)
                          : (themeState.hasMoodSelected
                                ? themeState.moodTheme.cardBorder
                                : AppColors.lightCardBorder),
                      indent: 20,
                      endIndent: 20,
                    ),
                    itemBuilder: (context, index) {
                      final ev = currentEvents[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: ev.iconColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(ev.icon, color: ev.iconColor, size: 18),
                        ),
                        title: Text(
                          ev.title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.text,
                            decoration: ev.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          ev.time,
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: isDark
                                ? Colors.white60
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              ev.isCompleted = !ev.isCompleted;
                            });
                          },
                          child: Icon(
                            ev.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: ev.isCompleted
                                ? accentColor
                                : (isDark
                                      ? Colors.white30
                                      : AppColors.textTertiary),
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1C24)
                        : (themeState.hasMoodSelected
                              ? themeState.moodTheme.cardColor
                              : Colors.white),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C2834)
                          : (themeState.hasMoodSelected
                                ? themeState.moodTheme.cardBorder
                                : AppColors.lightCardBorder),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 40,
                        color: isDark ? Colors.white24 : AppColors.textTertiary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.calendarNoEvents,
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white60
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context, accentColor, isDark),
        backgroundColor: accentColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
