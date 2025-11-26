# Ulti-Mate

Ulti-Mate is a Garmin Connect IQ Watch Application designed to assist Ultimate Frisbee players. It tracks game timing, scoring, and provides gender ratio reminders based on the standard ABBA pattern.

## Features

- **Game Timer**: Tracks total elapsed time since the start of the game.
- **Point Timer**: Tracks duration of the current point.
- **Score Tracking**: Counts completed points for Dark and Light teams.
- **Gender Ratio Indicator**: Displays "A" or "B" to indicate the gender ratio for the current point, following the ABBA pattern.

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
monkeyc -o bin/UltiMate.prg -f monkey.jungle -d fr235 -y developer_key.der
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

## Project Structure

- `source/`: Contains the Monkey C source code (`.mc` files).
- `resources/`: Contains layout, string, and image resources.
- `manifest.xml`: Application manifest defining permissions and supported devices.
- `monkey.jungle`: Project configuration file.

## Supported Devices

This application supports a wide range of Garmin devices, including:
- Forerunner series (235, 245, 255, 265, 945, 955, 965, etc.)
- Fenix series (5, 6, 7)
- Vivoactive series (3, 4, 5)
- Epix series
- Edge series

See `manifest.xml` for the complete list of supported products.

## Reference

- [Monkey C Command Line Setup](https://developer.garmin.com/connect-iq/reference-guides/monkey-c-command-line-setup/)

