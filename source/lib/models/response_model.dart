import 'package:json_annotation/json_annotation.dart';

part 'response_model.g.dart';

@JsonSerializable()
class ResponseModel extends Object {
  static const int SUCCESS_CODE = 1;

  bool get isSuccess {
    return code == SUCCESS_CODE;
  }

  @JsonKey(name: 'code')
  int code;

  @JsonKey(name: 'message')
  String message;

  @JsonKey(name: 'data')
  dynamic data;

  ResponseModel(
    this.code,
    this.message,
    this.data,
  );

  factory ResponseModel.fromJson(Map<String, dynamic> srcJson) =>
      _$ResponseModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ResponseModelToJson(this);
}
