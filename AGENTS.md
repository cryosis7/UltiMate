# Ulti-Mate Project Overview

## Purpose
Ulti-Mate is a Garmin Connect IQ Watch Application designed to assist Ultimate Frisbee players. It tracks game timing, scoring, and provides gender ratio reminders based on the standard ABBA pattern.

## Key Features
- **Game Timer**: Tracks total elapsed time since the start of the game.
- **Point Timer**: Tracks duration of the current point.
- **Score Tracking**: Counts completed points for Dark and Light teams.
- **Gender Ratio Indicator**: Displays "A" or "B" to indicate the gender ratio for the current point, following the ABBA pattern (A, B, B, A, A, B, B...).
- **Undo Score**: Press back button to undo the last scored point, restoring the previous point timer and gender ratio.
- **Pause Menu**: Custom menu to Resume, Save (and exit), or Discard (and exit) the session.
- **Confirm Exit Dialog**: Safety confirmation when pressing back with no scores to undo.
- **Activity Recording**: Records the game as a generic sport activity.

## Target Platform
- **SDK Version**: **Minimum SDK 1.4.0**. This is an older framework level; avoid modern Connect IQ APIs introduced in later versions (e.g., System 3 or System 4 features) unless strictly verified.
- **Devices**: Supports a wide range of Garmin devices including Vivoactive, Fenix, Forerunner, Epix, Instinct, Venu, and Edge series. See `manifest.xml` for the full list.

## Core Files
- `source/UltiMateApp.mc`: Application entry point and lifecycle management.
- `source/GameModel.mc`: Core game logic and state management (scores, timing, gender ratio, undo history).
- `source/UltiMateView.mc`: Main display logic and UI rendering.
- `source/UltiMateDelegate.mc`: Input handling (button presses) for the main game view.
- `source/PauseMenuView.mc`: Custom view for the pause screen and menu.
- `source/PauseMenuDelegate.mc`: Input handling for the pause menu.
- `source/ConfirmExitView.mc`: Confirmation dialog when exiting without saving.
- `source/ConfirmExitDelegate.mc`: Input handling for the exit confirmation dialog.
- `source/FontConstants.mc`: Module for cached font height constants.

## Documentation
- The API documentation for classes and methods is available at https://developer.garmin.com/connect-iq/api-docs/index.html
- MonkeyC Syntax is available at:
    - https://developer.garmin.com/connect-iq/monkey-c/functions/
    - https://developer.garmin.com/connect-iq/monkey-c/objects-and-memory/
    - https://developer.garmin.com/connect-iq/monkey-c/containers/
    - https://developer.garmin.com/connect-iq/monkey-c/monkey-types/
    - https://developer.garmin.com/connect-iq/monkey-c/exceptions-and-errors/
    - https://developer.garmin.com/connect-iq/monkey-c/annotations/
    - https://developer.garmin.com/connect-iq/monkey-c/coding-conventions/
    - https://developer.garmin.com/connect-iq/monkey-c/compiler-options/

---

# Monkey C Development Practices

## Code Style

### Naming Conventions
Following [Garmin's official coding conventions](https://developer.garmin.com/connect-iq/monkey-c/coding-conventions/):

- **Classes**: PascalCase (e.g., `UltiMateApp`, `GameModel`).
- **Methods**: camelCase (e.g., `getInitialView`, `incrementDark`).
- **Private Variables**: camelCase with a leading underscore (e.g., `_gameStartTime`, `_updateTimer`).
- **Public Variables**: camelCase (e.g., `currentTime`, `darkScore`).
- **Constants**: UPPER_CASE_WITH_UNDERSCORES (e.g., `MAX_SCORE`, `DEFAULT_TIMEOUT`).
- **Module Names**: PascalCase matching the filename.

### Indentation and Formatting
- Use **4 spaces** for indentation (not tabs).
- Maintain consistent indentation throughout all code files.
- Place opening braces `{` on the same line as the declaration.
- Use blank lines to separate logical sections of code.

### Comments
- Use self-documenting names over comments where possible.
- Do not use comments.

### Type Safety
- Use type annotations where possible, especially for function parameters and return types.
    - Example: `function onUpdate(dc as Dc) as Void`
- Explicitly type local variables if inference is ambiguous.

## API Compatibility
- **Target SDK**: The project targets a minimum SDK of **1.4.0**.
- **Constraint**: Do not use APIs, modules, or methods introduced in newer SDK versions (e.g., `Toybox.WatchUi.Menu2`, modern Complications, or newer Graphics features) without checking `minSdkVersion` compatibility.
- **Documentation**: Verify function availability in the Connect IQ API documentation for SDK 1.4.0.

## UI & Performance
- **Screen Updates**: 
    - Use `WatchUi.requestUpdate()` to schedule a redraw.
    - Avoid heavy computation in `onUpdate()`.
    - The `onUpdate()` method should clear the screen (`dc.clear()`) before drawing.
- **Timers**:
    - Use `Toybox.Timer.Timer` for periodic updates (e.g., updating the clock every second).
    - Ensure timers are stopped in `onHide()` or `onStop()`.
- **Font Heights**:
    - Use the `FontConstants` module for pre-cached font heights.
    - Avoid calling `Graphics.getFontHeight()` in `onUpdate()`.

## Logic Patterns
- **Time Tracking**: Use `Toybox.System.getTimer()` for relative time measurement (milliseconds).
- **Input Handling**: Handle inputs in the `Delegate`. Return `true` if the event was consumed, `false` otherwise.
- **Resource Management**: Always clean up resources (timers, sessions) in lifecycle methods (`onHide`, `onStop`).
- **Memory Management**: Be mindful of memory constraints on watch devices. Avoid creating unnecessary objects in frequently called methods.

## Code Organization
- **One Class Per File**: Each file should contain only one class or module.
- **File Naming**: Match the filename to the primary class name (e.g., `GameModel.mc` contains `GameModel` class).
- **Module Structure**: Use `using` statements at the top of files to import required modules.
- **Separation of Concerns**: Keep UI logic in Views, input handling in Delegates, and business logic in Model classes.

## Common Imports
```monkeyc
using Toybox.Application;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.ActivityRecording;
```
---

# Architecture & File Structure

The application follows the standard Connect IQ App-View-Delegate pattern, with a dedicated Model for state management.

## Components

### 1. Application (`UltiMateApp.mc`)
- Extends `Toybox.Application.AppBase`.
- Manages the application lifecycle (`onStart`, `onStop`).
- Initializes `FontConstants` module on app startup.
- Maintains reference to main view for cleanup on exit.
- `getInitialView()` returns the main `UltiMateView` and its associated `UltiMateDelegate`.

### 2. Model (`GameModel.mc`)
- Manages core game state and business logic, separated from UI concerns.
- **Responsibilities**:
    - Track scores (`dark`, `light`).
    - Track timing (game start, point start, pause state).
    - Calculate derived state (current gender ratio, next gender ratio, formatted time strings).
    - Handle game actions (`incrementDark`, `incrementLight`, `pause`, `resume`).
    - Maintain score history for undo functionality (`_historyPoints`, `_historyPointStartTimes`).
    - Provide `undoLastScore()` to revert the last scored point.

### 3. Font Constants (`FontConstants.mc`)
- Module (not a class) for caching font height values.
- **Responsibilities**:
    - Store pre-calculated font heights for all standard fonts.
    - Initialized once at app startup via `FontConstants.initialize()`.
    - Provides `FONT_TINY_HEIGHT`, `FONT_SMALL_HEIGHT`, `FONT_MEDIUM_HEIGHT`, `FONT_LARGE_HEIGHT`, and number font heights.
- **Purpose**: Avoids repeated calls to `Graphics.getFontHeight()` in `onUpdate()` methods.

### 4. View (`UltiMateView.mc`)
- Extends `Toybox.WatchUi.View`.
- **Responsibilities**:
    - Rendering the UI in `onUpdate(dc)`.
    - Managing the update timer (`_updateTimer`) which triggers screen refreshes every second.
    - Delegating game logic to `GameModel` instance.
    - Manages `ActivityRecording` session (start, stop, save, discard).
    - Provides `undoLastScore()` method for delegate to call.
    - Provides `showConfirmExit()` to push the exit confirmation view.
    - Provides `cleanup()` for proper resource cleanup on app exit.
- **Interaction**:
    - Uses `_gameModel` for all game state and logic.
    - Displays scores, times, and gender ratio from the model.

### 5. Delegate (`UltiMateDelegate.mc`)
- Extends `Toybox.WatchUi.BehaviorDelegate`.
- **Responsibilities**:
    - Handles user input during the active game (Select, Previous Page, Next Page, Back).
    - Triggers the pause state.
    - Handles Back button: undoes last score or shows confirm exit dialog.
- **Interaction**:
    - Calls `_view.incrementDark()` or `_view.incrementLight()` to update scores.
    - Calls `_view.pause()` to pause the game.
    - Calls `_view.undoLastScore()` on back press.
    - Calls `_view.showConfirmExit()` when no scores to undo.
    - Pushes `PauseMenuView` and `PauseMenuDelegate` when "Select" is pressed.

### 6. Pause Menu View (`PauseMenuView.mc`)
- Extends `Toybox.WatchUi.View`.
- **Responsibilities**:
    - Displays the "Paused" state, including a pause timer and menu options (Resume, Save, Discard).
    - Manages its own update timer to refresh the pause duration.
    - Handles visual selection state of menu items with scrolling display.
- **Interaction**:
    - Uses `_gameModel` to get formatted pause duration.
    - Calls `_view.resume()`, `_view.saveSession()`, or `_view.discardSession()` based on selection.

### 7. Pause Menu Delegate (`PauseMenuDelegate.mc`)
- Extends `Toybox.WatchUi.BehaviorDelegate`.
- **Responsibilities**:
    - Handles user input while in the pause menu.
    - Maps physical buttons (Next Page, Previous Page) to menu navigation.
    - Maps "Select" button to executing the selected menu item.
    - Maps "Back" button to resume and return to game.
- **Interaction**:
    - Calls `_view.selectNext()`, `_view.selectPrevious()`, or `_view.selectItem()` on the `PauseMenuView`.

### 8. Confirm Exit View (`ConfirmExitView.mc`)
- Extends `Toybox.WatchUi.View`.
- **Responsibilities**:
    - Displays exit confirmation dialog ("Discard and exit?").
    - Shows Yes/No options with visual selection state.
    - Warns user that game will not be saved.
- **Interaction**:
    - Calls `_view.discardSession()` and `System.exit()` if "Yes" selected.
    - Pops view if "No" selected to return to game.

### 9. Confirm Exit Delegate (`ConfirmExitDelegate.mc`)
- Extends `Toybox.WatchUi.BehaviorDelegate`.
- **Responsibilities**:
    - Handles user input in the confirm exit dialog.
    - Maps physical buttons (Next Page, Previous Page) to option selection.
    - Maps "Select" button to execute selected option.
    - Maps "Back" button to cancel and return to game.
- **Interaction**:
    - Calls `_view.selectNext()`, `_view.selectPrevious()`, or `_view.selectItem()` on the `ConfirmExitView`.

## Resource Management
- `resources/strings.xml`: Contains string definitions (e.g., AppName).
- `resources/drawables.xml`: Contains drawable definitions (e.g., launcher icon).
- `manifest.xml`: Defines app permissions, version, and supported products.
