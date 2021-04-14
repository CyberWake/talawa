import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTheme with ChangeNotifier{
  bool isDark = ThemeMode.system == ThemeMode.dark;
  ThemeMode mode = ThemeMode.system;

  Future<ThemeMode> currentTheme()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool myTheme = _prefs.getBool("myTheme");
    if(myTheme!=null){
      isDark = myTheme;
    }else if(isDark == null){
      isDark = ThemeMode.system == ThemeMode.dark;
    }
    mode = isDark?ThemeMode.dark:ThemeMode.light;
    return mode;
  }

  void switchTheme()async{
    isDark = !isDark;
    mode = isDark?ThemeMode.dark:ThemeMode.light;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setBool("myTheme",isDark);
    notifyListeners();
  }
}