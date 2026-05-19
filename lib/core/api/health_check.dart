import 'api_result.dart';

import 'health_check_stub.dart'
    if (dart.library.io) 'health_check_io.dart' as impl;

/// Ejecuta `GET /health` cuando la plataforma lo permite (`dart:io`).
Future<ApiResult<Map<String, dynamic>>> runBackendHealth(Uri? base) =>
    impl.runBackendHealth(base);
