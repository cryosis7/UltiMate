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
- `source/views/UltiMateView.mc`: Main display logic and UI rendering.
- `source/delegates/UltiMateDelegate.mc`: Input handling (button presses) for the main game view.
- `source/views/BaseMenuView.mc`: Reusable base class for scrolling menu views.
- `source/views/StartMenuView.mc`: Initial menu view (Start, Settings, Exit).
- `source/views/PauseMenuView.mc`: Custom view for the pause screen and menu.
- `source/delegates/PauseMenuDelegate.mc`: Input handling for the pause menu.
- `source/views/ConfirmExitView.mc`: Confirmation dialog when exiting without saving.
- `source/delegates/ConfirmExitDelegate.mc`: Input handling for the exit confirmation dialog.

## Documentation
- The API documentation for classes and methods is available at https://developer.garmin.com/connect-iq/api-docs/index.html
- MonkeyC Syntax is available at:
    - https://developer.garmin.com/connect-iq/api-docs/
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

### Comments
- Use self-documenting names over comments where possible.
- Do not add comments.

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
    - Cache font heights in `onLayout()` to avoid repeated calls to `Graphics.getFontHeight()` in `onUpdate()`.

## Logic Patterns
- **Time Tracking**: Use `Toybox.System.getTimer()` for relative time measurement (milliseconds).
- **Input Handling**: Handle inputs in the `Delegate`. Return `true` if the event was consumed, `false` otherwise.
- **Resource Management**: Always clean up resources (timers, sessions) in lifecycle methods (`onHide`, `onStop`).
- **Memory Management**: Be mindful of memory constraints on watch devices. Avoid creating unnecessary objects in frequently called methods.

## Code Organization
- **One Class Per File**: Each file should contain only one class or module.
- **File Naming**: Match the filename to the primary class name (e.g., `GameModel.mc` contains `GameModel` class).
- **Separation of Concerns**: Keep UI logic in Views, input handling in Delegates, and business logic in Model classes.
- **Inheritance**: Use `extends` keyword for class inheritance. Call parent methods using `ParentClass.methodName()` syntax (not `super`).
- **Code Reuse**: Extract common functionality into base classes. Use member variables for static configuration and overridable methods for dynamic values.

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
- `getInitialView()` returns the initial view (StartMenuView) and its associated delegate.

### 2. Model (`GameModel.mc`)
- Manages core game state and business logic, separated from UI concerns.
- **Responsibilities**:
    - Track scores (`dark`, `light`).
    - Track timing (game start, point start, pause state).
    - Calculate derived state (current gender ratio, next gender ratio, formatted time strings).
    - Handle game actions (`incrementDark`, `incrementLight`, `pause`, `resume`).
    - Maintain score history for undo functionality (`_historyPoints`, `_historyPointStartTimes`).
    - Provide `undoLastScore()` to revert the last scored point.

### 3. View (`UltiMateView.mc`)
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

### 4. Delegate (`UltiMateDelegate.mc`)
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

### 5. Base Menu View (`BaseMenuView.mc`)
- Extends `Toybox.WatchUi.View`.
- **Responsibilities**:
    - Provides reusable scrolling menu functionality for all menu views.
    - Manages menu navigation state (`_selectedIndex`) and common layout variables.
    - Handles menu rendering with current item large, prev/next items smaller.
    - Adjusts layout automatically when subheading is present (menu starts lower).
- **Configuration**:
    - Subclasses set `_title` and `_menuItems` in `initialize()`.
    - Subclasses override `getSubheading()` to return dynamic text (returns `null` by default).
    - Subclasses override `selectItem()` to handle menu item selection.
- **Common Methods**:
    - `selectNext()`, `selectPrevious()`, `getSelectedIndex()` - menu navigation.
    - `onLayout(dc)` - calculates positions based on presence of subheading.
    - `onUpdate(dc)` - draws title, optional subheading, and menu items.
    - `drawMenu(dc)` - renders the scrolling menu.

### 6. Start Menu View (`StartMenuView.mc`)
- Extends `BaseMenuView`.
- **Responsibilities**:
    - Displays the initial menu with "Ulti-Mate" title.
    - Provides menu items: Start, Settings, Exit.
- **Interaction**:
    - Starts game by switching to `UltiMateView`.
    - Opens settings menu to configure gender ratio.
    - Exits application.

### 7. Pause Menu View (`PauseMenuView.mc`)
- Extends `BaseMenuView`.
- **Responsibilities**:
    - Displays the "Paused" state with pause timer as subheading.
    - Provides menu items: Resume, Save, Discard.
    - Manages update timer to refresh the pause duration.
- **Interaction**:
    - Uses `_gameModel` to get formatted pause duration via `getSubheading()`.
    - Calls `_view.resume()`, `_view.saveSession()`, or `_view.discardSession()` based on selection.

### 8. Pause Menu Delegate (`PauseMenuDelegate.mc`)
- Extends `Toybox.WatchUi.BehaviorDelegate`.
- **Responsibilities**:
    - Handles user input while in the pause menu.
    - Maps physical buttons (Next Page, Previous Page) to menu navigation.
    - Maps "Select" button to executing the selected menu item.
    - Maps "Back" button to resume and return to game.
- **Interaction**:
    - Calls `_view.selectNext()`, `_view.selectPrevious()`, or `_view.selectItem()` on the `PauseMenuView`.

### 9. Confirm Exit View (`ConfirmExitView.mc`)
- Extends `Toybox.WatchUi.View`.
- **Responsibilities**:
    - Displays exit confirmation dialog ("Discard and exit?").
    - Shows Yes/No options with visual selection state.
    - Warns user that game will not be saved.
- **Interaction**:
    - Calls `_view.discardSession()` and `System.exit()` if "Yes" selected.
    - Pops view if "No" selected to return to game.

### 10. Confirm Exit Delegate (`ConfirmExitDelegate.mc`)
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
