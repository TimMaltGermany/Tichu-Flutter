import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:tuple/tuple.dart';

import 'package:tichu/components/card.dart';
import 'package:tichu/components/buttons/schupfen-button.dart';
import 'package:tichu/enums/card-state.dart';
import 'package:tichu/enums/player-role.dart';
import 'package:tichu/game-utils.dart';
import 'package:tichu/tichu-game.dart';

class SchupfenView extends BaseComponent with HasGameRef<TichuGame> {

  final paintBlackRectangle = Paint()
    ..color = Colors.black
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  late Rect schupfenBeforeRect;
  late Rect schupfenAfterRect;
  late Rect schupfenPartnerRect;
  final SchupfenButton buttonSchupfen = SchupfenButton(Vector2(280, 150));

  Card? playerBeforeCard;
  Card? playerAfterCard;
  Card? playerPartnerCard;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    var topLeftX = gameRef.avatars[PlayerRole.BEFORE]!.x +
        2 * GameUtils.CARD_WIDTH * 1.25;
    var topLeftY = gameRef.avatars[PlayerRole.BEFORE]!.y + 10;
    final a = Offset(topLeftX, topLeftY);
    final b = Offset(topLeftX + GameUtils.CARD_WIDTH * 1.1,
        topLeftY + GameUtils.CARD_HEIGHT * 1.1);
    schupfenBeforeRect = Rect.fromPoints(a, b);

    topLeftX = gameRef.avatars[PlayerRole.AFTER]!.x - 2 * GameUtils.CARD_WIDTH * 1.25;
    topLeftY = gameRef.avatars[PlayerRole.AFTER]!.y + 10;
    final a2 = Offset(topLeftX, topLeftY);
    final b2 = Offset(topLeftX + GameUtils.CARD_WIDTH * 1.1,
        topLeftY + GameUtils.CARD_HEIGHT * 1.1);
    schupfenAfterRect = Rect.fromPoints(a2, b2);

    topLeftX = gameRef.avatars[PlayerRole.PARTNER]!.x;
    topLeftY = gameRef.avatars[PlayerRole.PARTNER]!.y + GameUtils.CARD_HEIGHT * 1.25;
    final a3 = Offset(topLeftX, topLeftY);
    final b3 = Offset(topLeftX + GameUtils.CARD_WIDTH * 1.1,
        topLeftY + GameUtils.CARD_HEIGHT * 1.1);
    schupfenPartnerRect = Rect.fromPoints(a3, b3);

    this.buttonSchupfen.position = Vector2(gameRef.size.x - buttonSchupfen.width,
        gameRef.size.y - buttonSchupfen.height);

  }

  @override
  Future<void> onLoad() async {
    // createTablePlayAreaRectangles();
    gameRef.add(buttonSchupfen);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(schupfenBeforeRect, paintBlackRectangle);
    canvas.drawRect(schupfenAfterRect, paintBlackRectangle);
    canvas.drawRect(schupfenPartnerRect, paintBlackRectangle);
  }

  Tuple2<CardState, Offset> determineCardStateFromPosition(Card card,
      CardState currentCardState) {
    Rect cardRect = card.toRect();
    Tuple2<CardState, Offset> returnValue = Tuple2(CardState.ON_HAND, new Offset(0, 0));

    // reset previous drop, if any
    if (card == playerAfterCard) {
      playerAfterCard = null;
    }
    if (card == playerBeforeCard) {
      playerBeforeCard = null;
    }
    if (card == playerPartnerCard) {
      playerPartnerCard = null;
    }

    var intersectRect = schupfenPartnerRect.intersect(cardRect);
    if (intersectRect.width > 0 && intersectRect.height > 0) {
      if (playerPartnerCard == null) {
        playerPartnerCard = card;
        returnValue = Tuple2(
            CardState.ON_SCHUPF_AREA_PARTNER, schupfenPartnerRect.topLeft);
      }
    } else {
      intersectRect = schupfenBeforeRect.intersect(cardRect);
      if (intersectRect.width > 0 && intersectRect.height > 0) {
        if (playerBeforeCard == null) {
          playerBeforeCard = card;
          returnValue = Tuple2(
              CardState.ON_SCHUPF_AREA_BEFORE, schupfenBeforeRect.topLeft);
        }
      } else {
        intersectRect = schupfenAfterRect.intersect(cardRect);
        if (intersectRect.width > 0 && intersectRect.height > 0) {
          if (playerAfterCard == null) {
            playerAfterCard = card;
            returnValue = Tuple2(
                CardState.ON_SCHUPF_AREA_AFTER, schupfenAfterRect.topLeft);
          }
        }
      }
    }

    // show / hide button
    if (playerPartnerCard != null && playerAfterCard != null && playerBeforeCard != null) {
      buttonSchupfen.isVisible = true;
    } else {
      buttonSchupfen.isVisible = false;
    }

    return returnValue;
  }

  @override
  void remove() {
    super.remove();
    buttonSchupfen.isVisible = false;
    playerPartnerCard = null;
    playerAfterCard = null;
    playerBeforeCard = null;
  }
}