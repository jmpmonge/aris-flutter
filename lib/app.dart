import 'package:flutter/material.dart';

import 'features/home/presentation/home_preview_screen.dart';
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
      home: const HomePreviewScreen(),
    );
  }
}
