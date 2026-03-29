// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AIT Marketplace';

  @override
  String get tabHome => 'Home';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get tabCreate => 'Create';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabProfile => 'Profile';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionNotifications => 'Notifications';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageDialogTitle => 'Choose language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get profileTopUpTitle => 'Top up balance';

  @override
  String get profileAmountLabel => 'Amount (USD)';

  @override
  String get profileAmountHint => 'e.g. 25';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAdd => 'Add';

  @override
  String get profileInvalidAmount => 'Enter a valid amount';

  @override
  String profileAddedAmount(Object amount) {
    return 'Added $amount';
  }

  @override
  String get profileDefaultName => 'User';

  @override
  String get profileFeaturedTooltip => 'Featured seller - VIP';

  @override
  String get commonRetry => 'Retry';

  @override
  String get profileBalanceLabel => 'Balance';

  @override
  String get profileFeaturedBadge => 'Featured badge';

  @override
  String get profileFeaturedSubtitle => 'Pricing - verified check on profile and listing';

  @override
  String get profileTopUpBalance => 'Top up balance';

  @override
  String get profileMyListings => 'My listings';

  @override
  String get profileTransactionHistory => 'Transaction history';

  @override
  String get profileTransactionSubtitle => 'Top ups and badge purchases';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileNotSignedIn => 'Not signed in';

  @override
  String get profileSignInRegister => 'Sign in / Register';
}
