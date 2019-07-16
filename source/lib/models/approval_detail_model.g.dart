// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApprovalDetailModel _$ApprovalDetailModelFromJson(Map<String, dynamic> json) {
  return ApprovalDetailModel(
      json['approvalState'] as int,
      json['jobId'] as int,
      json['userName'] as String,
      json['departmentName'] as String,
      json['approvalType'] as int,
      json['leaveTypeName'] as String,
      json['createTime'] as String,
      json['beginTime'] as String,
      json['endTime'] as String,
      (json['duration'] as num)?.toDouble(),
      json['unitType'] as int,
      json['attendanceGroupName'] as String,
      json['clockTime'] as String,
      json['reason'] as String,
      json['destination'] as String,
      json['oldCarCode'] as String,
      json['carCode'] as String,
      json['identifyImage'] as String,
      (json['approveRecords'] as List)
          ?.map((e) => e == null
              ? null
              : ApproveRecord.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['currentApprover'] == null
          ? null
          : CurrentApprover.fromJson(
              json['currentApprover'] as Map<String, dynamic>));
}

Map<String, dynamic> _$ApprovalDetailModelToJson(
        ApprovalDetailModel instance) =>
    <String, dynamic>{
      'approvalState': instance.recordState,
      'jobId': instance.jobId,
      'userName': instance.userName,
      'departmentName': instance.departmentName,
      'approvalType': instance.approvalType,
      'leaveTypeName': instance.leaveType,
      'createTime': instance.createTime,
      'beginTime': instance.beginTime,
      'endTime': instance.endTime,
      'duration': instance.duration,
      'unitType': instance.unitType,
      'attendanceGroupName': instance.scheduleName,
      'clockTime': instance.clockTime,
      'reason': instance.reason,
      'destination': instance.destination,
      'oldCarCode': instance.oldCarCode,
      'carCode': instance.carCode,
      'identifyImage': instance.identifyImage,
      'approveRecords': instance.approveRecord,
      'currentApprover': instance.currentApprover
    };

ApproveRecord _$ApproveRecordFromJson(Map<String, dynamic> json) {
  return ApproveRecord(
      json['jobId'] as int,
      json['approverUserName'] as String,
      json['approveState'] as int,
      json['approveTime'] as String,
      json['rejectReason'] as String);
}

Map<String, dynamic> _$ApproveRecordToJson(ApproveRecord instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'approverUserName': instance.approvaerUserName,
      'approveState': instance.approveState,
      'approveTime': instance.approveTime,
      'rejectReason': instance.rejectReason
    };

CurrentApprover _$CurrentApproverFromJson(Map<String, dynamic> json) {
  return CurrentApprover(json['jobId'] as int, json['userName'] as String);
}

Map<String, dynamic> _$CurrentApproverToJson(CurrentApprover instance) =>
    <String, dynamic>{'jobId': instance.jobId, 'userName': instance.userName};
