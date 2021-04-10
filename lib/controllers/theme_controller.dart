import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTheme with ChangeNotifier{
  bool isDark = ThemeMode.system == ThemeMode.dark;

  MyTheme(){
    currentTheme();
  }

  Future<ThemeMode> currentTheme()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool myTheme = _prefs.getBool("myTheme");
    if(myTheme!=null){
      isDark = myTheme;
    }else if(isDark == null){
      isDark = ThemeMode.system == ThemeMode.dark;
    }
    return isDark?ThemeMode.dark:ThemeMode.light;
  }

  void switchTheme()async{
    isDark = !isDark;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setBool("myTheme",isDark);
    notifyListeners();
  }
}