//Flutter Packages are imported here
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//Pages are imported here
import 'package:provider/provider.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:talawa/controllers/theme_controller.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/splash_screen.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/_pages.dart';
import 'package:talawa/views/pages/login_signup/set_url_page.dart';
import 'package:talawa/views/pages/organization/profile_page.dart';

import 'controllers/auth_controller.dart';
import 'controllers/localization_controller.dart';
import 'controllers/org_controller.dart';
import 'views/pages/organization/create_organization.dart';
import 'views/pages/organization/switch_org_page.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Preferences preferences = Preferences();
String userID;
Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //ensuring weather the app is being initialized or not
  userID = await preferences.getUserId().whenComplete(() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]) //setting the orientation according to the screen it is running on
        .then((_) {
      runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider<MyTheme>(create: (_) => MyTheme()),
          ChangeNotifierProvider<Localization>(
            create: (_) => Localization(),
          ),
          ChangeNotifierProvider<GraphQLConfiguration>(
              create: (_) => GraphQLConfiguration()),
          ChangeNotifierProvider<OrgController>(create: (_) => OrgController()),
          ChangeNotifierProvider<AuthController>(
              create: (_) => AuthController()),
          ChangeNotifierProvider<Preferences>(create: (_) => Preferences()),
        ],
        child: MyApp(),
      ));
    });
  }); //getting user id
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeMode themeMode = Provider.of<MyTheme>(context, listen: true).isDark
        ? ThemeMode.dark
        : ThemeMode.light;
    Locale locale =
        Provider.of<Localization>(context, listen: true).currentLocale;
    if(themeMode==null||locale==null){
      return Container();
    }
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: UIData.appName,
        localizationsDelegates: [
          // 1
          S.delegate,
          // 2
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        darkTheme: ThemeData.dark().copyWith(
          accentColor: Color(0xFF31bd6a),
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: Color(0xFF31bd6a),
            cursorColor: Color(0xFF31bd6a),
            selectionHandleColor: Color(0xFF31bd6a),
          ),
        ),
        locale: locale,
        theme: ThemeData.light().copyWith(
          accentColor: Colors.black,
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: Color(0xFF31bd6a),
            cursorColor: Color(0xFF31bd6a),
            selectionHandleColor: Color(0xFF31bd6a),
          ),
          backgroundColor: Colors.white,
          primaryColor: UIData.primaryColor,
        ),
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        onGenerateRoute: (RouteSettings settings) {
          print(
              'build route for ${settings.name}'); //here we are building the routes for the app
          var routes = <String, WidgetBuilder>{
            UIData.homeRoute: (BuildContext context) => HomePage(),
            UIData.loginPageRoute: (BuildContext context) => UrlPage(),
            UIData.createOrgPage: (BuildContext context) =>
                CreateOrganization(),
            UIData.joinOrganizationPage: (BuildContext context) =>
                JoinOrganization(),
            UIData.switchOrgPage: (BuildContext context) =>
                SwitchOrganization(),
            UIData.profilePage: (BuildContext context) => ProfilePage(),
          };
          WidgetBuilder builder = routes[settings.name];
          return MaterialPageRoute(builder: (ctx) => builder(ctx));
        },
        themeMode: themeMode,
        home: SplashScreen(
          navigateAfter: SplashScreen(
            navigateAfter: userID == null
                ? ShowCaseWidget(
                    autoPlayDelay: Duration(seconds: 2),
                    builder: Builder(builder: (context) => UrlPage()),
                    autoPlay: true //userID == null,
                    )
                : HomePage(
                    openPageIndex: 3,
              autoLogin: true,
                  ),
          ),
        ),
      ), //checking weather the user is logged in or not
    );
  }
}
