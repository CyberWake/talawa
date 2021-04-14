import 'package:clippy_flutter/arc.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talawa/controllers/localization_controller.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/utils/uidata.dart';

class AskLocale extends StatefulWidget {
  @override
  _AskLocaleState createState() => _AskLocaleState();
}

class _AskLocaleState extends State<AskLocale> {
  final ScrollController _controller = ScrollController();
  Map selectedLanguage;

  @override
  void initState() {
    selectedLanguage = Provider.of<Localization>(context,listen: false).locale;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List languages = [
      {
        'language': S.of(context).enUS,
        'languageCode': 'en',
        'countryCode': 'US',
      },
      {
        'language': S.of(context).chinese,
        'languageCode': 'zh',
        'countryCode': 'CN',
      },
      {
        'language': S.of(context).spanish,
        'languageCode': 'es',
        'countryCode': '',
      },
      {
        'language': S.of(context).enUS,
        'languageCode': 'en',
        'countryCode': 'US',
      },
      {
        'language': S.of(context).chinese,
        'languageCode': 'zh',
        'countryCode': 'CN',
      },
      {
        'language': S.of(context).spanish,
        'languageCode': 'es',
        'countryCode': '',
      },
    ];
    return Card(
      color: Colors.black,
      child: Stack(children: [
        Container(
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top * 1.0,
              left: 10,
              right: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        ),
        Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top * 1.4),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).backgroundColor.withOpacity(0.9),
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex:4,
                child: Container(
                  width:double.infinity,
                  color: Colors.black.withOpacity(0.05),
                  padding: EdgeInsets.all(MediaQuery.of(context).padding.top),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black.withOpacity(0.1),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).padding.top,
                            MediaQuery.of(context).padding.top,
                            MediaQuery.of(context).padding.top,
                            MediaQuery.of(context).padding.top * 2),
                        child: Text(
                          S.of(context).titleChooseLanguage,
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).padding.top),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        child: Text(S.of(context).titleSelectedLanguage,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      languageTile(selectedLanguage),
                      Divider(
                        thickness: 0.9,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Scrollbar(
                            isAlwaysShown: true,
                            controller: _controller,
                            child: ListView.separated(
                              controller: _controller,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              itemCount: languages.length,
                              itemBuilder: (BuildContext context, int index) {
                                return languageTile(languages[index]);
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  height: 5,
                                );
                              },
                              //children: List.generate(languages.length, (index){return languageTile(languages[index]);})
                            ),
                          ),
                        ),
                      ),
                      Center(
                          child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).padding.top * 1.75,
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<Localization>(context, listen: false).setLocale(selectedLanguage);
                            Navigator.pushNamed(context, UIData.loginPageRoute);
                          },
                          child: Text(S.of(context).next),
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor),
                        ),
                      ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget languageTile(Map tileData) {
    return ListTile(
      onTap: () {
        Provider.of<Localization>(context, listen: false).setLocale(tileData);
        setState(() {
          selectedLanguage = tileData;
        });
      },
      leading: SizedBox(
        child: Container(
            height: 33.2,
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.1))),
            child: FittedBox(
                child: Flag(
                    '${tileData['countryCode'] != '' ? tileData['countryCode'].toLowerCase() : tileData['languageCode']}'))),
      ),
      title: Text('${tileData['language']}'),
      trailing: SizedBox(
        width: 10,
      ),
    );
  }
}
