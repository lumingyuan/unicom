import 'package:flutter/material.dart';

const double kTileHeight = 56;
const EdgeInsetsGeometry kPadding = EdgeInsets.symmetric(horizontal: 10);

class MyListTile extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget title;
  final Widget leading;
  final Widget trailing;
  final bool hasForward;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color color;

  MyListTile(this.title,
      {this.leading,
      this.trailing,
      this.onPressed,
      this.hasForward = true,
      this.height = kTileHeight,
      this.padding = kPadding,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: this.onPressed,
        child: Container(
          padding: padding,
          height: height,
          child: Row(
            children: <Widget>[
              leading ?? Container(),
              DefaultTextStyle(
                style: TextStyle(fontSize: 16, color: Colors.black87),
                child: title ?? const SizedBox(),
              ),
              Spacer(),
              DefaultTextStyle(
                style: TextStyle(fontSize: 16, color: Colors.black45),
                child: trailing ?? const SizedBox(),
              ),
              Container(width: 5),
              hasForward
                  ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
