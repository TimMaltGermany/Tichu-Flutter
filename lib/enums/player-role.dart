import 'package:json_annotation/json_annotation.dart';
import 'package:tichu/models/player-model.dart';
import 'package:tichu/models/register-player-model.dart';

enum PlayerRole {
  @JsonValue("before")
  BEFORE,
  @JsonValue("active")
  ACTIVE,
  @JsonValue("after")
  AFTER,
  @JsonValue("partner")
  PARTNER
}

int determineSeatFromRole(PlayerRole role, int playerSeat) {
  switch(role) {
    case PlayerRole.BEFORE:
    return (playerSeat + 3) % 4;
    case PlayerRole.ACTIVE:
      return playerSeat;
    case PlayerRole.AFTER:
      return (playerSeat + 1) % 4;
    case PlayerRole.PARTNER:
      return (playerSeat + 2) % 4;
  }
}


PlayerRole determineRole(String token, PlayerModel serverPlayer, RegisterPlayerModel player) {
  if (token == player.token) {
    return PlayerRole.ACTIVE;
  }
  if (serverPlayer.team == player.team) {
    return PlayerRole.PARTNER;
  }
  if ((serverPlayer.seat + 1) % 4 == player.seat) {
    return PlayerRole.BEFORE;
  }
  return PlayerRole.AFTER;
}

