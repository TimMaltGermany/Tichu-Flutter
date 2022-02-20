import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:tuple/tuple.dart';
import 'package:tichu/models/card_model.dart';
import 'package:tichu/enums/card-state.dart';

import 'package:tichu/game-utils.dart';
import 'package:tichu/tichu-game.dart';

class Card extends PositionComponent with Draggable, HasGameRef<TichuGame> {
  final CardModel cardModel;

  Vector2? dragDeltaPosition;

  bool get isDragging => dragDeltaPosition != null;

  String? owner;

  Card(this.cardModel) {
    position = Vector2(cardModel.x!.toDouble(), cardModel.y!.toDouble());
    size = Vector2(GameUtils.CARD_WIDTH, GameUtils.CARD_HEIGHT);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    try {
      if (cardModel.isVisible) {
        Sprite? cardSprite = gameRef.spriteMap[cardModel.name];
        cardSprite?.renderRect(canvas,
            const Rect.fromLTWH(
                0, 0, GameUtils.CARD_WIDTH, GameUtils.CARD_HEIGHT));
      }
    } on Exception catch (_, e) {
      print("render error for " + cardModel.name);
    } on StateError catch (_, e) {
      print("render error for " + cardModel.name);
    }
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    dragDeltaPosition = info.eventPosition.global - position;
    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    final localCoordinates = info.eventPosition.global;
    position = localCoordinates - dragDeltaPosition!;
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    dragDeltaPosition = null;
    Tuple2<CardState, Offset> stateOffset =
        gameRef.determineCardStateFromPosition(this, cardModel.state);
    if (stateOffset.item2.dx != 0) {
      position = Vector2(stateOffset.item2.dx, stateOffset.item2.dy);
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

  @override
  void onRemove() {
    super.onRemove();
  }

  @override
  Future<void> add(Component component) {
    return super.add(component);
  }

  void setOwner(String s) {
    owner = s;
  }

}
