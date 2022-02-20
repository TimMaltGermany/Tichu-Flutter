import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:tichu/tichu-game.dart';

class MusicButton extends Component {
  final TichuGame game;
  late Rect rect;
  late Sprite enabledSprite;
  late Sprite disabledSprite;
  bool isEnabled = true;

  MusicButton(this.game) {
    rect = Rect.fromLTWH(
      game.tileSize * .25,
      game.tileSize * .25,
      game.tileSize,
      game.tileSize,
    );
  }

  @override
  Future<void> onLoad() async {
    await game.images.load('ui/icon-music-enabled.png');
    await game.images.load('ui/icon-music-disabled.png');
    enabledSprite = Sprite(game.images.fromCache('ui/icon-music-enabled.png'));
    disabledSprite = Sprite(game.images.fromCache('ui/icon-music-disabled.png'));
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (isEnabled) {
      enabledSprite.renderRect(c, rect);
    } else {
      disabledSprite.renderRect(c, rect);
    }
  }

  void onTapDown() {
    if (isEnabled) {
      isEnabled = false;
      game.homeBGM.setVolume(0);
      game.playingBGM.setVolume(0);
    } else {
      isEnabled = true;
      game.homeBGM.setVolume(.25);
      game.playingBGM.setVolume(.25);
    }
  }
}