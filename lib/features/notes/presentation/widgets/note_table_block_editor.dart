import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import 'note_body_format.dart';

/// Tabla editable integrada en la nota amplia (v0.49.42).
class NoteTableBlockEditor extends StatelessWidget {
  const NoteTableBlockEditor({
    super.key,
    required this.state,
    required this.enabled,
    required this.onExitBelow,
    this.onTapBelow,
    required this.onAddRow,
  });

  final NoteTableBlockState state;
  final bool enabled;
  final VoidCallback onExitBelow;
  final VoidCallback? onTapBelow;
  final VoidCallback onAddRow;

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

  (int, int)? _nextCell(int row, int col) {
    if (col < state.columns - 1) return (row, col + 1);
    if (row < state.rowCount - 1) return (row + 1, 0);
    return null;
  }

  void _advanceFromCell(int row, int col) {
    final next = _nextCell(row, col);
    if (next != null) {
      state.focusCell(next.$1, next.$2);
      return;
    }

    final text = state.rowControllers[row][col].text.trim();
    if (text.isEmpty) {
      onExitBelow();
      return;
    }

    final lastRowHasContent = state.rowControllers.last
        .any((controller) => controller.text.trim().isNotEmpty);
    if (lastRowHasContent) {
      onAddRow();
      return;
    }
    onExitBelow();
  }

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
                for (var r = 0; r < state.rowCount; r++)
                  TableRow(
                    children: [
                      for (var c = 0; c < state.columns; c++)
                        TextField(
                          controller: state.rowControllers[r][c],
                          focusNode: state.focusNodes[r][c],
                          enabled: enabled,
                          style: _cellStyle,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: _nextCell(r, c) != null
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onSubmitted: (_) => _advanceFromCell(r, c),
                          decoration: _cellDecoration,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (onTapBelow != null)
          GestureDetector(
            onTap: enabled ? onTapBelow : null,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox(
              width: double.infinity,
              height: 36,
            ),
          ),
      ],
    );
  }
}

/// Estado editable con controllers y foco estables por celda.
final class NoteTableBlockState {
  NoteTableBlockState({
    required this.id,
    required NoteTableBlock data,
  }) : columns = data.columns {
    for (final row in data.rows) {
      _addRowFromData(row);
    }
  }

  final String id;
  final int columns;
  final List<List<TextEditingController>> rowControllers = [];
  final List<List<FocusNode>> focusNodes = [];

  int get rowCount => rowControllers.length;

  void _addRowFromData(List<String> row) {
    rowControllers.add(
      List.generate(
        columns,
        (c) => TextEditingController(text: c < row.length ? row[c] : ''),
      ),
    );
    focusNodes.add(List.generate(columns, (_) => FocusNode()));
  }

  void focusCell(int row, int col) {
    focusNodes[row][col].requestFocus();
  }

  NoteTableBlock snapshot() => NoteTableBlock(
        columns: columns,
        rows: [
          for (final row in rowControllers)
            [for (final cell in row) cell.text],
        ],
      );

  void addRow() {
    _addRowFromData(List.filled(columns, ''));
  }

  void dispose() {
    for (final row in rowControllers) {
      for (final cell in row) {
        cell.dispose();
      }
    }
    for (final row in focusNodes) {
      for (final node in row) {
        node.dispose();
      }
    }
  }
}
