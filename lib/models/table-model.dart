
import 'package:json_annotation/json_annotation.dart';
import 'package:tichu/models/card_model.dart';


// use 'flutter pub run build_runner build' to re-generate
part 'table-model.g.dart';

@JsonSerializable()
class TableModel {

  List<List<CardModel>> cards = [];

  TableModel();

  factory TableModel.fromJson(Map<String, dynamic> json) => _$TableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableModelToJson(this);

}
