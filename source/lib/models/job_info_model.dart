import 'package:json_annotation/json_annotation.dart'; 
  
part 'job_info_model.g.dart';


@JsonSerializable()
  class JobInfoModel extends Object {

  @JsonKey(name: 'officeRegion')
  String officeRegion;

  @JsonKey(name: 'entryDate')
  String entryDate;

  @JsonKey(name: 'companyLogo')
  String companyLogo;

  @JsonKey(name: 'extensionNumber')
  String extensionNumber;

  @JsonKey(name: 'companyName')
  String companyName;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'mobile')
  String mobile;

  @JsonKey(name: 'department')
  String department;

  @JsonKey(name: 'jobNumber')
  String jobNumber;

  JobInfoModel(this.officeRegion,this.entryDate,this.companyLogo,this.extensionNumber,this.companyName,this.name,this.mobile,this.department,this.jobNumber,);

  factory JobInfoModel.fromJson(Map<String, dynamic> srcJson) => _$JobInfoModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JobInfoModelToJson(this);

}

  
