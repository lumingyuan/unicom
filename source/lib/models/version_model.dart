import 'package:json_annotation/json_annotation.dart';

part 'version_model.g.dart';

@JsonSerializable()
class VersionModel extends Object {
  @JsonKey(name: 'ios')
  IosVersion ios;

  @JsonKey(name: 'android')
  AndroidVersion android;

  VersionModel(
    this.ios,
    this.android,
  );

  factory VersionModel.fromJson(Map<String, dynamic> srcJson) =>
      _$VersionModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$VersionModelToJson(this);
}

@JsonSerializable()
class IosVersion extends Object {
  @JsonKey(name: 'buildNumber')
  int buildNumber;

  @JsonKey(name: 'forceUpdate')
  int forceUpdate;

  @JsonKey(name: 'version')
  String version;

  @JsonKey(name: 'log')
  String log;

  @JsonKey(name: 'plist')
  String plist;

  IosVersion(
    this.buildNumber,
    this.forceUpdate,
    this.version,
    this.log,
    this.plist,
  );

  factory IosVersion.fromJson(Map<String, dynamic> srcJson) =>
      _$IosVersionFromJson(srcJson);

  Map<String, dynamic> toJson() => _$IosVersionToJson(this);
}

@JsonSerializable()
class AndroidVersion extends Object {
  @JsonKey(name: 'buildNumber')
  int buildNumber;

  @JsonKey(name: 'forceUpdate')
  int forceUpdate;

  @JsonKey(name: 'version')
  String version;

  @JsonKey(name: 'log')
  String log;

  @JsonKey(name: 'apk')
  String apk;

  AndroidVersion(
    this.buildNumber,
    this.forceUpdate,
    this.version,
    this.log,
    this.apk,
  );

  factory AndroidVersion.fromJson(Map<String, dynamic> srcJson) =>
      _$AndroidVersionFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AndroidVersionToJson(this);
}
