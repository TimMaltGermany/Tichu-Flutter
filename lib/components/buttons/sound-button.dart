import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:tichu/tichu-game.dart';

class SoundButton extends BaseComponent {
  final TichuGame game;
  late Rect rect;
  late Sprite enabledSprite;
  late Sprite disabledSprite;
  bool isEnabled = true;

  SoundButton(this.game) {
    rect = Rect.fromLTWH(
      game.tileSize * 1.5,
      game.tileSize * .25,
      game.tileSize,
      game.tileSize,
    );
  }

  @override
  Future<void> onLoad() async {
    await game.images.load('ui/icon-sound-enabled.png');
    await game.images.load('ui/icon-sound-disabled.png');
    enabledSprite = Sprite(game.images.fromCache('ui/icon-sound-enabled.png'));
    disabledSprite = Sprite(game.images.fromCache('ui/icon-sound-disabled.png'));
  }


  void render(Canvas c) {
    if (isEnabled) {
      enabledSprite.renderRect(c, rect);
    } else {
      disabledSprite.renderRect(c, rect);
    }
  }

  void onTapDown() {
    isEnabled = !isEnabled;
  }
}