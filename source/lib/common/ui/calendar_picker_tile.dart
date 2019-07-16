import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPickerTile extends StatelessWidget {
  final VoidCallback onDateSelected;
  final DateTime date;
  final String dayOfWeek;
  final bool isDayOfWeek;
  final bool isSelected;
  final int pointType; // 0 不显示 1显示蓝点 2显示黄点
  final TextStyle dayOfWeekStyles;
  final TextStyle dateStyles;
  final Widget child;
  final bool hasPoint; //是否包含点标示

  CalendarPickerTile({
    this.onDateSelected,
    this.date,
    this.child,
    this.dateStyles,
    this.dayOfWeek,
    this.dayOfWeekStyles,
    this.isDayOfWeek: false,
    this.isSelected: false,
    this.pointType: 0,
    this.hasPoint: true,
  });

  Widget renderDateOrDayOfWeek(BuildContext context) {
    if (isDayOfWeek) {
      return new InkWell(
        child: new Container(
          alignment: Alignment.center,
          child: new Text(
            dayOfWeek,
            style: dayOfWeekStyles,
          ),
        ),
      );
    } else {
      return new InkWell(
        onTap: onDateSelected,
        child: new Container(
          decoration: isSelected
              ? new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                )
              : new BoxDecoration(),
          alignment: Alignment.center,
          child: new Text(
            DateFormat('d').format(date).toString(),
            style: isSelected ? new TextStyle(color: Colors.white) : dateStyles,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget get pointWidget {
    bool hide = pointType == 0;
    Color color = pointType == 1 ? Colors.blue : Colors.orange;
    return Offstage(
      offstage: hide,
      child: ClipOval(
          child: Container(
        height: 5,
        width: 5,
        color: color,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return new InkWell(
        child: child,
        onTap: onDateSelected,
      );
    }

    if (isDayOfWeek) {
      return new Container(
        decoration: new BoxDecoration(
          color: Colors.white,
        ),
        child: renderDateOrDayOfWeek(context),
      );
    } else {
      return new Container(
        decoration: new BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: renderDateOrDayOfWeek(context),
              ),
            ),
            Offstage(
              offstage: !hasPoint,
              child: Container(
                height: 15,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(bottom: 5),
                child: pointWidget,
              ),
            ),
          ],
        ),
      );
    }
  }
}
