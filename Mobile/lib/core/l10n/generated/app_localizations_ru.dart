// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Маркетплейс';

  @override
  String get feedTitle => 'Главная';

  @override
  String get searchTab => 'Поиск';

  @override
  String get favoritesTab => 'Избранное';

  @override
  String get inboxTab => 'Сообщения';

  @override
  String get profileTab => 'Профиль';

  @override
  String get loginButton => 'Войти';

  @override
  String get registerButton => 'Регистрация';

  @override
  String get emailHint => 'Эл. почта';

  @override
  String get passwordHint => 'Пароль';

  @override
  String get loading => 'Загрузка...';

  @override
  String get errorGeneric => 'Произошла ошибка';

  @override
  String get emptyState => 'Здесь пока пусто.';
}
