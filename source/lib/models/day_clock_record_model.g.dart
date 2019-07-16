// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_clock_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayClockRecordModel _$DayClockRecordModelFromJson(Map<String, dynamic> json) {
  return DayClockRecordModel(
      json['date'] as String,
      json['dayType'] as int,
      (json['approvalRecordsData'] as List)
          ?.map((e) => e == null
              ? null
              : ApprovalRecordsData.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['attendanceGroupName'] as String,
      (json['clockRecord'] as List)
          ?.map((e) => e == null
              ? null
              : ClockRecord.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$DayClockRecordModelToJson(
        DayClockRecordModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'dayType': instance.dayType,
      'approvalRecordsData': instance.approvalRecordsData,
      'attendanceGroupName': instance.attendanceGroupName,
      'clockRecord': instance.clockRecord
    };

ApprovalRecordsData _$ApprovalRecordsDataFromJson(Map<String, dynamic> json) {
  return ApprovalRecordsData(
      (json['duration'] as num)?.toDouble(),
      json['unitType'] as int,
      json['approvalType'] as String,
      json['beginTime'] as String,
      json['endTime'] as String,
      json['clockState'] as int);
}

Map<String, dynamic> _$ApprovalRecordsDataToJson(
        ApprovalRecordsData instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'unitType': instance.unitType,
      'approvalType': instance.approvalType,
      'beginTime': instance.beginTime,
      'endTime': instance.endTime,
      'clockState': instance.clockState
    };

ClockRecord _$ClockRecordFromJson(Map<String, dynamic> json) {
  return ClockRecord(
      json['clockTime'] as String,
      json['flag'] as int,
      json['locationAddress'] as String,
      json['settingTime'] as String,
      json['state'] as int,
      json['type'] as int,
      json['clockRecordId'] as int);
}

Map<String, dynamic> _$ClockRecordToJson(ClockRecord instance) =>
    <String, dynamic>{
      'clockTime': instance.clockTime,
      'flag': instance.flag,
      'locationAddress': instance.locationAddress,
      'settingTime': instance.settingTime,
      'state': instance.state,
      'type': instance.type,
      'clockRecordId': instance.clockRecordId
    };
