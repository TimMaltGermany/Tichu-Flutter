import 'package:flame/components.dart';
import 'package:tichu/enums/announced.dart';
import 'package:tichu/components/buttons/button.dart';

class RemainingCardsButton extends Button {

   RemainingCardsButton(Vector2 position) :
          super('buttons.png', position, Vector2(153, 286), Vector2(146, 75));

   @override
   bool onTapDown(_) {
      if (this.isVisible) {
         gameRef.announce(Announced.NOTHING);
         return true;
      } else {
         return false;
      }
   }
}