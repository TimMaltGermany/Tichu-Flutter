// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register-player-model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterPlayerModel _$RegisterPlayerModelFromJson(Map<String, dynamic> json) =>
    RegisterPlayerModel()
      ..team = json['team'] as String
      ..name = json['name'] as String
      ..seat = json['seat'] as int
      ..serverIp = json['serverIp'] as String;

Map<String, dynamic> _$RegisterPlayerModelToJson(
        RegisterPlayerModel instance) =>
    <String, dynamic>{
      'team': instance.team,
      'name': instance.name,
      'seat': instance.seat,
      'serverIp': instance.serverIp,
    };
