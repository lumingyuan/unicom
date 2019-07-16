export './utils/image_util.dart';
export './utils/navigator_util.dart';
export './utils/toast_util.dart';

export './channel/utils_method_channel.dart';

export './ui/badge.dart';
export './ui/my_list_tile.dart';
export './ui/calendar_picker.dart';
export './ui/date_time_picker.dart';
export './ui/loading_dialog.dart';
export './ui/dialog.dart';

export 'package:toast/toast.dart';

import 'package:unicom_attendance/global.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
export 'package:flutter_easyrefresh/easy_refresh.dart'
    show EasyRefresh, EasyRefreshState, RefreshHeaderState, RefreshFooterState;

// 创建一个按钮，用于app中提交，确定等
Widget newCommonButton(String title, VoidCallback onPressed) {
  return new Container(
    height: 48,
    child: RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      onPressed: onPressed,
      color: Global.kTintColor,
      disabledColor: Colors.grey,
      child: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
    ),
  );
}

//创建所有的
PreferredSizeWidget newAppBar(BuildContext context, String title,
    {List<Widget> actions,
    PreferredSizeWidget bottom,
    Color backgroundColor,
    Brightness brightness,
    double elevation}) {
  return AppBar(
    backgroundColor: backgroundColor,
    title: Text('$title'),
    actions: actions,
    bottom: bottom,
    brightness: brightness,
    elevation: elevation ?? 0.5,
    leading: FlatButton(
      padding: EdgeInsets.all(0),
      child: Row(
        children: <Widget>[
          Container(width: 3),
          Icon(Icons.arrow_back_ios, color: Global.kTintColor, size: 20),
          Text(
            '返回',
            style: TextStyle(color: Global.kTintColor, fontSize: 16),
          )
        ],
      ),
      onPressed: () {
        Navigator.maybePop(context);
      },
    ),
  );
}

EasyRefresh newRefresh(BuildContext context,
    {@required Widget child,
    Key refreshKey,
    Key headerKey,
    Key footerKey,
    Widget emptyWidget,
    OnRefresh onRefresh,
    bool firstRefresh = true,
    LoadMore onLoadMore}) {
  if (emptyWidget == null) {
    emptyWidget = Container(
      padding: EdgeInsets.only(top: 120),
      child: Column(
        children: <Widget>[
          ImageUtil.image('no_data.png'),
          Container(height: 15),
          Text(
            '暂时没有数据',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
  return EasyRefresh(
    key: refreshKey,
    behavior: ScrollOverBehavior(),
    firstRefresh: firstRefresh,
    refreshHeader: ClassicsHeader(
      key: headerKey,
      refreshText: '下拉刷新',
      refreshReadyText: '释放刷新',
      refreshingText: '正在刷新...',
      refreshedText: '刷新结束',
      moreInfo: '更新于 %T',
      bgColor: Colors.transparent,
      textColor: Colors.black,
    ),
    refreshFooter: onLoadMore == null
        ? null
        : ClassicsFooter(
            key: footerKey,
            loadHeight: 50.0,
            loadText: '上拉加载',
            loadReadyText: '释放加载',
            loadingText: '正在加载',
            loadedText: '加载结束',
            noMoreText: '没有更多数据',
            moreInfo: '更新于 %T',
            bgColor: Colors.transparent,
            textColor: Colors.black,
          ),
    emptyWidget: emptyWidget,
    child: child,
    onRefresh: onRefresh,
    loadMore: onLoadMore,
  );
}

String formateDate(int unitType, String date) {
  String ret = '';
  if (unitType == 0) {
    ret = date;
  } else {
    DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm').parse(date);
    if (dateTime.hour < 12) {
      ret = DateFormat('yyyy-MM-dd 上午').format(dateTime);
    } else {
      ret = DateFormat('yyyy-MM-dd 下午').format(dateTime);
    }
  }
  return ret;
}
