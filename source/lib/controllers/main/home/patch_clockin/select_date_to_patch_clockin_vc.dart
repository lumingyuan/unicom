import 'package:unicom_attendance/global.dart';
import '../clockin_statistics/statistics_calendar_view.dart';

class SelectDateToPatchClockinVC extends StatefulWidget {
  final DateTime initialDate;

  SelectDateToPatchClockinVC({Key key, this.initialDate}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _SelectDateToPatchClockinVCState();
}

class _SelectDateToPatchClockinVCState
    extends State<SelectDateToPatchClockinVC> {
  DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.initialDate ?? DateTime.now();
  }

  //日期选择事件
  onDateTimePicked(DateTime date) {
    print('$date');
    selectedDate = date;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context, '选择日期'),
      body: StatisticsCalendarView(ClockManager.instance.now, true),
    );
  }
}
