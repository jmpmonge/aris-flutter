/// URL base del FastAPI en desarrollo local (v0.39 — solo `GET /health`).
abstract final class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Uri get baseUri => Uri.parse(baseUrl);
}
