// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_of_apply_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayOfApplyRecordModel _$DayOfApplyRecordModelFromJson(
    Map<String, dynamic> json) {
  return DayOfApplyRecordModel(
      json['date'] as String,
      (json['records'] as List)
          ?.map((e) =>
              e == null ? null : Records.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$DayOfApplyRecordModelToJson(
        DayOfApplyRecordModel instance) =>
    <String, dynamic>{'date': instance.date, 'records': instance.records};

Records _$RecordsFromJson(Map<String, dynamic> json) {
  return Records(
      json['approvalRecordId'] as int,
      json['approvalType'] as int,
      json['leaveTypeName'] as String,
      json['reason'] as String,
      json['beginTime'] as String,
      json['endTime'] as String,
      json['unitType'] as int,
      (json['duration'] as num)?.toDouble(),
      json['approvalState'] as int,
      json['attendanceGroupName'] as String,
      json['clockTime'] as String,
      json['destination'] as String,
      json['createTime'] as String,
      json['carCodeIndex'] as int,
      json['carCode'] as String,
      json['oldCarCode'] as String,
      json['departmentName'] as String,
      json['userName'] as String,
      json['approveRecord'],
      json['identifyImage'] as String);
}

Map<String, dynamic> _$RecordsToJson(Records instance) => <String, dynamic>{
      'approvalRecordId': instance.approvalRecordId,
      'approvalType': instance.approvalType,
      'leaveTypeName': instance.leaveTypeName,
      'reason': instance.reason,
      'beginTime': instance.beginTime,
      'endTime': instance.endTime,
      'unitType': instance.unitType,
      'duration': instance.duration,
      'approvalState': instance.approvalState,
      'attendanceGroupName': instance.scheduleName,
      'clockTime': instance.clockTime,
      'destination': instance.destination,
      'createTime': instance.createTime,
      'carCodeIndex': instance.carCodeIndex,
      'carCode': instance.carCode,
      'oldCarCode': instance.oldCarCode,
      'departmentName': instance.departmentName,
      'userName': instance.userName,
      'approveRecord': instance.approveRecord,
      'identifyImage': instance.identifyImage
    };
