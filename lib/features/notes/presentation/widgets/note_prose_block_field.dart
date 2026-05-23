import 'package:flutter/material.dart';

import '../../../../theme/aris_list_palette.dart';

/// Ritmo de línea dentro del bloque prose (v0.49.43).
/// Intro inserta `\n` normal; el aire visual viene de [bodyLineHeight].
abstract final class NoteProseBodyTypography {
  static const double fontSize = 17;
  static const double bodyLineHeight = 1.26;

  static TextStyle bodyStyleFor(BuildContext context) => TextStyle(
        fontSize: fontSize,
        height: bodyLineHeight,
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: FontWeight.w400,
        color: context.arisList.textPrimary,
      );
}

/// Bloque de texto libre multilínea en la nota amplia (v0.49.42–v0.49.43).
class NoteProseBlockField extends StatelessWidget {
  const NoteProseBlockField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.minLines,
    this.hintText,
    this.onTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final int minLines;
  final String? hintText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = NoteProseBodyTypography.bodyStyleFor(context);
    final field = DefaultTextHeightBehavior(
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: bodyStyle,
        enabled: enabled,
        minLines: minLines,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        scrollPadding: EdgeInsets.zero,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          hintText: hintText,
          hintStyle: TextStyle(
            color: context.arisList.textMuted,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
        ),
      ),
    );

    if (onTap == null) return field;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: field,
    );
  }
}

/// Estado editable de un bloque de prosa.
final class NoteProseBlockState {
  NoteProseBlockState({
    required this.id,
    String text = '',
  })  : controller = TextEditingController(text: text),
        focusNode = FocusNode();

  final String id;
  final TextEditingController controller;
  final FocusNode focusNode;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}
