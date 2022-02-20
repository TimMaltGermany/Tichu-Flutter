import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:tichu/tichu-game.dart';

class HomeView extends Component {
  final TichuGame game;
  late Rect titleRect;
  late Sprite titleSprite;

  HomeView(this.game) {
    titleRect = Rect.fromLTWH(
      game.tileSize,
      (game.screenSize.height / 2) - (game.tileSize * 4),
      game.tileSize * 7,
      game.tileSize * 4,
    );
  }

  @override
  Future<void> onLoad() async {
    await game.images.load('branding/title.png');
    titleSprite = Sprite(game.images.fromCache('branding/title.png'));
  }

  void render(Canvas c) {
    titleSprite.renderRect(c, titleRect);
  }

  void update(double t) {}
}