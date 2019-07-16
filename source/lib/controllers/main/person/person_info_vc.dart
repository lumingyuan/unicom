import 'package:unicom_attendance/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_location_picker/flutter_location_picker.dart';
import 'dart:io';

import './company_info_vc.dart';
import './person_name_edit_vc.dart';
import './person_mobile_vc.dart';

class PersonInfoVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _PersonInfoVCState();
  }
}

enum ItemType {
  ItemType_None,
  ItemType_Head,
  ItemType_Nickname,
  ItemType_Mobile,
  ItemType_Sex,
  ItemType_Area, //地区
  ItemType_Company, //公司
}

class _PersonInfoVCState extends State<PersonInfoVC> {
  BuildContext _innerContext;
  StreamSubscription<UserChangedEvent> userListener;

  @override
  void initState() {
    super.initState();

    userListener =
        Global.eventBus.on<UserChangedEvent>().listen((UserChangedEvent event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    userListener.cancel();
  }

  void onHeadTap() async {
    int op = await showActionSheetDialog(_innerContext, null, [
      {'title': '拍照', 'value': 1},
      {'title': '相册', 'value': 2}
    ]);
    if (op != null) {
      File image = await ImagePicker.pickImage(
          source: op == 1 ? ImageSource.camera : ImageSource.gallery);
      _onHeadImagePicked(image);
    }
  }

  void onSexTap() async {
    String sex = await showActionSheetDialog(_innerContext, '选择性别', [
      {'title': '男', 'value': '1'},
      {'title': '女', 'value': '0'}
    ]);
    if (sex != null) {
      String ret = await UserManager.instance.requestModifyUserInfo(2, sex);
      ToastUtil.showLoading('设置中...');
      ToastUtil.shortToast(
          context, '${ret ?? "修改成功"}', ret != null ? false : true);
      ToastUtil.hideLoading();
    }
  }

  void onMobileTap() {
    NavigatorUtil.pushVC(context, new PersonMobileVC());
  }

  void onNameTap() async {
    String name = await NavigatorUtil.pushVC(context, PersonNameEditVC());
    if (isNotEmpty(name)) {
      ToastUtil.showLoading('设置中...');
      String ret = await UserManager.instance.requestModifyUserInfo(1, name);
      ToastUtil.hideLoading();
      ToastUtil.shortToast(
          context, '${ret ?? "修改成功"}', ret != null ? false : true);
    }
  }

  ///选择地区
  void onAreaTap() async {
    LocationPicker.showPicker(
      context,
      showTitleActions: true,
      initialProvince: '上海',
      initialCity: '上海',
      initialTown: null,
      onChanged: (p, c, t) {
        print('$p $c $t');
      },
      onConfirm: (p, c, t) async {
        ToastUtil.showLoading('设置中...');
        String ret =
            await UserManager.instance.requestModifyUserInfo(3, "$p $c");
        ToastUtil.hideLoading();
        ToastUtil.shortToast(
            context, '${ret ?? "修改成功"}', ret != null ? false : true);
      },
    );
  }

  void onCompanyTap(JobData job) {
    NavigatorUtil.pushVC(context, new CompanyInfoVC(job.id));
  }

  ///
  ///对图片进行裁剪 >> base64加密 >> 上传服务器 >> 更新用户头像
  ///
  _onHeadImagePicked(File srcImage) async {
    if (srcImage == null) {
      return;
    }
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: srcImage.path,
        ratioX: 1,
        ratioY: 1,
        maxWidth: 512,
        maxHeight: 512);
    if (croppedImage == null) {
      print('用户已取消上传');
      return;
    }

    ToastUtil.showLoading('正在设置头像...');
    //上传服务器
    List<int> data = await croppedImage.readAsBytes();

    String base64 = base64Encode(data);

    String ret = await UserManager.instance.requestModifyUserInfo(0, base64);
    ToastUtil.hideLoading();
    if (isEmpty(ret)) {
      ToastUtil.shortToast(context, '修改成功', true);
    } else {
      ToastUtil.shortToast(context, ret);
    }
  }

  Widget buildSection(String title) {
    return Container(
      height: 40,
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        '$title',
        style: TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }

  Widget buildCell(ItemType type, String title, String content,
      {bool hasMore = true, dynamic data}) {
    Widget trailWidget;
    double height = kTileHeight;
    if (type == ItemType.ItemType_Head) {
      lLog('$content');
      trailWidget = new SizedBox(
        width: 56,
        height: 56,
        child: ClipOval(
          child: ImageUtil.imageFromUrl(content,
              placeholder: ImageUtil.image('def_head.png', fit: BoxFit.fill)),
        ),
      );
      height = 76;
    } else {
      trailWidget = Text('$content');
    }
    return MyListTile(
      Text('$title'),
      trailing: trailWidget,
      hasForward: hasMore,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 15),
      onPressed: () {
        switch (type) {
          case ItemType.ItemType_Head:
            onHeadTap();
            break;
          case ItemType.ItemType_Sex:
            onSexTap();
            break;
          case ItemType.ItemType_Mobile:
            onMobileTap();
            break;
          case ItemType.ItemType_Area:
            onAreaTap();
            break;
          case ItemType.ItemType_Nickname:
            onNameTap();
            break;
          case ItemType.ItemType_Company:
            onCompanyTap(data);
            break;
          default:
            break;
        }
      },
    );
  }

  List<Widget> buildCompanyCells() {
    List<Widget> widgets = new List();
    int count = UserManager.instance.userModel?.jobData?.length ?? 0;
    for (int i = 0; i < count; i++) {
      JobData company = UserManager.instance.userModel.jobData[i];
      if (i == 0) {
        widgets.add(new Divider(height: 1));
      }

      widgets.add(buildCell(
          ItemType.ItemType_Company, '${company.companyName}', "",
          data: company));
      if (i == count - 1) {
        widgets.add(new Divider(height: 1));
      } else {
        widgets.add(new Container(
          margin: EdgeInsets.only(left: 15),
          height: 1,
          color: Global.themeData.dividerColor,
        ));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = UserManager.instance.userModel;
    return Scaffold(
        appBar: newAppBar(context, '我的信息'),
        body: Builder(builder: (BuildContext context) {
          _innerContext = context;
          return Material(
            color: Color(0xf0f0f0),
            child: ListView(
              children: <Widget>[
                buildSection('基本信息'),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Divider(height: 1),
                      buildCell(ItemType.ItemType_Head, '头像',
                          "${Global.appDomain}${user?.logo}"),
                      Container(
                        height: 0.5,
                        color: Global.themeData.dividerColor,
                        margin: EdgeInsets.only(left: 15),
                      ),
                      buildCell(ItemType.ItemType_Nickname, '姓名',
                          '${user?.name ?? "未设置"}'),
                      Container(
                        height: 0.5,
                        color: Global.themeData.dividerColor,
                        margin: EdgeInsets.only(left: 15),
                      ),
                      buildCell(ItemType.ItemType_Mobile, '手机号',
                          '${user?.mobile ?? "未设置"}'),
                      Container(
                        height: 0.5,
                        color: Global.themeData.dividerColor,
                        margin: EdgeInsets.only(left: 15),
                      ),
                      buildCell(ItemType.ItemType_Sex, '性别',
                          '${user?.sex == 0 ? "女" : "男"}'),
                      Container(
                        height: 0.5,
                        color: Global.themeData.dividerColor,
                        margin: EdgeInsets.only(left: 15),
                      ),
                      buildCell(ItemType.ItemType_Area, '地区',
                          '${user?.region ?? "未设置"}'),
                      Divider(height: 1),
                    ],
                  ),
                ),
                buildSection('所在企业'),
                Container(
                  child: Column(children: buildCompanyCells()),
                )
              ],
            ),
          );
        }));
  }
}
