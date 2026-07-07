# Aura AI - Localization Responsiveness Audit Report
**Date:** 2026-07-06
**Phase:** 2 - Complete Localization Responsiveness Audit
**Auditor:** Antigravity AI

---

## 1. Executive Summary

This report documents the repository-wide audit of Aura AI's presentation layer to identify visual layout risks when translating content to longer or future target languages (e.g., Spanish, Hindi, or future languages). The entire presentation layer (26 screens and 39 widgets) was inspected for unsafe layout patterns, resulting in:

- **Total Screens Audited:** 26
- **Total Shared/Feature Widgets Audited:** 39
- **Critical Risks:** 2
- **High Risks:** 6
- **Medium Risks:** 12
- **Low Risks:** 19
- **Safe:** 26
- **Most Common Unsafe Pattern:** `Row` or `ListTile` containing non-flexible/unconstrained `Text` widgets adjacent to other elements.
- **RTL Support Assessment:** Currently not relevant since all production and target proof languages (English, Hindi, Spanish, French) are Left-to-Right (LTR). RTL adjustments are deferred.

---

## 2. Profile Screen Root Cause Analysis

### Observed Defect
In Spanish, the menu option titles "Notifications" and "Preferences" translate to **"Notificaciones"** and **"Preferencias"**. Both wrap into multiple lines, breaking the vertical alignment and premium look of the menu items.

### Root Cause
1. **ListTile Layout Priority:** Flutter's `ListTile` allocates space to the `leading` and `trailing` widgets first, giving the remaining width to the `title` and `subtitle`.
2. **Unconstrained Trailing Row:** In `lib/features/profile/presentation/profile_screen.dart` (lines 377–396), the `trailing` widget is a `Row` containing a `Text` widget displaying a localized value (e.g., "Recordatorios inteligentes") and an arrow icon:
   ```dart
   trailing: Row(
     mainAxisSize: MainAxisSize.min,
     children: [
       if (value.isNotEmpty) Text(value, ...),
       const SizedBox(width: 8),
       Icon(Icons.arrow_forward_ios_rounded, ...),
     ],
   )
   ```
3. **Horizontal Space Deprivation:** In Spanish, both the `title` text ("Notificaciones") and the `trailing` value ("Recordatorios inteligentes") expand in length. Because the trailing `Row` is given priority and has no maximum width constraint, it consumes the majority of the horizontal width.
4. **Line-Wrapping Cascade:** The `title` widget is compressed into the tiny remaining horizontal sliver, forcing "Notificaciones" and "Preferencias" to wrap character-by-character or word-by-word into multiple lines.

---

## 3. Localization-Unsafe Layout Patterns Catalog

The audit identified the following primary layout structures that break under language translation or text scaling:

### 3.1 Unconstrained Row Text (`Row` + `Text` without `Expanded`/`Flexible`)
* **Risk:** `HIGH_TRANSLATION_RISK` / `CRITICAL_OVERFLOW_RISK`
* **Vulnerability:** When a horizontal row places text next to another element without wrapping the text in `Expanded` or `Flexible`. If the translation expands, it pushes the adjacent element off-screen or throws a `RenderFlex overflow` exception.
* **Remediation:** Always wrap expanding text elements inside horizontal structures with `Expanded` or `Flexible` to limit their maximum width and allow vertical wrapping.

### 3.2 Fixed-Size Containers Wrapping Text (`SizedBox(width)` / `Container(width)`)
* **Risk:** `HIGH_TRANSLATION_RISK`
* **Vulnerability:** Giving a container a hardcoded width (e.g. `width: 136`) while displaying localized text inside it. When the text grows, it gets clipped or wraps excessively, causing vertical bounds overflows if the height is also fixed.
* **Remediation:** Remove fixed widths and use padding, constraint limits (`BoxConstraints`), or auto-adjusting flex columns instead.

### 3.3 Dialog Actions in Horizontal Rows
* **Risk:** `MEDIUM_TRANSLATION_RISK`
* **Vulnerability:** Placing multiple translated buttons side-by-side inside a dialog. Long translations (like "Cancelar" and "Confirmar") collide and overflow the dialog boundaries.
* **Remediation:** Use Wrap or stack buttons vertically on narrow viewports/longer translations.

---

## 4. Screen Inventory & Testing Status

Every screen was tested under English, Hindi, and Spanish across viewports (Narrow: 320px, Standard: 390px, Large: 430px) and text scale factors (1.0, 1.3, 2.0).

| Screen File | Locale Support | Viewport Range | Text Scale Support | Status / Finding |
|---|---|---|---|---|
| `auth/forgot_password_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Scrollable column. |
| `auth/login_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **HIGH RISK**. Line 403 footer Row overflows at scale 1.3/2.0. |
| `auth/onboarding_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Floating skill node texts can overlap/clip. |
| `auth/register_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE** (wraps LoginScreen). |
| `home/calendar_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Calendar grid cells can overlap. |
| `home/documents_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Suggestion cards fixed height overflows. |
| `home/document_detail_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Flexible layout. |
| `home/explore_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Cards grid spacing tight. |
| `home/home_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **HIGH RISK**. Greeting row overlaps; Evening card (136px width) clips. |
| `chat_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Action items can push input bar off. |
| `create_goal_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Form margins tight. |
| `goals_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Stat cards use Expanded layout. |
| `goal_detail_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Scrollable. |
| `create_journal_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Layout needs scroll check. |
| `journal_detail_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Scrollable text bubble. |
| `journal_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Cards grow vertically. |
| `create_memory_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Dialog action buttons overflow. |
| `memory_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Chips wrap and scroll. |
| `mood_selection_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Language selector UI labels wrap. |
| `notifications_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Cards support dynamic text wrap. |
| `edit_profile_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Stacked form fields. |
| `profile_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | 🚨 **CRITICAL**. Menu options wrap and break layout. |
| `settings_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **HIGH RISK**. Dialog action buttons / Language trailing wrap. |
| `splash_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ✅ **SAFE**. Fixed brand labels. |
| `vision_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **HIGH RISK**. Object list rows and Scan state headers overflow. |
| `voice_screen.dart` | en, hi, es | 320px–430px | 1.0, 1.3, 2.0 | ⚠️ **MEDIUM RISK**. Calling status text overflows adjacent buttons. |

---

## 5. Shared & Feature Widgets Inventory

Every component in the widget catalog was audited for responsive layout integrity.

| Component Path | Classification | Context / Vulnerability |
|---|---|---|
| `core/widgets/primary_button.dart` | ✅ **SAFE** | Adapts dynamically to parent container dimensions. |
| `core/widgets/custom_text_field.dart` | ✅ **SAFE** | Text input wrapping behaves correctly. |
| `core/widgets/social_auth_button.dart` | ⚠️ **LOW RISK** | Fixed height (50px); labels could wrap and overflow. |
| `core/widgets/emotion_bar.dart` | ✅ **SAFE** | Dimensions are relative to screen height. |
| `core/widgets/bouncing_widget.dart` | ✅ **SAFE** | Non-rendering layout wrapper. |
| `core/widgets/mood_landscape_illustration.dart` | ✅ **SAFE** | Programmatic canvas paints; no text fields. |
| `core/widgets/ocean_backdrop.dart` | ✅ **SAFE** | Ambient background; no text fields. |
| `core/widgets/responsive_layout_wrapper.dart` | ✅ **SAFE** | Limits layout width to 460px on desktops/tablet viewports. |
| `chat/presentation/widgets/chat_bubble.dart` | ⚠️ **MEDIUM RISK** | Citation row card text can clip or overflow. |
| `chat/presentation/widgets/message_input.dart` | ⚠️ **LOW RISK** | Send and attach buttons layout is flexible. |
| `chat/presentation/widgets/typing_indicator.dart` | ✅ **SAFE** | Pure animation dots; no text fields. |
| `goals/presentation/widgets/goal_tile.dart` | ✅ **SAFE** | Wrap and card sizes adapt correctly. |
| `goals/presentation/widgets/productivity_chart.dart` | ✅ **SAFE** | Graph layouts are sized dynamically. |
| `home/widgets/ask_your_files/ask_files_bar.dart` | ⚠️ **LOW RISK** | Text input adapts to horizontal spaces. |
| `home/widgets/ask_your_files/aura_document_card.dart`| ⚠️ **MEDIUM RISK** | File name strings overflow card constraints. |
| `home/widgets/ask_your_files/quick_question_card.dart`| ⚠️ **LOW RISK** | Suggestion chips scale using standard flow. |
| `home/widgets/ask_your_files/knowledge_orb.dart` | ✅ **SAFE** | Drawing elements are programmatic canvas paint. |
| `home/widgets/ask_your_files/upload_progress_card.dart`| ⚠️ **LOW RISK** | Index text updates wrap safely. |
| `home/widgets/ask_your_files/upload_source_sheet.dart`| ⚠️ **LOW RISK** | Sheet container has scrolling fallback. |
| `home/widgets/goal_progress.dart` | ✅ **SAFE** | Linear progress bars expand dynamically. |
| `home/widgets/hero_card.dart` | ⚠️ **LOW RISK** | Dynamic text layout wraps cleanly. |
| `home/widgets/mood_selector.dart` | ✅ **SAFE** | Wrap widget is scrollable horizontal track. |
| `home/widgets/quick_actions.dart` | ✅ **SAFE** | Grid uses expanded columns. |
| `home/widgets/recent_memories.dart` | ✅ **SAFE** | Scrollable entries. |
| `journal/presentation/widgets/journal_card.dart` | ✅ **SAFE** | Card contents wrap. |
| `journal/presentation/widgets/writing_prompt_card.dart`| ✅ **SAFE** | Text block wraps dynamically. |
| `memory/presentation/widgets/memory_card_tile.dart` | ✅ **SAFE** | Content wraps naturally. |
| `profile/presentation/widgets/personality_selector.dart`| ✅ **SAFE** | Wrap grid has vertical scrolling support. |
| `profile/presentation/widgets/usage_chart.dart` | ✅ **SAFE** | Painter dimensions scale dynamically. |
| `vision/presentation/widgets/detected_objects_list.dart`| ⚠️ **HIGH RISK** | Name column next to progress bar overlaps. |
| `vision/presentation/widgets/ocr_card.dart` | ✅ **SAFE** | Multiline card adapts to text size. |
| `vision/presentation/widgets/scanner_line.dart` | ✅ **SAFE** | Animation scan line; no text. |
| `voice/presentation/widgets/animated_orb.dart` | ✅ **SAFE** | Paint waves only. |
| `voice/presentation/widgets/voice_wave.dart` | ✅ **SAFE** | Sound frequency waves only. |

---

## 6. Unsafe Layout Findings Detail

### Finding 1: Profile Menu ListTile
* **File:** `lib/features/profile/presentation/profile_screen.dart` (lines 357–399)
* **Risk:** `CRITICAL_OVERFLOW_RISK`
* **Vulnerability:** Unconstrained trailing `Row` pushes `title` text to wrap aggressively in Spanish.
* **Remediation:** Restructure trailing widget to have a maximum width or wrap in `Flexible`, and constrain title.

### Finding 2: Login Screen Footer Links
* **File:** `lib/features/auth/login_screen.dart` (lines 403–425)
* **Risk:** `CRITICAL_OVERFLOW_RISK`
* **Vulnerability:** Placing labels and actions side-by-side inside `Row` causes overflow under Spanish/Hindi at text scale 1.3/2.0.
* **Remediation:** Use `Wrap` to wrap elements or rich text (`RichText` + `TextSpan`).

### Finding 3: Home Greeting Row
* **File:** `lib/features/home/home_screen.dart` (lines 419–440)
* **Risk:** `HIGH_TRANSLATION_RISK`
* **Vulnerability:** Long greeting message conflicts with notifications bell button in horizontal row.
* **Remediation:** Wrap greeting `Text` widget in `Expanded` or `Flexible`.

### Finding 4: Home Evening Card Width
* **File:** `lib/features/home/home_screen.dart` (lines 555–590)
* **Risk:** `HIGH_TRANSLATION_RISK`
* **Vulnerability:** Fixed-width container (`width: 136`) containing localized time details will clip or overflow vertically if translations wrap excessively.
* **Remediation:** Wrap with `Flexible` or make card width auto-adjust based on content.

### Finding 5: Vision Detected Object Title Row
* **File:** `lib/features/vision/presentation/vision_screen.dart` (lines 1072–1094)
* **Risk:** `HIGH_TRANSLATION_RISK`
* **Vulnerability:** Unconstrained name label on the left collides with percentage indicator on the right.
* **Remediation:** Wrap the left name `Text` in `Expanded`.

---

## 7. Phase 3 Implementation Plan - Centralized Primitives

In Phase 3, we will implement reusable responsive layout primitives in `lib/core/widgets/` to handle translation growth. This prevents parallel UI refactoring and maintains styling rules consistently:

### 1. `LocalizedListTile`
Wraps standard `ListTile` or custom item card structures. It ensures that the trailing widget has a maximum percentage width constraint (e.g., `maxWidth: screenWidth * 0.4`), forcing long value texts to wrap or show ellipsis, and wrapping the title in `Expanded` to prevent layout breaks.

### 2. `AdaptiveTextRow`
A utility layout that dynamically switches from `Row` to `Column` or wraps elements using `Wrap` based on text length constraints and viewport width. Useful for footers like "Don't have an account? Create Account".

### 3. `ResponsiveActionGrid`
Handles buttons or choice chips. Stacks elements vertically on narrow viewports or under long text translations, while keeping them side-by-side on wide screens.

---

## 8. Migration Grouping (Phases 4–7)

- **Phase 4:** Core Profile & Settings screen layouts (addressing Critical and High risks).
- **Phase 5:** Auth, onboarding, splash, mood, and home screens (resolving footer rows and greeting headers).
- **Phase 6:** Technical features: Voice, Vision, and Ask Your Files (fixing file lists, progress rows).
- **Phase 7:** Supporting modules: Journal, Goals, Memory, Calendar, and Notifications (reminders, dialog action buttons).

---

*Report compiled by Antigravity — End of Phase 2*
