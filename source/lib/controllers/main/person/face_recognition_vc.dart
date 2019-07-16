import 'package:unicom_attendance/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import 'car_face_approval_vc.dart';

class FaceRecognitionVC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _FaceRecongntionVCState();
}

class _FaceRecongntionVCState extends State<FaceRecognitionVC> {
  BuildContext _innerContext;
  String _faceUrl = '';

  @override
  void initState() {
    super.initState();

    requestFaceImage();
  }

  ///
  ///对图片进行裁剪 >> base64加密 >> 上传服务器 >> 更新用户头像
  ///
  _onHeadImagePicked(File srcImage, {bool change = false}) async {
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

    lLog(
        'imagesize: ${croppedImage.lengthSync()}, srcSize: ${srcImage.lengthSync()}, bytes:${srcImage.readAsBytesSync().length}');

    Toast.showLoading('正在上传人脸照片');
    //上传服务器
    List<int> data = await croppedImage.readAsBytes();
    String base64 = base64Encode(data);

    ResponseModel ret =
        await HttpManager.instance.post('uploadFaceImage', params: {
      'jobId': UserManager.instance.currentJobId,
      'type': change ? 1 : 0,
      'faceImage': base64
    });
    ToastUtil.hideLoading();
    if (ret.isSuccess) {
      ToastUtil.shortToast(context, change ? '提交成功，请等待审核' : '上传成功', true);
      requestFaceImage();
    } else {
      ToastUtil.shortToast(context, ret.message);
    }
  }

  /// 选择照片
  onChoosePhotoBtn({bool change = false}) async {
    int op = await showActionSheetDialog(_innerContext, null, [
      {'title': '拍照', 'value': 1},
      {'title': '相册', 'value': 2}
    ]);
    if (op != null) {
      File image = await ImagePicker.pickImage(
          source: op == 1 ? ImageSource.camera : ImageSource.gallery);
      _onHeadImagePicked(image, change: change);
    }
  }

  requestFaceImage() async {
    ResponseModel ret = await HttpManager.instance.post('loadFaceImage',
        params: {'jobId': UserManager.instance.currentJobId});
    if (ret.isSuccess) {
      _faceUrl = ret.data['identifyImage'];
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: newAppBar(context, '照片管理', actions: [
        FlatButton(
          onPressed: () {
            NavigatorUtil.pushVC(
                context,
                new CarFaceApprovalVC(
                  face: true,
                ));
          },
          child: Text('审核记录', style: TextStyle(color: Global.kTintColor)),
        )
      ]),
      backgroundColor: Global.kBackgroundColor,
      body: Builder(
        builder: (BuildContext context) {
          _innerContext = context;
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      buildTip(),
                      Offstage(
                        offstage: isEmpty(_faceUrl),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text('已添加照片', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: buildContent(),
                        ),
                      ),
                    ],
                  ),
                ),
                Offstage(
                  offstage: isEmpty(_faceUrl),
                  child: Container(
                    width: kScreenWidth,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: newCommonButton('更换照片', () {
                      onChoosePhotoBtn(change: true);
                    }),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTip() {
    return isEmpty(_faceUrl)
        ? Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Text(
                '人脸照片管理说明：\n ● 用于人脸识别设备打卡使用，若未添加请尽快添加照片。\n ● 添加的照片一定要保持五官端正无遮拦。'),
          )
        : Container(
            child: Column(
              children: <Widget>[
                (UserManager.instance.userModel?.companys?.length ?? 0) > 1
                    ? Container(
                        color: Colors.red[200],
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '照片信息无法直接同步，请到首页进行切换公司后再进入照片管理进行同步保存照片信息。',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          );
  }

  Widget buildContent() {
    return Container(
      child: isNotEmpty(_faceUrl)
          ? Card(child: ImageUtil.imageFromUrl('${Global.appDomain}$_faceUrl'))
          : Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                FlatButton(
                  onPressed: () {
                    onChoosePhotoBtn(change: false);
                  },
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ImageUtil.image('add_picture.png'),
                      Container(height: 10),
                      Text('添加照片',
                          style:
                              TextStyle(fontSize: 16, color: Color(0xff696969)))
                    ],
                  ),
                ),
              ]),
            ),
    );
  }
}
