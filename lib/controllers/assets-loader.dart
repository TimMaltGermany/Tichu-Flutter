

import 'package:flame/flame.dart';

import '../game-utils.dart';

class AssetsLoader {

  static loadImages() {
    Flame.images.loadAll([GameUtils.BACKGROUND_IMAGE]);
  }
}