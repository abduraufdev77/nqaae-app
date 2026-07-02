class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'NQAAE_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
