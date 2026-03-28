class Env {
  // Use 10.0.2.2 for Android emulator to hit localhost, or real IP for physical devices
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
}
