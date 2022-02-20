import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Image, Card;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:tuple/tuple.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:tichu/views/cards_to_be_played_area.dart';
import 'package:tichu/views/schupfen_view.dart';
import 'package:tichu/components/buttons/announce-tichu-button.dart';
import 'package:tichu/components/background.dart';
import 'package:tichu/enums/announced.dart';
import 'package:tichu/enums/colors.dart';
import 'package:tichu/enums/commands.dart';
import 'package:tichu/enums/phases.dart';
import 'package:tichu/enums/rank.dart';
import 'package:tichu/views/home-view.dart';
import 'package:tichu/components/buttons/start-button.dart';
import 'package:tichu/views/lost-view.dart';
import 'package:tichu/components/buttons/credits-button.dart';
import 'package:tichu/components/buttons/help-button.dart';
import 'package:tichu/views/help-view.dart';
import 'package:tichu/views/credits-view.dart';
import 'package:tichu/components/score-display.dart';
import 'package:tichu/components/avatar.dart';
import 'package:tichu/components/table_view.dart';
import 'package:tichu/components/card.dart';
import 'package:tichu/components/buttons/music-button.dart';
import 'package:tichu/components/buttons/remaining-cards-button.dart';
import 'package:tichu/components/buttons/sound-button.dart';
import 'package:tichu/enums/card-state.dart';
import 'package:tichu/enums/player-role.dart';
import 'package:tichu/game-utils.dart';

import 'controllers/tichu-rules.dart';

class TichuGame extends FlameGame with HasTappables, HasDraggables {

  late Size screenSize;
  late double tileSize;
  final Background background = Background();

  int score = 0;
  ScoreDisplay? scoreDisplay;

  late HomeView homeView;
  late LostView lostView;
  late HelpView helpView;
  late CreditsView creditsView;

  final StartButton startButton = StartButton(Vector2(10, 10));
  AnnounceButton? grandTichuButton;
  AnnounceButton? tichuButton;
  RemainingCardsButton? remainingCardsButton;

  SchupfenView? schupfenView;
  CardsToBePlayedArea? cardsToBePlayedArea;
  TableView? tableView;

  late HelpButton helpButton;
  late CreditsButton creditsButton;
  late MusicButton musicButton;
  late SoundButton soundButton;

  late AudioPlayer homeBGM;
  late AudioPlayer playingBGM;
  late SharedPreferences prefs;
  final Map<PlayerRole, Avatar> avatars = {};
  final Map<String, Sprite> spriteMap = {};

  final WebSocketChannel socket;

  Phase _gamePhase = Phase.GAME_STATE_REGISTER;

  final TichuRules tichuRules = TichuRules();

  TichuGame(this.socket);

  addAvatar(PlayerRole role, Avatar avatar) {
    avatars.putIfAbsent(role, () => avatar);
  }

  Phase get gamePhase => _gamePhase;

  set gamePhase(Phase gamePhase) {
    if (_gamePhase != gamePhase) {
      _gamePhase = gamePhase;
      if (gamePhase != Phase.GAME_STATE_REGISTER) {
        remove(background); // WAS background.remove();
      }
      if (gamePhase == Phase.GAME_STATE_2_GRAND_TICHU) {
        initGrandTichuPhaseButtons();
      }
      if (gamePhase == Phase.GAME_STATE_3_SCHUPFEN) {
        if (avatars[PlayerRole.ACTIVE]?.player?.announced ==
            Announced.NOTHING) {
          tichuButton = AnnounceButton(
              false, Vector2(150, 150), Vector2(305, 155), Vector2(150, 75));
          tichuButton!.position = Vector2(0, size.y - tichuButton!.height);
          add(tichuButton!);
        }
        schupfenView = SchupfenView();
        add(schupfenView!);
      }
      if (gamePhase == Phase.GAME_STATE_5_PLAY) {
        if (schupfenView != null) {
          remove(schupfenView!);
        }
        cardsToBePlayedArea = CardsToBePlayedArea();
        add(cardsToBePlayedArea!);
        tableView = TableView();
        add(tableView!);
      }
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    prefs = await SharedPreferences.getInstance();

    await images.load('buttons.png');
    await images.load('cards.png');

    await Flame.device.setLandscape();

    background.changePriorityWithoutResorting(-99);
    // WAS this.changePriority(background, -99);

    scoreDisplay = ScoreDisplay(this);

    avatars.forEach((_, avatar) {
      avatar.changePriorityWithoutResorting(1);
      // WAS this.changePriority(avatar, 1);
    });

    loadCards();

    await Flame.device.fullScreen();

    await addAll([background, startButton, scoreDisplay!] + avatars.values.toList(growable: false));

/*

    PhaseGame.score_popup = this.add_popup('', PhaseGame.score_text, PhaseGame.score_text.x, PhaseGame.score_text.y, 20);


    const spaceKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE);
    // const soundKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.S);
    // var bark = this.sound.add('bark');

    //  Emits only when the SPACE BAR is pressed down, and dispatches from the local Key object.
    //  Call stopImmediatePropagation to stop it reaching the two global handlers in this Scene.
    //  Call stopPropagation to stop it reaching any other Scene.
    spaceKey.on('down', function(key, event) {

        // event.stopPropagation();
        // event.stopImmediatePropagation();
        PhaseGame.playButtonAlwaysOn = !PhaseGame.playButtonAlwaysOn;
        });

    //soundKey.on('down', function(key, event) {
    //	bark.play();
    //});
*/

  }

  @override
  Color backgroundColor() => GameUtils.BACKGROUND_COLOR;

  @override
  void onGameResize(Vector2 canvasSize) {
    bool isResized = hasLayout && canvasSize != size;
    super.onGameResize(canvasSize);
    if (isResized) {
      forceResize(canvasSize);
    }

    remainingCardsButton?.position = Vector2(0.5 * canvasSize.x, canvasSize.y - 220);
    grandTichuButton?.position = Vector2(0, canvasSize.y - grandTichuButton!.height);
    tichuButton?.position = Vector2(0, canvasSize.y - tichuButton!.height);
    //  this.addButton({ name: 'button_bombe.png', x: SCREEN_WIDTH - 150, y: SCREEN_HEIGHT - 150 });
    //  this.addButton({ name: 'button_nein.png', x: SCREEN_WIDTH / 2 + 150, y: SCREEN_HEIGHT / 2 });
    //  this.addButton({ name: 'button_ja.png', x: SCREEN_WIDTH / 2 - 150, y: SCREEN_HEIGHT / 2 });
  }

  void forceResize(Vector2 size) {
    background.onGameResize(size);
    avatars.forEach((_, avatar) { avatar.onGameResize(size);});
    cardsToBePlayedArea?.onGameResize(size);
    schupfenView?.onGameResize(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_gamePhase != Phase.GAME_STATE_NEW &&
        _gamePhase != Phase.GAME_STATE_REGISTER) {
      scoreDisplay?.update(dt);
    }

  }

  /*
  @override
  //void onTapDown(TapDownDetails details) {
  void onTapDown(TapDownInfo details) {
    bool isHandled = false;

    /*
    if (!isHandled) {
      if (activeView == View.help || activeView == View.credits) {
        activeView = View.home;
        isHandled = true;
      }
    }
*/
/*
    if (!isHandled && startButton.rect.contains(details.eventPosition.global)) {
      if (this._gamePhase == Phases.GAME_STATE_NEW || this._gamePhase == Phases.GAME_STATE_6_END) {
        startButton.onTapDown();
        isHandled = true;
      }
    }

 */
    /*
    // help button
    if (!isHandled && helpButton.rect.contains(details.globalPosition)) {
      if (_gamePhase == View.home || _gamePhase == View.lost) {
        helpButton.onTapDown();
        isHandled = true;
      }
    }
*/
/*
    // credits button
    if (!isHandled && creditsButton.rect.contains(details.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        creditsButton.onTapDown();
        isHandled = true;
      }
    }

    // music button
    if (!isHandled && musicButton.rect.contains(details.globalPosition)) {
      musicButton.onTapDown();
      isHandled = true;
    }

    // sound button
    if (!isHandled && soundButton.rect.contains(details.globalPosition)) {
      soundButton.onTapDown();
      isHandled = true;
    }
*/

    if (!isHandled) {
      bool didHitAFly = false;
      /*
      flies.forEach((Fly fly) {
        if (fly.flyRect.contains(details.globalPosition)) {
          fly.onTapDown();
          didHitAFly = true;
          isHandled = true;
        }
      });
      if (activeView == View.playing && !didHitAFly) {
        if (soundButton.isEnabled) {
          Flame.audio.play(
              'sfx/haha' + (rnd.nextInt(5) + 1).toString() + '.ogg');
        }
        playHomeBGM();
        activeView = View.lost;
      }

       */
    }
  }
*/

  Tuple2<CardState, Offset> determineCardStateFromPosition(Card card,
      CardState currentCardState) {
    if (_gamePhase == Phase.GAME_STATE_3_SCHUPFEN) {
      return schupfenView!.determineCardStateFromPosition(
          card, currentCardState);
    }
    if (_gamePhase == Phase.GAME_STATE_5_PLAY) {
      return cardsToBePlayedArea!.determineCardStateFromPosition(
          card, currentCardState);
    }
    return Tuple2(currentCardState, const Offset(0, 0));
  }


saveValue(String key, int value) {
    prefs.setInt(key, value);
  }

  int getValue(key) {
    return prefs.getInt(key) ?? 0;
  }

  void playHomeBGM() {
    playingBGM.pause();
    playingBGM.seek(Duration.zero);
    homeBGM.resume();
  }

  void playPlayingBGM() {
    homeBGM.pause();
    homeBGM.seek(Duration.zero);
    playingBGM.resume();
  }

  void announce(Announced announcement) {
    if (announcement == Announced.TICHU) {
      tichuButton!.isActivated = false;
      tichuButton!.size = tichuButton!.size / 3;
      tichuButton!.position = Vector2((
          avatars[PlayerRole.ACTIVE]?.x ?? 0 ) + 5,
          size.y - tichuButton!.size.y);
    } else if (announcement == Announced.GRAND_TICHU) {
      // resize and move button
      grandTichuButton!.isActivated = false;
      grandTichuButton!.size = grandTichuButton!.size / 3;
      grandTichuButton!.position = Vector2((
          avatars[PlayerRole.ACTIVE]?.x ?? 0 ) + 5,
          size.y - grandTichuButton!.size.y);
      remove(remainingCardsButton!);
    } else {
      if (tichuButton != null) remove(tichuButton!);
      if (grandTichuButton != null) remove(grandTichuButton!);
      if (remainingCardsButton != null) remove(remainingCardsButton!);
    }
    sendMessage(socket, Commands.ANNOUNCE, {'value': announcement.toString()});
  }

  void loadCards() {
    int x = 0;
    double y = GameUtils.CARD_HEIGHT;

    Image image = images.fromCache('cards.png');

    spriteMap["PHOENIX"] = Sprite(image,
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(GameUtils.CARD_WIDTH, GameUtils.CARD_HEIGHT));
    spriteMap["MAHJONG"] = Sprite(image,
        srcPosition: Vector2(63, 0),
        srcSize: Vector2(GameUtils.CARD_WIDTH, GameUtils.CARD_HEIGHT));
    spriteMap["DRAKE"] = Sprite(image,
        srcPosition: Vector2(126, 0),
        srcSize: Vector2(GameUtils.CARD_WIDTH, GameUtils.CARD_HEIGHT));
    spriteMap["DOGS"] = Sprite(image,
        srcPosition: Vector2(189, 0),
        srcSize: Vector2(GameUtils.CARD_WIDTH, GameUtils.CARD_HEIGHT));

    // four cards in a row
    COLORS.forEach((color) => {
      NormalCardRanks.forEach((ix, rank) =>
      {
        if (color == "BLACK" && rank == "King") {
          // unfortunately, there is one empty space in the sprite tile image
          x = 0,
          y += GameUtils.CARD_HEIGHT
        },
        spriteMap[color + '_' + ix.toString()] = Sprite(image,
            srcPosition: Vector2(x * GameUtils.CARD_WIDTH, y),
            srcSize: Vector2(GameUtils.CARD_WIDTH, GameUtils.CARD_HEIGHT)),
        //print("card : $color $rank at position ${x*GameUtils.CARD_WIDTH},$y"),
        x += 1,
        if (x > 3) {
          x = 0,
          y += GameUtils.CARD_HEIGHT
        }
      })
    });
  }

  /*
  @override
  void onPanUpdate(DragUpdateDetails details) {
  // bool onDragEnd(int pointerId, DragEndInfo info) {
    super.onPanUpdate(details);
    // return false;
  }
*/

  void cardsSchupfen() {

    int seat = avatars[PlayerRole.ACTIVE]?.player?.seat ?? -1;
    sendMessage(socket, Commands.SCHUPFEN_FINISHED, {'cards': [
      {
        'seat': determineSeatFromRole(PlayerRole.BEFORE, seat),
        'card': schupfenView?.playerBeforeCard!.cardModel.name,
        'x': schupfenView?.playerBeforeCard!.cardModel.x,
        'y':schupfenView?.playerBeforeCard!.cardModel.y
      },
      {
        'seat': determineSeatFromRole(PlayerRole.AFTER, seat),
        'card': schupfenView?.playerAfterCard!.cardModel.name,
        'x': schupfenView?.playerAfterCard!.cardModel.x,
        'y':schupfenView?.playerAfterCard!.cardModel.y
      },
      {
        'seat': determineSeatFromRole(PlayerRole.PARTNER, seat),
        'card': schupfenView?.playerPartnerCard!.cardModel.name,
        'x': schupfenView?.playerPartnerCard!.cardModel.x,
        'y':schupfenView?.playerPartnerCard!.cardModel.y
      }
    ]
    });
    if (schupfenView != null) {
      remove(schupfenView!);
    }
  }

  void cardsPlay() {

    if (cardsToBePlayedArea != null) {
      List<String> cardNames = cardsToBePlayedArea!.getAndClearCards();
      sendMessage(socket, Commands.TURN_FINISHED, {'cards': cardNames});
    }
  }

  void playerPassed() {
    sendMessage(socket, Commands.TURN_FINISHED, {'cards': []});
  }

  void dealNewGame() {
    // TODO - ask for confirmation if game is not in new state

    _gamePhase = Phase.GAME_STATE_NEW;
    tichuRules.setCurrentHighestPlay([]);
    if (grandTichuButton != null) {
      remove(grandTichuButton!);
    }
    if (tichuButton != null) {
      remove(tichuButton!);
    }
    if (remainingCardsButton != null) {
      remove(remainingCardsButton!);
    }
    if (schupfenView != null) {
      remove(schupfenView!);
    }
    if (cardsToBePlayedArea != null) {
      remove(cardsToBePlayedArea!);
    }

    // do not remove avatars, only reset
    avatars.forEach((_, avatar) { avatar.reset();});

    if (tableView != null) {
      tableView!.reset();
      remove(tableView!);
    }

    sendMessage(socket, Commands.DEAL, {});

    //this.remove();
    //game.playPlayingBGM();
  }

  void initGrandTichuPhaseButtons() {
    grandTichuButton = AnnounceButton(true, Vector2(150, 150), Vector2(153, 1), Vector2(150, 105));
    add(grandTichuButton!);
    grandTichuButton!.position = Vector2(0, size.y - grandTichuButton!.height);
    grandTichuButton!.isActivated = true;
    grandTichuButton!.isVisible = true;

    remainingCardsButton = RemainingCardsButton(Vector2(280, 150));
    add(remainingCardsButton!);
    remainingCardsButton!.position = Vector2(0.5 * size.x, size.y - 220);
    remainingCardsButton!.isActivated = true;
    remainingCardsButton!.isVisible = true;
  }
}