// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
      json['image'] as String,
      (json['jobData'] as List)
          ?.map((e) =>
              e == null ? null : JobData.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['logo'] as String,
      json['mobile'] as String,
      json['name'] as String,
      json['region'] as String,
      json['sex'] as int,
      (json['companys'] as List)
          ?.map((e) => e == null
              ? null
              : CompanyDataModel.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['carCode'] as String);
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'image': instance.faceImage,
      'jobData': instance.jobData,
      'logo': instance.logo,
      'mobile': instance.mobile,
      'name': instance.name,
      'region': instance.region,
      'sex': instance.sex,
      'carCode': instance.cardCode,
      'companys': instance.companys
    };

JobData _$JobDataFromJson(Map<String, dynamic> json) {
  return JobData(json['companyName'] as String, json['id'] as int);
}

Map<String, dynamic> _$JobDataToJson(JobData instance) =>
    <String, dynamic>{'companyName': instance.companyName, 'id': instance.id};
