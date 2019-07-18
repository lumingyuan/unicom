// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyDataModel _$CompanyDataModelFromJson(Map<String, dynamic> json) {
  return CompanyDataModel(
      json['jobId'] as int,
      json['schedule'] == null
          ? null
          : Schedule.fromJson(json['schedule'] as Map<String, dynamic>),
      json['leavelApprovalId'] as int,
      json['workday'] as int,
      json['outApprovalId'] as int,
      json['companyId'] as int,
      json['companyName'] as String,
      json['clockApprovalId'] as int,
      json['attendanceGroup'] as String,
      json['approvalRecordCount'] as int,
      json['travelApprovalId'] as int,
      json['unapproveRecordCount'] as int);
}

Map<String, dynamic> _$CompanyDataModelToJson(CompanyDataModel instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'schedule': instance.schedule,
      'leavelApprovalId': instance.leavelApprovalId,
      'workday': instance.workday,
      'outApprovalId': instance.outApprovalId,
      'companyId': instance.companyId,
      'companyName': instance.companyName,
      'clockApprovalId': instance.clockApprovalId,
      'attendanceGroup': instance.attendanceGroup,
      'approvalRecordCount': instance.approvalRecordCount,
      'travelApprovalId': instance.travelApprovalId,
      'unapproveRecordCount': instance.unapproveRecordCount
    };

Schedule _$ScheduleFromJson(Map<String, dynamic> json) {
  return Schedule(
      json['lateComputeTime'] as int,
      json['lateDuration'] as int,
      (json['location'] as List)
          ?.map((e) => e == null
              ? null
              : ClockLocation.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['time'] as List)
          ?.map((e) =>
              e == null ? null : ClockTime.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
      'lateComputeTime': instance.lateComputeTime,
      'lateDuration': instance.lateDuration,
      'location': instance.locations,
      'time': instance.times
    };

ClockLocation _$ClockLocationFromJson(Map<String, dynamic> json) {
  return ClockLocation(
      json['addess'] as String, json['range'] as int, json['gps'] as String);
}

Map<String, dynamic> _$ClockLocationToJson(ClockLocation instance) =>
    <String, dynamic>{
      'addess': instance.address,
      'range': instance.range,
      'gps': instance.gps
    };

ClockTime _$ClockTimeFromJson(Map<String, dynamic> json) {
  return ClockTime(json['in'] as String, json['earlyDuration'] as int,
      json['out'] as String);
}

Map<String, dynamic> _$ClockTimeToJson(ClockTime instance) => <String, dynamic>{
      'in': instance.clockIn,
      'earlyDuration': instance.earlyDuration,
      'out': instance.clockOut
    };
