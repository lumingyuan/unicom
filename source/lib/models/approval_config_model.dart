import 'package:json_annotation/json_annotation.dart'; 
  
part 'approval_config_model.g.dart';


@JsonSerializable()
  class ApprovalConfigModel extends Object {

/////////////////////////////////////
///请假
  @JsonKey(name: 'leaveTypes')
  List<LeaveTypes> leaveTypes;

/////////////////////////////////
///共用数据
  @JsonKey(name: 'approvers')
  List<Approvers> approvers;

///////////////////////////
///外出/出差
  @JsonKey(name: 'unitType')
  int unitType;

  @JsonKey(name: 'clockState')
  int clockState;
/////////////////////////////

  ApprovalConfigModel(this.leaveTypes,this.approvers, this.unitType, this.clockState);

  factory ApprovalConfigModel.fromJson(Map<String, dynamic> srcJson) => _$ApprovalConfigModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ApprovalConfigModelToJson(this);

}

  
@JsonSerializable()
  class LeaveTypes extends Object {

  @JsonKey(name: 'leaveTypeId')
  int leaveTypeId;

  @JsonKey(name: 'leaveTypeName')
  String leaveTypeName;

  @JsonKey(name: 'unitType')
  int unitType;

  LeaveTypes(this.leaveTypeId,this.leaveTypeName,this.unitType);

  factory LeaveTypes.fromJson(Map<String, dynamic> srcJson) => _$LeaveTypesFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LeaveTypesToJson(this);

}

  
@JsonSerializable()
  class Approvers extends Object {

  @JsonKey(name: 'userName')
  String userName;

  @JsonKey(name: 'userLogo')
  String userLogo;

  Approvers(this.userName,this.userLogo,);

  factory Approvers.fromJson(Map<String, dynamic> srcJson) => _$ApproversFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ApproversToJson(this);

}

  
