import 'package:unicom_attendance/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class UserChangedEvent {}

class UserManager {
  final String kUserKey = 'key_user';

  static UserManager _instance = new UserManager();
  static UserManager get instance {
    return _instance;
  }

  UserModel _userModel; //帐户基本资料

  UserManager();

  bool get isLogin => this._userModel != null ? true : false;

  UserModel get userModel => this._userModel;
  set userModel(UserModel model) {
    _userModel = model;
    _saveToLocal();

    //广播用户信息更改
    Global.eventBus.fire(new UserChangedEvent());
  }

  ///当前选中的公司数据
  CompanyDataModel get currentCompanyModel {
    List<CompanyDataModel> companys =
        UserManager.instance.userModel.companys ?? new List();
    for (int i = 0; i < companys.length; ++i) {
      if (companys[i].jobId == Setting.currentJobId) {
        return companys[i];
      }
    }
    if (companys.length > 0) {
      Setting.currentJobId = companys[0].jobId;
      Setting.saveInt(Setting.kCurrentJobId, Setting.currentJobId);
      return companys[0];
    }
    return null;
  }

  // 当前公司id
  int get currentJobId {
    return currentCompanyModel?.jobId ?? 0;
  }

  //初始化，如有数据获取本地数据
  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = prefs.getString(kUserKey) ?? "";
    if (isNotEmpty(userJson)) {
      try {
        _userModel = UserModel.fromJson(json.decode(userJson));
      } catch (e) {}
    }
    //广播用户信息更改
    Global.eventBus.fire(new UserChangedEvent());
  }

  //用户资料更新
  void update({bool fire = true}) async {
    await _saveToLocal();

    if (fire) {
      Global.eventBus.fire(new UserChangedEvent());
    }
  }

  ///从服务器获取用户资料
  Future<bool> requestUser() async {
    ResponseModel ret = await HttpManager.instance.post('loadUserInfo');
    if (ret.isSuccess) {
      UserModel model = UserModel.fromJson(ret.data);
      model.companys = UserManager.instance.userModel?.companys;
      UserManager.instance.userModel = model;
      return true;
    } else {
      return false;
    }
  }

  ///
  /// 请求服务器设置用户资料并同步本地数据
  ///  key 0：头像；1：姓名；2：性别；3：地区；4：员工照片 5:车牌号码
  ///   错误返回提示信息，成功返回null
  Future<String> requestModifyUserInfo(int key, String val) async {
    ResponseModel ret = await HttpManager.instance
        .post('updateUserInfo', params: {'key': key, 'value': '$val'});
    if (ret.isSuccess) {
      await requestUser();
      return null;
    } else {
      return ret.message;
    }
  }

  //用户推出
  void logout() async {
    _userModel = null;

    await _deleteLocal(); //删除本地缓存

    Global.eventBus.fire(new UserChangedEvent());
  }

  _saveToLocal() async {
    if (_userModel != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(kUserKey, json.encode(_userModel.toJson()));
    }
  }

  _deleteLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(kUserKey);
  }
}
