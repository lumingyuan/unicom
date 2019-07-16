import 'package:unicom_attendance/global.dart';

import './choose_user_vc.dart';

class ApprovalUsersView extends StatefulWidget {
  final List<Approvers> approvers;

  ApprovalUsersView(this.approvers);

  @override
  State<StatefulWidget> createState() => new _ApprovalUsersViewState();
}

class _ApprovalUsersViewState extends State<ApprovalUsersView> {
  @override
  void initState() {
    super.initState();
  }

  ///暂时没用，没有选择审核者的功能
  void onAddPress() async {
    List<Map<String, dynamic>> ret =
        await NavigatorUtil.pushVC(context, new ChooseUserVC());
    if (ret == null) {
      //用户取消选择，不做处理
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = new List();
    widget.approvers?.forEach((Approvers user) {
      widgets.add(Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: ImageUtil.imageFromUrl(Global.appDomain + user.userLogo,
                    placeholder:
                        ImageUtil.image('def_head.png', fit: BoxFit.fill)),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                '${user.userName}',
                maxLines: 1,
              ),
            )
          ],
        ),
      ));
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      color: Colors.white,
      child: GridView.count(
        crossAxisCount: 5,
        childAspectRatio: 58 / 80,
        physics: NeverScrollableScrollPhysics(),
        children: widgets,
        shrinkWrap: true,
      ),
    );
  }
}
