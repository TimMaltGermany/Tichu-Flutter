import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:tichu/tichu-game.dart';

class HighscoreDisplay {
  final TichuGame game;
  late TextPainter painter;
  late TextStyle textStyle;
  late Offset position;

  HighscoreDisplay(this.game) {
    painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    Shadow shadow = Shadow(
      blurRadius: 3,
      color: Color(0xff000000),
      offset: Offset.zero,
    );

    textStyle = TextStyle(
      color: Color(0xffffffff),
      fontSize: 30,
      shadows: [shadow, shadow, shadow, shadow],
    );

    position = Offset.zero;

    updateHighscore();
  }

  void render(Canvas c) {
    painter.paint(c, position);
  }

  void updateHighscore() {
    int highscore = game.getValue('highscore');

    painter.text = TextSpan(
      text: 'High-score: ' + highscore.toString(),
      style: textStyle,
    );

    painter.layout();

    position = Offset(
      game.screenSize.width - (game.tileSize * .25) - painter.width,
      game.tileSize * .25,
    );
  }
}