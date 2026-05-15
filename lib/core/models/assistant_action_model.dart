/// Acción rápida del asistente (icono = clave estable, mappable a [IconData] en UI).
class AssistantActionModel {
  const AssistantActionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'iconKey': iconKey,
  };

  factory AssistantActionModel.fromJson(Map<String, dynamic> json) {
    return AssistantActionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconKey: json['iconKey'] as String,
    );
  }
}
