// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApprovalConfigModel _$ApprovalConfigModelFromJson(Map<String, dynamic> json) {
  return ApprovalConfigModel(
      (json['leaveTypes'] as List)
          ?.map((e) =>
              e == null ? null : LeaveTypes.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['approvers'] as List)
          ?.map((e) =>
              e == null ? null : Approvers.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['unitType'] as int,
      json['clockState'] as int);
}

Map<String, dynamic> _$ApprovalConfigModelToJson(
        ApprovalConfigModel instance) =>
    <String, dynamic>{
      'leaveTypes': instance.leaveTypes,
      'approvers': instance.approvers,
      'unitType': instance.unitType,
      'clockState': instance.clockState
    };

LeaveTypes _$LeaveTypesFromJson(Map<String, dynamic> json) {
  return LeaveTypes(json['leaveTypeId'] as int, json['leaveTypeName'] as String,
      json['unitType'] as int);
}

Map<String, dynamic> _$LeaveTypesToJson(LeaveTypes instance) =>
    <String, dynamic>{
      'leaveTypeId': instance.leaveTypeId,
      'leaveTypeName': instance.leaveTypeName,
      'unitType': instance.unitType
    };

Approvers _$ApproversFromJson(Map<String, dynamic> json) {
  return Approvers(json['userName'] as String, json['userLogo'] as String);
}

Map<String, dynamic> _$ApproversToJson(Approvers instance) => <String, dynamic>{
      'userName': instance.userName,
      'userLogo': instance.userLogo
    };
