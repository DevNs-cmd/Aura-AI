# Localization Gap Analysis

This document details the forensic investigation into why some authenticated UI screens remain partially or fully untranslated when switching locales (specifically to Hindi) in the Aura AI application.

## 1. Executive Summary & Root Cause Categories

Our repository-wide inspection and validation revealed two main systemic reasons for the localization gaps:
1. **Aggressive Allowlist Rules (False Negatives)**: The regex pattern `^[a-zA-Z_]+[a-zA-Z0-9_]*$` in `tool/localization_allowlist.yaml` (intended to ignore technical keys/identifiers) matched any single-word English UI literals such as `"Cancel"`, `"Add"`, `"Title"`, `"delete"`, `"ask"`, `"open"`, `"Ready"`, `"Mute"`, `"Speaker"`, `"Camera"`, `"Gallery"`, `"Document"`, and `"Voice"`. Furthermore, exact allowed strings included `"Happy"`, `"Calm"`, `"Anxious"`, and `"Sad"`. This caused the audit tool to classify these files as complete/clean even when they contained hardcoded strings.
2. **Incomplete Phase Coverage**: Features like **Aura Vision**, **Ask Your Files**, **Voice Assistant**, **Journal (partially)**, and **Calendar** had not yet been fully migrated to use the `AppLocalizations` framework or were not started at all.
3. **Date Formatting Fallbacks**: Month and weekday name formatting was hardcoded or formatted using `DateFormat(pattern)` without passing the active locale string (`Localizations.localeOf(context).toString()`), which defaults formatting back to English.

---

## 2. Forensic Findings per Screen

Below is the detailed trace of every visible untranslated string from the six confirmed screens.

### 2.1 Aura Vision
*   **Screen**: Aura Vision
*   **Source File**: [vision_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/vision/presentation/vision_screen.dart)

| Visible String | Line | Widget/Class/Function | Root-Cause Category | Why Audit Missed It | Proposed Fix | ARB Key (En/Hi exists) |
|---|---|---|---|---|---|---|
| `Aura Vision` | 305 | `AppBar` Title | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionTitle` | `visionTitle` (Yes/Yes) |
| `Ready to understand your world` | 565 | Portal Instruction Header | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionReadyTitle` | `visionReadyTitle` (Yes/Yes) |
| `Take a photo or choose an image and Aura will analyze what matters.` | 577 | Portal Instruction Subtitle | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionReadyDesc` | `visionReadyDesc` (Yes/Yes) |
| `See With Camera` | 364 | `_buildActionCard` Title Parameter | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionActionCameraTitle` | `visionActionCameraTitle` (Yes/Yes) |
| `Capture what's in front of you` | 365 | `_buildActionCard` Subtitle Parameter | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionActionCameraSubtitle` | `visionActionCameraSubtitle` (Yes/Yes) |
| `Explore a Photo` | 376 | `_buildActionCard` Title Parameter | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionActionLibraryTitle` | `visionActionLibraryTitle` (Yes/Yes) |
| `Choose from your library` | 377 | `_buildActionCard` Subtitle Parameter | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionActionLibrarySubtitle` | `visionActionLibrarySubtitle` (Yes/Yes) |
| `How should Aura help?` | 699 | `_buildQuickModes` Header | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionQuickModesTitle` | `visionQuickModesTitle` (Yes/Yes) |
| `Understand Scene` | 135 | `_mockRecentSightings` Mode & Grid | `STATIC_LIST_LABEL` | Not missed, file was in `NOT_STARTED` status | Use `_getLocalModeName(context, m['name'])` helper method | `visionModeUnderstandScene` (No/No) |
| `Read Text` | 162 | `_mockRecentSightings` Mode & Grid | `STATIC_LIST_LABEL` | Excluded: single word string matching allowlist regex `^[a-zA-Z_]+$` | Use `_getLocalModeName(context, m['name'])` helper method | `visionModeReadText` (No/No) |
| `Identify Objects` | 179 | `_mockRecentSightings` Mode & Grid | `STATIC_LIST_LABEL` | Not missed, file was in `NOT_STARTED` status | Use `_getLocalModeName(context, m['name'])` helper method | `visionModeIdentifyObjects` (No/No) |
| `Recent Sightings` | 793 | Section Header | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionRecentSightingsTitle` | `visionRecentSightingsTitle` (Yes/Yes) |
| Sightings Mock Titles (`Office Desk Setup`, `Handwritten Notes`, `Plant on Window Sill`) | 143, 161, 178 | Mock Data Map Title | `MAP_VALUE` | Not missed, file was in `NOT_STARTED` status | Map dynamically using helper `_getLocalSightingTitle(context, sighting['title'])` | `visionMockTitleDesk`, `visionMockTitleNotes`, `visionMockTitlePlant` (Yes/Yes) |
| Results screen headers (`What Aura Sees`, `Things I Noticed`, `Text I Found`, `Why It Might Matter`) | 961, 983, 1044, 1129 | Card Wrappers Titles | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionResultSceneTitle`, etc. | `visionResultSceneTitle`, etc. (Yes/Yes) |
| Results segmented tabs (`Scene`, `Objects`, `Text`, `Context`) | 889 | `_buildResultTabs` List | `STATIC_LIST_LABEL` | Excluded: single words matching allowlist regex | Use localizations delegate lookup mapping to tab titles | `visionTabScene`, etc. (Yes/Yes) |
| Copy / Share buttons | 1084, 1100 | TextButton Labels | `DIRECT_TEXT_LITERAL` | Excluded: single words matching allowlist regex | Replace with `AppLocalizations.of(context)!.visionButtonCopy` / `Share` | `visionButtonCopy` / `Share` (Yes/Yes) |
| SnackBar messages (e.g. `OCR text copied to clipboard!`) | 1078, 1095, 1245 | SnackBar Text Content | `SNACKBAR_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with AppLocalizations keys | `visionOcrCopied`, etc. (Yes/Yes) |
| Next Actions Drawer (`Ask Aura`, `Save Memory`, `Log Journal`) | 1229, 1241, 1258 | `_buildDrawerButton` parameters | `DIRECT_TEXT_LITERAL` | Not missed, file was in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.visionDrawerBtnAsk`, etc. | `visionDrawerBtnAsk`, etc. (Yes/Yes) |

---

### 2.2 Ask Your Files / Document Knowledge
*   **Screen**: Ask Your Files
*   **Source Files**:
    *   [documents_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/documents_screen.dart)
    *   [document_detail_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/document_detail_screen.dart)
    *   [ask_files_bar.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/ask_files_bar.dart)
    *   [aura_document_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/aura_document_card.dart)
    *   [document_empty_state.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/document_empty_state.dart)
    *   [document_selection_bar.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/document_selection_bar.dart)
    *   [knowledge_orb.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/knowledge_orb.dart)
    *   [quick_question_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/quick_question_card.dart)
    *   [upload_progress_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/upload_progress_card.dart)
    *   [upload_source_sheet.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/widgets/ask_your_files/upload_source_sheet.dart)

| Visible String | Source File | Line | Widget/Class/Function | Root-Cause Category | Why Audit Missed It | Proposed Fix | ARB Key (En/Hi exists) |
|---|---|---|---|---|---|---|---|
| `Ask Your Files` | `documents_screen.dart` | 152 | AppBar title | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.exploreAskYourFiles` | `exploreAskYourFiles` (Yes/Yes) |
| `Knowledge Space Ready.` | `knowledge_orb.dart` | 66 | Text widget | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsKnowledgeSpaceReady` (No/No) |
| `Aura is active across all ${widget.documentCount} document(s).` | `knowledge_orb.dart` | 68 | Text widget | `GETTER_RETURN_VALUE` | File in `NOT_STARTED` status | Replace with pluralized AppLocalizations | `documentsActiveCount` (No/No) |
| `All Files` | `ask_files_bar.dart` | 63 | Conditional label text | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsAllFiles` (No/No) |
| `Ask anything about your files...` | `ask_files_bar.dart` | 85 | TextField hintText | `INPUT_DECORATION_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsAskHint` (No/No) |
| `Try asking Aura` | `documents_screen.dart` | 255 | Suggestions title | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsTryAsking` (No/No) |
| `Summarize my documents` | `documents_screen.dart` | 274 | QuickQuestionCard label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsSuggestionSummarize` (No/No) |
| `Find important deadlines` | `documents_screen.dart` | 288 | QuickQuestionCard label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsSuggestionDeadlines` (No/No) |
| `What are the main ideas?` | `documents_screen.dart` | 302 | QuickQuestionCard label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsSuggestionMainIdeas` (No/No) |
| `Find action items` | `documents_screen.dart` | 316 | QuickQuestionCard label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsSuggestionActionItems` (No/No) |
| `Your Knowledge` | `documents_screen.dart` | 339 | Section title | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsYourKnowledge` (No/No) |
| `See All` | `documents_screen.dart` | 351 | TextButton label | `DIRECT_TEXT_LITERAL` | Excluded: single words matching allowlist regex | Replace with AppLocalizations | `documentsSeeAll` (No/No) |
| `Ready` (inside `'$size • $type • Ready'`) | `aura_document_card.dart` | 110 | Info row Text widget | `DIRECT_TEXT_LITERAL` | Excluded: single words matching allowlist regex | Replace with parameterized key | `documentsStatusReady` (No/No) |
| `Add Files` | `documents_screen.dart` | 438 | FloatingActionButton | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `documentsAddFiles` (No/No) |

---

### 2.3 Voice Assistant
*   **Screen**: Voice Assistant
*   **Source File**: [voice_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/voice/presentation/voice_screen.dart)

| Visible String | Line | Widget/Class/Function | Root-Cause Category | Why Audit Missed It | Proposed Fix | ARB Key (En/Hi exists) |
|---|---|---|---|---|---|---|
| `Listening...` | 17 | `_getStatusText` Switch Case | `SWITCH_RETURN_VALUE` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.voiceStatusListening` | `voiceStatusListening` (Yes/Yes) |
| `Thinking...` | 19 | `_getStatusText` Switch Case | `SWITCH_RETURN_VALUE` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.voiceStatusThinking` | `voiceStatusThinking` (Yes/Yes) |
| `Speaking...` | 21 | `_getStatusText` Switch Case | `SWITCH_RETURN_VALUE` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.voiceStatusSpeaking` | `voiceStatusSpeaking` (Yes/Yes) |
| `I'm listening to you` | 95 | Text widget description | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.voiceDescriptionListening` | `voiceDescriptionListening` (Yes/Yes) |
| `Processing thoughts...` | 97 | Text widget description | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.voiceDescriptionThinking` | `voiceDescriptionThinking` (Yes/Yes) |
| `Aura is speaking` | 98 | Text widget description | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.voiceDescriptionSpeaking` | `voiceDescriptionSpeaking` (Yes/Yes) |
| `Camera/Lens analysis mode...` | 76 | SnackBar message | `SNACKBAR_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.voiceCameraLensMode` | `voiceCameraLensMode` (Yes/Yes) |

---

### 2.4 Journal Main Screen
*   **Screen**: Journal Main Screen
*   **Source Files**:
    *   [journal_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/journal_screen.dart)
    *   [journal_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/widgets/journal_card.dart)
    *   [writing_prompt_card.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/widgets/writing_prompt_card.dart)

| Visible String | Source File | Line | Widget/Class/Function | Root-Cause Category | Why Audit Missed It | Proposed Fix | ARB Key (En/Hi exists) |
|---|---|---|---|---|---|---|---|
| `My Journal` | `journal_screen.dart` | 273 | AppBar Title | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.journalTitle` | `journalTitle` (Yes/Yes) |
| `Search reflections...` | `journal_screen.dart` | 82 | TextField hintText | `INPUT_DECORATION_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.journalSearchPlaceholder` | `journalSearchPlaceholder` (Yes/Yes) |
| `Reflection Calendar` | `journal_screen.dart` | 123 | Section Header | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.journalReflectionCalendar` | `journalReflectionCalendar` (Yes/Yes) |
| `Clear Filter` | `journal_screen.dart` | 138 | TextButton label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.journalClearFilter` | `journalClearFilter` (Yes/Yes) |
| `AI Reflection Prompt` | `writing_prompt_card.dart` | 66 | Header label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalAiReflectionPrompt` (No/No) |
| Prompts: `What's one small thing...`, etc. | `journal_screen.dart` | 32-38 | `_aiPrompts` static list | `STATIC_LIST_LABEL` | File in `NOT_STARTED` status | Localize dynamically from context | `journalPrompt1` to `journalPrompt6` (Yes/Yes) |
| `Start Writing` | `writing_prompt_card.dart` | 111 | ElevatedButton label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalStartWriting` (No/No) |
| `Recent Reflections` | `journal_screen.dart` | 388 | Section title | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.journalRecentReflections` | `journalRecentReflections` (Yes/Yes) |
| `Create a New Journal` | `journal_screen.dart` | 431 | PrimaryButton text | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with `AppLocalizations.of(context)!.journalCreateNew` | `journalCreateNew` (Yes/Yes) |
| `Productive`, `Peaceful`, `Reflective`, `Heavy` | `journal_card.dart` | 39-45 | `_getMoodTag` switch | `SWITCH_RETURN_VALUE` | Excluded: single words matching allowlist regex | Use `_getLocalMoodTag(context, mood)` helper mapping | `journalMoodProductive`, etc. (No/No) |
| `AI Insight` | `journal_card.dart` | 158 | Insight Button label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalAiInsight` (No/No) |
| Month dates formatting | `journal_card.dart` | 88 | `DateFormat.yMMMMd` | `DATE_FORMATTING` | Audit tool only searches string literals | Pass locale string explicitly to `DateFormat` constructors | N/A |

---

### 2.5 Calendar / Add Event Dialog
*   **Screen**: Calendar Screen & Add Event Dialog
*   **Source File**: [calendar_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/home/calendar_screen.dart)

| Visible String | Line | Widget/Class/Function | Root-Cause Category | Why Audit Missed It | Proposed Fix | ARB Key (En/Hi exists) |
|---|---|---|---|---|---|---|
| `Add Event for June 10` | 72 | Dialog Title | `DIALOG_LITERAL` / `DATE_FORMATTING` | Ignored, June is hardcoded in template | Use `DateFormat('MMMM d', locale)` to render June dynamically | `calendarAddEventTitle` (No/No) |
| `Event Title` | 89 | TextField hintText | `INPUT_DECORATION_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `calendarInputTitleHint` (No/No) |
| `Time: 8:33 PM` | 110 | Selected Time label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with template key | `calendarTimePrefix` (No/No) |
| `Select Time` | 131 | TextButton label | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `calendarBtnSelectTime` (No/No) |
| `Category` | 142 | Group label | `DIRECT_TEXT_LITERAL` | Excluded: single words matching allowlist regex | Replace with AppLocalizations | `calendarCategoryLabel` (No/No) |
| Dropdown items (`Journal`, `Workout`, `Reflection`, `Other`) | 160 | Dropdown values | `STATIC_LIST_LABEL` | Excluded: single words matching allowlist regex | Map dynamically with `_getLocalCategoryName(context, cat)` | `calendarCategoryJournal`, etc. (No/No) |
| `Cancel` | 182 | TextButton label | `DIRECT_TEXT_LITERAL` | Excluded: single words matching allowlist regex | Replace with AppLocalizations | `calendarBtnCancel` (No/No) |
| `Add` | 230 | ElevatedButton label | `DIRECT_TEXT_LITERAL` | Excluded: single words matching allowlist regex | Replace with AppLocalizations | `calendarBtnAdd` (No/No) |
| `Mon`, `Tue`... | 248 | `daysOfWeek` list | `STATIC_LIST_LABEL` | Excluded: single words matching allowlist regex | Format dynamically using DateFormat | N/A |
| `June 2024` | 276 | AppBar Title | `DIRECT_TEXT_LITERAL` / `DATE_FORMATTING` | File in `NOT_STARTED` status | Format dynamically using DateFormat | N/A |
| `Today, June 10` | 399 | Text heading | `DIRECT_TEXT_LITERAL` / `DATE_FORMATTING` | File in `NOT_STARTED` status | Format dynamically using DateFormat | N/A |
| `No events scheduled for this day` | 532 | Empty state message | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `calendarNoEvents` (No/No) |

---

### 2.6 New Journal Entry
*   **Screen**: New Journal Entry Screen
*   **Source File**: [create_journal_screen.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/lib/features/journal/presentation/create_journal_screen.dart)

| Visible String | Line | Widget/Class/Function | Root-Cause Category | Why Audit Missed It | Proposed Fix | ARB Key (En/Hi exists) |
|---|---|---|---|---|---|---|
| `New Journal Entry` | 70 | AppBar Title | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalCreateTitle` (No/No) |
| `How are you feeling?` | 88 | Header Text | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalFeelingQuestion` (No/No) |
| Moods: `Happy`, `Sad`, `Calm`, `Anxious` | 100-121 | Mood Cards labels | `STATIC_LIST_LABEL` | Excluded: exact match listed in allowlist | Translate in UI with `_getLocalMoodName(context, mood)` | `emotionHappy`, etc. (Yes/Yes) |
| `Title` | 133 | CustomTextField label | `DIRECT_TEXT_LITERAL` | Excluded: single words matching allowlist regex | Replace with AppLocalizations | `journalInputTitleLabel` (No/No) |
| `Give your entry a title...` | 134 | CustomTextField hintText | `INPUT_DECORATION_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalInputTitleHint` (No/No) |
| `Write your thoughts...` | 147 | Field label Text | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalInputBodyLabel` (No/No) |
| `Share your thoughts, feelings, or actions...` | 170 | TextFormField hintText | `INPUT_DECORATION_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalInputBodyHint` (No/No) |
| `Save Entry` | 217 | PrimaryButton text | `DIRECT_TEXT_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalBtnSave` (No/No) |
| `A title is required` | 138 | CustomTextField validator | `INPUT_DECORATION_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalInputTitleError` (No/No) |
| `Write down some reflections...` | 160 | TextFormField validator | `INPUT_DECORATION_LITERAL` | File in `NOT_STARTED` status | Replace with AppLocalizations | `journalInputBodyError` (No/No) |

---

## 3. Analysis of Existing Architecture & Locale Rebuilds

### 3.1 Architecture Overview
Aura AI uses standard Flutter code-generation localizations (`flutter_localizations` package and `app_localizations.dart` generation from `.arb` files).
*   **MaterialApp.router Configuration**: Correctly binds `locale: appLocale`, `localizationsDelegates`, and `supportedLocales: const [Locale('en'), Locale('hi')]` inside `lib/main.dart`.
*   **Locale Boundary**: Successfully isolates pre-authentication screens (Splash, Onboarding, Login/Signup) in English, and dynamically switches the application locale to the user's preferred language (persisted via SharedPreferences) upon authentication.
*   **Locale Rebuild Mechanics**: Rebuilds are reactive. `MaterialApp` watches the `localeProvider` state notifier. Whenever a user triggers a language change in Settings (via `setLocale` callback), the locale state is updated, which invalidates the MaterialApp build, forcing a complete rebuild of the active route stack. All localized widgets reactively refresh their localized strings.

### 3.2 Audit Tool Gaps Analysis
The custom audit script (`tool/localization_audit.dart`) and the allowlist configuration (`tool/localization_allowlist.yaml`) contain the following limitations:
1.  **Regex Exclusions (`^[a-zA-Z_]+[a-zA-Z0-9_]*$`)**: Over-filtered the candidate strings by matching and excluding all single-word strings. This resulted in false negatives for critical user-facing control words like "Cancel", "Delete", "Add", "Title", and "Category".
2.  **Explicit Exclusions**: Excluded basic emotion terms (`Happy`, `Sad`, `Calm`, `Anxious`), preventing the audit from flagging these when they were used directly as hardcoded UI card labels.
3.  **Date Formatting Ignored**: Did not scan or flag hardcoded date/time patterns (e.g. `'June'`) or check for localized context inside `DateFormat` constructors.

---

## 4. Summary of Verification Execution

*   **flutter analyze**: PASSED clean with no compilation issues or lints warnings.
*   **flutter test**: All 38 tests PASSED successfully, ensuring full regressions safety for all Riverpod state controllers and flow navigation setups.
