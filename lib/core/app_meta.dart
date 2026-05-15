/// Metadatos de build de la app (sin `package_info`; una sola fuente para UI y docs).
abstract final class AppMeta {
  static const String versionSemver = '0.28.0';
  static const String buildNumber = '1';

  /// Línea mostrada en pantallas (Perfil, etc.).
  static const String userVisibleVersionLine =
      'Aris · v$versionSemver (build de demostración)';
}
