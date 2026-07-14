import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../profile/profile_provider.dart';
import '../profile/billing_provider.dart';
import '../journal/presentation/journal_screen.dart';
import '../profile/presentation/profile_screen.dart';
import 'explore_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/bouncing_widget.dart';

import 'widgets/dynamic_inspiration_card.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/widgets/localized_navigation_label.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTabIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeDashboardView(),
      const ExploreScreen(),
      const SizedBox.shrink(), // Placeholder for middle action button
      const JournalScreen(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Middle "+" button tapped -> show beautiful options launcher bottom sheet
      _showQuickLauncherSheet();
      return;
    }
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _showQuickLauncherSheet() {
    final themeState = ref.read(themeProvider);
    final isDark = themeState.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : AppColors.lightCardBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.homeQuickActions,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLauncherOption(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: AppLocalizations.of(context)!.quickActionChat,
                  color: const Color(0xFF7C8CFF),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/chat');
                  },
                ),
                _buildLauncherOption(
                  icon: Icons.mic_none_rounded,
                  label: AppLocalizations.of(context)!.quickActionVoice,
                  color: const Color(0xFF7ED957),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/voice');
                  },
                ),
                _buildLauncherOption(
                  icon: Icons.filter_center_focus_rounded,
                  label: AppLocalizations.of(context)!.quickActionVision,
                  color: const Color(0xFF57C7D4),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/vision');
                  },
                ),
                _buildLauncherOption(
                  icon: Icons.edit_note_rounded,
                  label: AppLocalizations.of(context)!.quickActionJournal,
                  color: const Color(0xFFFFB84D),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentTabIndex = 3; // Shift to Journey tab
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLauncherOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncingWidget(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSlideUpdate(
    Offset localPosition,
    double width, {
    bool isTap = false,
  }) {
    final double usableWidth = width - 40;
    final double localX = localPosition.dx - 20;
    if (localX < 0 || localX > usableWidth) return;

    final double tabWidth = usableWidth / 5;
    final int index = (localX / tabWidth).floor().clamp(0, 4);

    if (index == 2) {
      if (isTap) {
        _onTabTapped(2);
      }
      return;
    }

    if (index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.background
                : AppColors.lightBackground),
      body: IndexedStack(index: _currentTabIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerMove: (event) {
            final double width = MediaQuery.of(context).size.width;
            _handleSlideUpdate(event.localPosition, width);
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1C24)
                  : (themeState.hasMoodSelected
                        ? themeState.moodTheme.cardColor
                        : Colors.white),
              borderRadius: BorderRadius.circular(32),
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
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildNavItem(
                    0,
                    Icons.home_rounded,
                    AppLocalizations.of(context)!.navHome,
                    isDark,
                    accentColor,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    1,
                    Icons.explore_rounded,
                    AppLocalizations.of(context)!.navExplore,
                    isDark,
                    accentColor,
                  ),
                ),
                Expanded(child: _buildMiddlePlusItem(isDark, accentColor)),
                Expanded(
                  child: _buildNavItem(
                    3,
                    Icons.edit_note_rounded,
                    AppLocalizations.of(context)!.navJourney,
                    isDark,
                    accentColor,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    4,
                    Icons.person_rounded,
                    AppLocalizations.of(context)!.navProfile,
                    isDark,
                    accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    bool isDark,
    Color accentColor,
  ) {
    final isSelected = _currentTabIndex == index;
    return BouncingWidget(
      onTap: () => _onTabTapped(index),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        scale: isSelected ? 1.18 : 1.0,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? accentColor
                    : (isDark ? Colors.white38 : AppColors.lightTextTertiary),
                size: 22,
              ),
              const SizedBox(height: 3),
              LocalizedNavigationLabel(
                label: label,
                color: isSelected
                    ? accentColor
                    : (isDark ? Colors.white38 : AppColors.lightTextTertiary),
                isSelected: isSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiddlePlusItem(bool isDark, Color accentColor) {
    final isSelected = _currentTabIndex == 2;
    return BouncingWidget(
      onTap: () => _onTabTapped(2),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        scale: isSelected ? 1.18 : 1.0,
        curve: Curves.easeOutBack,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class HomeDashboardView extends ConsumerStatefulWidget {
  const HomeDashboardView({super.key});

  @override
  ConsumerState<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends ConsumerState<HomeDashboardView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = ref.watch(profileProvider);
    final billing = ref.watch(billingProvider);
    final userName = profile.userName.isNotEmpty
        ? profile.userName
        : (authState.user?.displayName ?? 'Jose Maria');
    final userAvatar = profile.avatarUrl.isNotEmpty
        ? profile.avatarUrl
        : (authState.user?.avatarUrl ??
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256&h=256&fit=crop');
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    final now = DateTime.now();
    final dates = List.generate(
      7,
      (index) => now.subtract(Duration(days: 3 - index)),
    );

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.background
                : AppColors.lightBackground),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row matching the exact reference spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.homeGreeting(userName),
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.text,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2D2834)
                              : (themeState.hasMoodSelected
                                    ? themeState.moodTheme.cardBorder
                                    : AppColors.lightCardBorder),
                          width: 1.5,
                        ),
                        image: DecorationImage(
                          image: userAvatar.startsWith('http')
                              ? NetworkImage(userAvatar) as ImageProvider
                              : FileImage(File(userAvatar)) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Horizontal Calendar strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: dates.map((date) {
                  final isSelected =
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

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                        context.push('/calendar');
                      },
                      child: Column(
                        children: [
                          Text(
                            dayOfWeek,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white30
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accentColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              dayOfMonth,
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF1F1F1F)
                                    : (isDark ? Colors.white : AppColors.text),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Dynamic Inspiration Card
              const DynamicInspirationCard(),
              const SizedBox(height: 28),

              if (billing.plan == SubscriptionPlan.free) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unlock Unlimited AI',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Upgrade to Premium for unlimited chats, memories, and vision analysis.',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      BouncingWidget(
                        onTap: () => context.push('/choose-plan'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Upgrade',
                            style: GoogleFonts.outfit(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // Quick Journal section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.homeQuickJournal,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final state = context
                          .findAncestorStateOfType<_HomeScreenState>();
                      state?._onTabTapped(3);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.homeSeeAll,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2 Horizontal Quick Journal cards matching the reference image layout
              Row(
                children: [
                  Expanded(
                    child: _buildQuickCard(
                      title: AppLocalizations.of(context)!.quickPauseReflect,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.quickGratefulToday,
                      tag: AppLocalizations.of(context)!.quickPersonal,
                      color: const Color(0xFFFFECEB),
                      textColor: const Color(0xFF8B3A36),
                      tagColor: const Color(0xFFFFD4D2),
                      onTap: () {
                        final state = context
                            .findAncestorStateOfType<_HomeScreenState>();
                        state?._onTabTapped(3);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickCard(
                      title: AppLocalizations.of(context)!.quickSetIntentions,
                      subtitle: AppLocalizations.of(context)!.quickHowFeel,
                      tag: AppLocalizations.of(context)!.quickFamily,
                      color: const Color(0xFFECEBFF),
                      textColor: const Color(0xFF3B368B),
                      tagColor: const Color(0xFFD2D0FF),
                      onTap: () {
                        final state = context
                            .findAncestorStateOfType<_HomeScreenState>();
                        state?._onTabTapped(3);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCard({
    required String title,
    required String subtitle,
    required String tag,
    required Color color,
    required Color textColor,
    required Color tagColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: tagColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
