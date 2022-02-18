import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:tichu/game-utils.dart';
import 'package:tichu/tichu-game.dart';

class Background extends BaseComponent with HasGameRef<TichuGame> {
  Sprite? bgSprite;
  late Rect bgRect;

  Background() {
    bgRect = Rect.fromLTWH(0, 0, 100, 100);
  }

  @override
  Future<void> onLoad() async {
    await gameRef.images.load(GameUtils.BACKGROUND_IMAGE);
    bgSprite = Sprite(gameRef.images.fromCache(GameUtils.BACKGROUND_IMAGE));
  }

  @override
  void render(Canvas c) {
    super.render(c);
    bgSprite?.renderRect(c, bgRect);
  }

  @override
  void update(double t) {
    super.update(t);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    bgRect = Rect.fromLTWH(0, 0, gameSize.x, gameSize.y);
  }
}
