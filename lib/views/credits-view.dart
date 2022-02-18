import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:tichu/tichu-game.dart';

class CreditsView extends BaseComponent{
  final TichuGame game;
  late Rect rect;
  late Sprite sprite;

  CreditsView(this.game) {
    rect = Rect.fromLTWH(
      game.tileSize * .5,
      (game.screenSize.height / 2) - (game.tileSize * 6),
      game.tileSize * 8,
      game.tileSize * 12,
    );
  }

  @override
  Future<void> onLoad() async {
    await game.images.load('ui/dialog-credits.png');
    sprite = Sprite(game.images.fromCache('ui/dialog-credits.png'));
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }
}