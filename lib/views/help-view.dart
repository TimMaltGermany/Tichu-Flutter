import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:tichu/tichu-game.dart';

class HelpView extends BaseComponent {
  final TichuGame game;
  late Rect rect;
  late Sprite sprite;

  HelpView(this.game) {
    rect = Rect.fromLTWH(
      game.tileSize * .5,
      (game.screenSize.height / 2) - (game.tileSize * 6),
      game.tileSize * 8,
      game.tileSize * 12,
    );

  }

  @override
  Future<void> onLoad() async {
    await game.images.load('ui/dialog-help.png');
    sprite = Sprite(game.images.fromCache('ui/dialog-help.png'));
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }
}