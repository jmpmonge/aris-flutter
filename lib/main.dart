import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/local_action_service.dart';
import 'core/services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.initialize();
  await LocalActionService.initialize();
  runApp(const ArisApp());
}
