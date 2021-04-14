import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:talawa/controllers/localization_controller.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/views/pages/login_signup/ask_url.dart';

class AskLocale extends StatefulWidget {
  final Function updatePage;
  final int currentPageIndex;
  final int previousPageIndex;
  AskLocale({this.updatePage, this.currentPageIndex, this.previousPageIndex});
  @override
  _AskLocaleState createState() => _AskLocaleState();
}

class _AskLocaleState extends State<AskLocale> {
  final ScrollController _controller = ScrollController();
  Map selectedLanguage;

  @override
  void initState() {
    selectedLanguage = Provider.of<Localization>(context, listen: false).locale;
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
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            color: Colors.black.withOpacity(0.1),
            padding: EdgeInsets.all(MediaQuery.of(context).padding.top),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[500],
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: Text(S.of(context).confirmation),
                          content: Text(S.of(context).contentExit),
                          actions: [
                            ElevatedButton(
                              child: Text(S.of(context).no),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ElevatedButton(
                              child: Text(S.of(context).yes),
                              onPressed: () async {
                                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                                exit(0);
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      });
                      //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    },
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
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        separatorBuilder: (BuildContext context, int index) {
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
                            widget.updatePage(newPageIndex: 1);
                          },
                          child: Text(
                            S.of(context).next,
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              primary: Theme.of(context).primaryColor,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              )),
                        )))
              ],
            ),
          ),
        ),
      ],
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
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).textTheme.button.color)),
            child: FittedBox(
                child: Flag(
              '${tileData['countryCode'] != '' ? tileData['countryCode'].toLowerCase() : tileData['languageCode']}',
              fit: BoxFit.fill,
            ))),
      ),
      title: Text('${tileData['language']}'),
      trailing: SizedBox(
        width: 10,
      ),
    );
  }
}
