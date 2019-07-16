import 'package:json_annotation/json_annotation.dart';

part 'approval_detail_model.g.dart';

@JsonSerializable()
class ApprovalDetailModel extends Object {
  @JsonKey(name: 'approvalState')
  int recordState;

  @JsonKey(name: 'jobId')
  int jobId;

  @JsonKey(name: 'userName')
  String userName;

  @JsonKey(name: 'departmentName')
  String departmentName;

  @JsonKey(name: 'approvalType')
  int approvalType;

  @JsonKey(name: 'leaveTypeName')
  String leaveType;

  @JsonKey(name: 'createTime')
  String createTime;

  @JsonKey(name: 'beginTime')
  String beginTime;

  @JsonKey(name: 'endTime')
  String endTime;

  @JsonKey(name: 'duration')
  double duration;

  @JsonKey(name: 'unitType')
  int unitType;

  @JsonKey(name: 'attendanceGroupName')
  String scheduleName;

  @JsonKey(name: 'clockTime')
  String clockTime;

  @JsonKey(name: 'reason')
  String reason;

  @JsonKey(name: 'destination')
  String destination;

  @JsonKey(name: 'oldCarCode')
  String oldCarCode;

  @JsonKey(name: 'carCode')
  String carCode;

  @JsonKey(name: 'identifyImage')
  String identifyImage;

  @JsonKey(name: 'approveRecords')
  List<ApproveRecord> approveRecord;

  @JsonKey(name: 'currentApprover')
  CurrentApprover currentApprover;

  ApprovalDetailModel(
    this.recordState,
    this.jobId,
    this.userName,
    this.departmentName,
    this.approvalType,
    this.leaveType,
    this.createTime,
    this.beginTime,
    this.endTime,
    this.duration,
    this.unitType,
    this.scheduleName,
    this.clockTime,
    this.reason,
    this.destination,
    this.oldCarCode,
    this.carCode,
    this.identifyImage,
    this.approveRecord,
    this.currentApprover,
  );

  factory ApprovalDetailModel.fromJson(Map<String, dynamic> srcJson) =>
      _$ApprovalDetailModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ApprovalDetailModelToJson(this);
}

@JsonSerializable()
class ApproveRecord extends Object {
  @JsonKey(name: 'jobId')
  int jobId;

  @JsonKey(name: 'approverUserName')
  String approvaerUserName;

  @JsonKey(name: 'approveState')
  int approveState;

  @JsonKey(name: 'approveTime')
  String approveTime;

  @JsonKey(name: 'rejectReason')
  String rejectReason;

  ApproveRecord(
    this.jobId,
    this.approvaerUserName,
    this.approveState,
    this.approveTime,
    this.rejectReason,
  );

  factory ApproveRecord.fromJson(Map<String, dynamic> srcJson) =>
      _$ApproveRecordFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ApproveRecordToJson(this);
}

@JsonSerializable()
class CurrentApprover extends Object {
  @JsonKey(name: 'jobId')
  int jobId;

  @JsonKey(name: 'userName')
  String userName;

  CurrentApprover(
    this.jobId,
    this.userName,
  );

  factory CurrentApprover.fromJson(Map<String, dynamic> srcJson) =>
      _$CurrentApproverFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CurrentApproverToJson(this);
}
