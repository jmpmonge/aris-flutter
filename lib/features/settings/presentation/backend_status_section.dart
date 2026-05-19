import 'package:flutter/material.dart';

import '../../../core/api/api_config.dart';
import '../../../core/repositories/repositories.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../theme/app_spacing.dart';

/// Estado del backend FastAPI local (solo diagnóstico; no afecta mocks).
class BackendStatusSection extends StatefulWidget {
  const BackendStatusSection({super.key});

  @override
  State<BackendStatusSection> createState() => _BackendStatusSectionState();
}

enum _ConnectivityPhase {
  idle,
  checking,
  connected,
  disconnected,
}

class _BackendStatusSectionState extends State<BackendStatusSection> {
  _ConnectivityPhase _phase = _ConnectivityPhase.idle;
  String? _detail;

  String get _primaryLabel {
    switch (_phase) {
      case _ConnectivityPhase.idle:
        return 'Estado del backend: no comprobado';
      case _ConnectivityPhase.checking:
        return 'Comprobando…';
      case _ConnectivityPhase.connected:
        return 'Backend conectado';
      case _ConnectivityPhase.disconnected:
        return 'Backend sin conexión';
    }
  }

  Future<void> _runCheck() async {
    setState(() {
      _phase = _ConnectivityPhase.checking;
      _detail = null;
    });
    final r = await Repositories.backendStatus.checkHealth();
    if (!mounted) return;
    setState(() {
      if (r.isSuccess) {
        _phase = _ConnectivityPhase.connected;
        _detail =
            '${ApiConfig.baseUrl}/health';
      } else {
        _phase = _ConnectivityPhase.disconnected;
        _detail = r.error?.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget? trailing;
    if (_phase == _ConnectivityPhase.connected) {
      trailing = Icon(
        Icons.cloud_done_rounded,
        color: scheme.primary,
        size: 22,
      );
    } else if (_phase == _ConnectivityPhase.checking) {
      trailing = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: scheme.outline,
        ),
      );
    } else if (_phase == _ConnectivityPhase.disconnected &&
        (_detail?.isNotEmpty ?? false)) {
      trailing = Icon(
        Icons.cloud_off_outlined,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
        size: 22,
      );
    } else if (_phase == _ConnectivityPhase.idle) {
      trailing = Icon(
        Icons.cloud_queue_outlined,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
        size: 22,
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _primaryLabel,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      ApiConfig.baseUrl,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (_detail != null && _detail!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _detail!,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _phase == _ConnectivityPhase.checking ? null : _runCheck,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Comprobar conexión'),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'La app sigue usando datos mock si el servidor está apagado.',
            style: text.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
