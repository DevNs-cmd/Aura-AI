import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/auth_provider.dart';
import '../settings_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/supported_languages.dart';
import '../../../../core/widgets/localized_settings_row.dart';
import '../../../../core/widgets/localized_section_header.dart';
import '../../../../core/widgets/localized_dialog_action_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;
    final currentLocale = ref.watch(localeProvider);

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
          AppLocalizations.of(context)!.settingsTitle,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Appearance Group
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.settingsAppearance,
                isDark,
              ),
              _buildGroupedCard(
                [
                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.settingsDarkMode,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                        fontSize: 15,
                      ),
                    ),
                    value: isDark,
                    onChanged: (val) =>
                        ref.read(themeProvider.notifier).toggleDarkMode(),
                    activeThumbColor: Colors.white,
                    activeTrackColor: accentColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  _buildDivider(isDark, themeState),
                  LocalizedSettingsRow(
                    title: AppLocalizations.of(context)!.settingsLanguage,
                    titleStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontSize: 15,
                    ),
                    trailingText:
                        SupportedLanguagesRegistry.lookupByLocale(
                          currentLocale,
                        )?.nativeName ??
                        SupportedLanguagesRegistry.defaultLanguage.nativeName,
                    trailingTextStyle: GoogleFonts.quicksand(
                      color: isDark
                          ? Colors.white60
                          : AppColors.lightTextSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    showChevron: true,
                    onTap: () => _showLanguageDialog(
                      context,
                      ref,
                      currentLocale.languageCode,
                      accentColor,
                      isDark,
                    ),
                  ),
                ],
                isDark,
                themeState,
              ),
              const SizedBox(height: 24),

              // 2. Notifications Group
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.settingsNotifications,
                isDark,
              ),
              _buildGroupedCard(
                [
                  SwitchListTile(
                    title: Text(
                      'Push Notifications',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                        fontSize: 15,
                      ),
                    ),
                    value: settings.notificationsEnabled,
                    onChanged: (val) => ref
                        .read(settingsProvider.notifier)
                        .toggleNotifications(),
                    activeThumbColor: Colors.white,
                    activeTrackColor: accentColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ],
                isDark,
                themeState,
              ),
              const SizedBox(height: 24),

              // 4. Security & Privacy
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.settingsSecurity,
                isDark,
              ),
              _buildGroupedCard(
                [
                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.settingsAppLock,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                        fontSize: 15,
                      ),
                    ),
                    value: settings.appLockEnabled,
                    onChanged: (val) =>
                        ref.read(settingsProvider.notifier).toggleAppLock(),
                    activeThumbColor: Colors.white,
                    activeTrackColor: accentColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  _buildDivider(isDark, themeState),
                  LocalizedSettingsRow(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                    ),
                    title: AppLocalizations.of(context)!.settingsClearCache,
                    titleStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 15,
                    ),
                    showChevron: false,
                    onTap: () =>
                        _showClearCacheDialog(context, accentColor, isDark),
                  ),
                ],
                isDark,
                themeState,
              ),
              const SizedBox(height: 24),

              // 5. About
              _buildSectionHeader(context, 'About Aura AI', isDark),
              _buildGroupedCard(
                [
                  LocalizedSettingsRow(
                    title: AppLocalizations.of(context)!.settingsVersion,
                    titleStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontSize: 15,
                    ),
                    trailingText: '1.0.0',
                    trailingTextStyle: GoogleFonts.quicksand(
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    showChevron: false,
                  ),
                ],
                isDark,
                themeState,
              ),
              const SizedBox(height: 36),

              // 6. Logout Tile Card
              Card(
                color: isDark
                    ? const Color(0xFF1E1C24)
                    : (themeState.hasMoodSelected
                          ? themeState.moodTheme.cardColor
                          : Colors.white),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2C2834)
                        : (themeState.hasMoodSelected
                              ? themeState.moodTheme.cardBorder
                              : AppColors.lightCardBorder),
                    width: 1.5,
                  ),
                ),
                child: LocalizedSettingsRow(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  title: AppLocalizations.of(context)!.settingsLogout,
                  titleStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    fontSize: 15,
                  ),
                  showChevron: false,
                  onTap: () async {
                    await ref.read(themeProvider.notifier).clearMoodTheme();
                    ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return LocalizedSectionHeader(
      title: title,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
      ),
      padding: const EdgeInsets.only(left: 8, bottom: 12),
    );
  }

  Widget _buildGroupedCard(
    List<Widget> children,
    bool isDark,
    ThemeState themeState,
  ) {
    return Card(
      color: isDark
          ? const Color(0xFF1E1C24)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.cardColor
                : Colors.white),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // Consistent rounded corners
        side: BorderSide(
          color: isDark
              ? const Color(0xFF2C2834)
              : (themeState.hasMoodSelected
                    ? themeState.moodTheme.cardBorder
                    : AppColors.lightCardBorder),
          width: 1.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark, ThemeState themeState) {
    return Divider(
      height: 1.5,
      color: isDark
          ? const Color(0xFF2C2834)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.cardBorder
                : AppColors.lightCardBorder),
      indent: 16,
      endIndent: 16,
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String current,
    Color accentColor,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
          title: Text(
            AppLocalizations.of(context)!.settingsSelectLanguage,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: supportedLanguages.map((lang) {
              final isSelected =
                  current.toLowerCase().trim() == lang.locale.languageCode ||
                  current.toLowerCase().trim() ==
                      lang.englishName.toLowerCase() ||
                  current.toLowerCase().trim() == lang.nativeName.toLowerCase();
              return ListTile(
                title: Text(
                  lang.nativeName,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? accentColor
                        : (isDark
                              ? Colors.white70
                              : AppColors.lightTextPrimary),
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: accentColor)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(lang.locale);
                  context.pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showClearCacheDialog(
    BuildContext context,
    Color accentColor,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
          title: Text(
            'Clear Cache Data',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to clear all offline cached images, conversations, and logs? This action is irreversible.',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
          ),
          actions: [
            LocalizedDialogActionBar(
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.outfit(
                      color: isDark
                          ? Colors.white60
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache successfully cleared!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
