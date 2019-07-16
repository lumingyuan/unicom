import 'package:unicom_attendance/global.dart';

class CompanyInfoVC extends StatefulWidget {
  final int jobId;
  CompanyInfoVC(this.jobId);

  @override
  State<StatefulWidget> createState() {
    return new _CompanyInfoVCState();
  }
}

class _CompanyInfoVCState extends State<CompanyInfoVC> {
  JobInfoModel model;

  @override
  void initState() {
    super.initState();

    requestData();
  }

  Future<void> requestData() async {
    ResponseModel ret = await HttpManager.instance
        .post('loadJobInfo', params: {'jobId': widget.jobId});
    if (ret.isSuccess) {
      model = JobInfoModel.fromJson(ret.data);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget buildItem(String title, String value) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              '$title',
              style: TextStyle(color: Global.kDefTextColor),
            ),
            trailing: Text(
              '$value',
              style: TextStyle(color: Global.kDefTextColor),
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }

  List<Widget> buildContent() {
    List<Widget> widgets = new List();
    if (model != null) {
      widgets.add(new Container(
        color: Colors.white,
        height: 88,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: ImageUtil.imageFromUrl(
                    Global.appDomain + model.companyLogo),
              ),
            ),
            Container(width: 15),
            Text(
              '${model.companyName}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
          ],
        ),
      ));
      widgets.add(Divider(height: 1));

      widgets.add(Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Text(
          '我在该企业的信息',
          style: TextStyle(color: Global.kDefTextColor),
        ),
      ));

      widgets.add(Divider(height: 1));
      widgets.add(buildItem('姓名', model.name == null ? '' : model.name));
      widgets.add(buildItem('电话', model.mobile == null ? '' : model.mobile));
      widgets.add(
          buildItem('部门', model.department == null ? '' : model.department));
      widgets
          .add(buildItem('工号', model.jobNumber == null ? '' : model.jobNumber));
      widgets.add(buildItem(
          '分机号', model.extensionNumber == null ? '' : model.extensionNumber));
      widgets.add(buildItem(
          '办公地点', model.officeRegion == null ? '' : model.officeRegion));

      String timeStr = '';
      if (isNotEmpty(model.entryDate)) {
        timeStr = DateFormat('yyyy年MM月dd日')
            .format(DateFormat('yyyy-MM-dd').parse(model.entryDate));
      }
      widgets.add(buildItem('入职时间', timeStr));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context, '企业信息'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: requestData,
          child: ListView(
            children: buildContent(),
          ),
        ),
      ),
    );
  }
}
