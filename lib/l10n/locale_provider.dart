import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app_strings.dart';

/// Supported UI languages. English is the default.
enum AppLanguage { en, vi }

/// Holds the currently selected UI language and exposes the matching
/// [AppStrings] bundle. Only the interface language changes here — data coming
/// from OpenAlex (titles, abstracts, journal/author names, DOI) is never
/// translated, to keep academic accuracy.
class LocaleProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.en; // default: English

  AppLanguage get language => _language;

  /// The string bundle for the active language.
  AppStrings get strings => AppStrings(_language);

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }

  void toggle() {
    setLanguage(_language == AppLanguage.en ? AppLanguage.vi : AppLanguage.en);
  }
}

/// Convenience accessor so widgets can read localized strings with `context.s`.
///
/// This registers a dependency on [LocaleProvider], so any widget using it
/// rebuilds automatically when the language changes.
extension AppLocalizationsX on BuildContext {
  AppStrings get s => Provider.of<LocaleProvider>(this).strings;
}
