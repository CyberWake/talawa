//flutter package imported
import 'package:flutter/material.dart';

//pages are imported here
import 'package:talawa/utils/uidata.dart';

class MyAboutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: AboutListTile(
        applicationIcon: Image.asset('assets/images/talawaLogo-noBg.png'),
        icon: Image.asset('assets/images/talawaLogo-noBg.png'),
        aboutBoxChildren: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Text(
            "Collaborative",
          ),
        ],
        applicationName: UIData.appName,
        applicationVersion: "1.0.1",
        applicationLegalese: "Apache License 2.0",
      ),
    );
  }
}
