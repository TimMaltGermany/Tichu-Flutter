// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player-model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) => PlayerModel()
  ..team = json['team'] as String
  ..name = json['name'] as String
  ..seat = json['seat'] as int
  ..connected = json['connected'] as bool
  ..announced = $enumDecode(_$AnnouncedEnumMap, json['announced'])
  ..tricks = (json['tricks'] as List<dynamic>).map((e) => e as String).toList()
  ..phase = $enumDecode(_$PhaseEnumMap, json['phase'])
  ..personalGameStatus =
      $enumDecode(_$PlayerStatusEnumMap, json['personal_game_status'])
  ..hasPassed = json['has_passed'] as bool
  ..rank = json['rank'] as int
  ..cards = (json['cards'] as List<dynamic>)
      .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$PlayerModelToJson(PlayerModel instance) =>
    <String, dynamic>{
      'team': instance.team,
      'name': instance.name,
      'seat': instance.seat,
      'connected': instance.connected,
      'announced': _$AnnouncedEnumMap[instance.announced],
      'tricks': instance.tricks,
      'phase': _$PhaseEnumMap[instance.phase],
      'personal_game_status':
          _$PlayerStatusEnumMap[instance.personalGameStatus],
      'has_passed': instance.hasPassed,
      'rank': instance.rank,
      'cards': instance.cards,
    };

const _$AnnouncedEnumMap = {
  Announced.NOTHING: 'nothing',
  Announced.TICHU: 'Tichu',
  Announced.GRAND_TICHU: 'Grand Tichu',
};

const _$PhaseEnumMap = {
  Phase.GAME_STATE_REGISTER: 'register',
  Phase.GAME_STATE_NEW: 'new',
  Phase.GAME_STATE_2_GRAND_TICHU: 'grosses_tichu',
  Phase.GAME_STATE_3_SCHUPFEN: 'schupfen',
  Phase.GAME_STATE_5_PLAY: 'spiel',
  Phase.GAME_STATE_6_END: 'ende',
};

const _$PlayerStatusEnumMap = {
  PlayerStatus.PASSIVE: 'PASSIVE',
  PlayerStatus.ACTIVE: 'ACTIVE',
  PlayerStatus.DONE: 'DONE',
};
