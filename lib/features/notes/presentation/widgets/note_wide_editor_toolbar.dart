import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Barra inferior de herramientas — nota amplia (v0.49.41).
class NoteWideEditorToolbar extends StatelessWidget {
  const NoteWideEditorToolbar({
    super.key,
    required this.onChecklist,
    required this.onAttach,
    required this.onTable,
    required this.onScan,
    required this.onAris,
  });

  final VoidCallback onChecklist;
  final VoidCallback onAttach;
  final VoidCallback onTable;
  final VoidCallback onScan;
  final VoidCallback onAris;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.noteWideSurface,
        border: Border(
          top: BorderSide(color: AppColors.noteWideBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ToolIcon(
              icon: Icons.checklist_rounded,
              tooltip: 'Checklist',
              onPressed: onChecklist,
            ),
            _ToolIcon(
              icon: Icons.attach_file_rounded,
              tooltip: 'Adjuntar',
              onPressed: onAttach,
            ),
            _ToolIcon(
              icon: Icons.table_chart_outlined,
              tooltip: 'Tabla',
              onPressed: onTable,
            ),
            _ToolIcon(
              icon: Icons.document_scanner_outlined,
              tooltip: 'Escanear',
              onPressed: onScan,
            ),
            _ToolIcon(
              icon: Icons.auto_awesome_outlined,
              tooltip: 'Aris',
              onPressed: onAris,
              accent: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.accent = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.noteArisSky : AppColors.noteWideTextSecondary;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 22, color: color),
      visualDensity: VisualDensity.compact,
    );
  }
}
