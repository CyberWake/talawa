import 'package:flutter/material.dart';
import 'package:talawa/views/pages/_pages.dart';
import 'package:talawa/views/pages/login_signup/ask_locale.dart';
import 'package:talawa/views/pages/login_signup/ask_url.dart';
import 'package:talawa/views/pages/login_signup/register_page.dart';

class AuthScreenHolder extends StatefulWidget {
  final int pageIndex;
  AuthScreenHolder({this.pageIndex=0});
  @override
  _AuthScreenHolderState createState() => _AuthScreenHolderState();
}

class _AuthScreenHolderState extends State<AuthScreenHolder> with SingleTickerProviderStateMixin{
  AnimationController _controller;
  // animation
  Animation controllerAnimation;
  int currentIndex = 0;
  int previousIndex = 0;
  updatePage({int newPageIndex, int newPrevious}){
    setState(() {
      if(newPrevious == null) {
        previousIndex = currentIndex;
      }else{
        previousIndex = newPrevious;
      }
      currentIndex = newPageIndex;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  void initState() {
    currentIndex = widget.pageIndex;
    previousIndex = widget.pageIndex;
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    controllerAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            child: Card(
              color: Colors.black,
              child: Stack(children: [
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top * 1,
                      left: 10,
                      right: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                ),
                Container(
                  margin:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top * 1.4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.5),
                        offset: Offset(0, -1.5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: FadeTransition(
                    opacity: controllerAnimation,
                    child: WillPopScope(
                      onWillPop: () async{
                        if (currentIndex!=0) {
                          updatePage(newPageIndex :previousIndex,newPrevious: previousIndex==1?0:null);
                          return false;
                        }
                        else{
                          return false;
                        }
                      },
                      child: IndexedStack(
                        index: currentIndex,
                        children: [
                          AskLocale(updatePage: updatePage,currentPageIndex: currentIndex,previousPageIndex: previousIndex),
                          AskUrl(updatePage: updatePage,currentPageIndex: currentIndex,previousPageIndex: previousIndex),
                          RegisterPage(updatePage: updatePage,currentPageIndex: currentIndex,previousPageIndex: previousIndex),
                          LoginPage(updatePage: updatePage,currentPageIndex: currentIndex,previousPageIndex: previousIndex)
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            )
          );
        }
    );
  }
}
