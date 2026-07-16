import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/mood_theme_model.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/localization/supported_languages.dart';

class MoodSelectionScreen extends ConsumerStatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  ConsumerState<MoodSelectionScreen> createState() =>
      _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends ConsumerState<MoodSelectionScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  String _pendingLanguage = 'en';

  static const List<Map<String, String>> _moods = [
    {
      'emoji': '😊',
      'name': 'Happy',
      'description': 'Feeling positive and energetic',
    },
    {'emoji': '☁️', 'name': 'Calm', 'description': 'Relaxed and peaceful'},
    {
      'emoji': '🌱',
      'name': 'Motivated',
      'description': 'Ready to achieve goals',
    },
    {'emoji': '🌙', 'name': 'Relaxed', 'description': 'Taking things slowly'},
    {
      'emoji': '🌧️',
      'name': 'Reflective',
      'description': 'Thoughtful and introspective',
    },
    {
      'emoji': '⚡',
      'name': 'Focused',
      'description': 'Ready to get things done',
    },
    {'emoji': '😴', 'name': 'Tired', 'description': 'Need a gentle experience'},
    {
      'emoji': '❤️',
      'name': 'Inspired',
      'description': 'Feeling creative today',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.72);
    // Initialize pending language from current active locale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _pendingLanguage = ref.read(localeProvider).languageCode;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMoodName = _moods[_currentIndex]['name']!;
    final moodTheme = MoodThemeModel.fromMoodName(activeMoodName);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              moodTheme.background,
              moodTheme.backgroundGradient[1].withValues(alpha: 0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Header section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.moodTitle,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: const Color(0xFF1F1F1F),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.moodSubtitle,
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Horizontal Swipe Carousel
                SizedBox(
                  height: 380,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    physics: const BouncingScrollPhysics(),
                    itemCount: _moods.length,
                    itemBuilder: (context, index) {
                      final mood = _moods[index];
                      final isSelected = index == _currentIndex;
                      final cardTheme = MoodThemeModel.fromMoodName(
                        mood['name']!,
                      );

                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 300),
                            scale: isSelected ? 1.08 : 0.90,
                            curve: Curves.easeOutBack,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 250,
                              height: 320,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: cardTheme.backgroundGradient,
                                ),
                                border: isSelected
                                    ? Border.all(
                                        color: cardTheme.primary,
                                        width: 3.0,
                                      )
                                    : Border.all(
                                        color: cardTheme.cardBorder,
                                        width: 1.5,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: cardTheme.primary.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 28,
                                          spreadRadius: 6,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.03,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Scale up the emoji for the selected one
                                        AnimatedScale(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          scale: isSelected ? 1.15 : 1.0,
                                          child: Text(
                                            mood['emoji']!,
                                            style: const TextStyle(
                                              fontSize: 64,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          _getLocalizedMoodName(
                                            context,
                                            mood['name']!,
                                          ),
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: cardTheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: Text(
                                            _getLocalizedMoodDesc(
                                              context,
                                              mood['name']!,
                                            ),
                                            style: GoogleFonts.quicksand(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF555555),
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 16,
                                      right: 16,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: cardTheme.primary,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 16,
                                          color: cardTheme.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_moods.length, (index) {
                    final isSelected = index == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: isSelected ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? moodTheme.primary
                            : moodTheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // PreferredLanguageCard
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: GestureDetector(
                    onTap: () => _showLanguageSelectionSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: moodTheme.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.language_rounded,
                            color: moodTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.moodPreferredLanguage,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                SupportedLanguagesRegistry.lookupByCode(
                                      ref.watch(localeProvider).languageCode,
                                    )?.nativeName ??
                                    SupportedLanguagesRegistry
                                        .defaultLanguage
                                        .nativeName,
                                style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F1F1F),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: moodTheme.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: PrimaryButton(
                    text: AppLocalizations.of(context)!.moodBtnContinue,
                    backgroundColor: moodTheme.primary,
                    onPressed: () async {
                      // Commit mood theme
                      ref
                          .read(themeProvider.notifier)
                          .setMoodTheme(activeMoodName);

                      if (context.mounted) {
                        context.go('/home');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageSelectionSheet(BuildContext context) {
    final activeMoodName = _moods[_currentIndex]['name']!;
    final moodTheme = MoodThemeModel.fromMoodName(activeMoodName);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.moodChooseLanguage,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.moodLanguageSelectDesc,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...supportedLanguages.map((lang) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildLanguageOption(
                            context,
                            code: lang.locale.languageCode,
                            title: lang.nativeName,
                            subtitle: lang.englishName,
                            moodTheme: moodTheme,
                            setModalState: setModalState,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String code,
    required String title,
    required String subtitle,
    required MoodThemeModel moodTheme,
    required StateSetter setModalState,
  }) {
    final isSelected = _pendingLanguage == code;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _pendingLanguage = code;
        });
        setModalState(() {
          _pendingLanguage = code;
        });
        // Immediately set the locale in the controller to change application-wide locale instantly
        await ref.read(localeProvider.notifier).setLocale(Locale(code));
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? moodTheme.primary.withValues(alpha: 0.08)
              : const Color(0xFFF9F9FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? moodTheme.primary : const Color(0xFFEFEFF2),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: moodTheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedMoodName(BuildContext context, String mood) {
    final l10n = AppLocalizations.of(context)!;
    switch (mood) {
      case 'Happy':
        return l10n.moodNameHappy;
      case 'Calm':
        return l10n.moodNameCalm;
      case 'Motivated':
        return l10n.moodNameMotivated;
      case 'Relaxed':
        return l10n.moodNameRelaxed;
      case 'Reflective':
        return l10n.moodNameReflective;
      case 'Focused':
        return l10n.moodNameFocused;
      case 'Tired':
        return l10n.moodNameTired;
      case 'Inspired':
        return l10n.moodNameInspired;
      default:
        return mood;
    }
  }

  String _getLocalizedMoodDesc(BuildContext context, String mood) {
    final l10n = AppLocalizations.of(context)!;
    switch (mood) {
      case 'Happy':
        return l10n.moodDescHappy;
      case 'Calm':
        return l10n.moodDescCalm;
      case 'Motivated':
        return l10n.moodDescMotivated;
      case 'Relaxed':
        return l10n.moodDescRelaxed;
      case 'Reflective':
        return l10n.moodDescReflective;
      case 'Focused':
        return l10n.moodDescFocused;
      case 'Tired':
        return l10n.moodDescTired;
      case 'Inspired':
        return l10n.moodDescInspired;
      default:
        return '';
    }
  }
}
