import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

/// Raíz de la aplicación. Mantiene el árbol de widgets mínimo en fase 1.
class ArisApp extends StatelessWidget {
  const ArisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aris',
      theme: AppTheme.light(),
      home: const _BootstrapHome(),
    );
  }
}

/// Pantalla mínima de arranque: sin navegación ni features cableadas.
class _BootstrapHome extends StatelessWidget {
  const _BootstrapHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aris · base')),
      body: const Center(
        child: Text('Clara / Aris — proyecto base (solo mock, sin integración).'),
      ),
    );
  }
}
