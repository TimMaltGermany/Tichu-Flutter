
import 'package:json_annotation/json_annotation.dart';
import 'package:tichu/enums/card-state.dart';

// use 'flutter pub run build_runner build' to re-generate
part 'card-model.g.dart';

@JsonSerializable()
class CardModel {

  String name= '';
  String color= '';
  int rank = 0;
  double x  = -10;
  double y = -10;
  //TODO - needed?
  @JsonKey(name: 'is_selected')
  bool isSelected = false;
  //TODO - needed?
  bool is_to_be_played = false;
  @JsonKey(name: '_state')
  CardState state = CardState.ON_HAND;
  String owner = '';
  @JsonKey(name: 'is_visible')
  bool isVisible = false;

  CardModel();


  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$CardModelToJson(this);

}
