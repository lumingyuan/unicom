import 'package:unicom_attendance/global.dart';

import 'select_date_to_patch_clockin_vc.dart';
import '../choose_user/approval_users_view.dart';

class PatchClockinVC extends StatefulWidget {
  final String clockTime;
  final String attendanceGroupName;
  PatchClockinVC({this.attendanceGroupName, this.clockTime});

  @override
  State<StatefulWidget> createState() => new _PatchClockinVCState();
}

class _PatchClockinVCState extends State<PatchClockinVC> {
  String _patchDate;
  String _groupName;
  ApprovalConfigModel _config;
  TextEditingController _reasonController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    _patchDate = widget.clockTime;
    _groupName = widget.attendanceGroupName;

    requestConfig();
  }

  bool get submitEnable {
    return isNotEmpty(_patchDate) && isNotEmpty(_reasonController.text);
  }

  requestConfig() async {
    ResponseModel ret =
        await HttpManager.instance.post('loadApprovalData', params: {
      "approvalId":
          "${UserManager.instance.currentCompanyModel.clockApprovalId}",
      "approvalType": "1"
    });
    if (ret.isSuccess) {
      _config = ApprovalConfigModel.fromJson(ret.data);
      if (mounted) {
        setState(() {});
      }
    } else {
      ToastUtil.shortToast(context, ret.message);
      Future.delayed(Duration(seconds: 1)).then((_) {
        Navigator.pop(context);
      });
    }
  }

  //选择开始时间
  onPatchDatePress() async {
    dynamic ret =
        await NavigatorUtil.pushVC(context, new SelectDateToPatchClockinVC());
    if (ret != null) {
      _patchDate = ret['date'];
      _groupName = ret['groupName'];
      setState(() {});
    }
  }

  //提交按钮点击
  onSubmitPress() async {
    //判断时间是否正确
    if (_patchDate != null && isNotEmpty(_reasonController.text)) {
      Map<String, dynamic> patchMap = {
        'attendanceGroupName': _groupName,
        'clockTime': _patchDate,
        'reason': _reasonController.text
      };

      Map<String, dynamic> approvalMap = {
        'jobId': UserManager.instance.currentJobId,
        'approvalId':
            UserManager.instance.currentCompanyModel.clockApprovalId ?? 0,
        'approvalType': 1,
        'approvalData': json.encode(patchMap),
      };
      ResponseModel ret = await HttpManager.instance
          .post('submitApprovalData', params: approvalMap);
      if (ret.isSuccess) {
        ToastUtil.shortToast(context, '提交补卡申请成功，请等待审核');
        if (mounted) {
          Navigator.maybePop(context);
        }
      } else {
        ToastUtil.shortToast(context, ret.message);
      }
    } else {
      ToastUtil.shortToast(context, '结束时间不能早于开始时间');
    }
  }

  Widget buildListItem(String title, String content,
      {bool flag = false, VoidCallback onPress, bool hasForward = false}) {
    return MyListTile(
      Row(
        children: <Widget>[
          Container(
            width: 24,
            child: Offstage(
              offstage: !flag,
              child: Center(
                child: Text(
                  '＊',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
          Text('$title')
        ],
      ),
      trailing: isEmpty(content) ? null : Text('$content'),
      onPressed: onPress,
      hasForward: hasForward,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: newAppBar(context, '补卡申请'),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Material(
            color: Global.kBackgroundColor,
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(height: 10),
                  buildListItem(
                      '补卡时间点', '${isEmpty(_patchDate) ? '请选择' : _patchDate}',
                      flag: true, onPress: onPatchDatePress, hasForward: true),
                  Container(height: 10),
                  buildListItem('补卡原因', '', flag: true),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: TextField(
                      controller: _reasonController,
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                        hintText: '请输入...',
                      ),
                      maxLines: 4,
                      maxLength: 1000,
                    ),
                  ),
                  Container(height: 10),
                  buildListItem('审批人', '', flag: true),
                  ApprovalUsersView(_config?.approvers),
                  Container(
                    width: kScreenWidth,
                    margin: EdgeInsets.only(
                        left: 25, right: 25, top: 50, bottom: 30),
                    child: newCommonButton(
                        '提交申请', submitEnable ? onSubmitPress : null),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
