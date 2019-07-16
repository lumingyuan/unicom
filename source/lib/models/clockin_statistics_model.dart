import 'package:json_annotation/json_annotation.dart';

part 'clockin_statistics_model.g.dart';

@JsonSerializable()
class ClockinStatisticsModel extends Object {
  @JsonKey(name: 'outApprovalRecord')
  OutApprovalRecord outApprovalRecord;

  @JsonKey(name: 'restDay')
  RestDay restDay;

  @JsonKey(name: 'absenteeism')
  Absenteeism absenteeism;

  @JsonKey(name: 'late')
  Late late1;

  @JsonKey(name: 'leaveApprovalRecord')
  LeaveApprovalRecord leaveApprovalRecord;

  @JsonKey(name: 'travelApprovalRecord')
  TravelApprovalRecord travelApprovalRecord;

  @JsonKey(name: 'clockApprovalRecord')
  ClockApprovalRecord clockApprovalRecord;

  @JsonKey(name: 'attendanceDay')
  AttendanceDay attendanceDay;

  @JsonKey(name: 'early')
  Early early;

  @JsonKey(name: 'lack')
  Lack lack;

  @JsonKey(name: 'attendanceSchedule')
  AttendanceSchedule attendanceSchedule;

  ClockinStatisticsModel(
    this.outApprovalRecord,
    this.restDay,
    this.absenteeism,
    this.late1,
    this.leaveApprovalRecord,
    this.travelApprovalRecord,
    this.clockApprovalRecord,
    this.attendanceDay,
    this.early,
    this.lack,
    this.attendanceSchedule,
  );

  factory ClockinStatisticsModel.fromJson(Map<String, dynamic> srcJson) =>
      _$ClockinStatisticsModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ClockinStatisticsModelToJson(this);
}

@JsonSerializable()
class OutApprovalRecord extends Object {
  @JsonKey(name: 'data')
  List<String> data;

  @JsonKey(name: 'count')
  int count;

  OutApprovalRecord(
    this.data,
    this.count,
  );

  factory OutApprovalRecord.fromJson(Map<String, dynamic> srcJson) =>
      _$OutApprovalRecordFromJson(srcJson);

  Map<String, dynamic> toJson() => _$OutApprovalRecordToJson(this);
}

@JsonSerializable()
class RestDay extends Object {
  @JsonKey(name: 'data')
  List<String> data;

  @JsonKey(name: 'count')
  int count;

  RestDay(
    this.data,
    this.count,
  );

  factory RestDay.fromJson(Map<String, dynamic> srcJson) =>
      _$RestDayFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RestDayToJson(this);
}

@JsonSerializable()
class Absenteeism extends Object {
  @JsonKey(name: 'data')
  List<String> data;

  @JsonKey(name: 'count')
  int count;

  Absenteeism(
    this.data,
    this.count,
  );

  factory Absenteeism.fromJson(Map<String, dynamic> srcJson) =>
      _$AbsenteeismFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AbsenteeismToJson(this);
}

@JsonSerializable()
class Late extends Object {
  @JsonKey(name: 'data')
  List<dynamic> data;

  @JsonKey(name: 'count')
  int count;

  Late(
    this.data,
    this.count,
  );

  factory Late.fromJson(Map<String, dynamic> srcJson) =>
      _$LateFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LateToJson(this);
}

@JsonSerializable()
class LeaveApprovalRecord extends Object {
  @JsonKey(name: 'data')
  List<String> data;

  @JsonKey(name: 'count')
  int count;

  LeaveApprovalRecord(
    this.data,
    this.count,
  );

  factory LeaveApprovalRecord.fromJson(Map<String, dynamic> srcJson) =>
      _$LeaveApprovalRecordFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LeaveApprovalRecordToJson(this);
}

@JsonSerializable()
class TravelApprovalRecord extends Object {
  @JsonKey(name: 'data')
  List<String> data;

  @JsonKey(name: 'count')
  int count;

  TravelApprovalRecord(
    this.data,
    this.count,
  );

  factory TravelApprovalRecord.fromJson(Map<String, dynamic> srcJson) =>
      _$TravelApprovalRecordFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TravelApprovalRecordToJson(this);
}

@JsonSerializable()
class ClockApprovalRecord extends Object {
  @JsonKey(name: 'data')
  List<String> data;

  @JsonKey(name: 'count')
  int count;

  ClockApprovalRecord(
    this.data,
    this.count,
  );

  factory ClockApprovalRecord.fromJson(Map<String, dynamic> srcJson) =>
      _$ClockApprovalRecordFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ClockApprovalRecordToJson(this);
}

@JsonSerializable()
class AttendanceDay extends Object {
  @JsonKey(name: 'data')
  List<String> data;

  @JsonKey(name: 'count')
  int count;

  AttendanceDay(
    this.data,
    this.count,
  );

  factory AttendanceDay.fromJson(Map<String, dynamic> srcJson) =>
      _$AttendanceDayFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AttendanceDayToJson(this);
}

@JsonSerializable()
class Early extends Object {
  @JsonKey(name: 'data')
  List<String> data;

  @JsonKey(name: 'count')
  int count;

  Early(
    this.data,
    this.count,
  );

  factory Early.fromJson(Map<String, dynamic> srcJson) =>
      _$EarlyFromJson(srcJson);

  Map<String, dynamic> toJson() => _$EarlyToJson(this);
}

@JsonSerializable()
class Lack extends Object {
  @JsonKey(name: 'data')
  List<String> data;

  @JsonKey(name: 'count')
  int count;

  Lack(
    this.data,
    this.count,
  );

  factory Lack.fromJson(Map<String, dynamic> srcJson) =>
      _$LackFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LackToJson(this);
}

@JsonSerializable()
class AttendanceSchedule extends Object {
  @JsonKey(name: 'count')
  int count;

  @JsonKey(name: 'attendanceGroupName')
  String attendanceGroupName;

  AttendanceSchedule(
    this.count,
    this.attendanceGroupName,
  );

  factory AttendanceSchedule.fromJson(Map<String, dynamic> srcJson) =>
      _$AttendanceScheduleFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AttendanceScheduleToJson(this);
}
