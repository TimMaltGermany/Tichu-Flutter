// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table-model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableModel _$TableModelFromJson(Map<String, dynamic> json) {
  return TableModel()
    ..cards = (json['cards'] as List<dynamic>)
        .map((e) => (e as List<dynamic>)
            .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
            .toList())
        .toList();
}

Map<String, dynamic> _$TableModelToJson(TableModel instance) =>
    <String, dynamic>{
      'cards': instance.cards,
    };
