import '../mock/mock_user.dart';
import '../models/user_model.dart';

abstract final class UserService {
  static UserModel getCurrentUser() => MockUser.current;

  static List<ProfileMenuEntryModel> getProfileMenuEntries() =>
      MockUser.profileMenu;

  static String getHomeSummaryLine() => MockUser.homeSummary;

  static String getHomeSuggestionLine() => MockUser.homeSuggestion;

  static String getGreetingForNow() {
    final h = DateTime.now().hour;
    final name = getCurrentUser().displayName;
    if (h < 12) return 'Buenos días, $name';
    if (h < 20) return 'Buenas tardes, $name';
    return 'Buenas noches, $name';
  }
}
