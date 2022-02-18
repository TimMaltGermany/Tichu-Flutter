import 'package:flame/components.dart';

import 'package:tichu/enums/phases.dart';
import 'package:tichu/models/table-model.dart';
import 'package:tichu/tichu-game.dart';

import 'package:tichu/game-utils.dart';
import 'card.dart';


class TableView extends BaseComponent with HasGameRef<TichuGame> {
  TableModel? tableModel;

  Map<String, Card> cards = new Map();

  TableView() {}

  @override
  Future<void> onLoad() async {
  }

  void addCards(TichuGame game, TableModel model) {
    if (game.gamePhase == Phase.GAME_STATE_5_PLAY) {

      this.tableModel = model;
      print("Table model has '${tableModel?.cards.length}' number of tricks");
      Map<String, Card> updateCards = new Map();

      double x = 120;
      double y = 110;

      cards.forEach((name, card) {
          card.remove();
      });

      tableModel!.cards.forEach((trick) {
        double row_x = x;
        trick.forEach((card) {
          Card c;
          card.x = row_x;
          card.y = y;
          row_x += 0.5 * GameUtils.CARD_WIDTH;
          c = new Card(card);
          // print("Added card '${card.name}'");
          game.add(c);
          game.changePriority(c, 10);
          updateCards[card.name] = c;
        });
        y += 0.25 * GameUtils.CARD_HEIGHT;
        x += 0.25 * GameUtils.CARD_WIDTH;
      });

      cards = updateCards;
    }
  }

  void reset() {
    cards.forEach((_, card) {card.remove(); });

  }
}