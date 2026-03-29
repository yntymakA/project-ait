// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'AIT Маркетплейс';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabFavorites => 'Избранное';

  @override
  String get tabCreate => 'Создать';

  @override
  String get tabChats => 'Чаты';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get actionSearch => 'Поиск';

  @override
  String get actionNotifications => 'Уведомления';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageDialogTitle => 'Выберите язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get profileTopUpTitle => 'Пополнить баланс';

  @override
  String get profileAmountLabel => 'Сумма (USD)';

  @override
  String get profileAmountHint => 'например, 25';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonClear => 'Очистить';

  @override
  String get profileInvalidAmount => 'Введите корректную сумму';

  @override
  String profileAddedAmount(Object amount) {
    return 'Добавлено $amount';
  }

  @override
  String get profileDefaultName => 'Пользователь';

  @override
  String get profileFeaturedTooltip => 'Продавец Featured - VIP';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get profileBalanceLabel => 'Баланс';

  @override
  String get profileFeaturedBadge => 'Featured бейдж';

  @override
  String get profileFeaturedSubtitle => 'Тарифы - значок верификации в профиле и объявлении';

  @override
  String get profileTopUpBalance => 'Пополнить баланс';

  @override
  String get profilePhoneNumber => 'Номер телефона';

  @override
  String get profilePhoneNotSet => 'Не указан';

  @override
  String get profilePhoneEditTitle => 'Изменить номер телефона';

  @override
  String get profilePhoneHint => '+996 555 123 456';

  @override
  String get profileInvalidPhone => 'Введите корректный номер телефона';

  @override
  String get profileMyListings => 'Мои объявления';

  @override
  String get profileTransactionHistory => 'История транзакций';

  @override
  String get profileTransactionSubtitle => 'Пополнения и покупки бейджа';

  @override
  String get profileLogout => 'Выйти';

  @override
  String get profileNotSignedIn => 'Вы не авторизованы';

  @override
  String get profileSignInRegister => 'Войти / Регистрация';
}
