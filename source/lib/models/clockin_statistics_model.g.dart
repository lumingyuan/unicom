// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clockin_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClockinStatisticsModel _$ClockinStatisticsModelFromJson(
    Map<String, dynamic> json) {
  return ClockinStatisticsModel(
      json['outApprovalRecord'] == null
          ? null
          : OutApprovalRecord.fromJson(
              json['outApprovalRecord'] as Map<String, dynamic>),
      json['restDay'] == null
          ? null
          : RestDay.fromJson(json['restDay'] as Map<String, dynamic>),
      json['absenteeism'] == null
          ? null
          : Absenteeism.fromJson(json['absenteeism'] as Map<String, dynamic>),
      json['late'] == null
          ? null
          : Late.fromJson(json['late'] as Map<String, dynamic>),
      json['leaveApprovalRecord'] == null
          ? null
          : LeaveApprovalRecord.fromJson(
              json['leaveApprovalRecord'] as Map<String, dynamic>),
      json['travelApprovalRecord'] == null
          ? null
          : TravelApprovalRecord.fromJson(
              json['travelApprovalRecord'] as Map<String, dynamic>),
      json['clockApprovalRecord'] == null
          ? null
          : ClockApprovalRecord.fromJson(
              json['clockApprovalRecord'] as Map<String, dynamic>),
      json['attendanceDay'] == null
          ? null
          : AttendanceDay.fromJson(
              json['attendanceDay'] as Map<String, dynamic>),
      json['early'] == null
          ? null
          : Early.fromJson(json['early'] as Map<String, dynamic>),
      json['lack'] == null
          ? null
          : Lack.fromJson(json['lack'] as Map<String, dynamic>),
      json['attendanceSchedule'] == null
          ? null
          : AttendanceSchedule.fromJson(
              json['attendanceSchedule'] as Map<String, dynamic>));
}

Map<String, dynamic> _$ClockinStatisticsModelToJson(
        ClockinStatisticsModel instance) =>
    <String, dynamic>{
      'outApprovalRecord': instance.outApprovalRecord,
      'restDay': instance.restDay,
      'absenteeism': instance.absenteeism,
      'late': instance.late1,
      'leaveApprovalRecord': instance.leaveApprovalRecord,
      'travelApprovalRecord': instance.travelApprovalRecord,
      'clockApprovalRecord': instance.clockApprovalRecord,
      'attendanceDay': instance.attendanceDay,
      'early': instance.early,
      'lack': instance.lack,
      'attendanceSchedule': instance.attendanceSchedule
    };

OutApprovalRecord _$OutApprovalRecordFromJson(Map<String, dynamic> json) {
  return OutApprovalRecord(
      (json['data'] as List)?.map((e) => e as String)?.toList(),
      json['count'] as int);
}

Map<String, dynamic> _$OutApprovalRecordToJson(OutApprovalRecord instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

RestDay _$RestDayFromJson(Map<String, dynamic> json) {
  return RestDay((json['data'] as List)?.map((e) => e as String)?.toList(),
      json['count'] as int);
}

Map<String, dynamic> _$RestDayToJson(RestDay instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

Absenteeism _$AbsenteeismFromJson(Map<String, dynamic> json) {
  return Absenteeism((json['data'] as List)?.map((e) => e as String)?.toList(),
      json['count'] as int);
}

Map<String, dynamic> _$AbsenteeismToJson(Absenteeism instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

Late _$LateFromJson(Map<String, dynamic> json) {
  return Late(json['data'] as List, json['count'] as int);
}

Map<String, dynamic> _$LateToJson(Late instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

LeaveApprovalRecord _$LeaveApprovalRecordFromJson(Map<String, dynamic> json) {
  return LeaveApprovalRecord(
      (json['data'] as List)?.map((e) => e as String)?.toList(),
      json['count'] as int);
}

Map<String, dynamic> _$LeaveApprovalRecordToJson(
        LeaveApprovalRecord instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

TravelApprovalRecord _$TravelApprovalRecordFromJson(Map<String, dynamic> json) {
  return TravelApprovalRecord(
      (json['data'] as List)?.map((e) => e as String)?.toList(),
      json['count'] as int);
}

Map<String, dynamic> _$TravelApprovalRecordToJson(
        TravelApprovalRecord instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

ClockApprovalRecord _$ClockApprovalRecordFromJson(Map<String, dynamic> json) {
  return ClockApprovalRecord(
      (json['data'] as List)?.map((e) => e as String)?.toList(),
      json['count'] as int);
}

Map<String, dynamic> _$ClockApprovalRecordToJson(
        ClockApprovalRecord instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

AttendanceDay _$AttendanceDayFromJson(Map<String, dynamic> json) {
  return AttendanceDay(
      (json['data'] as List)?.map((e) => e as String)?.toList(),
      json['count'] as int);
}

Map<String, dynamic> _$AttendanceDayToJson(AttendanceDay instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

Early _$EarlyFromJson(Map<String, dynamic> json) {
  return Early((json['data'] as List)?.map((e) => e as String)?.toList(),
      json['count'] as int);
}

Map<String, dynamic> _$EarlyToJson(Early instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

Lack _$LackFromJson(Map<String, dynamic> json) {
  return Lack((json['data'] as List)?.map((e) => e as String)?.toList(),
      json['count'] as int);
}

Map<String, dynamic> _$LackToJson(Lack instance) =>
    <String, dynamic>{'data': instance.data, 'count': instance.count};

AttendanceSchedule _$AttendanceScheduleFromJson(Map<String, dynamic> json) {
  return AttendanceSchedule(
      json['count'] as int, json['attendanceGroupName'] as String);
}

Map<String, dynamic> _$AttendanceScheduleToJson(AttendanceSchedule instance) =>
    <String, dynamic>{
      'count': instance.count,
      'attendanceGroupName': instance.attendanceGroupName
    };
