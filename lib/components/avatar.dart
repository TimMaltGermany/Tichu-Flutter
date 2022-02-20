import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

import 'package:tichu/enums/phases.dart';
import 'package:tichu/enums/player-role.dart';
import 'package:tichu/enums/player-status.dart';
import 'package:tichu/models/player-model.dart';
import 'package:tichu/tichu-game.dart';

import 'package:tichu/game-utils.dart';
import 'card.dart';


class Avatar extends PositionComponent with HasGameRef<TichuGame> {
  PlayerModel? player;

  final PlayerRole role;

  Map<String, Card> cards = {};

  Sprite? img;
  final Rect avatarRect = const Rect.fromLTWH(0, 0, 63, 96);

  late TextPainter tp;
  late TextStyle textStyle;
  final Offset textOffset = const Offset(-20.0, -2.0);
  late Offset targetLocation;

  Avatar(this.role, Vector2 initialPosition) {
    position = initialPosition;
    tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textStyle = const TextStyle(
      color: Color(0xff000000),
      fontSize: 18, // '18px Courier',
      // fill: BLACK, //backgroundColor: WHITE,
      //         fillStyle: { color: BLACK, alpha: 1 }
    );

    /*
      grand_tichu_announced = context.add.image(x, y + 100,
          'buttons', 'button_grand_tichu.png').setOrigin(0, 0);
      grand_tichu_announced.setVisible(false);
      grand_tichu_announced.setScale(0.5);

      tichu_announced = context.add.image(x, y + 100,
          'buttons', 'button_tichu.png').setOrigin(0, 0);
      tichu_announced.setVisible(false);
      tichu_announced.setScale(0.5);

      if (role == PLAYER_ROLE.AFTER) {
        has_ticks_img = context.add.image(x - 0.5 * CARD_WIDTH, y, 'card-backside').setOrigin(0, 0);
      } else {
        has_ticks_img = context.add.image(x + 90, y, 'card-backside').setOrigin(0, 0);
      }
      has_ticks_img.setVisible(false);
      has_ticks_img.setScale(0.5);
       */
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await gameRef.images.load(GameUtils.CARD_BACKSIDE);
    img ??= Sprite(gameRef.images.fromCache(GameUtils.CARD_BACKSIDE));
  }

  void setPlayer(TichuGame game, PlayerModel player) {
    this.player = player;
    // print("Setting Player ${player!.name}");
    setPlayerImage(game);
    addCards(game);

    if (role == PlayerRole.ACTIVE &&
        game.gamePhase == Phase.GAME_STATE_5_PLAY) {
      // (de-)activate play / pass buttons
      game.cardsToBePlayedArea?.setButtonsActive(
          player.personalGameStatus == PlayerStatus.ACTIVE);
    }
  }

  void addCards(TichuGame game) {
    if ( // player!.personalGameStatus != PlayerStatus.DONE &&
    role == PlayerRole.ACTIVE) {
      player!.cards.sort((a, b) => a.rank.compareTo(b.rank));
      Map<String, Card> updateCards = {};

      double x = position.x + 120;
      for (var card in player!.cards) {
        x = max(x, min(game.size.x,
            (cards[card.name]?.position.x ?? 0) + 0.5 * GameUtils.CARD_WIDTH));
        if (player!.phase == Phase.GAME_STATE_5_PLAY) {
          card.isVisible = true;
        }
      }

      for (var cardModel in player!.cards) {
        if (cardModel.isVisible) {
          Card card;
          if (cards.containsKey(cardModel.name)) {
            card = cards[cardModel.name]!;
          } else {
            if (cardModel.x == null || cardModel.x! < 0) {
              cardModel.x = x;
              cardModel.y = position.y;
              x += 0.5 * GameUtils.CARD_WIDTH;
            }
            card = Card(cardModel);
            card.setOwner("avatar");
            card.changePriorityWithoutResorting(10 + min(0, cardModel.rank));
            print("Avatar: adding card " + card.cardModel.name);
            gameRef.add(card);
            // was game.changePriority(c, 10);
          }
          updateCards[cardModel.name] = card;
        }
      }

      cards.forEach((name, card) {
        if (!updateCards.containsKey(name)) {
          print("Avatar: removing card " + card.cardModel.name);
          card.setOwner("avatar-del");
          gameRef.remove(card);
        }
      });

      cards = updateCards;
    }
  }

  void setPlayerImage(TichuGame game) async {
    // print("trying to set Player ${player!.name}");
    final String imageName = 'avatars/' + player!.name.toLowerCase() + '.png';

    try {
      await game.images.load(imageName);
      img = Sprite(game.images.fromCache(imageName));
    } catch (_) {
      int chr = 0;
      for (var i = 0; i < player!.name.length; i++) {
        player!.name.characters.forEach((s) {
          chr += s.hashCode;
        });
      }
      int id = chr % 8 + 1;
      final String imageName = 'avatars/player_$id.png';
      await game.images.load(imageName);
      img = Sprite(game.images.fromCache(imageName));
    }
    // print("Player ${player!.name} set");
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // drawing order: -5;
    img?.renderRect(canvas, avatarRect);

    //       text.depth = 1;
    tp.paint(canvas, textOffset);
  }

  void onTapDown() {
    /*
      if (game.soundButton.isEnabled) {
        Flame.audio.play(
            'sfx/ouch' + (game.rnd.nextInt(11) + 1).toString() + '.ogg');
      }

      if (game.activeView == View.playing) {
        game.score += 1;
        if (game.score > game.getValue('highscore')) {
          game.saveValue('highscore', game.score);
          game.highscoreDisplay.updateHighscore();
        }
      }

     */
  }

  static Map<PlayerRole, Avatar> createAvatars(width, height) {
    Map<PlayerRole, Avatar> avatars = {
      PlayerRole.ACTIVE: Avatar(
          PlayerRole.ACTIVE, Vector2(90.0, height - 128.0)),
      PlayerRole.PARTNER: Avatar(
          PlayerRole.PARTNER, Vector2(width / 2.0, 20.0)),
      PlayerRole.BEFORE: Avatar(
          PlayerRole.BEFORE, Vector2(0, 0.4 * height)),
      PlayerRole.AFTER: Avatar(
          PlayerRole.AFTER, Vector2(width - 115.0, 0.4 * height))
    };

    return avatars;
  }

  @override
  void update(double dt) {
    super.update(dt);

    int numVisibleCards = player?.numVisibleCards() ?? 0;
    String infoText;
    if (player != null && numVisibleCards > 0) {
      infoText = player!.name + ' (' + numVisibleCards.toString() + ')';
    } else {
      infoText = (player?.name ?? '');
    }

    if (numVisibleCards == 14 && gameRef.gamePhase == Phase.GAME_STATE_5_PLAY) {
      gameRef.tichuButton?.isVisible = true;
    } else {
      gameRef.tichuButton?.isVisible = false;
    }

    tp.text = TextSpan(
      text: infoText,
      style: textStyle,
    );
    tp.layout();

    // TODO show play / pass buttons
    // check if it is player's turn and whether current set of cards is valid
/*
      avatar.text.setData('active', player.status === 'player active');
      if (player.status === 'player active') {
        background_color = 0xffcf05;
      } else if (Messaging.game_phase !== GAME_STATE_5_PLAY) {
        background_color = 0xffffff;
      }
      scene.set_player_active(player.status, player.role);
      avatar.has_ticks_img.setVisible(false);

      if (player.status === 'player done') {
        background_color = 0x31c8bc;
        if (player.role === PLAYER_ROLE_ACTIVE || Messaging.game_phase === GAME_STATE_6_END) {
          scene.player_done();
          let orientation = 1;
          if (player.role === PLAYER_ROLE_AFTER) {
            orientation = -1;
          }
          let x = avatar.img.x + orientation * 100;
          const y = avatar.img.y + 25;
          let depth = 0;
          if (player.tricks !== undefined) {
            for (let i = 0; i < player.tricks.length; i++) {
              //console.log(player.cards[i]);
              const data = player.tricks[i];
              const card = scene.children.getByName(data.key);
              const has_value = global_tichuRules.card_has_value(card);
              if (has_value) {
                depth += 1;
                card.depth = depth;
              } else {
                card.depth = -1;
              }
              card.setVisible(has_value);
              if (scene.tweens.isTweening(card)) {
                scene.tweens.killTweensOf(card);
              }
              tween_card(card, x, y, has_value);
              // console.log("Showing card " + card.name + " at (" + x + ", " + y + ")");
              if (has_value) {
                x += orientation * 25;
              }
            }
          }
        }
      } else {
        if (player.tricks !== undefined) {
          avatar.has_ticks_img.setVisible(true);
        }
        if (player.cards !== undefined) {
          //while (avatar.card_images === undefined) {
          //    await sleep(1000);
          //}
          let visible_cards = [];
          for (let i = 0; i < player.cards.length; i++) {
            //console.log(player.cards[i]);
            const card = scene.children.getByName(player.cards[i].name);
            if (!card.visible) {
              card.x = player.cards[i].x;
              card.y = player.cards[i].y;
              card.setVisible(true);
            }
            visible_cards.push(card);
          }
          visible_cards.sort(function(card_a, card_b) {
          return card_a.x - card_b.x;
          })
          let depth = 0;
          for (let i = 0; i < visible_cards.length; i++) {
            depth += 1;
            visible_cards[i].depth = depth;
          }
        }
      }
      if (player.highest_trick_owner !== undefined) {
        background_color = 0xff6400;
      }
      set_text_background_color(scene, avatar, player.role, background_color);
*/
  }


  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    switch (role) {
      case PlayerRole.ACTIVE:
        position.y = gameSize.y - avatarRect.height;
        break;
      case PlayerRole.PARTNER:
        position.x = gameSize.x / 2.0;
        break;
      case PlayerRole.BEFORE:
        position.y = 0.4 * gameSize.y;
        break;
      case PlayerRole.AFTER:
        position.x = gameSize.x - avatarRect.width;
        position.y = 0.4 * gameSize.y;
        break;
    }
  }

  void reset() {
    cards.forEach((_, card) {
      gameRef.remove(card);
    });
    cards.clear();
  }

/*
  void make_blink(txt) {
    const make_blink = txt.getData('active');
    if (make_blink) {
      txt.visible = !txt.visible;
    } else {
      txt.visible = true;
    }
  }

  void set_text_background_color(context, avatar, role, color) {
    if (avatar.text_back !== undefined) {
      avatar.text_back.destroy();
    }
    if (avatar.text !== undefined) {
      create_text_background(context, role, avatar.text.x, avatar.text.y, avatar, color);
    }
  }
*/

/*
  void create_text_background(context, role, text_x_pos, text_y_pos, target, color) {
    // console.log("showing color " + color + "for " + target.name + " at " + text_x_pos + "/ " + text_y_pos)
    let w, h;
    if (role === PLAYER_ROLE_AFTER) {
      text_y_pos = text_y_pos - 0.5 * (target.text.width + 10);
      text_x_pos -= target.text.height;
      w = target.text.height;
      h = target.text.width + 10;
    } else if (role === PLAYER_ROLE_BEFORE) {
      text_y_pos = text_y_pos - 0.5 * (target.text.width + 10);
      //text_x_pos += target.text.height;
      w = target.text.height;
      h = target.text.width + 10;
    } else {
      text_x_pos = text_x_pos - 0.5 * (target.text.width + 10);
      w = target.text.width + 10;
      h = target.text.height;
    }

    target.text_back = context.add.graphics();
    target.text_back.fillStyle(color, 1.0);
    target.text_back.fillRoundedRect(text_x_pos, text_y_pos, w, h, 8);
    target.text_back.setName('text_back_' + role);
    target.text_back.depth = -99;
  }


  void highlight_current_trick_owner(highest_trick_owner) {
    void do_it(avatar, role) {
      let color;
      if (highest_trick_owner != null && highest_trick_owner.name == avatar.name) {
        color = 0xff6400;
      } else {
        color = 0xffffff;
      }
      set_text_background_color(avatar.img.scene, avatar, role, color);
    }

    do_it(game.registry.get(PLAYER_ROLE_ACTIVE), PLAYER_ROLE_ACTIVE);
    do_it(game.registry.get(PLAYER_ROLE_BEFORE), PLAYER_ROLE_BEFORE);
    do_it(game.registry.get(PLAYER_ROLE_AFTER), PLAYER_ROLE_AFTER);
    do_it(game.registry.get(PLAYER_ROLE_PARTNER), PLAYER_ROLE_PARTNER);
  }

  void get_highest_trick_owner_avatar(highest_trick_owner_name) {
    let avatar = game.registry.get(PLAYER_ROLE_ACTIVE);
    if (highest_trick_owner_name === avatar.name) {
      return avatar;
    }
    avatar = game.registry.get(PLAYER_ROLE_BEFORE);
    if (highest_trick_owner_name === avatar.name) {
      return avatar;
    }
    avatar = game.registry.get(PLAYER_ROLE_AFTER);
    if (highest_trick_owner_name === avatar.name) {
      return avatar;
    }
    return game.registry.get(PLAYER_ROLE_PARTNER);
  }
*/

}