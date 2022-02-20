import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:tichu/tichu-game.dart';

class LostView extends Component {
  final TichuGame game;
  late Rect rect;
  late Sprite sprite;

  LostView(this.game) {
    rect = Rect.fromLTWH(
      game.tileSize,
      (game.screenSize.height / 2) - (game.tileSize * 5),
      game.tileSize * 7,
      game.tileSize * 5,
    );
  }

  @override
  Future<void> onLoad() async {
    await game.images.load('bg/lose-splash.png');
    sprite = Sprite(game.images.fromCache('bg/lose-splash.png'));
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void update(double t) {}
}