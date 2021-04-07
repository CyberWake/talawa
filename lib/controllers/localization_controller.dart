import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Localization with ChangeNotifier{
  Locale currentLocale = Locale('en','US');

  Localization(){
    getLocale();
  }

  getLocale()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String languageCode = _prefs.getString("languageCode");
    String countryCode = _prefs.getString("countryCode");
    if(languageCode==null && countryCode == null){
      currentLocale = Locale('en','US');
      return currentLocale;
    }else{
      currentLocale = Locale(languageCode,countryCode);
      return currentLocale;
    }
  }
  setLocale(Locale newLocale)async{
    currentLocale = newLocale;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("languageCode", newLocale.languageCode);
    _prefs.setString("countryCode", newLocale.countryCode);
    notifyListeners();
  }
}