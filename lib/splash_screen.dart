import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget navigateAfter;
  SplashScreen({Key key, this.navigateAfter}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 1))
        .then((value) => Navigator.pushReplacement(
            context,
            PageRouteBuilder(
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
            )));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
              image: AssetImage('assets/images/talawaLogo.png'),
              fit: BoxFit.fitWidth)),
    );
  }
}
