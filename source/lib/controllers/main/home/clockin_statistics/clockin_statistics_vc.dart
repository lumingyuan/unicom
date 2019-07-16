import 'package:unicom_attendance/global.dart';
import './statistics_calendar_view.dart';
import './statistics_list_view.dart';
import './statistics_list_cell.dart';

class ClockinStatisticsVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ClockinStatisticsVCState();
}

class _ClockinStatisticsVCState extends State<ClockinStatisticsVC>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  PageController _pageController = new PageController();

  DateTime _selectDate;

  StreamSubscription _dateClickEvent;

  @override
  void initState() {
    super.initState();

    _selectDate = ClockManager.instance.now;

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        _pageController.jumpToPage(_tabController.index);
        setState(() {});
      });

    _dateClickEvent = Global.eventBus
        .on<EventStatisticsDateClick>()
        .listen((EventStatisticsDateClick event) {
      if (event.date != null) {
        _selectDate = event.date;
        _tabController.animateTo(1);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_dateClickEvent != null) {
      _dateClickEvent.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context, '考勤统计',
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(46),
            child: TabBar(
              labelColor: Global.kTintColor,
              labelStyle: TextStyle(fontSize: 18),
              unselectedLabelColor: Color(0xff696969),
              unselectedLabelStyle: TextStyle(fontSize: 18),
              indicatorWeight: 1,
              controller: _tabController,
              tabs: <Widget>[
                Tab(text: '汇总'),
                Tab(text: '月历'),
              ],
            ),
          )),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          new StatisticsListView(),
          new StatisticsCalendarView(_selectDate),
        ],
        controller: _pageController,
      ),
    );
  }
}
