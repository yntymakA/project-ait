class Env {
  // Android emulator reaches host machine via 10.0.2.2.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
