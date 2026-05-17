/// Evento de agenda (solo cliente; sin acoplar a proveedor de calendario).
class EventModel {
  const EventModel({
    required this.id,
    required this.start,
    this.end,
    required this.title,
    this.detail = '',
    this.syntheticBackendId = false,
    this.hasCivilCalendarDate = true,
    this.dateText = '',
    this.timeText = '',
    this.location = '',
    this.description = '',
    this.participants = const [],
    this.durationMinutes,
    this.confidence,
    this.needsConfirmation,
    this.missingFields = const [],
    this.sourceText,
    this.createdAt,
    this.updatedAt,
  });

  /// `true` cuando el id es generado en cliente (**no** valido para PATCH/DELETE servidor).
  final bool syntheticBackendId;

  final String id;
  final DateTime start;
  final DateTime? end;
  final String title;

  /// Línea resumida (descripción · ubicación · participantes).
  final String detail;

  /// Cuando viene de backend con `date_text` no ISO («lunes», «mañana», …): `false`.
  final bool hasCivilCalendarDate;

  /// Coincidencias con GET `/events` (JSON snake_case → aquí camelCase tolerante).
  final String dateText;
  final String timeText;
  final String location;
  final String description;
  final List<String> participants;
  final int? durationMinutes;
  final double? confidence;
  final bool? needsConfirmation;
  final List<String> missingFields;
  final String? sourceText;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Eventos **`mock_*`** del CalendarService offline no llaman servidor.
  bool get supportsBackendMutation =>
      !syntheticBackendId && !id.startsWith('mock_');

  /// Etiqueta principal de día tal como servidor / usuario (prioridad sobre día civil sintético).
  String get visibleDateLabel =>
      dateText.trim().isEmpty ? '' : dateText.trim();

  /// Para edición rápida: participantes como "Luis, Ana".
  String get participantsCommaSeparated =>
      participants.isEmpty ? '' : participants.join(', ');

  /// Línea compacta para listas tipo Home (hora + título + detalle).
  String get homePreviewLine {
    final h = start.hour.toString().padLeft(2, '0');
    final m = start.minute.toString().padLeft(2, '0');
    final when = '$h:$m';
    final day = dateText.trim();
    if (!hasCivilCalendarDate && day.isNotEmpty) {
      if (detail.isEmpty) return '$day · $when · $title';
      return '$day · $when · $title ($detail)';
    }
    if (detail.isEmpty) return '$when · $title';
    return '$when · $title ($detail)';
  }

  String get timeHm {
    final h = start.hour.toString().padLeft(2, '0');
    final m = start.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'syntheticBackendId': syntheticBackendId,
    'hasCivilCalendarDate': hasCivilCalendarDate,
    'start': start.toIso8601String(),
    if (end != null) 'end': end!.toIso8601String(),
    'title': title,
    'detail': detail,
    'date_text': dateText,
    'time_text': timeText,
    'location': location,
    'description': description,
    'participants': participants,
    if (durationMinutes != null) 'duration_minutes': durationMinutes,
    if (confidence != null) 'confidence': confidence,
    if (needsConfirmation != null) 'needs_confirmation': needsConfirmation,
    'missing_fields': missingFields,
    if (sourceText != null) 'source_text': sourceText,
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
  };

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      syntheticBackendId: json['syntheticBackendId'] as bool? ?? false,
      hasCivilCalendarDate:
          json['hasCivilCalendarDate'] as bool? ??
              json['has_civil_calendar_date'] as bool? ??
              true,
      start: DateTime.parse(json['start'] as String),
      end: json['end'] != null ? DateTime.parse(json['end'] as String) : null,
      title: json['title'] as String,
      detail: json['detail'] as String? ?? '',
      dateText: json['date_text'] as String? ?? '',
      timeText: json['time_text'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      participants: json['participants'] is List
          ? [
              ...(json['participants'] as List)
                  .map((x) => x?.toString().trim())
                  .whereType<String>(),
            ]
          : [],
      durationMinutes: json['duration_minutes'] != null
          ? int.tryParse('${json['duration_minutes']}')
          : null,
      confidence: json['confidence'] != null
          ? double.tryParse('${json['confidence']}')
          : null,
      needsConfirmation: json['needs_confirmation'] as bool?,
      missingFields:
          json['missing_fields'] is List
              ? [
                  ...(json['missing_fields'] as List)
                      .map((x) => x?.toString().trim())
                      .whereType<String>(),
                ]
              : [],
      sourceText: json['source_text'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse('${json['updated_at']}')
          : null,
    );
  }
}
