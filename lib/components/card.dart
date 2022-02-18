import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/gestures.dart';
import 'package:tuple/tuple.dart';
import 'package:tichu/models/card-model.dart';
import 'package:tichu/enums/card-state.dart';

import 'package:tichu/game-utils.dart';
import 'package:tichu/tichu-game.dart';

class Card extends PositionComponent with Draggable, HasGameRef<TichuGame> {

  final CardModel cardModel;

  Vector2? dragDeltaPosition;
  bool get isDragging => dragDeltaPosition != null;

  Card(this.cardModel) {
    position = Vector2(cardModel.x, cardModel.y);
    size = Vector2(GameUtils.CARD_WIDTH, GameUtils.CARD_HEIGHT);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    Sprite? cardSprite = gameRef.spriteMap[cardModel.name];
    cardSprite?.renderRect(c,
        Rect.fromLTWH(0, 0, GameUtils.CARD_WIDTH, GameUtils.CARD_HEIGHT));
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    dragDeltaPosition = info.eventPosition.global - position;
    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    final localCoords = info.eventPosition.global;
    position = localCoords - dragDeltaPosition!;
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    dragDeltaPosition = null;
    Tuple2<CardState, Offset> stateOffset = gameRef.determineCardStateFromPosition(this,cardModel.state);
    if (stateOffset.item2.dx != 0) {
      position = new Vector2(stateOffset.item2.dx, stateOffset.item2.dy);
      cardModel.x = position.x;
      cardModel.y = position.y;
    }
    return false;
  }

  @override
  bool onDragCancel(int pointerId) {
    dragDeltaPosition = null;
    return false;
  }
}

