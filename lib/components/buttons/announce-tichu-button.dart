import 'package:flame/components.dart';
import 'package:tichu/enums/announced.dart';
import 'button.dart';

class AnnounceButton extends Button {
   final bool isGrandTichu;

   AnnounceButton(this.isGrandTichu, Vector2 initialPosition, Vector2 initialSrcPosition, Vector2 initialSrcSize):
          super('buttons.png', initialPosition, initialSrcPosition, initialSrcSize);


   @override
   bool onTapDown(_) {
      if (isActivated && isVisible) {
         gameRef.announce(
             this.isGrandTichu ? Announced.GRAND_TICHU : Announced.TICHU);
      }
      return true;
   }
}