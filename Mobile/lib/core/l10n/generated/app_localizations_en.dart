// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Marketplace';

  @override
  String get feedTitle => 'Explore';

  @override
  String get searchTab => 'Search';

  @override
  String get favoritesTab => 'Favorites';

  @override
  String get inboxTab => 'Inbox';

  @override
  String get profileTab => 'Profile';

  @override
  String get loginButton => 'Log In';

  @override
  String get registerButton => 'Register';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get emptyState => 'Nothing here yet.';
}
