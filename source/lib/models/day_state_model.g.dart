// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayStateModel _$DayStateModelFromJson(Map<String, dynamic> json) {
  return DayStateModel(json['date'] as String, json['state'] as int);
}

Map<String, dynamic> _$DayStateModelToJson(DayStateModel instance) =>
    <String, dynamic>{'date': instance.date, 'state': instance.state};
