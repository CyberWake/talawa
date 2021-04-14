import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class Loading extends StatefulWidget {
  final bool withTimer;
  final Function refresh;
  Loading({Key key,this.refresh,this.withTimer=true}) : super(key: key);
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool loading = true;
  Timer _timer;
  void loadingFunc() {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    _timer = Timer(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.withTimer) {
      loadingFunc();
    }else{
      setState(() {
        loading=false;
      });
    }
    print(1);
  }

  @override
  void didUpdateWidget(Loading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.withTimer) {
      loadingFunc();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.withTimer) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularProgressIndicator()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/error.svg',
                width: MediaQuery.of(context).size.width / 1.3,
              ),
              SizedBox(height: 30),
              Text(
                widget.withTimer?'No data or something went wrong':'No data',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 30),
              TextButton.icon(onPressed: widget.refresh, icon: Icon(Icons.autorenew), label: Text('Re-Try'))
            ],
          );
  }
}
