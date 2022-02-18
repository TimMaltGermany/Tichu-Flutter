import 'package:flame/components.dart';
import 'button.dart';

class PlayButton extends Button {

   PlayButton(Vector2 position, Vector2 srcPosition) :
          super('buttons.png', position, srcPosition, Vector2(150, 75), isVisibleSetting : false);

   @override
   bool onTapDown(_) {
      if (this.isVisible) {
         gameRef.cardsPlay();
         this.isVisible = false;
         return true;
      } else {
         return false;
      }
   }
}