import '../custom_navigation_drawer.dart';
import 'package:flutter/material.dart';

class CollapsingListTile extends StatefulWidget {
  final String title;
  final Widget image;
  final AnimationController animationController;
  final bool isSelected;
  final Function onTap;

  CollapsingListTile(
      {@required this.title,
      @required this.image,
      @required this.animationController,
      this.isSelected = false,
      this.onTap});

  @override
  _CollapsingListTileState createState() => _CollapsingListTileState();
}

class _CollapsingListTileState extends State<CollapsingListTile> {
  Animation<double> widthAnimation, sizedBoxAnimation;

  @override
  void initState() {
    super.initState();
    widthAnimation =
        Tween<double>(begin: 70, end: 200).animate(widget.animationController);
    sizedBoxAnimation =
        Tween<double>(begin: 0, end: 10).animate(widget.animationController);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          color: widget.isSelected
              ? Theme.of(context).backgroundColor.withOpacity(0.6)
              : Theme.of(context).backgroundColor.withOpacity(0.2),
        ),
        width: widthAnimation.value,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        padding: EdgeInsets.all(5),
        child: Center(
          child: Row(
            children: <Widget>[
              widget.image,
              SizedBox(width: sizedBoxAnimation.value),
              (widthAnimation.value >= 190)
                  ? Text(widget.title,
                      style: widget.isSelected
                          ? listTitleSelectedTextStyle
                          : listTitleDefaultTextStyle)
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
