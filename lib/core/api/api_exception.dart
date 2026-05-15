/// Error futuro de capa HTTP / API. Sin red en v0.37.
class ApiException implements Exception {
  ApiException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() =>
      'ApiException($code): $message${cause != null ? ' ($cause)' : ''}';
}
