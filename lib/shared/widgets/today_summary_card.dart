import 'package:flutter/material.dart';

import '../../core/models/event_model.dart';
import '../../core/models/note_model.dart';
import '../../core/models/task_model.dart';
import '../../core/repositories/repositories.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/home_card_theme.dart';
import '../../features/calendar/presentation/widgets/event_detail_sheet.dart';
import '../../features/home/presentation/widgets/home_event_timeline_row.dart';
import '../navigation/app_bottom_navigation.dart';
import 'premium_pressable.dart';

/// Azul calendario HOY — v0.49.86 paleta clara iOS.
const Color _kCalendarBlueLight = AppColors.brandBlueStrongLight;
const Color _kCalendarBlueDark = AppColors.calendarBlueDark;

/// Línea vertical timeline — v0.49.86.
const Color _kTimelineSpineLight = AppColors.homeTimelineLineLight;
const Color _kTimelineSpineDark = Color(0xFF416A98);

/// Icono microsección TAREAS — v0.49.86.
const Color _kTasksSectionIconLight = AppColors.homeWeatherAccentLight;
const Color _kTasksSectionIconDark = AppColors.tasksOrangeDark;

/// Icono sección NOTAS en Home — v0.49.86.
const Color _kNotesSectionIconLight = AppColors.noteSectionLabelLight;
const Color _kNotesSectionIconDark = AppColors.suggestionGreenDark;

/// Bloque **HOY** — v0.49.73 sustituye MAIL por NOTAS en Home.
class TodaySummaryCard extends StatefulWidget {
  const TodaySummaryCard({
    super.key,
    required this.events,
    required this.tasks,
    required this.notes,
    this.maxAgendaItems = 2,
    this.maxTaskItems = 3,
    this.maxNoteItems = 2,
    this.onOpenCalendar,
    this.onOpenTasks,
    this.onOpenNotes,
  });

  final List<EventModel> events;
  final List<TaskModel> tasks;
  final List<NoteModel> notes;
  final int maxAgendaItems;
  final int maxTaskItems;
  final int maxNoteItems;
  final VoidCallback? onOpenCalendar;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenNotes;

  @override
  State<TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends State<TodaySummaryCard> {
  String? _expandedTaskId;
  String? _expandedHomeEventId;

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
    final visibleIds = widget.events
        .take(widget.maxAgendaItems.clamp(0, widget.events.length))
        .map((e) => e.id)
        .toSet();
    if (_expandedHomeEventId != null && !visibleIds.contains(_expandedHomeEventId)) {
      _expandedHomeEventId = null;
    }
  }

  void _toggleHomeEventExpand(String id) {
    setState(() {
      _expandedHomeEventId = _expandedHomeEventId == id ? null : id;
    });
  }

  Future<void> _openHomeEventEditor(EventModel event) async {
    await EventDetailSheet.show(context, event);
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

  static const double _pad = AppSpacing.homeCardPadding;

  static const double _eventTimeColWidth = 52;
  static const double _eventTimelineColWidth = 18;
  /// Gap único entre columna del punto y el bloque de texto (título + descripción).
  static const double _eventTimelineTextGap = 12;
  /// Alineación vertical legacy (pull-up enlace «+ X más»).
  static const double _eventMoreLinkPullUp = 6;
  static const double _eventDotSize = 7.5;
  /// Desplaza el punto para alinearlo con la primera línea del título (no al centro de la fila).
  static const double _eventDotAlignPaddingTop = 6;
  /// Espacio entre filas de evento (compacto).
  static const double _eventRowGap = 4;
  /// Altura fija fila evento (hora + punto + texto; hover solo en texto).
  static const double _eventRowHeight = 52;
  static const double _eventTimelineLineTrim = 4;
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
      ? _kTimelineSpineDark.withValues(alpha: 0.34)
      : _kTimelineSpineLight.withValues(alpha: 0.42);

  /// Grosor spine vertical — muy fino, no compite con los puntos.
  static const double _eventTimelineLineWidth = 1.0;

  static TextStyle _hoyLabelStyle(ColorScheme scheme, bool isDark) =>
      HomeCardTheme.sectionTitleStyle(scheme, isDark ? Brightness.dark : Brightness.light);

  static const double _labelToContentGap =
      AppSpacing.homeCardHeaderToContentGap;
  /// Cabeceras de sección alineadas con hora / mail / círculos de tarea (v0.48.42).
  static const EdgeInsets _sectionHeaderPadding = EdgeInsets.symmetric(
    vertical: AppSpacing.homeCardHeaderInkPaddingV,
  );
  /// Inicio del texto «TAREAS» / títulos de fila (icono cabecera + gap).
  static const double _sectionTitleTextInset =
      AppSpacing.homeCardHeaderIconSize + AppSpacing.homeCardHeaderIconTitleGap;
  /// Separación entre filas de tarea (2–4 px).
  static const double _taskRowGap = 3;

  static const String _emptyCalendarLine = 'Sin eventos próximos hoy';
  static const String _emptyTasksLine = 'Sin tareas pendientes';

  static Widget _thinGroupDivider(ColorScheme scheme, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        height: 1,
        thickness: 1,
        color: HomeCardTheme.sectionDivider(scheme, brightness),
      ),
    );
  }

  /// Separación última línea de sección → «+ X más» (referencia TAREAS).
  static const double _lastLineToMoreLinkPad = 5;
  static const double _moreLinkTopPad = 2;
  static const EdgeInsets _moreLinkPadding = EdgeInsets.only(
    top: _moreLinkTopPad,
    bottom: 1,
  );

  /// Compensa hueco residual tarjeta compacta ↔ enlace «+ X más».
  static const double _homeEventMoreLinkPullUp = _eventMoreLinkPullUp;

  Widget _buildMoreLink({
    required String label,
    required VoidCallback? onTap,
    required ColorScheme scheme,
    required bool isDark,
    double contentLeftInset = 0,
  }) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final style = TextStyle(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: HomeCardTheme.moreLinkText(scheme, brightness),
    );

    return Padding(
      padding: EdgeInsets.only(left: contentLeftInset),
      child: PremiumPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: _moreLinkPadding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(label, style: style),
          ),
        ),
      ),
    );
  }

  String _moreEventsLabel(int count) =>
      count == 1 ? '+ 1 evento más' : '+ $count eventos más';

  String _moreTasksLabel(int count) =>
      count == 1 ? '+ 1 tarea más' : '+ $count tareas más';

  String _moreNotesLabel(int count) =>
      count == 1 ? '+ 1 nota más' : '+ $count notas más';

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

  /// Cabecera TAREAS — icono naranja + chevron si hay destino (v0.48.42).
  static Widget _buildTasksHeaderRow({
    required ColorScheme scheme,
    required bool isDark,
    required Color iconColor,
    required Color chevronColor,
    bool showChevron = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          kAppNavTasksTabIcon,
          size: AppSpacing.homeCardHeaderIconSize,
          color: iconColor,
        ),
        const SizedBox(width: AppSpacing.homeCardHeaderIconTitleGap),
        Text('TAREAS', style: _hoyLabelStyle(scheme, isDark)),
        if (showChevron) ...[
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
      ],
    );
  }

  static Widget _buildNotesHeaderRow({
    required ColorScheme scheme,
    required bool isDark,
    required Color notesIconColor,
    required Color chevronColor,
    bool showChevron = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          kAppNavNotesTabIcon,
          size: AppSpacing.homeCardHeaderIconSize,
          color: notesIconColor,
        ),
        const SizedBox(width: AppSpacing.homeCardHeaderIconTitleGap),
        Text('NOTAS', style: _hoyLabelStyle(scheme, isDark)),
        if (showChevron) ...[
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
      ],
    );
  }

  Widget _buildNoteEntry(
    NoteModel note,
    ColorScheme scheme,
    bool isDark,
  ) {
    return Text(
      '• ${note.title}',
      style: TextStyle(
        fontSize: 13.5,
        height: 1.28,
        fontWeight: FontWeight.w400,
        color: homeCardSecondaryText(scheme, isDark),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNotesBody(ColorScheme scheme, bool isDark) {
    final total = widget.notes.length;
    if (total == 0) {
      return Text(
        'Sin notas recientes.',
        style: TextStyle(
          fontSize: 13.5,
          height: 1.3,
          fontWeight: FontWeight.w400,
          color: homeCardSecondaryText(scheme, isDark),
        ),
      );
    }

    final visibleCount = widget.maxNoteItems.clamp(1, total);
    final visibleNotes = widget.notes.take(visibleCount).toList();
    final moreNotes = total - visibleNotes.length;

    final children = <Widget>[];
    for (var i = 0; i < visibleNotes.length; i++) {
      if (i > 0) {
        children.add(const SizedBox(height: 6));
      }
      children.add(_buildNoteEntry(visibleNotes[i], scheme, isDark));
    }

    if (moreNotes > 0) {
      children.add(const SizedBox(height: _lastLineToMoreLinkPad));
      children.add(
        _buildMoreLink(
          label: _moreNotesLabel(moreNotes),
          onTap: widget.onOpenNotes,
          scheme: scheme,
          isDark: isDark,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final brightness = isDark ? Brightness.dark : Brightness.light;
    final neutralChevron = HomeCardTheme.neutralChevron(scheme, brightness);

    final calendarBlue =
        isDark ? _kCalendarBlueDark : _kCalendarBlueLight;
    final tasksOrange =
        isDark ? _kTasksSectionIconDark : _kTasksSectionIconLight;
    final notesIconColor =
        isDark ? _kNotesSectionIconDark : _kNotesSectionIconLight;

    final maxEvents = widget.maxAgendaItems.clamp(0, widget.events.length);
    final maxTasks = widget.maxTaskItems;
    final visibleEvents = widget.events.take(maxEvents).toList();
    final moreEvents = widget.events.length - visibleEvents.length;

    final allTasks = _homeVisibleTasks();
    final displayedTasks = allTasks.take(maxTasks).toList();
    final moreTasks = allTasks.length - displayedTasks.length;

    final emptyLineStyle = TextStyle(
      fontSize: 13.5,
      height: 1.3,
      fontWeight: FontWeight.w400,
      color: homeCardSecondaryText(scheme, isDark),
    );

    final hoyHeader = widget.onOpenCalendar != null
        ? PremiumPressable(
            onTap: widget.onOpenCalendar,
            borderRadius: BorderRadius.circular(
              AppSpacing.homeCardHeaderInkBorderRadius,
            ),
            pressTint: PremiumPressTints.accent(isDark),
            child: Padding(
              padding: _sectionHeaderPadding,
              child: _buildHoyHeaderRow(
                scheme: scheme,
                isDark: isDark,
                calendarIconColor: calendarBlue,
                chevronColor: neutralChevron,
              ),
            ),
          )
        : Padding(
            padding: _sectionHeaderPadding,
            child: _buildHoyHeaderRow(
              scheme: scheme,
              isDark: isDark,
              calendarIconColor:
                  scheme.onSurfaceVariant.withValues(alpha: 0.45),
              chevronColor: scheme.onSurfaceVariant.withValues(alpha: 0.45),
            ),
          );

    final tasksHeader = widget.onOpenTasks != null
        ? PremiumPressable(
            onTap: widget.onOpenTasks,
            borderRadius: BorderRadius.circular(
              AppSpacing.homeCardHeaderInkBorderRadius,
            ),
            pressTint: PremiumPressTints.accent(isDark),
            child: Padding(
              padding: _sectionHeaderPadding,
              child: _buildTasksHeaderRow(
                scheme: scheme,
                isDark: isDark,
                iconColor: tasksOrange,
                chevronColor: neutralChevron,
              ),
            ),
          )
        : Padding(
            padding: _sectionHeaderPadding,
            child: _buildTasksHeaderRow(
              scheme: scheme,
              isDark: isDark,
              iconColor: tasksOrange,
              chevronColor: neutralChevron,
              showChevron: false,
            ),
          );

    final notesHeader = widget.onOpenNotes != null
        ? PremiumPressable(
            onTap: widget.onOpenNotes,
            borderRadius: BorderRadius.circular(
              AppSpacing.homeCardHeaderInkBorderRadius,
            ),
            pressTint: PremiumPressTints.accent(
              isDark,
              lightHue: notesIconColor,
            ),
            child: Padding(
              padding: _sectionHeaderPadding,
              child: _buildNotesHeaderRow(
                scheme: scheme,
                isDark: isDark,
                notesIconColor: notesIconColor,
                chevronColor: neutralChevron,
              ),
            ),
          )
        : Padding(
            padding: _sectionHeaderPadding,
            child: _buildNotesHeaderRow(
              scheme: scheme,
              isDark: isDark,
              notesIconColor: notesIconColor,
              chevronColor: neutralChevron,
              showChevron: false,
            ),
          );

    final taskBlockChildren = <Widget>[
      tasksHeader,
      const SizedBox(
        height: AppSpacing.homeTasksSectionHeaderToFirstTaskGap,
      ),
    ];
    if (displayedTasks.isEmpty) {
      taskBlockChildren.add(
        Padding(
          padding: const EdgeInsets.only(left: _sectionTitleTextInset),
          child: Text(_emptyTasksLine, style: emptyLineStyle),
        ),
      );
    } else {
      for (var i = 0; i < displayedTasks.length; i++) {
        final t = displayedTasks[i];
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
        if (i < displayedTasks.length - 1) {
          taskBlockChildren.add(const SizedBox(height: _taskRowGap));
        }
      }
    }
    if (moreTasks > 0) {
      taskBlockChildren.add(
        _buildMoreLink(
          label: _moreTasksLabel(moreTasks),
          onTap: widget.onOpenTasks,
          scheme: scheme,
          isDark: isDark,
        ),
      );
    }

    final sections = <Widget>[
      hoyHeader,
      const SizedBox(height: _labelToContentGap),
      if (visibleEvents.isNotEmpty)
        _EventCalendarStackedTable(
          events: visibleEvents,
          scheme: scheme,
          isDark: isDark,
          expandedEventId: _expandedHomeEventId,
          onToggleEvent: _toggleHomeEventExpand,
          onEditEvent: _openHomeEventEditor,
        )
      else
        Text(_emptyCalendarLine, style: emptyLineStyle),
      if (moreEvents > 0)
        Transform.translate(
          offset: const Offset(
            0,
            -_homeEventMoreLinkPullUp,
          ),
          child: _buildMoreLink(
            label: _moreEventsLabel(moreEvents),
            onTap: widget.onOpenCalendar,
            scheme: scheme,
            isDark: isDark,
          ),
        ),
      _thinGroupDivider(scheme, isDark),
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
      _thinGroupDivider(scheme, isDark),
      notesHeader,
      const SizedBox(height: _labelToContentGap),
      _buildNotesBody(scheme, isDark),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.homePageMarginH),
      child: DecoratedBox(
        decoration: HomeCardTheme.cardDecoration(
          scheme: scheme,
          brightness: brightness,
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

/// Calendario HOY: línea vertical cuando todas las filas están compactas.
class _EventCalendarStackedTable extends StatelessWidget {
  const _EventCalendarStackedTable({
    required this.events,
    required this.scheme,
    required this.isDark,
    required this.expandedEventId,
    required this.onToggleEvent,
    required this.onEditEvent,
  });

  final List<EventModel> events;
  final ColorScheme scheme;
  final bool isDark;
  final String? expandedEventId;
  final ValueChanged<String> onToggleEvent;
  final ValueChanged<EventModel> onEditEvent;

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
    final allCompact = expandedEventId == null;

    final axisLeft = tw + (cw - lineW) / 2;
    final showSpine = allCompact && n >= 2;
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
              HomeEventTimelineRow(
                key: ValueKey('home-event-${events[i].id}'),
                event: events[i],
                timeLabel: events[i].timeText.trim().isNotEmpty
                    ? events[i].timeText.trim()
                    : events[i].timeHm,
                isExpanded: expandedEventId == events[i].id,
                onToggle: () => onToggleEvent(events[i].id),
                onEdit: () => onEditEvent(events[i]),
                timeColumnWidth: tw,
                timelineColumnWidth: cw,
                timelineTextGap: gw,
                dotSize: dotSize,
                dotPaddingTop: dotPadTop,
                dotColor: dotColor,
                timeTextColor: scheme.onSurfaceVariant,
                minRowHeight: allCompact ? rowH : null,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// _calendarEventRow removed — reemplazado por HomeEventTimelineRow + CalendarDayEventCard (v0.49.88).

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

  /// Misma tabulación que el texto «TAREAS» en la cabecera de sección.
  static const double _titleTextInset =
      _TodaySummaryCardState._sectionTitleTextInset;

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
  static const Color _expandBgLight = AppColors.surfaceRaisedLight;
  static const Color _expandBgDark = AppColors.surfaceRaisedDark;
  static const Color _expandBorderLight = AppColors.outlineLight;
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _titleTextInset,
          height: _iconHitHeight,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _iconColWidth,
              height: _iconHitHeight,
              child: PremiumPressable(
                onTap: () => onCompleteTap(),
                borderRadius: BorderRadius.circular(_iconHitHeight / 2),
                pressTint: PremiumPressTints.neutral(isDark),
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
        ),
        Expanded(
          child: PremiumPressable(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(_textBlockInkBorderRadius),
            pressTint: PremiumPressTints.neutral(isDark),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: _textBlockInkPaddingV,
                bottom: _textBlockInkPaddingV,
                end: _textBlockInkPaddingH,
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
      ],
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