
import 'package:tichu/enums/player-status.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tichu/models/card-model.dart';
import 'package:tichu/enums/announced.dart';
import 'package:tichu/enums/phases.dart';

// use 'flutter pub run build_runner build' to re-generate
part 'player-model.g.dart';

@JsonSerializable()
class PlayerModel {

  /// team currently selected by the user
  String team = '';
  /// player (display) name
  String name = '';
  String _token = "invalid";

  int seat = -1;

  bool connected = false;
  Announced announced = Announced.NOTHING;
  List<String> tricks = [];
  Phase phase = Phase.GAME_STATE_NEW;
  @JsonKey(name: 'personal_game_status')
  PlayerStatus personalGameStatus = PlayerStatus.PASSIVE;
  @JsonKey(name: 'has_passed')
  bool hasPassed = false;
  int rank = 99;
  List<CardModel> cards = [];

  PlayerModel();


  /// authorization token returned after login
  String get token => _token;

  bool hasTeamSelected() {
    return team.isNotEmpty;
  }

  bool isValidToken() {
    return _token.length > 16;
  }

  int numVisibleCards() {
    return cards.where((i) => i.isVisible).length;
  }

  /// A necessary factory constructor for creating a new PlayerModel instance
  /// from a map. Pass the map to the generated `_$PlayerModelFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory PlayerModel.fromJson(Map<String, dynamic> json) => _$PlayerModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$PlayerModelToJson`.
  Map<String, dynamic> toJson() => _$PlayerModelToJson(this);

}
