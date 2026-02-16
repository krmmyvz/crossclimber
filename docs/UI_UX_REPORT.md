# UI/UX Field Report – 23 Nov 2025

## Tutorial system findings
- **Repeated overlays:** `TutorialNotifier` returned a default empty progress state until `SharedPreferences` finished loading, so `_checkTutorial` in `GameScreen` always thought no phases were seen and replayed the tutorial on every launch.
- **Wrong step numbering:** `_showTutorial` passed `currentStepIndex + 1` to the overlay even though the overlay itself adds `+1`, so the very first dialog was labelled "Step 2", giving the impression that earlier steps were skipped.
- **Missing highlights:** Several `TutorialHighlight` values (`hints`, `timer`, `sortButton`, `pauseButton`, `combo`, `undo`) never pointed to real widgets because the corresponding `GlobalKey`s were either absent or never assigned. As a result, overlay cutouts appeared in random places or nowhere at all.

### Resolutions
1. Defer tutorial display until the notifier finishes reading persisted progress (`isLoaded` guard + provider listener) and introduce an explicit introduction phase check so the onboarding shows exactly once.
2. Track the active tutorial phase to prevent duplicate overlays, localize step indices correctly, and mark phases as seen immediately after the last card is dismissed.
3. Wire actual UI elements (timer badge, credits/hints badge, undo button, combo counter, sorting button, pause icon) to dedicated `GlobalKey`s so highlights align with the intended widgets.

## Theme & color issues
- **Lost surfaces in custom themes:** Each custom `ColorScheme` previously defined only 8–9 colors. Any widget that referenced tokens like `primaryContainer`, `surfaceContainerHigh`, or `outlineVariant` fell back to near-black defaults, so cards/buttons effectively disappeared when users switched to Dracula/Nord/Gruvbox/Monokai.
- **Mismatched brightness:** Even though all custom palettes are dark, the app forced `ThemeMode.light` whenever a custom theme was active, leading to incorrect system overlays and Material components assuming light-mode contrast rules.
- **Keyboard background using undefined token:** `CustomKeyboard` referenced `colorScheme.surfaceContainer`, which does not exist on stable channels and silently resolved to null-like behavior, so the keyboard background would occasionally mirror the scaffold color and look invisible.

### Resolutions
1. Introduced `_buildCustomDarkScheme`, which seeds a full Material 3 color scheme and then overrides the brand colors. This guarantees every derived token exists while preserving the intended palette.
2. When a custom theme is active, force `ThemeMode.dark` so Flutter treats the palette as dark across system UI and built-in widgets.
3. Replace the undefined `surfaceContainer` usage with `surfaceContainerHigh` to keep the custom keyboard legible across all schemes.

## Outstanding follow-ups
- Localize the tutorial strings (titles/descriptions) instead of piping raw keys into the overlay.
- Clean up the analyzer warnings flagged in `game_screen.dart` (`use_build_context_synchronously`) and remove the leftover `print` statements from `level_repository.dart`.
- Consider surfacing per-phase tutorial toggles inside settings (currently only a global "show tips" boolean exists).
