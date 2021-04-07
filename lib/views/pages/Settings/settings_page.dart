import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talawa/controllers/localization_controller.dart';
import 'package:talawa/generated/l10n.dart';

class SettingsPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> languages = [
    {'language': S.of(context).enUS, 'languageCode': 'en', 'countryCode': 'US'},
    {'language': S.of(context).en, 'languageCode': 'en', 'countryCode': ''},
    {'language': S.of(context).chinese, 'languageCode': 'zh', 'countryCode': 'CN'},
    {'language': S.of(context).spanish, 'languageCode': 'es', 'countryCode': ''},
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).settings,
          style: TextStyle(fontSize: 18.0 ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            tileColor:
            Theme.of(context).backgroundColor,
            title: Text(S.of(context).changeLanguage,style: TextStyle(fontSize: 18.0),),
            leading: Icon(Icons.language,color: Theme.of(context).primaryColor,),
            onTap: (){
              showModal(
                                  context: context,
                                  configuration:
                                      FadeScaleTransitionConfiguration(
                                    transitionDuration:
                                        Duration(milliseconds: 800),
                                    reverseTransitionDuration:
                                        Duration(milliseconds: 500),
                                  ),
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: Text('Languages'),
                                        content: Container(
                                          width:
                                              300.0, // Change as per your requirement
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: languages.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ListTile(
                                                onTap: (){
                                                  Locale newLocale = Locale(languages[index]['languageCode'], languages[index]['countryCode']);
                                                  Provider.of<Localization>(context, listen: false)
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
          )
        ],
      ),
    );
  }

}