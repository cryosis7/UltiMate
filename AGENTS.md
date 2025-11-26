# Ulti-Mate Project Overview

## Purpose
Ulti-Mate is a Garmin Connect IQ Watch Application designed to assist Ultimate Frisbee players. It tracks game timing, scoring, and provides gender ratio reminders based on the standard ABBA pattern.

## Key Features
- **Game Timer**: Tracks total elapsed time since the start of the game.
- **Point Timer**: Tracks duration of the current point.
- **Score Tracking**: Counts completed points.
- **Gender Ratio Indicator**: Displays "A" or "B" to indicate the gender ratio for the current point, following the ABBA pattern (A, B, B, A, A, B, B...).
- **Pause Menu**: Custom menu to Resume, Save (and exit), or Discard (and exit) the session.
- **Activity Recording**: Records the game as a generic sport activity.

## Target Platform
- **SDK Version**: **Minimum SDK 1.4.0**. This is an older framework level; avoid modern Connect IQ APIs introduced in later versions (e.g., System 3 or System 4 features) unless strictly verified.
- **Devices**: Supports a wide range of Garmin devices including Vivoactive, Fenix, Forerunner, Epix, and Edge series. See `manifest.xml` for the full list.

## Core Files
- `source/UltiMateApp.mc`: Application entry point.
- `source/GameModel.mc`: Core game logic and state management (scores, timing, gender ratio).
- `source/UltiMateView.mc`: Main display logic and UI rendering.
- `source/UltiMateDelegate.mc`: Input handling (button presses) for the main game view.
- `source/PauseMenuView.mc`: Custom view for the pause screen and menu.
- `source/PauseMenuDelegate.mc`: Input handling for the pause menu.

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
- `getInitialView()` returns the main `UltiMateView` and its associated `UltiMateDelegate`.

### 2. Model (`GameModel.mc`)
- Manages core game state and business logic, separated from UI concerns.
- **Responsibilities**:
    - Track scores (`dark`, `light`).
    - Track timing (game start, point start, pause state).
    - Calculate derived state (current gender ratio, formatted time strings).
    - Handle game actions (`incrementDark`, `incrementLight`, `pause`, `resume`).

### 3. View (`UltiMateView.mc`)
- Extends `Toybox.WatchUi.View`.
- **Responsibilities**:
    - Rendering the UI in `onUpdate(dc)`.
    - Managing the update timer (`_updateTimer`) which triggers screen refreshes every second.
    - Delegating game logic to `GameModel` instance.
    - Manages `ActivityRecording` session (start, stop, save, discard).
- **Interaction**:
    - Uses `_gameModel` for all game state and logic.
    - Displays scores, times, and gender ratio from the model.

### 4. Delegate (`UltiMateDelegate.mc`)
- Extends `Toybox.WatchUi.BehaviorDelegate`.
- **Responsibilities**:
    - Handles user input during the active game (Select, Previous Page, Next Page).
    - Triggers the pause state.
- **Interaction**:
    - Calls `_view.incrementDark()` or `_view.incrementLight()` to update scores.
    - Calls `_view.pause()` to pause the game.
    - Pushes `PauseMenuView` and `PauseMenuDelegate` when "Select" is pressed.

### 5. Pause Menu View (`PauseMenuView.mc`)
- Extends `Toybox.WatchUi.View`.
- **Responsibilities**:
    - Displays the "Paused" state, including a pause timer and menu options (Resume, Save, Discard).
    - Manages its own update timer to refresh the pause duration.
    - Handles visual selection state of menu items.
- **Interaction**:
    - Uses `_gameModel` to get formatted pause duration.
    - Calls `_view.resume()`, `_view.saveSession()`, or `_view.discardSession()` based on selection.

### 6. Pause Menu Delegate (`PauseMenuDelegate.mc`)
- Extends `Toybox.WatchUi.BehaviorDelegate`.
- **Responsibilities**:
    - Handles user input while in the pause menu.
    - Maps physical buttons (Next Page, Previous Page) to menu navigation.
    - Maps "Select" button to executing the selected menu item.
- **Interaction**:
    - Calls `_view.selectNext()`, `_view.selectPrevious()`, or `_view.selectItem()` on the `PauseMenuView`.

## Resource Management
- `resources/strings.xml`: Contains string definitions (e.g., AppName).
- `manifest.xml`: Defines app permissions, version, and supported products.
