/// Application configuration for environment-based settings.
class AppConfig {
  /// Base URL for the backend API.
  ///
  /// Set via build-time argument: --dart-define=API_BASE_URL=https://your-api.vercel.app
  /// Defaults to localhost for local development.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
