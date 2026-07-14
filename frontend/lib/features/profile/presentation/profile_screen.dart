import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../auth/auth_provider.dart';
import '../profile_provider.dart';
import '../billing_provider.dart';
import 'widgets/personality_selector.dart';
import 'widgets/usage_chart.dart';
import 'edit_profile_screen.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/widgets/localized_settings_row.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/avatar_source_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final themeState = ref.watch(themeProvider);
    final billing = ref.watch(billingProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      try {
        final pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          ref.read(profileProvider.notifier).updateAvatar(pickedFile.path);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.profileAvatarUpdatedSuccess,
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error picking image: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }

    void showAvatarPicker() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
        builder: (sheetContext) => AvatarSourceSheet(
          accentColor: accentColor,
          isDark: isDark,
          onSourceSelected: (source) => pickImage(source),
        ),
      );
    }

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
                child: GestureDetector(
                  onTap: () => showAvatarPicker(),
                  child: Stack(
                    children: [
                      Container(
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
                            image: profile.avatarUrl.startsWith('http')
                                ? NetworkImage(profile.avatarUrl) as ImageProvider
                                : FileImage(File(profile.avatarUrl)) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
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
              GestureDetector(
                onTap: () => context.push('/billing'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      billing.plan == SubscriptionPlan.pro
                          ? Icons.workspace_premium_rounded
                          : (billing.isPremium ? Icons.diamond_rounded : Icons.person_outline_rounded),
                      color: billing.plan == SubscriptionPlan.pro
                          ? Colors.purple
                          : (billing.isPremium ? Colors.amber[700] : Colors.grey),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        billing.plan == SubscriptionPlan.pro
                            ? 'Pro Member'
                            : (billing.isPremium ? 'Premium Member' : 'Free Member'),
                        style: GoogleFonts.quicksand(
                          color: billing.plan == SubscriptionPlan.pro
                              ? Colors.purple
                              : (billing.isPremium
                                  ? (isDark ? Colors.amber[200] : Colors.amber[800])
                                  : (isDark ? Colors.white60 : AppColors.textSecondary)),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
                      icon: Icons.payment_rounded,
                      iconColor: const Color(0xFF57C7D4),
                      title: (() {
                        final lang = Localizations.localeOf(
                          context,
                        ).languageCode;
                        switch (lang) {
                          case 'es':
                            return 'Facturación y suscripción';
                          case 'hi':
                            return 'बिलिंग और सदस्यता';
                          case 'fr':
                            return 'Facturation et abonnement';
                          case 'de':
                            return 'Abrechnung & Abo';
                          default:
                            return 'Billing & Subscription';
                        }
                      })(),
                      value: '',
                      onTap: () => context.push('/billing'),
                    ),
                    _buildItemDivider(isDark, themeState),
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
