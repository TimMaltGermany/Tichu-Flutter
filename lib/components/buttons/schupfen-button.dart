import 'package:flame/components.dart';
import 'button.dart';

class SchupfenButton extends Button {

   SchupfenButton(Vector2 position) :
          super('buttons.png', position, Vector2(305, 1), Vector2(150, 75), isVisibleSetting : false);

   @override
   bool onTapDown(_) {
      if (isVisible) {
         gameRef.cardsSchupfen();
         parent?.remove(this);
      }
      return true;
   }
}