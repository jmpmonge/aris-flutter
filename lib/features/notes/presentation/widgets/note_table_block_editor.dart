import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import 'note_body_format.dart';

/// Tabla editable integrada en la nota amplia (v0.49.42).
class NoteTableBlockEditor extends StatelessWidget {
  const NoteTableBlockEditor({
    super.key,
    required this.state,
    required this.enabled,
    required this.onAddRow,
    required this.onWriteBelow,
    this.onTapBelow,
  });

  final NoteTableBlockState state;
  final bool enabled;
  final VoidCallback onAddRow;
  final VoidCallback onWriteBelow;
  final VoidCallback? onTapBelow;

  static const TextStyle _cellStyle = TextStyle(
    fontSize: 17,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.noteWideTextPrimary,
  );

  static const InputDecoration _cellDecoration = InputDecoration(
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    filled: false,
    fillColor: Colors.transparent,
    isCollapsed: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    hintText: null,
  );

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: AppColors.noteWideBorder, width: 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.noteWideSurface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.noteWideBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Table(
              border: TableBorder(
                horizontalInside: border,
                verticalInside: border,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {
                for (var c = 0; c < state.columns; c++)
                  c: const FlexColumnWidth(),
              },
              children: [
                for (var r = 0; r < state.rowControllers.length; r++)
                  TableRow(
                    children: [
                      for (var c = 0; c < state.columns; c++)
                        TextField(
                          controller: state.rowControllers[r][c],
                          enabled: enabled,
                          style: _cellStyle,
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          decoration: _cellDecoration,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton.icon(
              onPressed: enabled ? onAddRow : null,
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: AppColors.noteWideTextSecondary,
              ),
              label: const Text(
                'Añadir fila',
                style: TextStyle(
                  color: AppColors.noteWideTextSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                visualDensity: VisualDensity.compact,
              ),
            ),
            TextButton.icon(
              onPressed: enabled ? onWriteBelow : null,
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: AppColors.noteArisBlue,
              ),
              label: const Text(
                'Escribir debajo',
                style: TextStyle(
                  color: AppColors.noteArisBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        if (onTapBelow != null) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: enabled ? onTapBelow : null,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox(
              width: double.infinity,
              height: 28,
            ),
          ),
        ],
      ],
    );
  }
}

/// Estado editable con controllers estables por celda.
final class NoteTableBlockState {
  NoteTableBlockState({
    required this.id,
    required NoteTableBlock data,
  }) : columns = data.columns {
    for (final row in data.rows) {
      rowControllers.add(
        List.generate(
          columns,
          (c) => TextEditingController(text: c < row.length ? row[c] : ''),
        ),
      );
    }
  }

  final String id;
  final int columns;
  final List<List<TextEditingController>> rowControllers = [];

  NoteTableBlock snapshot() => NoteTableBlock(
        columns: columns,
        rows: [
          for (final row in rowControllers)
            [for (final cell in row) cell.text],
        ],
      );

  void addRow() {
    rowControllers.add(
      List.generate(columns, (_) => TextEditingController()),
    );
  }

  void dispose() {
    for (final row in rowControllers) {
      for (final cell in row) {
        cell.dispose();
      }
    }
  }
}
