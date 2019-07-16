import 'package:json_annotation/json_annotation.dart'; 
import 'company_data_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
  class UserModel extends Object {


  @JsonKey(name: 'image')
  String faceImage;

  @JsonKey(name: 'jobData')
  List<JobData> jobData;

  @JsonKey(name: 'logo')
  String logo;

  @JsonKey(name: 'mobile')
  String mobile;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'region')
  String region;

  @JsonKey(name: 'sex')
  int sex;

  @JsonKey(name: 'carCode')
  String cardCode;

  @JsonKey(name: 'companys')
  List<CompanyDataModel> companys;

  UserModel(this.faceImage,this.jobData,this.logo,this.mobile,this.name,this.region,this.sex, this.companys, this.cardCode);

  factory UserModel.fromJson(Map<String, dynamic> srcJson) => _$UserModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

}

@JsonSerializable()
  class JobData extends Object {

  @JsonKey(name: 'companyName')
  String companyName;

  @JsonKey(name: 'id')
  int id;

  JobData(this.companyName,this.id,);

  factory JobData.fromJson(Map<String, dynamic> srcJson) => _$JobDataFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JobDataToJson(this);

}