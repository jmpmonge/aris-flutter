import 'package:flutter/material.dart';

import '../../../core/models/local_action_model.dart';
import '../../../core/services/local_action_service.dart';
import '../../../core/services/mail_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/local_action_card.dart';
import '../../../shared/widgets/local_action_empty_state.dart';
import '../../../theme/app_spacing.dart';

/// Mail — pestañas **visuales** + hilos simulados.
class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  int _folder = 0;

  @override
  void initState() {
    super.initState();
    LocalActionService.revision.addListener(_onArisActions);
  }

  @override
  void dispose() {
    LocalActionService.revision.removeListener(_onArisActions);
    super.dispose();
  }

  void _onArisActions() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final tabs = MailService.getFolderLabels();
    final mails = MailService.getInboxPreview(folderIndex: _folder);
    final mailActions =
        LocalActionService.getActionsByType(LocalActionType.mail);

    return SafeArea(
      child: Column(
        key: const Key('tab_mail'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(
            title: 'Mail',
            subtitle: 'Bandejas simuladas · sin IMAP',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SegmentedButton<int>(
              segments: [
                for (var i = 0; i < tabs.length; i++)
                  ButtonSegment<int>(value: i, label: Text(tabs[i])),
              ],
              selected: {_folder},
              onSelectionChanged: (s) => setState(() => _folder = s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.fabStackClearance,
              ),
              children: [
                Text(
                  'Acciones de correo sugeridas',
                  style: text.labelSmall?.copyWith(
                    letterSpacing: 1.05,
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (mailActions.isEmpty)
                  const LocalActionEmptyState(
                    message:
                        'Sin sugerencias todavía. En Inicio prueba «responder correo…».',
                  )
                else
                  ...List.generate(mailActions.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: LocalActionCard(action: mailActions[i]),
                    );
                  }),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bandeja (${tabs[_folder]})',
                  style: text.labelSmall?.copyWith(
                    letterSpacing: 1.05,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...List.generate(mails.length, (i) {
                  final m = mails[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: scheme.secondaryContainer,
                                child: Text(
                                  m.senderName.isNotEmpty
                                      ? m.senderName.substring(0, 1)
                                      : '?',
                                  style: text.labelLarge?.copyWith(
                                    color: scheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  m.senderName,
                                  style: text.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            m.subject,
                            style: text.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            m.preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
