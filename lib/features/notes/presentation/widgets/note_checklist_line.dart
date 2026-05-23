import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/aris_list_palette.dart';
import 'note_body_format.dart';
import 'note_prose_block_field.dart';

/// Línea de checklist integrada en el cuerpo de la nota (v0.49.41–v0.49.43).
/// Intro con texto → nueva fila; Intro en línea vacía → salida al cuerpo libre.
class NoteChecklistLine extends StatelessWidget {
  const NoteChecklistLine({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.done,
    required this.onToggle,
    this.onEnter,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback? onEnter;
  final bool enabled;

  static const double _circleSize = 22;
  /// Alineación óptica con la primera línea (sin padding externo del bloque).
  static const double _circleTopPad = 2;
  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    final list = context.arisList;
    final textStyle = NoteProseBodyTypography.bodyStyleFor(context).copyWith(
      color: done ? list.textMuted : list.textPrimary,
      decoration: done ? TextDecoration.lineThrough : null,
      decorationColor: list.textMuted,
    );

    return DefaultTextHeightBehavior(
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: _circleTopPad),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: enabled ? onToggle : null,
                borderRadius: BorderRadius.circular(_circleSize),
                child: SizedBox(
                  width: _circleSize,
                  height: _circleSize,
                  child: Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: _circleSize,
                    color: done ? list.accent : list.textMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: Focus(
              onKeyEvent: (node, event) {
                if (onEnter == null) return KeyEventResult.ignored;
                if (event is! KeyDownEvent) return KeyEventResult.ignored;
                if (event.logicalKey != LogicalKeyboardKey.enter) {
                  return KeyEventResult.ignored;
                }
                if (HardwareKeyboard.instance.isShiftPressed) {
                  return KeyEventResult.ignored;
                }
                onEnter!();
                return KeyEventResult.handled;
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                style: textStyle,
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                scrollPadding: EdgeInsets.zero,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado editable de una línea (controller y foco estables).
final class NoteChecklistLineState {
  NoteChecklistLineState({
    required this.id,
    required NoteChecklistItem item,
  })  : item = item,
        controller = TextEditingController(text: item.text),
        focusNode = FocusNode();

  final String id;
  NoteChecklistItem item;
  final TextEditingController controller;
  final FocusNode focusNode;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}
