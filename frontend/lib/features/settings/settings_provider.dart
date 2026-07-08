import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_provider.dart';

class SettingsState {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool appLockEnabled;
  final String voicePitch;

  SettingsState({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.appLockEnabled = false,
    this.voicePitch = 'Empathetic',
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? appLockEnabled,
    String? voicePitch,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      voicePitch: voicePitch ?? this.voicePitch,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;
  SharedPreferences? _prefs;

  SettingsNotifier(this._ref) : super(SettingsState()) {
    _initPrefs();
    _ref.listen<ThemeState>(themeProvider, (prev, next) {
      state = state.copyWith(isDarkMode: next.isDarkMode);
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final notifs = _prefs?.getBool('notifications_enabled') ?? true;
    final lock = _prefs?.getBool('app_lock_enabled') ?? false;
    final pitch = _prefs?.getString('voice_pitch') ?? 'Empathetic';

    // Synchronize isDarkMode from themeProvider
    final isDark = _ref.read(themeProvider).isDarkMode;

    state = SettingsState(
      isDarkMode: isDark,
      notificationsEnabled: notifs,
      appLockEnabled: lock,
      voicePitch: pitch,
    );
  }

  Future<void> toggleDarkMode() async {
    await _ref.read(themeProvider.notifier).toggleDarkMode();
    state = state.copyWith(isDarkMode: _ref.read(themeProvider).isDarkMode);
  }

  Future<void> toggleNotifications() async {
    final val = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: val);
    await _prefs?.setBool('notifications_enabled', val);
  }

  Future<void> toggleAppLock() async {
    final val = !state.appLockEnabled;
    state = state.copyWith(appLockEnabled: val);
    await _prefs?.setBool('app_lock_enabled', val);
  }

  Future<void> setVoicePitch(String value) async {
    state = state.copyWith(voicePitch: value);
    await _prefs?.setString('voice_pitch', value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(ref);
  },
);
