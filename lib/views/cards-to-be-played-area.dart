

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:tichu/components/buttons/pass-button.dart';
import 'package:tichu/components/buttons/play-button.dart';
import 'package:tichu/components/buttons/button.dart';
import 'package:tichu/components/card.dart';
import 'package:tichu/controllers/tichu-rules.dart';
import 'package:tichu/enums/card-state.dart';
import 'package:tichu/game-utils.dart';
import 'package:tichu/models/card-model.dart';
import 'package:tuple/tuple.dart';

import '../tichu-game.dart';

class CardsToBePlayedArea extends BaseComponent with HasGameRef<TichuGame> {

  final paintBlackRectangle = Paint()
    ..color = Colors.black
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  final paintRedRectangle = Paint()
    ..color = Colors.red
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  late Rect cardsToBePlayedRect;
  Rect intersectionRect = Rect.fromLTWH(0,0,0,0);

  final Button buttonPlay = PlayButton(Vector2(400, 78), Vector2(305, 78));
  final Button buttonPass = PassButton(Vector2(400,209));
  final Button buttonBomb = PlayButton(Vector2(400,300), Vector2(1, 1));

  final Map<String, Card> cardsInPlayArea = new Map();

  bool currentSetOfCardsIsValid = false;
  bool showButtons = false;

  void createTablePlayAreaRectangles() async {
    final tl = Offset(0.25 * gameRef.size.x, 0.5 * gameRef.size.y);
    final br = Offset(0.75 * gameRef.size.x, 0.5 * gameRef.size.y + GameUtils.CARD_HEIGHT);
    cardsToBePlayedRect = Rect.fromPoints(tl, br);
    final brHalf = Offset(0.75 * gameRef.size.x, 0.5 * gameRef.size.y + 0.5 * GameUtils.CARD_HEIGHT);
    intersectionRect = Rect.fromPoints(tl, brHalf);
  }

  @override
  Future<void> onLoad() async {
    createTablePlayAreaRectangles();
    buttonPlay.position = Vector2(gameRef.size.x - 160, gameRef.size.y - 3 * 70);
    buttonPass.position = Vector2(gameRef.size.x - 160, gameRef.size.y - 2 * 70);
    buttonBomb.position = Vector2(gameRef.size.x - 160, gameRef.size.y - 4 * 70);

    gameRef.add(buttonPlay);
    gameRef.add(buttonPass);
    gameRef.add(buttonBomb);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (currentSetOfCardsIsValid || cardsInPlayArea.isEmpty) {
      canvas.drawRect(cardsToBePlayedRect, paintBlackRectangle);
    } else {
      canvas.drawRect(cardsToBePlayedRect, paintRedRectangle);
    }
  }

  @override
  void update(double t) {
    super.update(t);
    buttonPass.isVisible = showButtons && gameRef.tichuRules.isPassAllowed();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    createTablePlayAreaRectangles();
  }

  Tuple2<CardState, Offset> determineCardStateFromPosition(Card card,
      CardState currentCardState) {
    Tuple2<CardState, Offset> res;

    if (currentCardState != CardState.ON_HAND) {
      return Tuple2(currentCardState, new Offset(0, 0));
    }

    Rect cardRect = card.toRect();
    var intersectRect = intersectionRect.intersect(cardRect);
    if (intersectRect.width > 0 && intersectRect.height > 0) {
      cardsInPlayArea[card.cardModel.name] = card;
      res = Tuple2(
          CardState.ON_TABLE_TO_BE_PLAYED,
          Offset(card.position.x, intersectionRect.topLeft.dy));
    } else {
      cardsInPlayArea.remove(card.cardModel.name);
      res = Tuple2(currentCardState, new Offset(0, 0));
    }
    buttonPlay.isVisible = showButtons && isValidSet(cardsInPlayArea);
    return res;
  }

  void setButtonsActive(bool setActive) {
    this.showButtons = setActive;
  }

  bool isValidSet(Map<String, Card> cardsInPlayArea) {
    List<CardModel> cards = List.from(cardsInPlayArea.map((key, value) => MapEntry(key, value.cardModel)).values);
    this.currentSetOfCardsIsValid =  gameRef.tichuRules.isValidAndHigherSet(cards);
    if (currentSetOfCardsIsValid && gameRef.tichuRules.isValidAnHigherBomb(cards)) {
      buttonBomb.isVisible = true;
    } else {
      buttonBomb.isVisible = false;
    }
    return currentSetOfCardsIsValid;
  }

  @override
  void remove() {
    super.remove();
    setButtonsActive(false);
    buttonPlay.isVisible = false;
    buttonPass.isVisible = false;
    cardsInPlayArea.clear();
  }
}