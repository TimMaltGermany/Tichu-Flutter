// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tichu/components/avatar.dart';
import 'package:tichu/enums/player-role.dart';
import 'package:tichu/models/player-model.dart';
import 'package:tichu/models/table-model.dart';
import 'package:tichu/models/register-player-model.dart';
import 'package:tichu/enums/commands.dart';
import 'package:tichu/enums/phases.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:tichu/game-utils.dart';
import 'package:tichu/tichu-game.dart';

class TichuTable extends StatefulWidget {
  final RegisterPlayerModel player;

  const TichuTable({Key? key, required this.player}) : super(key: key);

  @override
  _TichuTableState createState() => _TichuTableState(player);
}

class _TichuTableState extends State<TichuTable> {

  late WebSocketChannel _channel;
  late Map<PlayerRole, Avatar> _avatars;

  late TichuGame _game;

  _TichuTableState(RegisterPlayerModel player) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://${player.serverIp}:${GameUtils.PORT}?token=${player.token}'),
    );

    _channel.stream.forEach((element) {
      Map<String, Object> data = jsonDecode(element);
      String cmd = data['cmd'] as String;
      switch(cmd) {
        case Commands.REGISTER_PLAYER:
          handleRegisterPlayer(data, player);
          break;
        case Commands.START_GAME:
          print("four players joined the game - we can start!");
          _game.gamePhase = Phase.GAME_STATE_NEW;
          break;

        case Commands.DEAL:
          this._avatars.forEach((_, avatar) { avatar.reset();});
          break;

        case Commands.PLAYER_UPDATE:
          String token = data['userID'] as String;
          
          PlayerModel serverPlayer = PlayerModel.fromJson(data['player'] as Map<String, dynamic>);
          PlayerRole role = determineRole(token, serverPlayer, player);
          print("received update for player '${serverPlayer.name}' with role $role and status '${serverPlayer.personalGameStatus}'");
          if (role == PlayerRole.ACTIVE) {
            this._game.gamePhase = serverPlayer.phase;
          }
          this._avatars[role]!.setPlayer(this._game, serverPlayer);
          break;

        case Commands.UPDATE_GAME_STATE:
          TableModel tableModel = TableModel.fromJson(data as Map<String, dynamic>);
          print("received update for table with cards '${tableModel.cards}' ");
          if (tableModel.cards.length > 0) {
            _game.tichuRules.setCurrentHighestPlay(
                tableModel.cards[tableModel.cards.length - 1]);
          } else {
            _game.tichuRules.setCurrentHighestPlay([]);
          }
          _game.tableView?.addCards(_game, tableModel);
          break;

        default:
          print("Unhandled command: ");
          print(element);
      }
    });

    _game = TichuGame(this._channel);

    this._avatars = Avatar.createAvatars(100, 100);
    this._avatars.forEach((role, avatar) {this._game.addAvatar(role, avatar);});

    sendMessage(_channel, Commands.REGISTER_PLAYER, player);
  }

  void handleRegisterPlayer(Map<String, Object> data, RegisterPlayerModel player) {
    String token = data['userID'] as String;
    PlayerModel serverPlayer = PlayerModel.fromJson(data['player'] as Map<String, dynamic>);
    PlayerRole role;
    if (token == player.token) {
      print("we are registered....");
      player.seat = serverPlayer.seat;
      // the team may have changed if the selected team was already full or
      // if there were already two teams
      player.team = serverPlayer.team;
      role = PlayerRole.ACTIVE;
    } else {
      role = determineRole(token, serverPlayer, player);
      print("player '${serverPlayer.name}' joined the game with role $role");
    }
    this._avatars[role]!.setPlayer(this._game, serverPlayer);
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }

/*
  @override
  void initState() {
  super.initState();
 // AssetsLoader.loadImages();
  }
*/

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}