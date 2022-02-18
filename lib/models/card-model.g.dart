// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card-model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) {
  return CardModel()
    ..name = json['name'] as String
    ..color = json['color'] as String
    ..rank = json['rank'] as int
    ..x = (json['x'] as num).toDouble()
    ..y = (json['y'] as num).toDouble()
    ..isSelected = json['is_selected'] as bool
    ..is_to_be_played = json['is_to_be_played'] as bool
    ..state = _$enumDecode(_$CardStateEnumMap, json['_state'])
    ..owner = json['owner'] as String
    ..isVisible = json['is_visible'] as bool;
}

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
      'name': instance.name,
      'color': instance.color,
      'rank': instance.rank,
      'x': instance.x,
      'y': instance.y,
      'is_selected': instance.isSelected,
      'is_to_be_played': instance.is_to_be_played,
      '_state': _$CardStateEnumMap[instance.state],
      'owner': instance.owner,
      'is_visible': instance.isVisible,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$CardStateEnumMap = {
  CardState.ON_HAND: 'on hand',
  CardState.ON_SCHUPF_AREA_BEFORE: 'on schupf area before',
  CardState.ON_SCHUPF_AREA_AFTER: 'on schupf area after',
  CardState.ON_SCHUPF_AREA_PARTNER: 'on schupf area partner',
  CardState.ON_TABLE_TO_BE_PLAYED: 'on table to be played',
  CardState.ON_TABLE_PLAYED: 'on table played',
  CardState.OFF_TABLE: 'off table',
};
