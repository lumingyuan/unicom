import 'package:flutter/material.dart';
import './calendar_picker_tile.dart';
import 'package:date_utils/date_utils.dart';

typedef DayBuilder(BuildContext context, DateTime day);
typedef int DayOfState(DateTime day);

class CalendarPicker extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  final DayBuilder dayBuilder;
  final DateTime initialCalendarDateOverride;
  final bool swipeEnable;
  final bool showPoint; // 是否显示日历的小点
  final DayOfState stateFunc;

  CalendarPicker(
      {this.onDateSelected,
      this.dayBuilder,
      this.initialCalendarDateOverride,
      this.swipeEnable: false,
      this.showPoint: true,
      this.stateFunc});

  @override
  _CalendarPickerState createState() => new _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  final calendarUtils = new Utils();
  List<DateTime> selectedMonthsDays;
  DateTime _selectedDate = new DateTime.now();
  String currentMonth;
  DateTime get selectedDate => _selectedDate;

  void initState() {
    super.initState();
    if (widget.initialCalendarDateOverride != null)
      _selectedDate = widget.initialCalendarDateOverride;
    selectedMonthsDays = Utils.daysInMonth(_selectedDate);
  }

  @override
  void didUpdateWidget(CalendarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCalendarDateOverride != null)
      _selectedDate = widget.initialCalendarDateOverride;
    selectedMonthsDays = Utils.daysInMonth(_selectedDate);
  }

  Widget get calendarGridView {
    return new Container(
      child: new GestureDetector(
        onHorizontalDragStart: widget.swipeEnable
            ? (gestureDetails) => beginSwipe(gestureDetails)
            : null,
        onHorizontalDragUpdate: widget.swipeEnable
            ? (gestureDetails) => getDirection(gestureDetails)
            : null,
        onHorizontalDragEnd: (gestureDetails) =>
            widget.swipeEnable ? endSwipe(gestureDetails) : null,
        child: new GridView.count(
          childAspectRatio: 5 / 4,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 7,
          padding: new EdgeInsets.only(bottom: 0.0),
          children: calendarBuilder(),
        ),
      ),
    );
  }

  Widget get calendarTitle {
    List<Widget> dayWidgets = [];

    List<String> titles = ['日', '一', '二', '三', '四', '五', '六'];
    titles.forEach((day) {
      dayWidgets.add(Expanded(
          flex: 1,
          child: new CalendarPickerTile(isDayOfWeek: true, dayOfWeek: day)));
    });
    return Container(
        height: 35,
        child: Row(
          children: dayWidgets,
        ));
  }

  List<Widget> calendarBuilder() {
    List<Widget> dayWidgets = [];
    bool monthStarted = false;
    bool monthEnded = false;

    selectedMonthsDays.forEach((day) {
      if (monthStarted && day.day == 01) {
        monthEnded = true;
      }
      if (Utils.isFirstDayOfMonth(day)) {
        monthStarted = true;
      }
      if (this.widget.dayBuilder != null) {
        dayWidgets.add(new CalendarPickerTile(
          child: this.widget.dayBuilder(context, day),
          date: day,
          onDateSelected: () => handleSelectedDateAndUserCallback(day),
        ));
      } else {
        dayWidgets.add(new CalendarPickerTile(
          onDateSelected: () => handleSelectedDateAndUserCallback(day),
          date: day,
          dateStyles: configureDateStyle(monthStarted, monthEnded),
          isSelected: Utils.isSameDay(selectedDate, day),
          pointType: widget.stateFunc != null ? widget.stateFunc(day) : 0,
          hasPoint: widget.showPoint,
        ));
      }
    });
    return dayWidgets;
  }

  TextStyle configureDateStyle(monthStarted, monthEnded) {
    TextStyle dateStyles;
    dateStyles = monthStarted && !monthEnded
        ? new TextStyle(color: Colors.black)
        : new TextStyle(color: Colors.black38);
    return dateStyles;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          calendarTitle,
          calendarGridView,
        ],
      ),
    );
  }

  void nextMonth() {
    setState(() {
      _selectedDate = Utils.nextMonth(_selectedDate);
      selectedMonthsDays = Utils.daysInMonth(_selectedDate);
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void previousMonth() {
    setState(() {
      _selectedDate = Utils.previousMonth(_selectedDate);
      selectedMonthsDays = Utils.daysInMonth(_selectedDate);
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  var gestureStart;
  var gestureDirection;

  void beginSwipe(DragStartDetails gestureDetails) {
    gestureStart = gestureDetails.globalPosition.dx;
  }

  void getDirection(DragUpdateDetails gestureDetails) {
    if (gestureDetails.globalPosition.dx < gestureStart) {
      gestureDirection = 'rightToLeft';
    } else {
      gestureDirection = 'leftToRight';
    }
  }

  void endSwipe(DragEndDetails gestureDetails) {
    if (gestureDirection == 'rightToLeft') {
      nextMonth();
    } else {
      previousMonth();
    }
  }

  void handleSelectedDateAndUserCallback(DateTime day) {
    setState(() {
      _selectedDate = day;
      selectedMonthsDays = Utils.daysInMonth(day);
    });
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected(day);
    }
  }
}
