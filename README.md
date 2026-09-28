# Minecraft Bedrock Server Management & Auto-Restart Daemon

A lightweight, robust Bash daemon suite designed to automate the lifecycle, scheduled restarts, and crash recovery of a Minecraft Bedrock Server running on Ubuntu ARM64 (such as Oracle Cloud Infrastructure Ampere instances) via the FEX-Emu emulation layer.

---

## Key Features

* **Automated Screen Management:** Automatically detects or creates the detached GNU `screen` session (`bedrock`) so you do not need to manually orchestrate background sessions.
* **Automatic Startup Integration:** Launching the daemon automatically spins up the Minecraft Bedrock server if it is offline.
* **Scheduled Midnight Restarts:** Performs daily automated restarts (default target: Midnight GMT/UK time) complete with formatted, color-coded in-game player warnings.
* **Crash Recovery & Guardian:** Continuously monitors the process state and automatically restarts the server within 5 seconds if an unexpected crash occurs.
* **Graceful Ctrl+C Handling:** Intercepts `Ctrl+C` in the launcher screen to issue a 10-second in-game warning, execute a safe `stop` command, verify world file save completion, and exit cleanly.

---

## Prerequisites

Before running the scripts, ensure your ARM64 environment has the following installed and configured:

1. **GNU Screen:**
   ```bash
   sudo apt update && sudo apt install screen -y
   ```

2. **FEX-Emu (x86_64 Emulator for ARM64):**
   * Installed and configured to execute the x86_64 Minecraft Bedrock binary (`bedrock_server`).

3. **Unix Line Endings (LF):**
   * Ensure both script files are saved with Unix (`LF`) line endings. If edited on Windows, convert them via:
     ```bash
     sed -i 's/\r$//' RestartLauncher.sh Runner.sh
     ```
---

## Configuration & Setup

Prior to first execution, update the file path variables to match your server installation directory.

### 1. Configure Runner.sh
Open `Runner.sh` and update lines **3** and **7** with your absolute server path:
```bash
# Line 3 & Line 7: Set your Minecraft Bedrock launcher path & FexEmu rootFS path
```

### 2. Configure RestartLauncher.sh
Open `RestartLauncher.sh` and update line **80**  with your server directory:
```bash
# Line 80: Set your working directory path to the runner.sh file
```

### 3. Grant Execution Permissions
Make both scripts executable:
```bash
chmod +x RestartLauncher.sh Runner.sh
```

---

## Usage

### Starting the Server script
Run `RestartLauncher.sh` inside its own dedicated screen session or directly in your main terminal:

```bash
# Option A: Run inside a dedicated management screen (Recommended)
screen -S restarter ./RestartLauncher.sh

# Option B: Run directly in terminal
./RestartLauncher.sh
```

> **Note:** Upon launch, the script checks if the `bedrock` screen session exists (creating it if missing) and verifies if the server is running. If offline, it immediately initializes the server via `Runner.sh`.

---

## Functionality Overview

### 1. In-Game Scheduled Restart Countdown
At the target restart time (Midnight GMT/UK), the server broadcasts formatted color announcements to all online players before executing a graceful shutdown and restart:

<img width="393" height="166" alt="image" src="https://github.com/user-attachments/assets/3bac010b-8440-45c5-a3e2-8c9ee85351b0" />

---

### 2. Manual Shutdown via Ctrl+C
When performing server maintenance, within to the `RestartLauncher.sh` screen and entering `Ctrl + C`. The script intercepts the signal, broadcasts a 10-second warning in-game, safely stops the server, and exits cleanly without triggering an auto-restart:

<img width="666" height="118" alt="image" src="https://github.com/user-attachments/assets/5a8fd264-7998-463b-833a-e8d947041beb" />

---

### 3. Automatic Crash Detection & Recovery
If the server process terminates unexpectedly (outside of a scheduled restart or manual `Ctrl + C` shutdown), the script detects the missing process, logs the crash event in the `RestartLauncher.sh` terminal, and automatically boots the server back up after a 5-second delay:

<img width="792" height="41" alt="image" src="https://github.com/user-attachments/assets/686a1b6c-4fb9-4807-9722-5829860f4176" />

---


## Personal Touch/Alternations
### 1. Use Different Emulator or MC Server Launcher
Within the `runner.sh` file change the FEX-Emu flags and launcher to whatever emultor and or launcher wanted
### 2. change restart time
At the start of the `RestartLauncher.sh` there is a variable called `TargetTime` changing this to a different time HH:MM will change what time the restart happens at (on unix the time must be an hour behind current time so 2am is 1am to UNIX so must but put as is)
