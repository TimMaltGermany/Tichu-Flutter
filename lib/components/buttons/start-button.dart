import 'package:flame/components.dart';
import 'package:tichu/enums/commands.dart';
import 'package:tichu/game-utils.dart';
import 'button.dart';

class StartButton extends Button {
   StartButton(Vector2 initialPosition) :
        super('buttons.png', initialPosition, Vector2(1, 209),Vector2(150, 104));

   @override
   bool onTapDown(_) {
      gameRef.dealNewGame();
      return true;
   }
}