import './calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'dart:async';

class DateTimePicker extends StatefulWidget {
  final int unitType; // 0小时 1天（上下午）

  DateTimePicker(this.unitType);

  @override
  State<StatefulWidget> createState() {
    return new _DateTimePickerState();
  }

  static Future<DateTime> show(BuildContext context, int unitType) async {
    DateTime date = await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: DateTimePicker(unitType),
            ),
          );
        });
    return date;
  }
}

class _DateTimePickerState extends State<DateTimePicker>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  DateTime _selectedDate;

  TabController _tabController;

  Picker timePicker;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    _selectedDate = new DateTime(now.year, now.month, now.day);

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        _currentIndex = _tabController.index;
        setState(() {});
      });

    if (widget.unitType == 0) {
      timePicker = new Picker(
          adapter: NumberPickerAdapter(data: [
            NumberPickerColumn(begin: 0, end: 24),
            NumberPickerColumn(begin: 0, end: 60),
          ]),
          hideHeader: true,
          itemExtent: 36,
          height: 200,
          delimiter: [
            PickerDelimiter(
                child: Container(
              width: 30.0,
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(':'),
            ))
          ],
          onSelect: (Picker picker, int index, List<int> data) {
            DateTime newDate = DateTime(_selectedDate.year, _selectedDate.month,
                _selectedDate.day, data[0], data[1]);
            _selectedDate = newDate;
            setState(() {});
          });
    } else {
      timePicker = new Picker(
          adapter: PickerDataAdapter(pickerdata: ["上午", "下午"]),
          hideHeader: true,
          itemExtent: 36,
          height: 200,
          onSelect: (Picker picker, int index, List<int> data) {
            bool isAm = data[0] == 0;
            DateTime newDate = DateTime(_selectedDate.year, _selectedDate.month,
                _selectedDate.day, isAm ? 0 : 12, 0);
            _selectedDate = newDate;
            setState(() {});
          });
    }
  }

  Widget get pickerHead {
    final DateFormat dateFmt = DateFormat('yyyy年M月d日');
    final DateFormat timeFmt = DateFormat('HH:mm');
    String dateStr = dateFmt.format(_selectedDate);
    String timeStr = timeFmt.format(_selectedDate);
    if (widget.unitType == 1) {
      timeStr = _selectedDate.hour < 12 ? '上午' : '下午';
    }

    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Container(
            width: 240,
            child: TabBar(
              labelPadding: EdgeInsets.all(0),
              indicatorSize: TabBarIndicatorSize.tab,
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  text: dateStr,
                ),
                Tab(
                  text: timeStr,
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.only(right: 10),
            width: 68,
            height: 36,
            child: FlatButton(
              color: Colors.blue,
              child: Text('确定', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(_selectedDate);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          pickerHead,
          _currentIndex == 0
              ? CalendarPicker(
                  onDateSelected: (DateTime date) {
                    _selectedDate = date;
                    setState(() {});
                  },
                  initialCalendarDateOverride: _selectedDate,
                  showPoint: false,
                  swipeEnable: true,
                )
              : timePicker.makePicker()
        ],
      ),
    );
  }
}
