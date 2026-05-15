import 'package:flutter/material.dart';

class MailFeatureShell extends StatelessWidget {
  const MailFeatureShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Correo · mock (sin IMAP/SMTP)')),
    );
  }
}
