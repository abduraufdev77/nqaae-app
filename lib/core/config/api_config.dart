class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'NQAAE_API_BASE_URL',
    defaultValue: 'http://172.16.16.82:8000',
  );
}