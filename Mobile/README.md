# Mobile Run Guide

Universal launch guide for any developer machine and any Android device.

This project uses default API URL from env.dart:
http://127.0.0.1:8000

For physical Android devices, this works only when USB reverse is enabled.

## 1) Prerequisites

1. Flutter SDK installed and available in PATH.
2. Android Studio and Android SDK Platform Tools installed.
3. USB debugging enabled on phone (for USB mode).
4. Backend running on host machine port 8000.

## 2) Start backend

From repository root:

cd BackEnd
docker compose up -d
curl http://127.0.0.1:8000/health

Expected: JSON response with healthy status.

## 3) Check connected devices

From Mobile folder:

flutter devices

Copy the device id you want to run on.

## 4) USB mode for physical Android phone (recommended)

1. Connect phone by cable.
2. Confirm phone is listed in adb:

adb devices

3. Set port reverse for selected device id:

adb -s <DEVICE_ID> reverse tcp:8000 tcp:8000
adb -s <DEVICE_ID> reverse --list

4. Run app:

cd Mobile
flutter run -d <DEVICE_ID>

## 5) Android emulator mode

1. Start emulator:

flutter emulators
flutter emulators --launch <EMULATOR_ID>

2. Get emulator device id:

flutter devices

3. Option A, keep default URL and use reverse:

adb -s <EMULATOR_DEVICE_ID> reverse tcp:8000 tcp:8000
flutter run -d <EMULATOR_DEVICE_ID>

4. Option B, no reverse, use host alias for emulator:

flutter run -d <EMULATOR_DEVICE_ID> --dart-define=API_URL=http://10.0.2.2:8000

## 6) Wi-Fi mode for physical Android phone (no USB)

1. Find host LAN IP, for example 192.168.1.100.
2. Ensure phone and host are in same network.
3. Run with explicit API URL:

cd Mobile
flutter run -d <DEVICE_ID> --dart-define=API_URL=http://<HOST_LAN_IP>:8000

## 7) PATH fix for adb not found

If terminal shows command not found: adb, add platform-tools to PATH.

macOS zsh:

echo 'export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"' >> ~/.zshrc
source ~/.zshrc
adb version

## 8) Common errors

1. more than one device/emulator
Use explicit device selection: flutter run -d <DEVICE_ID>

2. Target file adb not found
Do not combine commands like flutter run adb reverse ...
Run adb command first, then run flutter command.

3. Lost connection to device
Restart adb and reconnect device:

adb kill-server
adb start-server
adb devices

4. cd path errors with spaces
Use quotes around paths:

cd "/path/with spaces/project/Mobile"
