import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:tichu/tichu-game.dart';

class ScoreDisplay extends BaseComponent {
  final TichuGame game;
  late TextPainter painter;
  late TextStyle textStyle;
  late Offset position;

  Vector2 coord = Vector2(250, 250);

  ScoreDisplay(this.game) {
    painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
    );

    textStyle = TextStyle(
      color: Color(0xffffffff),
      fontSize: 90,
      shadows: <Shadow>[
        Shadow(
          blurRadius: 7,
          color: Color(0xff000000),
          offset: Offset(3, 3),
        ),
      ],
    );
    position = Offset.zero;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    painter.paint(c, position);
  }

  @override
  void update(double t) {
    super.update(t);
    if ((painter.text?.toPlainText() ?? '') != game.score.toString()) {
      painter.text = TextSpan(
        text: game.score.toString(),
        style: textStyle,
      );

      painter.layout();

      position = Offset(
        coord.x - (painter.width / 2),
        coord.y - (painter.height / 2),
      );
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    coord = Vector2(size.x / 2, size.y * .25);
  }
}