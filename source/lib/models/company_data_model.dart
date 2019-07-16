import 'package:json_annotation/json_annotation.dart';

part 'company_data_model.g.dart';

List<CompanyDataModel> getCompanyDataModelList(List<dynamic> list) {
  List<CompanyDataModel> result = [];
  list.forEach((item) {
    result.add(CompanyDataModel.fromJson(item));
  });
  return result;
}

@JsonSerializable()
class CompanyDataModel extends Object {
  @JsonKey(name: 'jobId')
  int jobId;

  @JsonKey(name: 'schedule')
  Schedule schedule;

  @JsonKey(name: 'leavelApprovalId')
  int leavelApprovalId;

  @JsonKey(name: 'workday')
  int workday;

  @JsonKey(name: 'outApprovalId')
  int outApprovalId;

  @JsonKey(name: 'companyName')
  String companyName;

  @JsonKey(name: 'clockApprovalId')
  int clockApprovalId;

  @JsonKey(name: 'attendanceGroup')
  String attendanceGroup;

  @JsonKey(name: 'approvalRecordCount')
  int approvalRecordCount;

  @JsonKey(name: 'travelApprovalId')
  int travelApprovalId;

  @JsonKey(name: 'unapproveRecordCount')
  int unapproveRecordCount;

  CompanyDataModel(
    this.jobId,
    this.schedule,
    this.leavelApprovalId,
    this.workday,
    this.outApprovalId,
    this.companyName,
    this.clockApprovalId,
    this.attendanceGroup,
    this.approvalRecordCount,
    this.travelApprovalId,
    this.unapproveRecordCount,
  );

  factory CompanyDataModel.fromJson(Map<String, dynamic> srcJson) =>
      _$CompanyDataModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CompanyDataModelToJson(this);
}

@JsonSerializable()
class Schedule extends Object {
  @JsonKey(name: 'lateComputeTime')
  int lateComputeTime;

  @JsonKey(name: 'lateDuration')
  int lateDuration;

  @JsonKey(name: 'location')
  List<ClockLocation> locations;

  @JsonKey(name: 'time')
  List<ClockTime> times;

  Schedule(
    this.lateComputeTime,
    this.lateDuration,
    this.locations,
    this.times,
  );

  factory Schedule.fromJson(Map<String, dynamic> srcJson) =>
      _$ScheduleFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}

@JsonSerializable()
class ClockLocation extends Object {
  @JsonKey(name: 'addess')
  String address;

  @JsonKey(name: 'range')
  int range;

  @JsonKey(name: 'gps')
  String gps;

  ClockLocation(
    this.address,
    this.range,
    this.gps,
  );

  factory ClockLocation.fromJson(Map<String, dynamic> srcJson) =>
      _$ClockLocationFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ClockLocationToJson(this);
}

@JsonSerializable()
class ClockTime extends Object {
  @JsonKey(name: 'in')
  String clockIn;

  @JsonKey(name: 'earlyDuration')
  int earlyDuration;

  @JsonKey(name: 'out')
  String clockOut;

  ClockTime(
    this.clockIn,
    this.earlyDuration,
    this.clockOut,
  );

  factory ClockTime.fromJson(Map<String, dynamic> srcJson) =>
      _$ClockTimeFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ClockTimeToJson(this);
}

