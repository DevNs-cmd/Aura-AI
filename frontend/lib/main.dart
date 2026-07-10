import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/localization/locale_controller.dart';
import 'features/auth/auth_provider.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AuraApp()));
}

class AuraApp extends ConsumerWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final userLocale = ref.watch(localeProvider);

    final moodTheme = themeState.hasMoodSelected ? themeState.moodTheme : null;

    // Apply strict locale boundary: pre-authentication remains in English
    final appLocale = authState.status == AuthStatus.authenticated
        ? userLocale
        : const Locale('en');

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: appLocale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.getTheme(
        isDark: false,
        accentColor: themeState.accentColor,
        moodTheme: moodTheme,
      ),
      darkTheme: AppTheme.getTheme(
        isDark: true,
        accentColor: themeState.accentColor,
        moodTheme: moodTheme,
      ),
      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 400),
      themeAnimationCurve: Curves.easeInOut,
      routerConfig: appRouter,
    );
  }
}
