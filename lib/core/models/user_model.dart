/// Usuario actual simulado (sin autenticación real).
class UserModel {
  const UserModel({
    required this.id,
    required this.displayName,
    required this.emailSimulated,
    this.avatarInitial,
  });

  final String id;
  final String displayName;
  final String emailSimulated;
  final String? avatarInitial;

  String get primaryInitial {
    if (avatarInitial != null && avatarInitial!.isNotEmpty) {
      return avatarInitial!;
    }
    return displayName.isNotEmpty ? displayName.substring(0, 1) : '?';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'emailSimulated': emailSimulated,
    if (avatarInitial != null) 'avatarInitial': avatarInitial,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      emailSimulated: json['emailSimulated'] as String,
      avatarInitial: json['avatarInitial'] as String?,
    );
  }
}

/// Entrada de menú en Perfil (icono como clave serializable).
class ProfileMenuEntryModel {
  const ProfileMenuEntryModel({
    required this.iconKey,
    required this.title,
    required this.subtitle,
  });

  final String iconKey;
  final String title;
  final String subtitle;

  Map<String, dynamic> toJson() => {
    'iconKey': iconKey,
    'title': title,
    'subtitle': subtitle,
  };

  factory ProfileMenuEntryModel.fromJson(Map<String, dynamic> json) {
    return ProfileMenuEntryModel(
      iconKey: json['iconKey'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
    );
  }
}
