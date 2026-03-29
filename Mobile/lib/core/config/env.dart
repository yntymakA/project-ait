class Env {
  // Physical phone on the same Wi-Fi reaches backend via host LAN IP.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.253.226.126:8000',
  );
}
