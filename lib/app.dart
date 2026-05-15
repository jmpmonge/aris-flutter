import 'package:flutter/material.dart';

import 'shared/navigation/app_navigation_shell.dart';
import 'theme/app_theme.dart';

/// Raíz de la aplicación con tema claro / oscuro según sistema.
class ArisApp extends StatelessWidget {
  const ArisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aris',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AppNavigationShell(),
    );
  }
}
