import 'package:flutter/material.dart';

import 'core/repositories/repositories.dart';
import 'shared/layout/responsive_app_frame.dart';
import 'shared/navigation/app_navigation_shell.dart';
import 'theme/app_theme.dart';

/// Raíz de la aplicación: tema claro / oscuro / sistema según [Repositories.settings].
class ArisApp extends StatefulWidget {
  const ArisApp({super.key});

  @override
  State<ArisApp> createState() => _ArisAppState();
}

class _ArisAppState extends State<ArisApp> {
  @override
  void initState() {
    super.initState();
    Repositories.settings.themeListenable.addListener(_onThemeMode);
  }

  @override
  void dispose() {
    Repositories.settings.themeListenable.removeListener(_onThemeMode);
    super.dispose();
  }

  void _onThemeMode() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aris',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Repositories.settings.themeListenable.value,
      builder: (context, child) {
        return ResponsiveAppFrame(child: child ?? const SizedBox.shrink());
      },
      home: const AppNavigationShell(),
    );
  }
}
