class Env {
  // Use 10.0.2.2 for Android emulator to hit localhost, or real IP for physical devices
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.253.226.126:8000',
  );
}
