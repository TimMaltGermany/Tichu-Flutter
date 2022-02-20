import 'dart:math';
import 'package:flame/components.dart';

import 'package:tichu/enums/phases.dart';
import 'package:tichu/models/table-model.dart';
import 'package:tichu/tichu-game.dart';

import 'package:tichu/game-utils.dart';
import 'card.dart';


class TableView extends Component with HasGameRef<TichuGame> {
  TableModel? tableModel;

  Map<String, Card> cards = {};

  TableView();

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  void addCards(TableModel model) {
    if (gameRef.gamePhase == Phase.GAME_STATE_5_PLAY) {

      tableModel = model;
      print("Table model has '${tableModel?.cards.length}' tricks");
      Map<String, Card> updateCards = {};

      double x = 120;
      double y = 110;

      cards.forEach((name, card) {
        card.cardModel.isVisible = false;
      });

      for (var trick in tableModel!.cards) {
        double rowX = x;
        for (var cardModel in trick) {
          Card? alreadyOnTable = cards.remove(cardModel.name);
          Card card;
          if (alreadyOnTable == null) {
            cardModel.x = rowX;
            cardModel.y = y;
            card = Card(cardModel);
          } else {
            card = alreadyOnTable;
            card.cardModel.x = rowX;
            card.cardModel.y = y;
          }
          card.cardModel.isVisible = true;
          rowX += 0.5 * GameUtils.CARD_WIDTH;

          card.changePriorityWithoutResorting(10 + min(0, cardModel.rank));
          print("table: Added card '${cardModel.name}'");
          card.setOwner("table");
          if (alreadyOnTable == null) {
            gameRef.add(card);
          }
          // WAS game.changePriority(c, 10);
          updateCards[cardModel.name] = card;
        }
        y += 0.25 * GameUtils.CARD_HEIGHT;
        x += 0.25 * GameUtils.CARD_WIDTH;
      }

      cards.forEach((name, card) {
        gameRef.remove(card);
      });
      cards = updateCards;
    }
  }

  void reset() {
    print("table: removing all cards ");
    cards.forEach((_, card) {gameRef.remove(card); });
  }
}