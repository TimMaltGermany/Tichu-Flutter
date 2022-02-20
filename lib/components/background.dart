import 'dart:ui';
import 'package:flame/components.dart';
import 'package:tichu/game-utils.dart';
import 'package:tichu/tichu-game.dart';

class Background extends Component with HasGameRef<TichuGame> {
  Sprite? bgSprite;
  late Rect bgRect;

  Background() {
    bgRect = const Rect.fromLTWH(0, 0, 100, 100);
  }

  @override
  Future<void> onLoad() async {
    await gameRef.images.load(GameUtils.BACKGROUND_IMAGE);
    bgSprite = Sprite(gameRef.images.fromCache(GameUtils.BACKGROUND_IMAGE));
    super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    bgSprite?.renderRect(canvas, bgRect);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    bgRect = Rect.fromLTWH(0, 0, gameSize.x, gameSize.y);
  }
}
