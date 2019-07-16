import 'package:unicom_attendance/global.dart';

class EventStatisticsDateClick {
  DateTime date;
  EventStatisticsDateClick(this.date);
}

class StatisticsListCell extends StatefulWidget {
  final String title;
  final String text;
  final List<dynamic> expandData;
  final Color textColor;
  final bool isFirstCell;
  final bool isLastCell;
  StatisticsListCell(this.title, this.text, this.expandData,
      {this.textColor = const Color(0xff696969),
      this.isFirstCell = false,
      this.isLastCell = false});

  @override
  State<StatefulWidget> createState() {
    return new _StatisticsListCellState();
  }
}

class _StatisticsListCellState extends State<StatisticsListCell> {
  bool isExpaned;

  @override
  void initState() {
    super.initState();

    isExpaned = false;
  }

  Widget buildTitle() {
    return InkWell(
      onTap: () {
        isExpaned = !isExpaned;
        setState(() {});
      },
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: <Widget>[
            Text('${widget.title}', style: TextStyle(fontSize: 17)),
            Spacer(),
            Text(
              '${widget.text}',
              style: TextStyle(color: widget.textColor, fontSize: 16),
            ),
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.expand_more, color: widget.textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent() {
    return Offstage(
      offstage: !isExpaned,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.expandData?.length ?? 0,
        itemBuilder: (_, int index) {
          String item = widget.expandData.elementAt(index).toString();
          return Container(
            color: Global.kBackgroundColor,
            padding: EdgeInsets.only(left: 15),
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    // 点击日期跳转到月历
                    try {
                      DateTime date = new DateFormat('yyyy-MM-dd').parse(item);
                      EventStatisticsDateClick event =
                          new EventStatisticsDateClick(date);
                      Global.eventBus.fire(event);
                    } catch (e) {
                      lLog('$e');
                    }
                  },
                  child: Container(
                    width: kScreenWidth,
                    alignment: Alignment.centerLeft,
                    constraints: BoxConstraints(
                      minHeight: 40,
                    ),
                    child: Text('$item'),
                  ),
                ),
                Offstage(
                  offstage: index == widget.expandData.length - 1,
                  child: Divider(height: 1),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Offstage(
            offstage: widget.isFirstCell,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              child: Divider(height: 1),
            ),
          ),
          buildTitle(),
          buildContent(),
          Offstage(
            offstage: !widget.isLastCell,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              child: Divider(height: 1),
            ),
          ),
        ],
      ),
    );
  }
}
