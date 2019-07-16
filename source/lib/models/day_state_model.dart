import 'package:json_annotation/json_annotation.dart'; 
  
part 'day_state_model.g.dart';


List<DayStateModel> getDayStateModelList(List<dynamic> list){
    List<DayStateModel> result = [];
    list.forEach((item){
      result.add(DayStateModel.fromJson(item));
    });
    return result;
  }
@JsonSerializable()
  class DayStateModel extends Object {

  @JsonKey(name: 'date')
  String date;

  @JsonKey(name: 'state')
  int state;

  DayStateModel(this.date,this.state,);

  factory DayStateModel.fromJson(Map<String, dynamic> srcJson) => _$DayStateModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DayStateModelToJson(this);

}

  
