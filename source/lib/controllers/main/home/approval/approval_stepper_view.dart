import 'package:unicom_attendance/global.dart';

class ApprovalStepperView extends StatelessWidget {
  final bool isFirstPoint; //是否是第一个结点
  final bool isEndPoint; //是否是最后一个结点
  final ApproveRecord approve;
  final bool isSelf;

  ApprovalStepperView(this.approve, this.isFirstPoint, this.isEndPoint,
      {this.isSelf = false});

  Widget buildStepper() {
    Color lineColor = const Color(0xfff0f0f0);
    List<String> stateImgs = [
      'state_stepper_refuse.png',
      'state_stepper_agree.png',
      'state_stepper_wait.png',
    ];
    String img = stateImgs[approve.approveState];
    if (isFirstPoint) {
      img = stateImgs[1];
    }
    return Column(
      children: <Widget>[
        Container(
          width: isFirstPoint ? 0 : 1.0,
          height: 5,
          color: lineColor,
        ),
        ImageUtil.image(img, width: 25, height: 25, fit: BoxFit.contain),
        Expanded(
          child: Container(
            width: isEndPoint ? 0 : 1.0,
            color: lineColor,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String actionTitle = '发起申请';
    if (approve.approveState == 0) {
      actionTitle = '已拒绝';
    } else if (approve.approveState == 1 && !isFirstPoint) {
      actionTitle = '已同意';
    } else if (approve.approveState == 2) {
      actionTitle = isFirstPoint ? '发起申请' : '审批中';
    }
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          top: 0,
          bottom: 0,
          child: SizedBox(width: 40.0, child: buildStepper()),
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 50, end: 5, top: 5),
          constraints: BoxConstraints(minHeight: 45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 25,
                child: Row(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: 100),
                      child: Text(
                        isSelf ? '我' : '${approve.approvaerUserName}',
                        style: TextStyle(
                            fontSize: 15, color: Global.kDefTextColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      width: 10,
                    ),
                    Text(
                      '$actionTitle',
                      style:
                          TextStyle(fontSize: 15, color: Global.kDefTextColor),
                    ),
                    Spacer(),
                    Text(
                      '${approve.approveTime}',
                      style: TextStyle(fontSize: 13, color: Color(0xff919191)),
                    )
                  ],
                ),
              ),
              Offstage(
                offstage: approve.approveState != 0,
                child: Text(
                  '${approve.rejectReason}',
                  style: TextStyle(
                    color: Color(0xff919191),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
