import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_spacing.dart';

/// Cabecera Home — marca textual Nunito Sans ExtraBold (v0.48.23) + avatar; oscuro v0.48.16.
class ArisHeader extends StatelessWidget {
  const ArisHeader({
    super.key,
    this.onAssistantTap,
  });

  /// Conserva el gesto previo (p. ej. abrir asistente). Sin rutas nuevas.
  final VoidCallback? onAssistantTap;

  /// Ritmo vertical superior (SafeArea ya está en [HomeScreen]).
  static const double _paddingTop = 18;

  /// Alineación con contenido interno de tarjetas (~18 margen + ~14 padding).
  static const double _contentPaddingLeft = 30;
  static const double _paddingRight = AppSpacing.homePageMarginH;

  static const double _subtitleSize = 14;
  static const double _titleSubtitleGap = 4;

  static const double _avatarSize = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const kLightArisWordmark = Color(0xFF071B3F);
    /// Modo oscuro: azul claro legible (referencia #DCE8FF).
    const kDarkArisWordmark = Color(0xFFDCE8FF);

    final arisStyle = GoogleFonts.nunitoSans(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.1,
      height: 1.0,
      color: isDark ? kDarkArisWordmark : kLightArisWordmark,
    );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('aris', style: arisStyle),
        const SizedBox(height: _titleSubtitleGap),
        Text(
          'Una forma más inteligente de organizar tu día.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: _subtitleSize,
            height: 1.28,
            fontWeight: FontWeight.w400,
            color: isDark
                ? const Color(0xFFC3CAD6)
                : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    /// Mismo azul de contenedor que [ProfileScreen] (`primaryContainer` / `onPrimaryContainer`).
    final avatar = Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        'J',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _contentPaddingLeft,
        _paddingTop,
        _paddingRight,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: column),
          if (onAssistantTap != null) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAssistantTap,
                customBorder: const CircleBorder(),
                child: avatar,
              ),
            ),
          ] else ...[
            const SizedBox(width: 8),
            avatar,
          ],
        ],
      ),
    );
  }
}
