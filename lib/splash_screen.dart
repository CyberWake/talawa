import 'package:flutter/material.dart';
import 'package:talawa/controllers/auth_controller.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';

class SplashScreen extends StatefulWidget {
  final Widget navigateAfter;
  SplashScreen({Key key, this.navigateAfter}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{
  AnimationController _controller;
  AuthController _authController = AuthController();
  Future getNewToken()async{
    _authController.getNewToken();
    GraphQLConfiguration().getToken();
  }
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 750,
      ),
      lowerBound: 0.00001,
      upperBound: 1.0,
    )..forward()..repeat(reverse: true);
    getNewToken().whenComplete((){
      Future.delayed(Duration(milliseconds: 1500)).whenComplete((){
        _controller.dispose();
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) =>
              widget.navigateAfter,
              transitionDuration: Duration(seconds: 2),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: 0.0,
                  child: child,
                );
              },
            ));
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child){
          return Transform.scale(
              scale: _controller.value,
              child: child,);
          },
        child: Container(
            decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: AssetImage('assets/images/talawaLogo-noBg.png'),
                )),
          ),
        ),
    );
  }
}
