# Ulti-Mate

Ulti-Mate is a Garmin Connect IQ Watch Application designed to assist Ultimate Frisbee players. It tracks game timing, scoring, and provides gender ratio reminders based on the standard ABBA pattern.

## Features

- **Game Timer**: Tracks total elapsed time since the start of the game.
- **Point Timer**: Tracks duration of the current point.
- **Score Tracking**: Counts completed points for Dark and Light teams.
- **Gender Ratio Indicator**: Displays "A" or "B" to indicate the gender ratio for the current point, following the ABBA pattern.
- **Undo Score**: Press back button to undo the last scored point.
- **Pause Menu**: Custom menu to Resume, Save (and exit), or Discard (and exit) the session.
- **Activity Recording**: Records the game as a generic sport activity.

## Prerequisites

To build and run this project, you need:

1.  **Connect IQ SDK**: Download and install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/).
2.  **Java Runtime Environment (JRE)**: Required for the SDK tools.
3.  **Developer Key**: A developer key (`developer_key.der`) is required to sign the application.

    If you don't have a key, generate one using:
    ```bash
    openssl genrsa -out developer_key.der 4096
    ```

## Build and Run Instructions

The following instructions assume you have the Connect IQ SDK `bin` directory in your system `PATH`.

### 1. Start the Simulator

Start the Connect IQ simulator in a separate terminal window or background process:

```bash
connectiq
```

### 2. Build the Application

Use `monkeyc` to compile the application. Replace `fr235` with your target device ID (e.g., `fenix7`, `vivoactive4`, etc.).

```bash
monkeyc -o bin/UltiMate.prg -f monkey.jungle -y developer_key.der
```

*   `-o bin/UltiMate.prg`: Output program file.
*   `-f monkey.jungle`: Project configuration file.
*   `-d fr235`: Target device ID (must be listed in `manifest.xml`).
*   `-y developer_key.der`: Path to your developer key.

### 3. Run in Simulator

Use `monkeydo` to push the compiled program to the running simulator:

```bash
monkeydo bin/UltiMate.prg fr235
```

**Note:** The device ID used in `monkeydo` must match the one used during compilation.

### 4. Deploy to Physical Watch

To run the application on your actual Garmin watch, you need to "side-load" the compiled application file.

1. **Connect your watch** to your computer via USB. It should appear as a removable drive (mass storage or MTP).

2. **Build the application** for your specific watch model:
   ```bash
   monkeyc -o bin/UltiMate.prg -f monkey.jungle -d <your_device_id> -y developer_key.der
   ```
   Replace `<your_device_id>` with your watch model (e.g., `fr235`, `fenix7`, `vivoactive4`).

3. **Copy the application file**:
   - Locate the `bin/UltiMate.prg` file on your computer.
   - Open your watch's drive.
   - Navigate to the `GARMIN/APPS` folder.
   - Copy `UltiMate.prg` into the `GARMIN/APPS` folder.

4. **Disconnect and Run**:
   - Safely eject/disconnect your watch.
   - The watch may display "Updating" briefly.
   - Go to your Activities/Apps list on the watch, and you should see "Ulti-Mate" (or the name defined in strings).

## Release The App

Build and package for release:
```bash
mkdir release/[version]/
monkeyc --package-app --release -o release/[version]/UltiMate.iq -f monkey.jungle -y developer_key.der -O 2pz 
```


**Troubleshooting:**
- If the app doesn't appear, check that the `device_id` used in the build command matches your physical device exactly.
- Ensure you copied the file to `GARMIN/APPS` and not another folder.
- Some devices require a restart after side-loading.

## Project Structure

- `source/`: Contains the Monkey C source code (`.mc` files).
  - `UltiMateApp.mc`: Application entry point.
  - `GameModel.mc`: Core game logic and state management.
  - `UltiMateView.mc`: Main display logic and UI rendering.
  - `UltiMateDelegate.mc`: Input handling for the main game view.
  - `PauseMenuView.mc`: Custom pause screen and menu view.
  - `PauseMenuDelegate.mc`: Input handling for the pause menu.
  - `ConfirmExitView.mc`: Exit confirmation dialog view.
  - `ConfirmExitDelegate.mc`: Input handling for the exit confirmation.
  - `FontConstants.mc`: Cached font height constants module.
- `resources/`: Contains layout, string, and image resources.
- `manifest.xml`: Application manifest defining permissions and supported devices.
- `monkey.jungle`: Project configuration file.

## Supported Devices

This application supports a wide range of Garmin devices, including:
- Forerunner series (235, 245, 255, 265, 945, 955, 965, etc.)
- Fenix series (5, 6, 7, 8)
- Vivoactive series (3, 4, 5)
- Epix series
- Edge series
- Instinct series
- Venu series

See `manifest.xml` for the complete list of supported products.

## Reference

- [Monkey C Command Line Setup](https://developer.garmin.com/connect-iq/reference-guides/monkey-c-command-line-setup/)
