import 'package:flutter/material.dart';

import '../../core/models/event_model.dart';
import '../../core/models/task_model.dart';
import '../../core/repositories/repositories.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../navigation/app_bottom_navigation.dart';

/// Azul calendario HOY — v0.48.17 contraste reforzado (claro/oscuro).
const Color _kCalendarBlueLight = Color(0xFF1F6FEB);
const Color _kCalendarBlueDark = AppColors.calendarBlueDark;

/// Divisor calendario ↔ tareas (v0.48.17 / v0.48.33 oscuro).
const Color _kCalendarGroupDividerLight = Color(0xFFCBD5E1);

/// Línea vertical timeline — secundaria frente a los puntos (v0.48.27).
const Color _kTimelineSpineLight = Color(0xFFC7DCFF);
const Color _kTimelineSpineDark = Color(0xFF416A98);

/// Icono microsección TAREAS (v0.48.28).
const Color _kTasksSectionIconLight = Color(0xFFF59E0B);
const Color _kTasksSectionIconDark = AppColors.tasksOrangeDark;

/// Overlay cabecera HOY → Calendario (claro azul; oscuro neutro v0.48.33).
WidgetStateProperty<Color?> _hoyHeaderOverlayColor(bool isDark) {
  const light = Color(0xFFEAF3FF);
  const lightHover = Color(0xFFDDEBFF);
  return WidgetStateProperty.resolveWith((states) {
    if (isDark) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.surfaceHoverDark.withValues(alpha: 0.96);
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return AppColors.surfaceRaisedDark.withValues(alpha: 0.92);
      }
      return Colors.transparent;
    }
    if (states.contains(WidgetState.pressed)) {
      return light.withValues(alpha: 0.92);
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return lightHover.withValues(alpha: 0.72);
    }
    return Colors.transparent;
  });
}

/// Hover/pressed azul — bloque texto evento y bloque texto tarea en HOY (misma cápsula).
WidgetStateProperty<Color?> _calendarEventRowOverlayColor(bool isDark) {
  const lightHover = Color(0xFFEAF3FF);
  const lightPressed = Color(0xFFDDEBFF);
  const darkHover = AppColors.surfaceHoverDark;
  const darkPressed = AppColors.surfaceRaisedDark;
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) {
      return (isDark ? darkPressed : lightPressed)
          .withValues(alpha: isDark ? 0.88 : 0.90);
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return (isDark ? darkHover : lightHover)
          .withValues(alpha: isDark ? 0.82 : 0.88);
    }
    return null;
  });
}

/// Hover/pressed neutro — bloque textual de tarea (integrado con la tarjeta).
WidgetStateProperty<Color?> _taskTextBlockOverlayColor(bool isDark) {
  const lightHover = Color(0xFFF3F5F8);
  const lightPressed = Color(0xFFEEF2F6);
  const darkHover = AppColors.surfaceHoverDark;
  const darkPressed = AppColors.surfaceRaisedDark;
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) {
      return isDark
          ? darkPressed.withValues(alpha: 0.94)
          : lightPressed.withValues(alpha: 0.96);
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return isDark
          ? darkHover.withValues(alpha: 0.90)
          : lightHover.withValues(alpha: 0.94);
    }
    return null;
  });
}

/// Bloque **HOY** — v0.48.14 cabecera completa pulsable + timeline/alineación eventos.
class TodaySummaryCard extends StatefulWidget {
  const TodaySummaryCard({
    super.key,
    required this.events,
    required this.tasks,
    this.onOpenCalendar,
    this.onOpenTasks,
  });

  final List<EventModel> events;
  final List<TaskModel> tasks;
  final VoidCallback? onOpenCalendar;
  final VoidCallback? onOpenTasks;

  @override
  State<TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends State<TodaySummaryCard> {
  String? _expandedTaskId;

  /// Copias temporales de tareas recién completadas (persisten aunque salgan de
  /// [widget.tasks] tras el PATCH).
  final Map<String, TaskModel> _recentlyCompletedTasks = {};

  /// Orden estable de ids en Home (evita saltos al completar / desaparecer).
  final List<String> _homeTaskOrderIds = [];

  static const Duration _tasksBlockSizeDuration = Duration(milliseconds: 180);

  @override
  void didUpdateWidget(covariant TodaySummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _mergeHomeTaskOrderIds();
  }

  void _ensureHomeTaskOrderIds() {
    if (_homeTaskOrderIds.isNotEmpty) return;
    _homeTaskOrderIds.addAll(
      widget.tasks.where((t) => !t.completed).map((t) => t.id),
    );
  }

  void _mergeHomeTaskOrderIds() {
    final byId = <String, TaskModel>{};
    for (final task in widget.tasks) {
      final recent = _recentlyCompletedTasks[task.id];
      if (recent != null) {
        byId[task.id] = recent;
      } else if (!task.completed) {
        byId[task.id] = task;
      }
    }
    for (final recent in _recentlyCompletedTasks.values) {
      byId.putIfAbsent(recent.id, () => recent);
    }

    final merged = <String>[];
    for (final id in _homeTaskOrderIds) {
      if (byId.containsKey(id)) merged.add(id);
    }
    for (final task in widget.tasks) {
      if (byId.containsKey(task.id) && !merged.contains(task.id)) {
        merged.add(task.id);
      }
    }
    for (final id in _recentlyCompletedTasks.keys) {
      if (byId.containsKey(id) && !merged.contains(id)) merged.add(id);
    }
    _homeTaskOrderIds
      ..clear()
      ..addAll(merged);
  }

  void _toggleTaskExpand(String id) {
    setState(() {
      _expandedTaskId = _expandedTaskId == id ? null : id;
    });
  }

  /// Lista visible en Home: pendientes + completadas recientes (orden estable).
  List<TaskModel> _homeVisibleTasks() {
    _ensureHomeTaskOrderIds();

    final byId = <String, TaskModel>{};
    for (final task in widget.tasks) {
      final recent = _recentlyCompletedTasks[task.id];
      if (recent != null) {
        byId[task.id] = recent;
      } else if (!task.completed) {
        byId[task.id] = task;
      }
    }
    for (final recent in _recentlyCompletedTasks.values) {
      byId.putIfAbsent(recent.id, () => recent);
    }

    final visible = <TaskModel>[];
    final used = <String>{};
    for (final id in _homeTaskOrderIds) {
      final t = byId[id];
      if (t != null) {
        visible.add(t);
        used.add(id);
      }
    }
    for (final task in widget.tasks) {
      if (byId.containsKey(task.id) && !used.contains(task.id)) {
        visible.add(byId[task.id]!);
        used.add(task.id);
      }
    }
    for (final id in _recentlyCompletedTasks.keys) {
      if (!used.contains(id) && byId.containsKey(id)) {
        visible.add(byId[id]!);
      }
    }
    return visible;
  }

  Future<void> _onTaskCompleteTap(TaskModel task) async {
    final willComplete = !task.completed;

    if (willComplete) {
      _ensureHomeTaskOrderIds();
      if (!_homeTaskOrderIds.contains(task.id)) {
        _homeTaskOrderIds.add(task.id);
      }
      setState(() {
        _recentlyCompletedTasks[task.id] = task.copyWith(completed: true);
        if (_expandedTaskId == task.id) {
          _expandedTaskId = null;
        }
      });
    }

    await Repositories.task.setTaskCompleted(task.id, willComplete);

    if (!mounted) return;

    if (willComplete) {
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _recentlyCompletedTasks.remove(task.id);
          _homeTaskOrderIds.remove(task.id);
        });
      });
    } else {
      setState(() {
        _recentlyCompletedTasks.remove(task.id);
        _homeTaskOrderIds.remove(task.id);
      });
    }
  }

  static const double _radius = AppSpacing.homeCardRadius;
  static const double _pad = AppSpacing.homeCardPadding;

  static const double _eventTimeColWidth = 52;
  static const double _eventTimelineColWidth = 18;
  /// Gap único entre columna del punto y el bloque de texto (título + descripción).
  static const double _eventTimelineTextGap = 12;
  /// Alineación vertical: sube el bloque textual del evento respecto a hora/punto (px).
  static const double _eventTextTopOffset = -5;
  static const double _eventDotSize = 7.5;
  /// Desplaza el punto para alinearlo con la primera línea del título (no al centro de la fila).
  static const double _eventDotAlignPaddingTop = 6;
  /// Padding y radio cápsula hover — evento (texto) y tarea (texto) en HOY (v0.48.20+ unificado).
  static const double _eventTextInkPaddingH = 9;
  static const double _eventTextInkPaddingV = 6;
  static const double _eventTextInkBorderRadius = 12;
  /// Espacio entre filas de evento (compacto).
  static const double _eventRowGap = 4;
  /// Altura fija fila evento (hora + punto + texto; hover solo en texto).
  static const double _eventRowHeight = 52;
  static const double _eventTimelineLineTrim = 4;
  static const int _maxHomeTasks = 2;

  /// Texto secundario / cuerpo como [SuggestionCard] y tarjetas `surface`.
  static Color homeCardSecondaryText(ColorScheme scheme, bool isDark) =>
      isDark ? AppColors.textSecondaryDark : scheme.onSurfaceVariant;

  /// Párrafo descripción en expansión tarea — mismo tono que cuerpo de tarjeta.
  static TextStyle homeCardBodyDescriptionStyle(
    ColorScheme scheme,
    bool isDark,
  ) =>
      TextStyle(
        fontSize: 13,
        height: 1.26,
        fontWeight: FontWeight.w400,
        color: homeCardSecondaryText(scheme, isDark),
      );

  /// Línea vertical timeline (v0.48.27): azul muy suave, no compite con los puntos.
  static Color _eventTimelineLineColor(bool isDark) => isDark
      ? _kTimelineSpineDark.withValues(alpha: 0.62)
      : _kTimelineSpineLight.withValues(alpha: 0.70);

  /// Grosor spine vertical (1.2 px para legibilidad sin dominar).
  static const double _eventTimelineLineWidth = 1.2;

  static TextStyle _hoyLabelStyle(ColorScheme scheme, bool isDark) =>
      TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
        height: 1.0,
        color: isDark ? scheme.onSurface : AppColors.primaryDeep,
      );

  static const double _labelToContentGap =
      AppSpacing.homeCardHeaderToContentGap;
  /// Separación entre filas de tarea (2–4 px).
  static const double _taskRowGap = 3;

  static const String _emptyCalendarLine = 'Sin eventos para hoy.';
  static const String _emptyAllLine = 'Sin eventos ni tareas para hoy.';

  static Widget _thinGroupDivider(bool isDark) {
    final Color lineColor = isDark
        ? AppColors.outlineVariantDark.withValues(alpha: 0.85)
        : _kCalendarGroupDividerLight.withValues(alpha: 0.80);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Divider(
        height: 1,
        thickness: 1,
        color: lineColor,
      ),
    );
  }

  /// Fila compacta cabecera HOY (v0.48.29): sin `minHeight`; chevron 26×26.
  static Widget _buildHoyHeaderRow({
    required ColorScheme scheme,
    required bool isDark,
    required Color calendarIconColor,
    required Color chevronColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: AppSpacing.homeCardHeaderIconSize,
          color: calendarIconColor,
        ),
        const SizedBox(width: AppSpacing.homeCardHeaderIconTitleGap),
        Text('HOY', style: _hoyLabelStyle(scheme, isDark)),
        const Spacer(),
        SizedBox(
          width: AppSpacing.homeCardHeaderChevronBox,
          height: AppSpacing.homeCardHeaderChevronBox,
          child: Center(
            child: Icon(
              Icons.chevron_right_rounded,
              size: AppSpacing.homeCardHeaderChevronSize,
              color: chevronColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Microcabecera TAREAS — icono naranja + etiqueta (sin cajetín; v0.48.28).
  static Widget _tasksSectionMicroHeader(ColorScheme scheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.homeTasksSectionHeaderLeftInset,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            kAppNavTasksTabIcon,
            size: AppSpacing.homeTasksSectionIconSize,
            color: isDark ? _kTasksSectionIconDark : _kTasksSectionIconLight,
          ),
          const SizedBox(width: AppSpacing.homeTasksSectionIconTitleGap),
          Text('TAREAS', style: _hoyLabelStyle(scheme, isDark)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasEvents = widget.events.isNotEmpty;
    final visibleTasks = _homeVisibleTasks();
    final hasTasks = visibleTasks.isNotEmpty;
    final hasAny = hasEvents || hasTasks;
    final showCalendarTasksDivider = hasEvents && hasTasks;

    final hoyHeader = widget.onOpenCalendar != null
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onOpenCalendar,
              borderRadius: BorderRadius.circular(
                AppSpacing.homeCardHeaderInkBorderRadius,
              ),
              overlayColor: _hoyHeaderOverlayColor(isDark),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.homeCardHeaderInkPaddingH,
                  vertical: AppSpacing.homeCardHeaderInkPaddingV,
                ),
                child: _buildHoyHeaderRow(
                  scheme: scheme,
                  isDark: isDark,
                  calendarIconColor:
                      isDark ? _kCalendarBlueDark : _kCalendarBlueLight,
                  chevronColor:
                      isDark ? _kCalendarBlueDark : _kCalendarBlueLight,
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.homeCardHeaderInkPaddingH,
              vertical: AppSpacing.homeCardHeaderInkPaddingV,
            ),
            child: _buildHoyHeaderRow(
              scheme: scheme,
              isDark: isDark,
              calendarIconColor:
                  scheme.onSurfaceVariant.withValues(alpha: 0.45),
              chevronColor: scheme.onSurfaceVariant.withValues(alpha: 0.45),
            ),
          );

    final sections = <Widget>[
      hoyHeader,
      const SizedBox(height: _labelToContentGap),
    ];

    if (!hasAny) {
      sections.add(
        Text(
          _emptyAllLine,
          style: TextStyle(
            fontSize: 14.5,
            height: 1.35,
            fontWeight: FontWeight.w400,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      if (hasEvents) {
        sections.add(
          _EventCalendarStackedTable(
            events: widget.events,
            scheme: scheme,
            isDark: isDark,
          ),
        );
      } else {
        sections.add(
          Text(
            _emptyCalendarLine,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.35,
              fontWeight: FontWeight.w400,
              color: scheme.onSurfaceVariant,
            ),
          ),
        );
      }

      if (hasTasks) {
        if (showCalendarTasksDivider) {
          sections.add(_thinGroupDivider(isDark));
          sections.add(
            const SizedBox(
              height: AppSpacing.homeTasksSectionDividerToHeaderGap,
            ),
          );
        } else {
          sections.add(
            const SizedBox(
              height: AppSpacing.homeTasksSectionNoDividerToHeaderGap,
            ),
          );
        }
        final displayed = visibleTasks.length > _maxHomeTasks
            ? visibleTasks.sublist(0, _maxHomeTasks)
            : visibleTasks;
        final more = visibleTasks.length - displayed.length;

        final taskBlockChildren = <Widget>[
          _tasksSectionMicroHeader(scheme, isDark),
          const SizedBox(
            height: AppSpacing.homeTasksSectionHeaderToFirstTaskGap,
          ),
        ];
        for (var i = 0; i < displayed.length; i++) {
          final t = displayed[i];
          taskBlockChildren.add(
            AnimatedOpacity(
              opacity: t.completed ? 0.72 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _TaskRow(
                task: t,
                scheme: scheme,
                isDark: isDark,
                isExpanded: _expandedTaskId == t.id,
                onToggleExpand: () => _toggleTaskExpand(t.id),
                onCompleteTap: () => _onTaskCompleteTap(t),
              ),
            ),
          );
          if (i < displayed.length - 1) {
            taskBlockChildren.add(const SizedBox(height: _taskRowGap));
          }
        }
        if (more > 0) {
          taskBlockChildren.add(const SizedBox(height: 5));
          taskBlockChildren.add(
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onOpenTasks,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                splashColor: AppColors.primaryDeep.withValues(alpha: 0.06),
                highlightColor: AppColors.primaryDeep.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '+ $more tareas más',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: widget.onOpenTasks != null
                            ? (isDark
                                ? scheme.primary.withValues(alpha: 0.92)
                                : AppColors.primaryDeep.withValues(alpha: 0.78))
                            : scheme.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        sections.add(
          AnimatedSize(
            duration: _tasksBlockSizeDuration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: taskBlockChildren,
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(
            color: scheme.outline.withValues(
              alpha: AppColors.homeCardBorderAlpha(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(
                alpha: AppColors.homeCardShadowAlpha(
                  isDark ? Brightness.dark : Brightness.light,
                ),
              ),
              blurRadius: AppSpacing.shadowBlurHomeCard,
              offset: AppSpacing.shadowOffsetHomeCard,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(_pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections,
          ),
        ),
      ),
    );
  }
}

/// Calendario HOY: **una** línea vertical en capa inferior del Stack; filas altura fija.
class _EventCalendarStackedTable extends StatelessWidget {
  const _EventCalendarStackedTable({
    required this.events,
    required this.scheme,
    required this.isDark,
  });

  final List<EventModel> events;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lineColor =
        _TodaySummaryCardState._eventTimelineLineColor(isDark);
    final lineW = _TodaySummaryCardState._eventTimelineLineWidth;
    final tw = _TodaySummaryCardState._eventTimeColWidth;
    final cw = _TodaySummaryCardState._eventTimelineColWidth;
    final gw = _TodaySummaryCardState._eventTimelineTextGap;
    final dotSize = _TodaySummaryCardState._eventDotSize;
    final dotPadTop = _TodaySummaryCardState._eventDotAlignPaddingTop;
    final rowH = _TodaySummaryCardState._eventRowHeight;
    final trim = _TodaySummaryCardState._eventTimelineLineTrim;
    final n = events.length;
    final dotColor = isDark ? _kCalendarBlueDark : _kCalendarBlueLight;
    final rowGap = _TodaySummaryCardState._eventRowGap;

    final axisLeft = tw + (cw - lineW) / 2;
    final showSpine = n >= 2;
    final dotCenterOffsetY = dotPadTop + dotSize / 2;
    final spineTop = dotCenterOffsetY + trim;
    final spineHeight = (n - 1) * (rowH + rowGap) - 2 * trim;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topLeft,
      children: [
        if (showSpine && spineHeight > 0)
          Positioned(
            left: axisLeft,
            top: spineTop,
            child: IgnorePointer(
              child: Container(
                width: lineW,
                height: spineHeight,
                color: lineColor,
              ),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < n; i++) ...[
              if (i > 0) SizedBox(height: rowGap),
              _calendarEventRow(
                events[i],
                scheme,
                isDark,
                dotColor,
                dotSize,
                tw,
                cw,
                gw,
                rowH,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Una fila de evento: sin línea (solo punto); altura fija para alinear la capa Stack.
Widget _calendarEventRow(
  EventModel event,
  ColorScheme scheme,
  bool isDark,
  Color dotColor,
  double dotSize,
  double tw,
  double cw,
  double gw,
  double rowH,
) {
  final dotPadTop = _TodaySummaryCardState._eventDotAlignPaddingTop;
  final timeStr =
      event.timeText.trim().isNotEmpty ? event.timeText.trim() : event.timeHm;
  final subtitle = event.detail.trim().isNotEmpty
      ? event.detail.trim()
      : (event.description.trim().isNotEmpty
          ? event.description.trim()
          : (event.location.trim().isNotEmpty ? event.location.trim() : ''));

  final textPadH = _TodaySummaryCardState._eventTextInkPaddingH;
  final textPadV = _TodaySummaryCardState._eventTextInkPaddingV;
  final textRadius = _TodaySummaryCardState._eventTextInkBorderRadius;

  return SizedBox(
    height: rowH,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: tw,
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                timeStr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: cw,
          child: Padding(
            padding: EdgeInsets.only(top: dotPadTop),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: gw),
        Expanded(
          child: Transform.translate(
            offset: const Offset(
              0,
              _TodaySummaryCardState._eventTextTopOffset,
            ),
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(textRadius),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(textRadius),
                overlayColor: _calendarEventRowOverlayColor(isDark),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 0,
                    end: textPadH,
                    top: textPadV,
                    bottom: textPadV,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.75,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.22,
                            fontWeight: FontWeight.w400,
                            color:
                                _TodaySummaryCardState.homeCardSecondaryText(
                              scheme,
                              isDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

enum HomeTaskVisualKind { pending, inProgress, completed }

HomeTaskVisualKind homeTaskVisualKind(TaskModel t) {
  if (t.completed) return HomeTaskVisualKind.completed;
  final p = t.priority?.trim().toLowerCase() ?? '';
  if (p == 'in_progress' ||
      p == 'inprogress' ||
      p == 'doing' ||
      p == 'active') {
    return HomeTaskVisualKind.inProgress;
  }
  return HomeTaskVisualKind.pending;
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.scheme,
    required this.isDark,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onCompleteTap,
  });

  final TaskModel task;
  final ColorScheme scheme;
  final bool isDark;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final Future<void> Function() onCompleteTap;

  static const double _iconSize = 22;
  static const double _iconColWidth = 22;

  /// Altura visual compacta del área del icono.
  /// No usamos AppSpacing.minTouchTarget aquí porque fuerza la fila a 44 px
  /// y descompensa la alineación vertical con el texto.
  static const double _iconHitHeight = 32;

  /// Gap entre círculo/check y cápsula textual.
  static const double _iconTextGap = 10;

  /// Desplaza el bloque entero de tareas hacia dentro de la tarjeta.
  static const double _taskRowLeftInset = 12;

  /// Cápsula hover del bloque textual.
  static const double _textBlockInkPaddingH = 9;
  static const double _textBlockInkPaddingV = 5;
  static const double _textBlockInkBorderRadius = 13;

  static const double _titleMetaGap = 7;
  static const double _titleDescriptionGap = 3;

  /// Alineación óptica del círculo/check con la primera línea del título.
  /// Se calcula pensando en:
  /// - padding vertical del bloque textual = 5
  /// - línea del título ≈ 18 px
  /// - icono = 22 px
  static const double _taskIconTopWhenStartAligned = 3.5;

  static const double _expandRadius = 13;
  static const double _expandPadH = 11;
  static const double _expandPadV = 7.5;
  /// Panel expandido — misma familia que hover de tarea (v0.48.30, sin amarillo).
  static const Color _expandBgLight = Color(0xFFF3F5F8);
  static const Color _expandBgDark = AppColors.surfaceRaisedDark;
  static const Color _expandBorderLight = Color(0xFFDDE3EA);
  static const Color _expandBorderDark = AppColors.outlineVariantDark;

  /// Meta texto panel expandido oscuro.
  static const Color _expandTextDarkMeta = AppColors.textSecondaryDark;

  static TextStyle _detailMetaStyle(ColorScheme scheme, bool isDark) {
    return TextStyle(
      fontSize: 12.75,
      height: 1.25,
      fontWeight: FontWeight.w400,
      color: isDark ? scheme.onSurfaceVariant : AppColors.textSecondaryLight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final kind = homeTaskVisualKind(task);

    final meta = <String>[];
    if (task.dateText != null && task.dateText!.trim().isNotEmpty) {
      meta.add(task.dateText!.trim());
    }
    if (task.timeText != null && task.timeText!.trim().isNotEmpty) {
      meta.add(task.timeText!.trim());
    }
    if (task.dateIso != null && task.dateIso!.trim().isNotEmpty) {
      meta.add(task.dateIso!.trim());
    }
    final metaStr = meta.join(' · ');

    final IconData iconData;
    final Color iconColor;

    switch (kind) {
      case HomeTaskVisualKind.completed:
        iconData = Icons.check_circle_rounded;
        iconColor = isDark ? scheme.tertiary : AppColors.taskCompletedGreen;
      case HomeTaskVisualKind.inProgress:
        iconData = Icons.pending_rounded;
        iconColor = isDark ? scheme.primary : AppColors.calendarBlue;
      case HomeTaskVisualKind.pending:
        iconData = Icons.radio_button_unchecked_rounded;
        iconColor = isDark
            ? scheme.onSurfaceVariant
            : AppColors.taskPendingMuted;
    }

    final titleStyle = TextStyle(
      fontSize: 14.75,
      height: 1.22,
      fontWeight: FontWeight.w500,
      color: task.completed
          ? scheme.onSurfaceVariant.withValues(alpha: 0.85)
          : scheme.onSurface,
      decoration: task.completed ? TextDecoration.lineThrough : null,
      decorationColor: scheme.onSurfaceVariant,
    );

    final metaSmallStyle = TextStyle(
      fontSize: 12,
      height: 1.18,
      fontWeight: FontWeight.w400,
      color: _TodaySummaryCardState.homeCardSecondaryText(scheme, isDark),
    );

    final Widget? expandedPanel = _buildExpandedPanel(
      scheme: scheme,
      isDark: isDark,
      kind: kind,
      metaStr: metaStr,
    );

    return Padding(
      padding: const EdgeInsets.only(left: _taskRowLeftInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _iconColWidth,
            height: _iconHitHeight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCompleteTap(),
                customBorder: const CircleBorder(),
                overlayColor: _calendarEventRowOverlayColor(isDark),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: _taskIconTopWhenStartAligned,
                    ),
                    child: Icon(
                      iconData,
                      size: _iconSize,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: _iconTextGap),
          Expanded(
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(_textBlockInkBorderRadius),
              child: InkWell(
                onTap: onToggleExpand,
                borderRadius: BorderRadius.circular(_textBlockInkBorderRadius),
                overlayColor: _taskTextBlockOverlayColor(isDark),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: _textBlockInkPaddingH,
                    vertical: _textBlockInkPaddingV,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: isExpanded ? 6 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle,
                            ),
                          ),
                          if (metaStr.isNotEmpty && !isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: _titleMetaGap,
                              ),
                              child: Text(
                                metaStr,
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: metaSmallStyle,
                              ),
                            ),
                        ],
                      ),
                      if (expandedPanel != null) ...[
                        const SizedBox(height: _titleDescriptionGap),
                        expandedPanel,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildExpandedPanel({
    required ColorScheme scheme,
    required bool isDark,
    required HomeTaskVisualKind kind,
    required String metaStr,
  }) {
    if (!isExpanded) return null;

    final expandMeta = isDark
        ? _detailMetaStyle(scheme, isDark).copyWith(
            color: _expandTextDarkMeta,
          )
        : _detailMetaStyle(scheme, isDark);

    final pieces = <Widget>[];

    final desc = (task.description ?? '').trim();
    if (desc.isNotEmpty) {
      pieces.add(
        Text(
          desc,
          style: _TodaySummaryCardState.homeCardBodyDescriptionStyle(
            scheme,
            isDark,
          ),
        ),
      );
    }

    if (task.dueDate != null) {
      final d = task.dueDate!;
      pieces.add(
        Text(
          'Vencimiento (local): '
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
          style: expandMeta,
        ),
      );
    }

    if (metaStr.isNotEmpty) {
      pieces.add(
        Text('Fecha / hora: $metaStr', style: expandMeta),
      );
    }

    if (task.priority != null && task.priority!.trim().isNotEmpty) {
      pieces.add(
        Text(
          'Prioridad: ${task.priority}',
          style: expandMeta,
        ),
      );
    }

    pieces.add(
      Text(
        switch (kind) {
          HomeTaskVisualKind.completed => 'Estado: completada',
          HomeTaskVisualKind.inProgress => 'Estado: en curso',
          HomeTaskVisualKind.pending => 'Estado: pendiente',
        },
        style: expandMeta,
      ),
    );

    final tagStr = task.tags.where((x) => x.trim().isNotEmpty).join(' · ');
    if (tagStr.isNotEmpty) {
      pieces.add(
        Text('Etiquetas: $tagStr', style: expandMeta),
      );
    }

    final borderColor = isDark
        ? _expandBorderDark.withValues(alpha: 0.55)
        : _expandBorderLight.withValues(alpha: 0.85);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? _expandBgDark : _expandBgLight,
        borderRadius: BorderRadius.circular(_expandRadius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _expandPadH,
          vertical: _expandPadV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < pieces.length; i++) ...[
              if (i > 0) const SizedBox(height: 4),
              pieces[i],
            ],
          ],
        ),
      ),
    );
  }
}