import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/localization/generated/app_localizations.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  Widget _buildToolTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

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
          AppLocalizations.of(context)!.exploreTitle,
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
              Text(
                AppLocalizations.of(context)!.exploreDiscoverTools,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Grid layout for 4 growth tools
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05,
                children: [
                  _buildToolTile(
                    context,
                    title: AppLocalizations.of(context)!.exploreAskWithAura,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.exploreAiAssistantChat,
                    icon: Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFF7C8CFF),
                    onTap: () => context.push('/chat'),
                    isDark: isDark,
                  ),
                  _buildToolTile(
                    context,
                    title: AppLocalizations.of(context)!.exploreAnalyzeAnything,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.exploreVisionScanner,
                    icon: Icons.filter_center_focus_rounded,
                    color: const Color(0xFF57C7D4),
                    onTap: () => context.push('/vision'),
                    isDark: isDark,
                  ),
                  _buildToolTile(
                    context,
                    title: AppLocalizations.of(context)!.exploreAskYourFiles,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.exploreUploadDocuments,
                    icon: Icons.folder_open_rounded,
                    color: const Color(0xFFFFB84D),
                    onTap: () => context.push('/documents'),
                    isDark: isDark,
                  ),
                  _buildToolTile(
                    context,
                    title: AppLocalizations.of(context)!.exploreVoiceAssistant,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.exploreTalkHandsFree,
                    icon: Icons.mic_none_rounded,
                    color: const Color(0xFF7ED957),
                    onTap: () => context.push('/voice'),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recommended section
              Text(
                AppLocalizations.of(context)!.exploreRecommendedForYou,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.text,
                ),
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.exploreDailyReflection,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppColors.text,
                          ),
                        ),
                        Icon(
                          Icons.wb_sunny_outlined,
                          color: const Color(0xFFFFB84D),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)!.exploreDailyReflectionDesc,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white60
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigates to Journey/Journal tab or trigger writing
                        context.push('/chat');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor.withValues(alpha: 0.12),
                        foregroundColor: accentColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.exploreTryNow,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
