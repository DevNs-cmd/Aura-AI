# Aura AI - Localization-Safe Responsive Primitives Documentation
**Date:** 2026-07-06
**Phase:** 3 - Create Localization-Safe UI Foundation
**Author:** Antigravity AI

---

## 1. Overview

In Phase 3, we implemented **9 centralized responsive layout primitives** inside `lib/core/widgets/`. These primitives prevent text truncation, RenderFlex overflows, and character-by-character wrapping when handling long translations (e.g. Spanish, Hindi, or future languages) and increased system text scaling.

All primitives are fully integrated and verified via widget tests located in [test/localized_primitives_test.dart](file:///C:/Users/ayesh/.gemini/antigravity/scratch/aura_ai/test/localized_primitives_test.dart).

---

## 2. Primitives Catalog & Responsive Behavior

### 2.1 `LocalizedSettingsRow`
* **Path:** `lib/core/widgets/localized_settings_row.dart`
* **Purpose:** Replaces row items in settings or profile sections containing leading icons, titles, subtitles, and trailing elements.
* **Layout Adaptation:**
  * Uses `LayoutBuilder` to monitor parent constraints.
  * If the width is narrow (under `300` pixels) or title + trailing text are both long, it automatically stacks the trailing elements/description below the title in a `Column` inside an `Expanded` region.
  * If space permits, it lays them out horizontally using `Expanded` for the title and `Flexible` for the trailing widget, allocating bounded width cleanly.
  * Prevents character-by-character wrapping of titles.

### 2.2 `LocalizedActionRow`
* **Path:** `lib/core/widgets/localized_action_row.dart`
* **Purpose:** Formats category titles and action button links (e.g. "My Journal" + "See All") side-by-side.
* **Layout Adaptation:**
  * Estimates text widths statically.
  * If horizontal space is insufficient, it stacks the action link below the title, maintaining alignment.
  * Otherwise, uses `Expanded(child: Text(title))` and aligns the action text button cleanly on the right.

### 2.3 `LocalizedSectionHeader`
* **Path:** `lib/core/widgets/localized_section_header.dart`
* **Purpose:** Formats settings category labels and card section headers safely.
* **Layout Adaptation:**
  * Employs `Expanded` wrapping to support natural multiline text flow instead of clipping.

### 2.4 `LocalizedButton`
* **Path:** `lib/core/widgets/localized_button.dart`
* **Purpose:** Adaptive button replacing standard fixed-height buttons.
* **Layout Adaptation:**
  * Uses `minimumSize: Size(88, 48)` (satisfying the Android/iOS touch target guidelines) instead of a hardcoded `fixedSize`.
  * Allows vertical growth to fit 1–2 lines of translated text safely without clipping or using FittedBox (which makes text unreadably small).

### 2.5 `LocalizedDialogActionBar`
* **Path:** `lib/core/widgets/localized_dialog_action_bar.dart`
* **Purpose:** Formats alert and confirmation dialog buttons.
* **Layout Adaptation:**
  * Uses Flutter's `OverflowBar` to lay out actions side-by-side.
  * Automatically stacks dialog action buttons vertically if horizontal width is constrained, preserving action priority.

### 2.6 `LocalizedAdaptiveChipGroup`
* **Path:** `lib/core/widgets/localized_adaptive_chip_group.dart`
* **Purpose:** Groups choice, filter, or action chips.
* **Layout Adaptation:**
  * Employs `Wrap` with custom `spacing` and `runSpacing` instead of a horizontal scrolling row, unless explicit scroll UX is requested.

### 2.7 `LocalizedResponsiveHeader`
* **Path:** `lib/core/widgets/localized_responsive_header.dart`
* **Purpose:** Standard top page app-bar headers.
* **Layout Adaptation:**
  * Wraps the header title in `Expanded` to prevent clashing with trailing menu or leading back buttons.

### 2.8 `LocalizedNavigationLabel`
* **Path:** `lib/core/widgets/localized_navigation_label.dart`
* **Purpose:** Bottom navigation item labels.
* **Layout Adaptation:**
  * Configures `maxLines: 1` and `TextOverflow.ellipsis` to support long translations gracefully according to documented UX policy.

### 2.9 `LocalizedMetadataRow`
* **Path:** `lib/core/widgets/localized_metadata_row.dart`
* **Purpose:** Key-value lists (e.g. document size, upload dates).
* **Layout Adaptation:**
  * Stacks key and value vertically if total length exceeds horizontal space, preventing clipping.

---

## 3. Verification Plan

All primitives have been verified using a dedicated test suite with synthetic long translations.

### 3.1 Automated Tests
Run the test command:
```bash
flutter test test/localized_primitives_test.dart
```

### 3.2 Visual & Layout Assertions
* **No horizontal RenderFlex overflows** under narrow viewports (300px–320px).
* **Text scale factors** of `1.3` and `2.0` layout successfully without clipping.
* **Tappable areas** maintain required dimensions.
