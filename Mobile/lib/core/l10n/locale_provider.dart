import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefKey = 'app_locale_code';

class AppLocaleNotifier extends Notifier<Locale?> {
  bool _restored = false;

  @override
  Locale? build() {
    if (!_restored) {
      _restored = true;
      _restore();
    }
    return null;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localePrefKey);
    if (!ref.mounted) return;
    if (code == null || code.isEmpty) {
      state = null;
      return;
    }
    state = Locale(code);
  }

  Future<void> setLocaleCode(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null || code.isEmpty) {
      await prefs.remove(_localePrefKey);
      if (!ref.mounted) return;
      state = null;
      return;
    }
    await prefs.setString(_localePrefKey, code);
    if (!ref.mounted) return;
    state = Locale(code);
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale?>(
  AppLocaleNotifier.new,
);
