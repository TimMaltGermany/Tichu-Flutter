import 'package:json_annotation/json_annotation.dart';

enum Phase {
  @JsonValue("register") GAME_STATE_REGISTER,
  @JsonValue("new") GAME_STATE_NEW,
  @JsonValue("grosses_tichu") GAME_STATE_2_GRAND_TICHU,
  @JsonValue("schupfen") GAME_STATE_3_SCHUPFEN,
  @JsonValue("spiel") GAME_STATE_5_PLAY,
  @JsonValue("ende") GAME_STATE_6_END
}