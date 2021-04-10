import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:talawa/controllers/localization_controller.dart';
import 'package:talawa/controllers/theme_controller.dart';
import 'package:talawa/generated/l10n.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> languages = [
      {
        'language': S.of(context).enUS,
        'languageCode': 'en',
        'countryCode': 'US'
      },
      {'language': S.of(context).en, 'languageCode': 'en', 'countryCode': ''},
      {
        'language': S.of(context).chinese,
        'languageCode': 'zh',
        'countryCode': 'CN'
      },
      {
        'language': S.of(context).spanish,
        'languageCode': 'es',
        'countryCode': ''
      },
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).settings,
          style: TextStyle(fontSize: 18.0),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            tileColor: Theme.of(context).backgroundColor,
            title: Text(
              S.of(context).changeLanguage,
              style: TextStyle(fontSize: 18.0),
            ),
            leading: Icon(
              Icons.language,
              color: Theme.of(context).primaryColor,
              semanticLabel: 'Change Language',
            ),
            onTap: () {
              showModal(
                  context: context,
                  configuration: FadeScaleTransitionConfiguration(
                    transitionDuration: Duration(milliseconds: 800),
                    reverseTransitionDuration: Duration(milliseconds: 500),
                  ),
                  builder: (BuildContext context) => AlertDialog(
                        title: Text('Languages'),
                        content: Container(
                          width: 300.0, // Change as per your requirement
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: languages.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                onTap: () {
                                  Locale newLocale = Locale(
                                      languages[index]['languageCode'],
                                      languages[index]['countryCode']);
                                  Provider.of<Localization>(context,
                                          listen: false)
                                      .setLocale(newLocale);
                                  Navigator.pop(context);
                                },
                                title: Text(languages[index]['language']),
                              );
                            },
                          ),
                        ),
                      ));
            },
          ),
          ListTile(
            tileColor: Theme.of(context).backgroundColor,
            leading: Icon(Icons.image_outlined, color: Theme.of(context).primaryColor,semanticLabel: 'Switch Theme',),
            title: Text(
              S.of(context).changeTheme,
              style: TextStyle(fontSize: 18.0),
            ),
            trailing: SizedBox(
              height: 55,
              width: 100,
              child: FlutterSwitch(
                toggleSize: 45.0,
                borderRadius: 30.0,
                padding: 2.0,
                activeToggleColor: Color(0xFF6E40C9),
                inactiveToggleColor: Color(0xFF2F363D),
                activeSwitchBorder: Border.all(
                  color: Color(0xFF3C1E70),
                  width: 2.0,
                ),
                inactiveSwitchBorder: Border.all(
                  color: Color(0xFFD1D5DA),
                  width: 2.0,
                ),
                activeColor: Color(0xFF271052),
                inactiveColor: Colors.white,
                activeIcon: Icon(
                  Icons.nightlight_round,
                  color: Color(0xFFF8E3A1),
                ),
                inactiveIcon: Icon(
                  Icons.wb_sunny,
                  color: Color(0xFFFFDF5D),
                ),
                value: Provider.of<MyTheme>(context,listen: true).isDark
                    ? true
                    : false,
                onToggle: (bool value) {
                  print('working');
                  Provider.of<MyTheme>(context,listen: false).switchTheme();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
