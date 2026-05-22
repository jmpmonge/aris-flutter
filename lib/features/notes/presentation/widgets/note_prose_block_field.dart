import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Bloque de texto libre en la nota amplia (v0.49.42).
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

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 17,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.noteWideTextPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      style: bodyStyle,
      enabled: enabled,
      minLines: minLines,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.noteWideTextMuted,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: EdgeInsets.zero,
        isCollapsed: true,
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
