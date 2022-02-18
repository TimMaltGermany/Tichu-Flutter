import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:tichu/tichu-game.dart';
import 'package:tichu/view.dart';

class CreditsButton extends BaseComponent {
  final TichuGame game;
  late Rect rect;
  late Sprite sprite;

  CreditsButton(this.game) {
    rect = Rect.fromLTWH(
      game.screenSize.width - (game.tileSize * 1.25),
      game.screenSize.height - (game.tileSize * 1.25),
      game.tileSize,
      game.tileSize,
    );
  }

  @override
  Future<void> onLoad() async {
    await game.images.load('ui/icon-credits.png');
    sprite = Sprite(game.images.fromCache('ui/icon-credits.png'));
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {
    // game.activeView = View.credits;
    // TODO - show credits
  }
}