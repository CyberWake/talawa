//imported flutter packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
//importing the pages here
import 'package:provider/provider.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:talawa/generated/l10n.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/views/pages/events/events.dart';
import 'package:talawa/views/pages/manage/manage.dart';
import 'package:talawa/views/pages/newsfeed/newsfeed.dart';

import 'organization/profile_page.dart';

class HomePage extends StatefulWidget {
  final bool autoLogin;
  final int openPageIndex;
  HomePage({this.openPageIndex = 0,this.autoLogin = false});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  int currentIndex = 0;

  PersistentTabController _controller;
  Preferences preferences = Preferences();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.openPageIndex;
    _controller = PersistentTabController(initialIndex: currentIndex);
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /*Future<void> getUserInfo() async {
    final String userID = await preferences
        .getUserId(); //getting the current user id from the server
    String mutation = Queries().fetchUserInfo2(
        userID); //getting some more user information with the ID
    ApiFunctions apiFunctions = ApiFunctions();
    final result = await apiFunctions.gqlmutation(mutation);
  }*/

  List<Widget> _buildScreens() {
    //here we are building the screens that are mention in the app bar
    return [
      Manage(autoLogin: widget.autoLogin),
      NewsFeed(), //first page of the news feed
      Events(), //Third page of creating the events and viewing it
      ShowCaseWidget(autoPlay:true,autoPlayDelay:Duration(seconds: 1),builder: Builder(builder: (BuildContext context)=>ProfilePage(autoLogin: widget.autoLogin),)), //last page of the profile
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        //mentioning the screen home in the bottom bar
        icon: Icon(Icons.people),
        title: (S.of(context).manage),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        //mentioning the screen home in the bottom bar
        icon: Icon(Icons.home),
        title: (S.of(context).home),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        //mentioning the Events home in the bottom bar
        icon: Icon(Icons.calendar_today),
        title: (S.of(context).events),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        //mentioning the screen Profile in the bottom bar
        icon: Icon(Icons.account_circle_outlined),
        title: (S.of(context).profile),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white,
      ),
    ];
  }

  void onTabTapped(int index) {
    //this function tells us what should be done if the particular tab is clicked
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 1500),
        builder: (context, value, child) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return RadialGradient(
                      radius: value * 5,
                      colors: [
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                        Colors.transparent
                      ],
                      stops: [0.0, 0.55, 0.6, 1.0],
                      center: FractionalOffset(0.5, 0.5))
                  .createShader(bounds);
            },
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<GraphQLConfiguration>(
                  create: (_) => GraphQLConfiguration(),
                ),
                ChangeNotifierProvider<Preferences>(
                  create: (_) => Preferences(),
                )
              ],
              child: Builder(builder: (BuildContext context) {
                BuildContext rootContext = context;
                Provider.of<GraphQLConfiguration>(rootContext, listen: false)
                    .getOrgUrl();
                Provider.of<Preferences>(rootContext, listen: false)
                    .getCurrentOrgId();
                return PersistentTabView(rootContext,
                    backgroundColor: Theme.of(context).primaryColor,
                    controller: _controller,
                    items: _navBarsItems(),
                    screens: _buildScreens(),
                    confineInSafeArea: true,
                    handleAndroidBackButtonPress: true,
                    navBarStyle: NavBarStyle.style1,
                    resizeToAvoidBottomInset: true,
                    itemAnimationProperties: ItemAnimationProperties(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.ease,
                    ),
                    screenTransitionAnimation: ScreenTransitionAnimation(
                      animateTabTransition: true,
                      curve: Curves.ease,
                      duration: Duration(milliseconds: 200),
                    ));
              }),
            ),
          );
        });
  }
}
