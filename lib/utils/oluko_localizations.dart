import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class OlukoLocalizations {
  OlukoLocalizations(this.locale);

  final Locale locale;

  static OlukoLocalizations of(BuildContext context) {
    return Localizations.of<OlukoLocalizations>(context, OlukoLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = new Map();

  Future<bool> load() async {
    String data = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');

    Map<String, dynamic> _result = jsonDecode(data) as Map<String, dynamic>;
    Map<String, String> _values = new Map();

    _result.forEach((String key, dynamic value) {
      _values[key] = value.toString();
    });
    _localizedValues[this.locale.languageCode] = _values;
    return true;
  }

  String find(String key) {
    return _localizedValues[locale.languageCode][key] ?? '';
  }
}

class OlukoLocalizationsDelegate extends LocalizationsDelegate<OlukoLocalizations> {
  const OlukoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<OlukoLocalizations> load(Locale locale) async {
    OlukoLocalizations localizations = new OlukoLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(OlukoLocalizationsDelegate old) => false;
}
