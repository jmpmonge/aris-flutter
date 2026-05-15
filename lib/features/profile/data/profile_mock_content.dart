import 'package:flutter/material.dart';

/// Opciones de menú simuladas en [ProfileScreen].
abstract final class ProfileMockContent {
  static const options = <(IconData, String, String)>[
    (Icons.person_rounded, 'Cuenta', 'Datos de perfil simulados'),
    (Icons.tune_rounded, 'Preferencias', 'Notificaciones, idioma…'),
    (Icons.hub_outlined, 'Integraciones', 'Próximamente · sin APIs'),
    (Icons.shield_outlined, 'Privacidad', 'Políticas de ejemplo'),
    (Icons.help_outline_rounded, 'Ayuda', 'Centro de ayuda mock'),
  ];
}
