// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionModel _$VersionModelFromJson(Map<String, dynamic> json) {
  return VersionModel(
      json['ios'] == null
          ? null
          : IosVersion.fromJson(json['ios'] as Map<String, dynamic>),
      json['android'] == null
          ? null
          : AndroidVersion.fromJson(json['android'] as Map<String, dynamic>));
}

Map<String, dynamic> _$VersionModelToJson(VersionModel instance) =>
    <String, dynamic>{'ios': instance.ios, 'android': instance.android};

IosVersion _$IosVersionFromJson(Map<String, dynamic> json) {
  return IosVersion(
      json['buildNumber'] as int,
      json['forceUpdate'] as int,
      json['version'] as String,
      json['log'] as String,
      json['plist'] as String);
}

Map<String, dynamic> _$IosVersionToJson(IosVersion instance) =>
    <String, dynamic>{
      'buildNumber': instance.buildNumber,
      'forceUpdate': instance.forceUpdate,
      'version': instance.version,
      'log': instance.log,
      'plist': instance.plist
    };

AndroidVersion _$AndroidVersionFromJson(Map<String, dynamic> json) {
  return AndroidVersion(json['buildNumber'] as int, json['forceUpdate'] as int,
      json['version'] as String, json['log'] as String, json['apk'] as String);
}

Map<String, dynamic> _$AndroidVersionToJson(AndroidVersion instance) =>
    <String, dynamic>{
      'buildNumber': instance.buildNumber,
      'forceUpdate': instance.forceUpdate,
      'version': instance.version,
      'log': instance.log,
      'apk': instance.apk
    };
