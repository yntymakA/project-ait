class Env {
  // USB Android phone mode: use localhost with adb reverse.
  // Run: /Users/main/Library/Android/sdk/platform-tools/adb reverse tcp:8000 tcp:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
