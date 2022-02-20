import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flame/sprite.dart';

import '../../tichu-game.dart';

class Button extends PositionComponent with Tappable, HasGameRef<TichuGame> {
  Sprite? sprite;
  final String imagePath;

  final Vector2 srcPosition;
  final Vector2 srcSize;
  bool isVisible = true;
  bool isActivated = true;

  Button(this.imagePath, Vector2 position, this.srcPosition, this.srcSize,
      {bool isVisibleSetting = true})
      : isVisible = isVisibleSetting,
        super(
          position: position,
          size: srcSize,
          priority: 99,
        );

  @override
  Future<void> onLoad() async {
    await gameRef.images.load(imagePath);
    sprite = Sprite(gameRef.images.fromCache(imagePath),
        srcPosition: srcPosition, srcSize: srcSize);
    super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isVisible) {
      sprite?.renderRect(canvas, size.toRect());
    }
  }

  @override
  bool onTapUp(info) {
    return true;
  }

  @override
  bool onTapDown(info) {
    return true;
  }

  @override
  bool onTapCancel() {
    return true;
  }
}
