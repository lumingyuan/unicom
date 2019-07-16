import 'package:unicom_attendance/global.dart';

import 'car_face_approval_vc.dart';

class CarManagerVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _CarManagerVCState();
  }
}

class _CarManagerVCState extends State<CarManagerVC> {
  List<dynamic> _carList = new List();

  initState() {
    super.initState();

    requestCar();
  }

  Future<void> requestCar() async {
    ResponseModel ret = await HttpManager.instance.post('loadCarCodeData',
        params: {'jobId': UserManager.instance.currentJobId});
    if (ret.isSuccess) {
      _carList = ret.data as List;
      if (mounted) {
        setState(() {});
      }
    }
  }

  onAddBtn() async {
    await doUpdateCar(_carList.length, add: true);
  }

  onChangeCarBtn(int codeIndex) async {
    await doUpdateCar(codeIndex, add: false);
  }

  doUpdateCar(int index, {bool add = true}) async {
    String carCode = await showAddCarAlert(add: add);
    if (index == null || index >= 3 || index < 0) {
      return;
    }
    if (isNotEmpty(carCode)) {
      // 上传车牌
      ResponseModel ret =
          await HttpManager.instance.post('updateCarCode', params: {
        'jobId': UserManager.instance.currentJobId,
        'type': add ? 0 : 1,
        'codeIndex': index,
        'carCode': carCode,
      });
      if (!ret.isSuccess) {
        if (ret.code == -1) {
          //  车牌已存在，添加失败
          bool add = await showAlertDialog(
              context, '温馨提示', '该车牌已经存在，继续添加需要上级审批，是否继续添加？',
              cancel: true);
          if (add) {
            ResponseModel addRet = await HttpManager.instance
                .post('updateExistedCarCode', params: {
              'jobId': UserManager.instance.currentJobId,
              'codeIndex': index,
              'carCode': carCode,
            });
            if (addRet.isSuccess) {
              requestCar();
            } else {
              ToastUtil.shortToast(context, addRet.message);
            }
          }
        } else {
          ToastUtil.shortToast(context, ret.message);
        }
      } else {
        ToastUtil.shortToast(context, '提交成功,请等待审批');
        requestCar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context, '车牌管理', actions: [
        FlatButton(
          onPressed: () {
            NavigatorUtil.pushVC(context, new CarFaceApprovalVC());
          },
          child: Text('审核记录', style: TextStyle(color: Global.kTintColor)),
        )
      ]),
      body: RefreshIndicator(
        onRefresh: requestCar,
        child: ListView(
          children: <Widget>[
            buildTip(),
            buildCar(),
            Offstage(
              offstage: _carList.length >= 3,
              child: Container(
                width: kScreenWidth,
                margin:
                    EdgeInsets.only(left: 15, right: 15, top: 50, bottom: 10),
                child: newCommonButton('+ 添加新车牌号', onAddBtn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 提示语
  buildTip() {
    return Column(
      children: <Widget>[
        (UserManager.instance.userModel?.companys?.length ?? 0) > 1
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                color: Colors.red[200],
                child: Text(
                  '车牌信息无法直接同步，请到首页进行切换公司后再进入车牌管理进行同步保存车牌信息。',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              )
            : Container(),
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 10),
          color: Colors.white,
          width: kScreenWidth,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            '''车牌管理说明：
● 请核对输入的车牌号与上传的照片为同一个号码。
● 最多可添加三个车牌，若添加已经存着的则需要管理员审批。
● 点击车牌即可进行添加和编辑操作''',
            style: TextStyle(
              color: Global.kDefTextColor,
              fontSize: 13,
            ),
          ),
        )
      ],
    );
  }

  buildCar() {
    return Container(
      child: Column(
        children: _carList.map((car) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: <Widget>[
                    Text(
                      '车牌号${car['dataIndex'] + 1}',
                      style: TextStyle(
                        color: Global.kDefTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.only(left: 25, right: 15),
                height: 44,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Text(
                      '${car['carCode']}',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        onChangeCarBtn(car['dataIndex'] ?? -1);
                      },
                      child: Text(
                        '点击更换车牌',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  //显示添加车牌对话框
  Future<String> showAddCarAlert({bool add = true}) {
    TextEditingController controller = new TextEditingController();
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(add ? '添加新车牌' : '更改车牌'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.only(top: 24),
            content: Container(
              width: MediaQuery.of(context).size.width - 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    color: Colors.red[200],
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text(
                      '请输入车牌号，例如浙A12345,提交新的车牌号需要管理员进行审批。',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Container(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.only(top: 20),
                    child: CupertinoTextField(
                      placeholder: '请输入车牌号',
                      maxLength: 10,
                      maxLines: 1,
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  '取消',
                  style: TextStyle(color: Color(0xff333333)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                },
              )
            ],
          ),
    );
  }
}
