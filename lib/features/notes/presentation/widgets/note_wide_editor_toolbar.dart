import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import 'note_attach_toolbar_icon.dart';
import 'note_checklist_toolbar_icon.dart';
import 'note_scan_toolbar_icon.dart';
import 'note_table_toolbar_icon.dart';

/// Barra inferior de herramientas — nota amplia (v0.49.41).
class NoteWideEditorToolbar extends StatelessWidget {
  const NoteWideEditorToolbar({
    super.key,
    required this.onChecklist,
    required this.onAttach,
    required this.onTable,
    required this.onScan,
    required this.onAris,
    this.checklistActive = false,
  });

  final VoidCallback onChecklist;
  final VoidCallback onAttach;
  final VoidCallback onTable;
  final VoidCallback onScan;
  final VoidCallback onAris;
  final bool checklistActive;

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
              tooltip: 'Checklist',
              onPressed: onChecklist,
              active: checklistActive,
              child: NoteChecklistToolbarIcon(
                color: checklistActive
                    ? AppColors.noteArisSky
                    : AppColors.noteWideTextMuted,
              ),
            ),
            _ToolIcon(
              tooltip: 'Adjuntar',
              onPressed: onAttach,
              child: NoteAttachToolbarIcon(
                color: AppColors.noteWideTextMuted,
              ),
            ),
            _ToolIcon(
              tooltip: 'Tabla',
              onPressed: onTable,
              child: NoteTableToolbarIcon(
                color: AppColors.noteWideTextMuted,
              ),
            ),
            _ToolIcon(
              tooltip: 'Escanear',
              onPressed: onScan,
              child: NoteScanToolbarIcon(
                color: AppColors.noteWideTextMuted,
              ),
            ),
            _ToolIcon(
              icon: Icons.auto_awesome_outlined,
              tooltip: 'Aris',
              onPressed: onAris,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.child,
    this.active = false,
  });

  final IconData? icon;
  final Widget? child;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color =
        active ? AppColors.noteArisSky : AppColors.noteWideTextMuted;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: child ??
          Icon(
            icon,
            size: 22,
            color: color,
          ),
      visualDensity: VisualDensity.compact,
    );
  }
}
