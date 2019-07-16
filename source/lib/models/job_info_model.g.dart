// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobInfoModel _$JobInfoModelFromJson(Map<String, dynamic> json) {
  return JobInfoModel(
      json['officeRegion'] as String,
      json['entryDate'] as String,
      json['companyLogo'] as String,
      json['extensionNumber'] as String,
      json['companyName'] as String,
      json['name'] as String,
      json['mobile'] as String,
      json['department'] as String,
      json['jobNumber'] as String);
}

Map<String, dynamic> _$JobInfoModelToJson(JobInfoModel instance) =>
    <String, dynamic>{
      'officeRegion': instance.officeRegion,
      'entryDate': instance.entryDate,
      'companyLogo': instance.companyLogo,
      'extensionNumber': instance.extensionNumber,
      'companyName': instance.companyName,
      'name': instance.name,
      'mobile': instance.mobile,
      'department': instance.department,
      'jobNumber': instance.jobNumber
    };
