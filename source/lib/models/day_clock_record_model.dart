import 'package:json_annotation/json_annotation.dart';

part 'day_clock_record_model.g.dart';

@JsonSerializable()
class DayClockRecordModel extends Object {
  @JsonKey(name: 'date')
  String date;

  @JsonKey(name: 'dayType')
  int dayType;

  @JsonKey(name: 'approvalRecordsData')
  List<ApprovalRecordsData> approvalRecordsData;

  @JsonKey(name: 'attendanceGroupName')
  String attendanceGroupName;

  @JsonKey(name: 'clockRecord')
  List<ClockRecord> clockRecord;

  DayClockRecordModel(
    this.date,
    this.dayType,
    this.approvalRecordsData,
    this.attendanceGroupName,
    this.clockRecord,
  );

  factory DayClockRecordModel.fromJson(Map<String, dynamic> srcJson) =>
      _$DayClockRecordModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DayClockRecordModelToJson(this);
}

@JsonSerializable()
class ApprovalRecordsData extends Object {
  @JsonKey(name: 'duration')
  double duration;

  @JsonKey(name: 'unitType')
  int unitType;

  @JsonKey(name: 'approvalType')
  String approvalType;

  @JsonKey(name: 'beginTime')
  String beginTime;

  @JsonKey(name: 'endTime')
  String endTime;

  ///是否外勤打卡（0：否；1：是）
  @JsonKey(name: 'clockState')
  int clockState;

  ApprovalRecordsData(this.duration, this.unitType, this.approvalType,
      this.beginTime, this.endTime, this.clockState);

  factory ApprovalRecordsData.fromJson(Map<String, dynamic> srcJson) =>
      _$ApprovalRecordsDataFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ApprovalRecordsDataToJson(this);
}

///
///state
/// 打卡状态（0：缺卡；1：正常；2：迟到；3：早退）
///flag
/// 打卡标识（0：手动打卡；1：自动打卡；2：无感打卡)
///
@JsonSerializable()
class ClockRecord extends Object {
  @JsonKey(name: 'clockTime')
  String clockTime;

  @JsonKey(name: 'flag')
  int flag;

  @JsonKey(name: 'locationAddress')
  String locationAddress;

  @JsonKey(name: 'settingTime')
  String settingTime;

  @JsonKey(name: 'state')
  int state;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'clockRecordId')
  int clockRecordId;

  ClockRecord(
    this.clockTime,
    this.flag,
    this.locationAddress,
    this.settingTime,
    this.state,
    this.type,
    this.clockRecordId,
  );

  factory ClockRecord.fromJson(Map<String, dynamic> srcJson) =>
      _$ClockRecordFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ClockRecordToJson(this);
}
