import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talawa/generated/l10n.dart';

class Localization with ChangeNotifier{
  Locale currentLocale;
  String languageCode;
  String countryCode;
  String language;
  Map locale;

  Localization(){
    getLocale();
  }

  Future readPreferences()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode = _prefs.getString("languageCode");
    countryCode = _prefs.getString("countryCode");
    language = _prefs.getString("language");
  }

  getLocale()async{
    readPreferences().whenComplete((){
      if(languageCode==null && countryCode == null){
        currentLocale = Locale('en','US');
        locale = {
          "languageCode": currentLocale.languageCode,
          "countryCode": currentLocale.countryCode,
          "language": "English(US)"
        };
        return currentLocale;
      }else{
        currentLocale = Locale(languageCode,countryCode);
        locale = {
          "languageCode": languageCode,
          "countryCode": countryCode,
          "language": language
        };
        return currentLocale;
      }
    });
  }

  setLocale(Map newLocaleMap)async{
    locale = newLocaleMap;
    Locale newLocale = Locale(
        newLocaleMap['languageCode'],
        newLocaleMap['countryCode']);
    currentLocale = newLocale;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("languageCode", newLocale.languageCode);
    _prefs.setString("countryCode", newLocale.countryCode);
    _prefs.setString("language", newLocaleMap['language']);
    notifyListeners();
  }
}