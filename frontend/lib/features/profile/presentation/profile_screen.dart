import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../auth/auth_provider.dart';
import '../profile_provider.dart';
import 'widgets/personality_selector.dart';
import 'widgets/usage_chart.dart';
import 'edit_profile_screen.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/widgets/localized_settings_row.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.profileTitle,
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
                Icons.edit_outlined,
                color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                size: 18,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Avatar Circle
              Center(
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(profile.avatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                profile.userName,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.text,
                ),
              ),
              const SizedBox(height: 6),

              // Premium badge & Diamond
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diamond_rounded, color: accentColor, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.profilePremiumMember,
                      style: GoogleFonts.quicksand(
                        color: isDark
                            ? Colors.white60
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Reconstructed horizontal stats row card
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    _buildStatCol(
                      context,
                      isDark,
                      label: AppLocalizations.of(context)!.profileStatMemories,
                      value: '128',
                    ),
                    _buildDivider(isDark, themeState),
                    _buildStatCol(
                      context,
                      isDark,
                      label: AppLocalizations.of(context)!.profileStatGoals,
                      value: '24',
                    ),
                    _buildDivider(isDark, themeState),
                    _buildStatCol(
                      context,
                      isDark,
                      label: AppLocalizations.of(context)!.profileStatProgress,
                      value: '86%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu list items modeled after the reference image
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
                child: Column(
                  children: [
                    _buildProfileMenuItem(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.notifications_none_rounded,
                      iconColor: const Color(0xFFFFB84D),
                      title: AppLocalizations.of(
                        context,
                      )!.profileMenuNotifications,
                      value: AppLocalizations.of(
                        context,
                      )!.profileMenuSmartReminders,
                      onTap: () => context.push('/notifications'),
                    ),
                    _buildItemDivider(isDark, themeState),
                    _buildProfileMenuItem(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.tune_rounded,
                      iconColor: const Color(0xFF7ED957),
                      title: AppLocalizations.of(
                        context,
                      )!.profileMenuPreferences,
                      value: AppLocalizations.of(
                        context,
                      )!.profileMenuPersonalizedForYou,
                      onTap: () {
                        context.push('/settings');
                      },
                    ),
                    _buildItemDivider(isDark, themeState),
                    _buildProfileMenuItem(
                      context,
                      isDark: isDark,
                      accentColor: accentColor,
                      icon: Icons.logout_rounded,
                      iconColor: Colors.redAccent,
                      title: AppLocalizations.of(context)!.profileMenuLogout,
                      value: '',
                      onTap: () async {
                        await ref.read(themeProvider.notifier).clearMoodTheme();
                        ref.read(authProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // AI Personality Selection Selector Below
              PersonalitySelector(
                selected: profile.selectedPersonality,
                onChanged: (val) {
                  ref.read(profileProvider.notifier).setPersonality(val);
                },
              ),
              const SizedBox(height: 24),

              // Usage Chart
              const UsageChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark, ThemeState themeState) {
    return Container(
      width: 1.5,
      height: 36,
      color: isDark
          ? const Color(0xFF2C2834)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.cardBorder
                : AppColors.lightCardBorder),
    );
  }

  Widget _buildItemDivider(bool isDark, ThemeState themeState) {
    return Divider(
      height: 1.5,
      color: isDark
          ? const Color(0xFF2C2834)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.cardBorder
                : AppColors.lightCardBorder),
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _buildStatCol(
    BuildContext context,
    bool isDark, {
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(
    BuildContext context, {
    required bool isDark,
    required Color accentColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return LocalizedSettingsRow(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: title,
      titleStyle: GoogleFonts.outfit(
        fontWeight: FontWeight.bold,
        color: iconColor == Colors.redAccent
            ? Colors.redAccent
            : (isDark ? Colors.white : AppColors.text),
        fontSize: 14,
      ),
      trailingText: value,
      trailingTextStyle: GoogleFonts.quicksand(
        color: isDark ? Colors.white60 : AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      showChevron: true,
      onTap: onTap,
    );
  }
}
