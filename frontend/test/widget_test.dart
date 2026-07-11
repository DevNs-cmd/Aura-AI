import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_ai/core/theme/mood_theme_model.dart';
import 'package:aura_ai/core/theme/theme_provider.dart';
import 'package:aura_ai/features/splash/presentation/splash_controller.dart';
import 'package:aura_ai/features/auth/auth_provider.dart';
import 'package:aura_ai/features/chat/chat_provider.dart';
import 'package:aura_ai/features/journal/journal_provider.dart';
import 'package:aura_ai/features/goals/goals_provider.dart';
import 'package:aura_ai/features/memory/memory_provider.dart';
import 'package:aura_ai/models/memory.dart';
import 'package:aura_ai/features/voice/voice_provider.dart';
import 'package:aura_ai/features/vision/vision_provider.dart';
import 'package:aura_ai/features/profile/profile_provider.dart';
import 'package:aura_ai/features/settings/settings_provider.dart';
import 'package:aura_ai/features/notifications/notifications_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Splash Screen Tests', () {
    test('SplashController initializes state to not initialized', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(
        splashControllerProvider,
        (previous, next) {},
      );

      final splashState = subscription.read();
      expect(splashState.isInitialized, false);
      expect(splashState.errorMessage, null);
    });

    test('SplashController initializes after delay', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(
        splashControllerProvider,
        (previous, next) {},
      );

      expect(subscription.read().isInitialized, false);
      await Future.delayed(const Duration(milliseconds: 3200));
      expect(subscription.read().isInitialized, true);
    });
  });

  group('Authentication Provider Tests', () {
    test('Initial AuthState is unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.unauthenticated);
      expect(authState.user, null);
      expect(authState.errorMessage, null);
    });

    test('SignIn successfully updates state to authenticated', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      final List<AuthState> states = [];
      container.listen<AuthState>(authProvider, (previous, next) {
        states.add(next);
      });

      await notifier.signIn('alex@example.com', 'password123');

      // Verify states captured: authenticating state then authenticated
      expect(states.isNotEmpty, true);
      expect(states[0].status, AuthStatus.authenticating);
      expect(states[1].status, AuthStatus.authenticated);
      expect(states[1].user?.email, 'alex@example.com');
    });

    test('SignIn with error email triggers AuthStatus.error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      await notifier.signIn('error@example.com', 'wrong');

      final finalState = container.read(authProvider);
      expect(finalState.status, AuthStatus.error);
      expect(finalState.errorMessage, 'Invalid credentials. Please try again.');
    });
  });

  group('Chat Provider Tests', () {
    test('Initial state loads default conversation history', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final chatState = container.read(chatProvider);
      expect(chatState.messages.length, 3);
      expect(chatState.messages.first.content.contains('Hello!'), true);
      expect(chatState.isTyping, false);
    });

    test('Sending message appends to state and triggers AI reply', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(chatProvider.notifier);

      final List<ChatState> states = [];
      container.listen<ChatState>(chatProvider, (previous, next) {
        states.add(next);
      });

      await notifier.sendMessage('Explain code');

      // Check transitions: 2 state updates occur
      expect(states.length, 2);

      // First transition: user message added, typing active
      expect(states[0].messages.length, 4);
      expect(states[0].messages.last.isUser, true);
      expect(states[0].isTyping, true);

      // Second transition: AI reply added, typing inactive
      expect(states[1].messages.length, 5);
      expect(states[1].messages.last.isUser, false);
      expect(states[1].messages.last.content.contains('python'), true);
      expect(states[1].isTyping, false);
    });
  });

  group('Journal Provider Tests', () {
    test('Initial state loads default journal list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final journalState = container.read(journalProvider);
      expect(journalState.entries.length, 3);
      expect(journalState.entries.first.title, 'A Morning Walk in the Park');
      expect(journalState.isLoading, false);
    });

    test('Creating entry appends to state list', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(journalProvider.notifier);
      final List<JournalState> states = [];
      container.listen<JournalState>(journalProvider, (previous, next) {
        states.add(next);
      });

      await notifier.createEntry(
        'Tense Debug Session',
        'Code compile failed but fixed',
        'Okay',
      );

      // Check transitions: 2 state updates occur (isLoading true, then loaded)
      expect(states.length, 2);
      expect(states[0].isLoading, true);
      expect(states[1].isLoading, false);
      expect(states[1].entries.length, 4);
      expect(states[1].entries.first.title, 'Tense Debug Session');
      expect(states[1].entries.first.mood, 'Okay');
    });
  });

  group('Goals Provider Tests', () {
    test('Initial state loads default goals list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final goalsState = container.read(goalsProvider);
      expect(goalsState.goals.length, 3);
      expect(goalsState.goals.first.title, 'Morning Yoga Routine');
      expect(goalsState.isLoading, false);
    });

    test('Creating goal appends to state list', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(goalsProvider.notifier);
      final List<GoalsState> states = [];
      container.listen<GoalsState>(goalsProvider, (previous, next) {
        states.add(next);
      });

      await notifier.createGoal(
        'Drink Water',
        'Health',
        8,
        'glasses',
        'Oct 15',
      );

      // Check transitions: 2 state updates occur (isLoading true, then loaded)
      expect(states.length, 2);
      expect(states[0].isLoading, true);
      expect(states[1].isLoading, false);
      expect(states[1].goals.length, 4);
      expect(states[1].goals.last.title, 'Drink Water');
      expect(states[1].goals.last.category, 'Health');
    });

    test('Setting progress updates goal fraction', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(goalsProvider.notifier);
      await notifier.setProgress('goal-1', 0.95);

      final finalState = container.read(goalsProvider);
      expect(finalState.goals.first.progress, 0.95);
    });
  });

  group('Memory Provider Tests', () {
    test('Initial state loads default memories list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final memoryState = container.read(memoryProvider);
      expect(memoryState.memories.length, 3);
      expect(memoryState.memories.first.title, 'Favorite Coffee Order');
      expect(memoryState.isLoading, false);
    });

    test('Creating memory appends to state list', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(memoryProvider.notifier);
      final List<MemoryState> states = [];
      container.listen<MemoryState>(memoryProvider, (previous, next) {
        states.add(next);
      });

      await notifier.createMemory(
        'Birth Date',
        'October 31st',
        MemoryCategory.personal,
        'medium',
        false,
      );

      // Check transitions: 2 state updates occur (isLoading true, then loaded)
      expect(states.length, 2);
      expect(states[0].isLoading, true);
      expect(states[1].isLoading, false);
      expect(states[1].memories.length, 4);
      expect(states[1].memories.first.title, 'Birth Date');
    });

    test('Toggling pin status updates state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(memoryProvider.notifier);

      // Toggle pinned memory (initially true)
      await notifier.togglePinState('mem-1');

      final nextState = container.read(memoryProvider);
      expect(nextState.memories.first.isPinned, false);
    });

    test('Removing memory deletes from list', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(memoryProvider.notifier);
      await notifier.removeMemory('mem-3');

      final finalState = container.read(memoryProvider);
      expect(finalState.memories.length, 2);
    });
  });

  group('Voice Provider Tests', () {
    test('Initial state parameters are set correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final voiceState = container.read(voiceProvider);
      expect(voiceState.status, VoiceStatus.listening);
      expect(voiceState.isMuted, false);
      expect(voiceState.isSpeakerOn, true);
    });

    test('Toggling mute/speaker updates state properties', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(voiceProvider.notifier);

      notifier.toggleMute();
      expect(container.read(voiceProvider).isMuted, true);

      notifier.toggleSpeaker();
      expect(container.read(voiceProvider).isSpeakerOn, false);
    });

    test('Explicitly setting status modifies call state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(voiceProvider.notifier);

      notifier.setStatus(VoiceStatus.speaking);
      expect(container.read(voiceProvider).status, VoiceStatus.speaking);
    });
  });

  group('Vision Provider Tests', () {
    test('Initial state parameters are empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final visionState = container.read(visionProvider);
      expect(visionState.imagePath, null);
      expect(visionState.isScanning, false);
      expect(visionState.showResults, false);
      expect(visionState.detectedObjects.length, 0);
    });

    test('Selecting image sets path and runs scanner', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(visionProvider.notifier);
      final List<VisionState> states = [];
      container.listen<VisionState>(visionProvider, (previous, next) {
        states.add(next);
      });

      notifier.selectImage('camera');

      // Check immediate transition: image loaded and isScanning true
      expect(states.length, 1);
      expect(states[0].imagePath != null, true);
      expect(states[0].isScanning, true);
      expect(states[0].showResults, false);

      // Wait for future delayed scanning (2 seconds)
      await Future.delayed(const Duration(milliseconds: 2100));

      final finalState = container.read(visionProvider);
      expect(finalState.isScanning, false);
      expect(finalState.showResults, true);
      expect(finalState.detectedObjects.length, 3);
      expect(finalState.detectedObjects.first['name'], 'Laptop');
      expect(finalState.ocrText != null, true);
    });

    test('Clearing scanner resets state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(visionProvider.notifier);
      notifier.selectImage('gallery');
      notifier.clearImage();

      final resetState = container.read(visionProvider);
      expect(resetState.imagePath, null);
      expect(resetState.showResults, false);
    });
  });

  group('Profile Provider Tests', () {
    test('Initial state parameters are set correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(profileProvider);
      expect(state.userName, 'Alex Rivera');
      expect(state.email, 'alex.rivera@example.com');
      expect(state.selectedPersonality, 'Empathetic');
    });

    test('Updating profile values alters name and email', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profileProvider.notifier);
      notifier.updateProfile('Alex R.', 'alexr@gmail.com');

      final nextState = container.read(profileProvider);
      expect(nextState.userName, 'Alex R.');
      expect(nextState.email, 'alexr@gmail.com');
    });

    test('Updating personality modifies selector values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profileProvider.notifier);
      notifier.setPersonality('Analytical');

      final nextState = container.read(profileProvider);
      expect(nextState.selectedPersonality, 'Analytical');
    });
  });

  group('Settings Provider Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state parameters are set correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(settingsProvider);
      expect(state.isDarkMode, false);
      expect(state.notificationsEnabled, true);
    });

    test('Toggling dark mode and notifications alters state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);

      notifier.toggleDarkMode();
      expect(container.read(settingsProvider).isDarkMode, true);

      notifier.toggleNotifications();
      expect(container.read(settingsProvider).notificationsEnabled, false);
    });

    test('Modifying pitch updates state values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);

      notifier.setVoicePitch('Calm');
      expect(container.read(settingsProvider).voicePitch, 'Calm');
    });
  });

  group('Notifications Provider Tests', () {
    test('Initial state preloads mock alerts', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(notificationsProvider);
      expect(state.notifications.length, 3);
      expect(state.notifications.any((n) => !n.isRead), true);
    });

    test('Reading individual notification changes its status', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);
      await notifier.readNotification('notif-1');

      final nextState = container.read(notificationsProvider);
      expect(
        nextState.notifications.firstWhere((n) => n.id == 'notif-1').isRead,
        true,
      );
    });

    test('Dismissing notification removes it from list', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);
      await notifier.dismiss('notif-2');

      final finalState = container.read(notificationsProvider);
      expect(finalState.notifications.any((n) => n.id == 'notif-2'), false);
      expect(finalState.notifications.length, 2);
    });
  });

  group('Mood Theme and ThemeNotifier Tests', () {
    test(
      'MoodThemeModel.fromMoodName returns correct color palettes and fallbacks',
      () {
        final happy = MoodThemeModel.fromMoodName('Happy');
        expect(happy.name, 'Happy');
        expect(happy.primary, const Color(0xFFFFB84D));
        expect(happy.background, const Color(0xFFFFF7EF));

        final calm = MoodThemeModel.fromMoodName('Calm');
        expect(calm.name, 'Calm');
        expect(calm.primary, const Color(0xFF7C9EFF));

        final tired = MoodThemeModel.fromMoodName('Tired');
        expect(tired.name, 'Tired');
        expect(tired.primary, const Color(0xFF8E9AAF));

        final inspired = MoodThemeModel.fromMoodName('Inspired');
        expect(inspired.name, 'Inspired');
        expect(inspired.primary, const Color(0xFFFF3B30));

        final reflective = MoodThemeModel.fromMoodName('Reflective');
        expect(reflective.name, 'Reflective');
        expect(reflective.primary, const Color(0xFFEC4899));

        final unknown = MoodThemeModel.fromMoodName('UnknownMood');
        expect(unknown.name, 'Happy'); // Fallback to Happy
      },
    );

    test(
      'ThemeState handles mood select states and providers correctly',
      () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(themeProvider.notifier);

        // Default state
        expect(container.read(themeProvider).currentMood, 'none');
        expect(container.read(themeProvider).hasMoodSelected, false);
        expect(
          container.read(themeProvider).accentColor,
          const Color(0xFFFFB84D),
        ); // default AppColors.primary

        // Set mood
        await notifier.setMoodTheme('Calm');
        expect(container.read(themeProvider).currentMood, 'Calm');
        expect(container.read(themeProvider).hasMoodSelected, true);
        expect(
          container.read(themeProvider).accentColor,
          const Color(0xFF7C9EFF),
        ); // Calm primary

        // Clear mood
        await notifier.clearMoodTheme();
        expect(container.read(themeProvider).currentMood, 'none');
        expect(container.read(themeProvider).hasMoodSelected, false);
      },
    );
  });
}
