# Localization Inventory

This file catalogs every UI surface in the Aura AI application, derived from code inspection.

## Category Summary
- **CORE**: 1/9 localized
- **AUTH**: 0/5 localized
- **CHAT**: 1/4 localized
- **GOALS**: 0/8 localized
- **HOME**: 5/17 localized
- **JOURNAL**: 0/8 localized
- **MEMORY**: 0/5 localized
- **MOOD**: 0/1 localized
- **NOTIFICATIONS**: 0/2 localized
- **PROFILE**: 1/5 localized
- **SETTINGS**: 0/2 localized
- **SPLASH**: 0/1 localized
- **VISION**: 0/4 localized
- **VOICE**: 0/1 localized
- **APP SHELL**: 0/1 localized

## Detailed Inventory

### CORE

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **LocaleNotifier** | [locale_controller.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/localization/locale_controller.dart) | 1 | `NOT_STARTED` | Contains 1 hardcoded strings |
| **SupportedLanguage** | [supported_languages.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/localization/supported_languages.dart) | 9 | `NOT_STARTED` | Contains 9 hardcoded strings |
| **MoodThemeModel** | [mood_theme_model.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/theme/mood_theme_model.dart) | 66 | `PARTIAL` | Contains 49 hardcoded strings |
| **ThemeState** | [theme_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/theme/theme_provider.dart) | 11 | `NOT_STARTED` | Contains 11 hardcoded strings |
| **EmotionBarItemData** | [emotion_bar.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/widgets/emotion_bar.dart) | 12 | `PARTIAL` | Contains 9 hardcoded strings |
| **MoodLandscapeIllustration** | [mood_landscape_illustration.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/core/widgets/mood_landscape_illustration.dart) | 12 | `NOT_STARTED` | Contains 12 hardcoded strings |
| **AuraApp** | [main.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/main.dart) | 2 | `COMPLETE` | Fully localized with 2 keys |
| **Memory** | [memory.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/models/memory.dart) | 1 | `NOT_STARTED` | Contains 1 hardcoded strings |
| **User** | [user.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/models/user.dart) | 8 | `NOT_STARTED` | Contains 8 hardcoded strings |

### AUTH

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **AuthState** | [auth_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/auth_provider.dart) | 4 | `NOT_STARTED` | Contains 4 hardcoded strings |
| **AuthRepository** | [auth_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/auth_repository.dart) | 14 | `NOT_STARTED` | Contains 14 hardcoded strings |
| **ForgotPasswordScreen** | [forgot_password_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/forgot_password_screen.dart) | 11 | `NOT_STARTED` | Contains 11 hardcoded strings |
| **LoginScreen** | [login_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/login_screen.dart) | 33 | `NOT_STARTED` | Contains 33 hardcoded strings |
| **OnboardingScreen** | [onboarding_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/auth/onboarding_screen.dart) | 20 | `NOT_STARTED` | Contains 20 hardcoded strings |

### CHAT

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **ChatRepository** | [chat_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/chat/chat_repository.dart) | 49 | `NOT_STARTED` | Contains 49 hardcoded strings |
| **ChatScreen** | [chat_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/chat/presentation/chat_screen.dart) | 22 | `PARTIAL` | Contains 15 hardcoded strings |
| **ChatBubble** | [chat_bubble.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/chat/presentation/widgets/chat_bubble.dart) | 24 | `NOT_STARTED` | Contains 24 hardcoded strings |
| **MessageInput** | [message_input.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/chat/presentation/widgets/message_input.dart) | 1 | `COMPLETE` | Fully localized with 1 keys |

### GOALS

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **GoalsState** | [goals_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/goals_provider.dart) | 1 | `NOT_STARTED` | Contains 1 hardcoded strings |
| **GoalsRepository** | [goals_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/goals_repository.dart) | 19 | `NOT_STARTED` | Contains 19 hardcoded strings |
| **CreateGoalScreen** | [create_goal_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/create_goal_screen.dart) | 20 | `NOT_STARTED` | Contains 20 hardcoded strings |
| **GoalsScreen** | [goals_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/goals_screen.dart) | 14 | `NOT_STARTED` | Contains 14 hardcoded strings |
| **GoalDetailScreen** | [goal_detail_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/goal_detail_screen.dart) | 25 | `NOT_STARTED` | Contains 25 hardcoded strings |
| **CategoryFocusChart** | [category_focus_chart.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/widgets/category_focus_chart.dart) | 4 | `NOT_STARTED` | Contains 4 hardcoded strings |
| **GoalTile** | [goal_tile.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/widgets/goal_tile.dart) | 1 | `NOT_STARTED` | Contains 1 hardcoded strings |
| **ProductivityChart** | [productivity_chart.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/goals/presentation/widgets/productivity_chart.dart) | 8 | `NOT_STARTED` | Contains 8 hardcoded strings |

### HOME

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **CalendarEvent** | [calendar_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/calendar_screen.dart) | 22 | `PARTIAL` | Contains 10 hardcoded strings |
| **DocumentsScreen** | [documents_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/documents_screen.dart) | 67 | `PARTIAL` | Contains 56 hardcoded strings |
| **DocumentDetailScreen** | [document_detail_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/document_detail_screen.dart) | 41 | `PARTIAL` | Contains 30 hardcoded strings |
| **ExploreScreen** | [explore_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/explore_screen.dart) | 16 | `PARTIAL` | Contains 5 hardcoded strings |
| **HomeScreen** | [home_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/home_screen.dart) | 28 | `PARTIAL` | Contains 8 hardcoded strings |
| **AskFilesBar** | [ask_files_bar.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/ask_files_bar.dart) | 8 | `COMPLETE` | Fully localized with 8 keys |
| **AuraDocumentCard** | [aura_document_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/aura_document_card.dart) | 14 | `PARTIAL` | Contains 9 hardcoded strings |
| **DocumentEmptyState** | [document_empty_state.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/document_empty_state.dart) | 4 | `COMPLETE` | Fully localized with 4 keys |
| **DocumentSelectionBar** | [document_selection_bar.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/document_selection_bar.dart) | 5 | `PARTIAL` | Contains 1 hardcoded strings |
| **KnowledgeOrb** | [knowledge_orb.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/knowledge_orb.dart) | 11 | `COMPLETE` | Fully localized with 11 keys |
| **UploadProgressCard** | [upload_progress_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/upload_progress_card.dart) | 2 | `PARTIAL` | Contains 1 hardcoded strings |
| **UploadSourceSheet** | [upload_source_sheet.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/upload_source_sheet.dart) | 13 | `PARTIAL` | Contains 3 hardcoded strings |
| **GoalProgressCard** | [goal_progress.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/goal_progress.dart) | 1 | `COMPLETE` | Fully localized with 1 keys |
| **HeroCard** | [hero_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/hero_card.dart) | 17 | `PARTIAL` | Contains 7 hardcoded strings |
| **MoodItem** | [mood_selector.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/mood_selector.dart) | 14 | `PARTIAL` | Contains 12 hardcoded strings |
| **QuickActionItem** | [quick_actions.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/quick_actions.dart) | 15 | `PARTIAL` | Contains 12 hardcoded strings |
| **MemoryUiItem** | [recent_memories.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/recent_memories.dart) | 1 | `COMPLETE` | Fully localized with 1 keys |

### JOURNAL

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **JournalState** | [journal_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/journal_provider.dart) | 1 | `NOT_STARTED` | Contains 1 hardcoded strings |
| **JournalRepository** | [journal_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/journal_repository.dart) | 27 | `NOT_STARTED` | Contains 27 hardcoded strings |
| **CreateJournalScreen** | [create_journal_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/create_journal_screen.dart) | 23 | `PARTIAL` | Contains 9 hardcoded strings |
| **JournalDetailScreen** | [journal_detail_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/journal_detail_screen.dart) | 12 | `PARTIAL` | Contains 9 hardcoded strings |
| **JournalScreen** | [journal_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/journal_screen.dart) | 13 | `PARTIAL` | Contains 3 hardcoded strings |
| **JournalCard** | [journal_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/widgets/journal_card.dart) | 11 | `PARTIAL` | Contains 9 hardcoded strings |
| **JournalMoodItem** | [mood_selector.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/widgets/mood_selector.dart) | 10 | `PARTIAL` | Contains 8 hardcoded strings |
| **WritingPromptCard** | [writing_prompt_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/widgets/writing_prompt_card.dart) | 5 | `PARTIAL` | Contains 1 hardcoded strings |

### MEMORY

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **MemoryState** | [memory_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/memory_provider.dart) | 1 | `NOT_STARTED` | Contains 1 hardcoded strings |
| **MemoryRepository** | [memory_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/memory_repository.dart) | 11 | `NOT_STARTED` | Contains 11 hardcoded strings |
| **CreateMemoryScreen** | [create_memory_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/presentation/create_memory_screen.dart) | 15 | `NOT_STARTED` | Contains 15 hardcoded strings |
| **MemoryScreen** | [memory_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/presentation/memory_screen.dart) | 19 | `NOT_STARTED` | Contains 19 hardcoded strings |
| **MemoryCardTile** | [memory_card_tile.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/memory/presentation/widgets/memory_card_tile.dart) | 10 | `NOT_STARTED` | Contains 10 hardcoded strings |

### MOOD

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **MoodSelectionScreen** | [mood_selection_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/mood/presentation/mood_selection_screen.dart) | 53 | `NOT_STARTED` | Contains 53 hardcoded strings |

### NOTIFICATIONS

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **NotificationsRepository** | [notifications_repository.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/notifications/notifications_repository.dart) | 15 | `NOT_STARTED` | Contains 15 hardcoded strings |
| **NotificationsScreen** | [notifications_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/notifications/presentation/notifications_screen.dart) | 28 | `NOT_STARTED` | Contains 28 hardcoded strings |

### PROFILE

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **EditProfileScreen** | [edit_profile_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/profile/presentation/edit_profile_screen.dart) | 31 | `PARTIAL` | Contains 20 hardcoded strings |
| **ProfileScreen** | [profile_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/profile/presentation/profile_screen.dart) | 11 | `PARTIAL` | Contains 4 hardcoded strings |
| **PersonalitySelector** | [personality_selector.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/profile/presentation/widgets/personality_selector.dart) | 13 | `PARTIAL` | Contains 10 hardcoded strings |
| **UsageChart** | [usage_chart.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/profile/presentation/widgets/usage_chart.dart) | 1 | `COMPLETE` | Fully localized with 1 keys |
| **ProfileState** | [profile_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/profile/profile_provider.dart) | 3 | `NOT_STARTED` | Contains 3 hardcoded strings |

### SETTINGS

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **SettingsScreen** | [settings_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/settings/presentation/settings_screen.dart) | 21 | `PARTIAL` | Contains 9 hardcoded strings |
| **SettingsState** | [settings_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/settings/settings_provider.dart) | 8 | `NOT_STARTED` | Contains 8 hardcoded strings |

### SPLASH

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **SplashScreen** | [splash_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/splash/presentation/splash_screen.dart) | 4 | `NOT_STARTED` | Contains 4 hardcoded strings |

### VISION

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **_PortalBracketsPainter** | [vision_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/vision/presentation/vision_screen.dart) | 168 | `PARTIAL` | Contains 136 hardcoded strings |
| **DetectedObjectsList** | [detected_objects_list.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/vision/presentation/widgets/detected_objects_list.dart) | 12 | `PARTIAL` | Contains 9 hardcoded strings |
| **OcrCard** | [ocr_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/vision/presentation/widgets/ocr_card.dart) | 3 | `PARTIAL` | Contains 1 hardcoded strings |
| **VisionState** | [vision_provider.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/vision/vision_provider.dart) | 10 | `NOT_STARTED` | Contains 10 hardcoded strings |

### VOICE

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **VoiceAssistantScreen** | [voice_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/voice/presentation/voice_screen.dart) | 17 | `PARTIAL` | Contains 2 hardcoded strings |

### APP SHELL

| Component / Widget | File Path | Candidate Strings | Status | Notes |
|--------------------|-----------|------------------|--------|-------|
| **app_router.dart** | [app_router.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/routes/app_router.dart) | 38 | `NOT_STARTED` | Contains 38 hardcoded strings |
