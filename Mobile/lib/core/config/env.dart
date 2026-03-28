class Env {
  // Make sure this matches your deployed or local FastAPI instance block URL.
  // Using 10.0.2.2 for Android emulator -> localhost.
  // Using localhost for iOS simulator.
  // In a real app, this would use flutter_dotenv or similar.
  static const String apiBaseUrl = 'http://localhost:8000'; // Change to 10.0.2.2 if testing on Android Emulator
}
