import 'package:flame/components.dart';
import 'button.dart';

class PassButton extends Button {

   PassButton(Vector2 position) :
          super('buttons.png', position, Vector2(153,209), Vector2(150, 75), isVisibleSetting : false);

   @override
   bool onTapDown(_) {
      if (this.isVisible) {
         gameRef.playerPassed();
         this.isVisible = false;
         return true;
      } else {
         return false;
      }
   }
}