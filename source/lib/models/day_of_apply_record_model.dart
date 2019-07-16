import 'package:json_annotation/json_annotation.dart';

part 'day_of_apply_record_model.g.dart';

List<DayOfApplyRecordModel> getDayOfApplyRecordModelList(List<dynamic> list) {
  List<DayOfApplyRecordModel> result = [];
  list.forEach((item) {
    result.add(DayOfApplyRecordModel.fromJson(item));
  });
  return result;
}

@JsonSerializable()
class DayOfApplyRecordModel extends Object {
  @JsonKey(name: 'date')
  String date;

  @JsonKey(name: 'records')
  List<Records> records;

  DayOfApplyRecordModel(
    this.date,
    this.records,
  );

  factory DayOfApplyRecordModel.fromJson(Map<String, dynamic> srcJson) =>
      _$DayOfApplyRecordModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DayOfApplyRecordModelToJson(this);
}

@JsonSerializable()
class Records extends Object {
  @JsonKey(name: 'approvalRecordId')
  int approvalRecordId;

  @JsonKey(name: 'approvalType')
  int approvalType;

  @JsonKey(name: 'leaveTypeName')
  String leaveTypeName;

  @JsonKey(name: 'reason')
  String reason;

  @JsonKey(name: 'beginTime')
  String beginTime;

  @JsonKey(name: 'endTime')
  String endTime;

  @JsonKey(name: 'unitType')
  int unitType;

  @JsonKey(name: 'duration')
  double duration;

  @JsonKey(name: 'approvalState')
  int approvalState;

////补卡特有字段
  @JsonKey(name: 'attendanceGroupName')
  String scheduleName;

  @JsonKey(name: 'clockTime')
  String clockTime;

  @JsonKey(name: 'destination')
  String destination;

  ///更换车牌特有字段
  @JsonKey(name: 'createTime')
  String createTime;

  @JsonKey(name: 'carCodeIndex')
  int carCodeIndex;

  @JsonKey(name: 'carCode')
  String carCode;

  @JsonKey(name: 'oldCarCode')
  String oldCarCode;

  @JsonKey(name: 'departmentName')
  String departmentName;

  @JsonKey(name: 'userName')
  String userName;

  @JsonKey(name: 'approveRecord')
  dynamic approveRecord;

  @JsonKey(name: 'identifyImage')
  String identifyImage;

  Records(
    this.approvalRecordId,
    this.approvalType,
    this.leaveTypeName,
    this.reason,
    this.beginTime,
    this.endTime,
    this.unitType,
    this.duration,
    this.approvalState,
    this.scheduleName,
    this.clockTime,
    this.destination,
    this.createTime,
    this.carCodeIndex,
    this.carCode,
    this.oldCarCode,
    this.departmentName,
    this.userName,
    this.approveRecord,
    this.identifyImage,
  );

  factory Records.fromJson(Map<String, dynamic> srcJson) =>
      _$RecordsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RecordsToJson(this);
}
