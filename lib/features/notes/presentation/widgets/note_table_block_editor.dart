import 'package:flutter/material.dart';

import '../../../../theme/aris_list_palette.dart';
import '../../../../theme/app_spacing.dart';
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

  (int, int)? _nextCell(int row, int col) {
    if (col < state.columns - 1) return (row, col + 1);
    if (row < state.rowCount - 1) return (row + 1, 0);
    return null;
  }

  void _advanceFromCell(int row, int col) {
    final text = state.rowControllers[row][col].text.trim();
    final isNewEmptyRow = state.newEmptyRowIndex == row;

    if (text.isEmpty && col == 0 && isNewEmptyRow) {
      state.newEmptyRowIndex = null;
      onExitBelow();
      return;
    }

    if (text.isNotEmpty && isNewEmptyRow) {
      state.newEmptyRowIndex = null;
    }

    final next = _nextCell(row, col);
    if (next != null) {
      state.focusCell(next.$1, next.$2);
      return;
    }

    if (text.isNotEmpty || state.rowHasContent(row)) {
      onAddRow();
      return;
    }

    onExitBelow();
  }

  @override
  Widget build(BuildContext context) {
    final list = context.arisList;
    final cellStyle = TextStyle(
      fontSize: 17,
      height: 1.26,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: list.textPrimary,
    );
    final border = BorderSide(color: list.borderNormal, width: 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: list.elevated.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: list.borderNormal),
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
                          style: cellStyle,
                          maxLines: 1,
                          scrollPadding: EdgeInsets.zero,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _advanceFromCell(r, c),
                          onEditingComplete: () => _advanceFromCell(r, c),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            filled: false,
                            fillColor: Colors.transparent,
                            isCollapsed: true,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: AppSpacing.noteBodyTableCellPadV,
                            ),
                            hintText: null,
                          ),
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
              height: AppSpacing.noteBodyTableTapBelow,
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

  int? newEmptyRowIndex;

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
    newEmptyRowIndex = rowCount - 1;
  }

  bool isRowEmpty(int row) {
    return rowControllers[row].every((c) => c.text.trim().isEmpty);
  }

  bool rowHasContent(int row) {
    return rowControllers[row].any((c) => c.text.trim().isNotEmpty);
  }

  bool get isLastRowEmpty => rowCount > 0 && isRowEmpty(rowCount - 1);

  void removeLastRowIfEmpty() {
    if (rowCount <= 1 || !isLastRowEmpty) return;
    newEmptyRowIndex = null;
    final row = rowCount - 1;
    for (final cell in rowControllers[row]) {
      cell.dispose();
    }
    for (final node in focusNodes[row]) {
      node.dispose();
    }
    rowControllers.removeAt(row);
    focusNodes.removeAt(row);
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
