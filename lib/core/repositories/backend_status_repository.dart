import '../api/api_client.dart';
import '../api/api_result.dart';

/// Comprueba disponibilidad del backend vía `GET /health` (v0.39).
///
/// No sustituye repositorios mock de dominio; solo diagnóstico de red.
abstract interface class BackendStatusRepository {
  Future<ApiResult<Map<String, dynamic>>> checkHealth();
}

final class RemoteBackendStatusRepository implements BackendStatusRepository {
  RemoteBackendStatusRepository(this._client);

  final ApiClient _client;

  @override
  Future<ApiResult<Map<String, dynamic>>> checkHealth() =>
      _client.checkHealth();
}
