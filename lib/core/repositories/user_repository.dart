import '../models/user_model.dart';
import '../services/user_service.dart';

/// Contrato de usuario / perfil. Implementación: [LocalUserRepository].
abstract interface class UserRepository {
  UserModel getCurrentUser();

  List<ProfileMenuEntryModel> getProfileMenuEntries();

  String getHomeSummaryLine();

  String getHomeSuggestionLine();

  String getGreetingForNow();
}

final class LocalUserRepository implements UserRepository {
  @override
  UserModel getCurrentUser() => UserService.getCurrentUser();

  @override
  List<ProfileMenuEntryModel> getProfileMenuEntries() =>
      UserService.getProfileMenuEntries();

  @override
  String getHomeSummaryLine() => UserService.getHomeSummaryLine();

  @override
  String getHomeSuggestionLine() => UserService.getHomeSuggestionLine();

  @override
  String getGreetingForNow() => UserService.getGreetingForNow();
}
