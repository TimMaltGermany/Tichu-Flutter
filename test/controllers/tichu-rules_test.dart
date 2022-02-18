
import 'package:optional/optional_internal.dart';
import 'package:test/test.dart';
import 'package:tichu/controllers/tichu-rules.dart';
import 'package:tichu/enums/colors.dart';
import 'package:tichu/enums/rank.dart';
import 'package:tichu/models/card-model.dart';

void main() {
  group('Check Straight', () {
    test('straight must be least 5 cards long', () {
      final tichuRules = TichuRules();
      List<CardModel> cards = [
        new CardModel(), new CardModel(), new CardModel(), new CardModel()
      ];
      Optional<int> res = tichuRules.getHighestRankIfStraight(
          cards, allowPhoenix: false);

      expect(res.isPresent, false);
    });

    test('valid straights of length 5', () {
      final tichuRules = TichuRules();
      int straightLength = 5;

      for (int lowestRank = 1; lowestRank <=
          MAX_NUMBER_RANKS - straightLength; lowestRank++) {
        List<CardModel> cards = [];
        for (int rank = lowestRank; rank <
            lowestRank + straightLength; rank++) {
          CardModel card = new CardModel();
          card.rank = rank;
          expect(card.rank <= MAX_NUMBER_RANKS, true);
          cards.add(card);
        }
        Optional<int> res = tichuRules.getHighestRankIfStraight(
            cards, allowPhoenix: false);
        expect(res.isPresent, true, reason: "correct straight expected");
        expect(res.value, lowestRank + straightLength - 1);
      }
    });

    test('valid straights of length 6 and more', () {
      final tichuRules = TichuRules();
      for (int straightLength = 6; straightLength <=
          MAX_NUMBER_RANKS; straightLength++) {
        for (int lowestRank = 1; lowestRank <=
            MAX_NUMBER_RANKS - straightLength + 1; lowestRank++) {
          List<CardModel> cards = getStraightOfLength(lowestRank, straightLength);
          Optional<int> res = tichuRules.getHighestRankIfStraight(
              cards, allowPhoenix: false);
          expect(res.isPresent, true, reason: "correct straight expected");
          expect(res.value, lowestRank + straightLength - 1);
        }
      }
    });

    test('valid straights of length 8 with Phoenix', () {
      final tichuRules = TichuRules();
      int straightLength = 8;
      for (int lowestRank = 1; lowestRank <=
          MAX_NUMBER_RANKS - straightLength + 1; lowestRank++) {
        List<CardModel> cards = [];
        List<CardModel>? previousSet;
        for (int rank = lowestRank; rank <
            lowestRank + straightLength; rank++) {
          CardModel card = new CardModel();
          if (rank == 2 * lowestRank) {
            card.rank = RANK_PHOENIX;
          } else {
            card.rank = rank;
          }
          cards.add(card);
        }
        Optional<int> res = tichuRules.getHighestRankIfStraight(
            cards, allowPhoenix: true);
        expect(res.isPresent, true, reason: "correct straight expected");
        expect(res.value, lowestRank + straightLength - 1);
        if (previousSet != null) {
          tichuRules.setCurrentHighestPlay(previousSet);
          bool isValidSet = tichuRules.isValidAndHigherSet(cards);
          expect(isValidSet, true);
          tichuRules.setCurrentHighestPlay(cards);
          isValidSet = tichuRules.isValidAndHigherSet(previousSet);
          expect(isValidSet, false);
        }
        previousSet = cards;
      }
    });
  });

  group('Check Singles, Pairs and Triples', () {
    test('single cards are always valid', () {
      final tichuRules = TichuRules();
      List<CardModel>? lastCards;
      for (int rank = RANK_PHOENIX; rank <= RANK_DRAKE; rank++) {
        CardModel card = new CardModel();
        card.rank = rank;
        List<CardModel> cards = [card];
        tichuRules.setCurrentHighestPlay([]);
        expect(tichuRules.isValidAndHigherSet(cards), true, reason: "should be valid for rank " + rank.toString());
        if (lastCards != null) {
          tichuRules.setCurrentHighestPlay(lastCards);
          expect(tichuRules.isValidAndHigherSet(cards), true);
          tichuRules.setCurrentHighestPlay(cards);
          expect(tichuRules.isValidAndHigherSet(lastCards), false);
        }
      }
    });

    test('Mahjong is not allowed in pairs or triplets', () {
      final tichuRules = TichuRules();
      for (int ix = 2; ix < 4; ix++) {
        int rank = RANK_MAHJONG;
        List<CardModel> cards = [];
        for (int i = 0; i < ix; i++) {
          CardModel card1 = new CardModel();
          card1.rank = rank;
          cards.add(card1);
        }
        tichuRules.setCurrentHighestPlay([]);
        expect(tichuRules
            .getRankIfAllOfSameRank(cards, cards.length)
            .isPresent, false, reason: "there cannot be two Mahjongs");
        expect(tichuRules.isValidAndHigherSet(cards), false,
            reason: "Mahjong is not allowed here");
      }
    });


    test('pairs and triplets, quadruplets must be of the same rank', () {
      final tichuRules = TichuRules();
      for (int ix = 2; ix <= 4; ix++) {
        List<CardModel>? lastCards;
        for (int rank = 2; rank < RANK_DRAKE; rank++) {
          List<CardModel> cards = getSetOfCardsOfSameRank(rank, ix, false);
          tichuRules.setCurrentHighestPlay([]);
          expect(tichuRules.getRankIfAllOfSameRank(cards, cards.length).isPresent, true, reason: "rank not same");
          expect(tichuRules.isValidAndHigherSet(cards), true, reason: "not valid and higher for rank " + rank.toString());
          if (lastCards != null) {
            tichuRules.setCurrentHighestPlay(lastCards);
            expect(tichuRules.isValidAndHigherSet(cards), true, reason: "not higher than previous set");
            tichuRules.setCurrentHighestPlay(cards);
            expect(tichuRules.isValidAndHigherSet(lastCards), false, reason: "higher than previous set");
          }
        }
      }
    });

    test('pairs and triplets, quadruplets must be of the same rank (with Phoenix)', () {
      final tichuRules = TichuRules();
      for (int ix = 2; ix <= 4; ix++) {
        // if ix == 4, then it is a quadruplets, but those are not allowed in Tichu
        // with Phoenixes !
        List<CardModel>? lastCards;
        for (int rank = 2; rank < RANK_DRAKE; rank++) {
          List<CardModel> cards = getSetOfCardsOfSameRank(rank, ix, true);

          tichuRules.setCurrentHighestPlay([]);
          expect(tichuRules.isValidAndHigherSet(cards), ix < 4, reason: "not valid and higher for rank " + rank.toString());
          if (lastCards != null) {
            tichuRules.setCurrentHighestPlay(lastCards);
            expect(tichuRules.isValidAndHigherSet(cards), ix < 4, reason: "not higher than previous set");
            tichuRules.setCurrentHighestPlay(cards);
            expect(tichuRules.isValidAndHigherSet(lastCards), false, reason: "higher than previous set");
          }
        }
      }
    });

    test('sets of cards of different rank are not not pairs / triplets', () {
      final tichuRules = TichuRules();
      for (int ix = 2; ix <= 4; ix++) {
        // if ix == 4, then this is also a Bomb (unless there is a Phoenix)
        List<CardModel>? lastCards;
        for (int rank = 2; rank < RANK_DRAKE; rank++) {
          List<CardModel> cards = [];
          for (int i=0; i<ix; i++) {
            CardModel card1 = new CardModel();
            if (i == 1) {
              card1.rank = rank - 1;
            } else {
              card1.rank = rank;
            }
            cards.add(card1);
          }
          tichuRules.setCurrentHighestPlay([]);
          expect(tichuRules.getRankIfAllOfSameRank(cards, cards.length).isPresent, false, reason: "rank should not be the same");
          expect(tichuRules.isValidAndHigherSet(cards), false, reason: "not valid" + rank.toString());
          if (lastCards != null) {
            tichuRules.setCurrentHighestPlay(lastCards);
            expect(tichuRules.isValidAndHigherSet(cards), false, reason: "not valid, regardless of previous");
            tichuRules.setCurrentHighestPlay(cards);
            expect(tichuRules.isValidAndHigherSet(lastCards), false, reason: "not valid, regardless of previous (2)");
          }
        }
      }
    });
  });

  group('Check single cards with Phoenix', () {
    test('Phoenix is higher than all other normal cards', () {
      final tichuRules = TichuRules();
      for (int rank = 1; rank < RANK_DRAKE; rank++) {
        CardModel card = new CardModel();
        card.rank = rank;
        tichuRules.setCurrentHighestPlay([card]);

        card = new CardModel();
        card.rank = RANK_PHOENIX;
        List<CardModel> cards = [card];

        expect(tichuRules.isValidAndHigherSet(cards), true,
            reason: "PHOENIX is higher than any other normal card, fail: " + rank.toString());

      }
    });

    test('normal cards must be of higher rank than the card that was played before the PHOENIX', () {
      final tichuRules = TichuRules();
      CardModel phoenix = new CardModel();
      phoenix.rank = RANK_PHOENIX;
      for (int rank = 1; rank < RANK_DRAKE; rank++) {
        CardModel card = new CardModel();
        card.rank = rank;
        tichuRules.setCurrentHighestPlay([card]);
        tichuRules.setCurrentHighestPlay([phoenix]);

        for (int rank2 = 1; rank2 < RANK_DRAKE; rank2++) {
          CardModel card2 = new CardModel();
          card2.rank = rank2;
          List<CardModel> cards = [card2];
          expect(tichuRules.isValidAndHigherSet(cards), rank2 > rank,
              reason: "normal card must be higher than assumed rank of PHOENIX, fail for rank: " +
                  rank.toString());
        }
      }
    });

    test('Phoenix is not higher than the DRAKE', () {
      final tichuRules = TichuRules();
        CardModel card = new CardModel();
        card.rank = RANK_DRAKE;
        tichuRules.setCurrentHighestPlay([card]);

        card = new CardModel();
        card.rank = RANK_PHOENIX;
        List<CardModel> cards = [card];

        expect(tichuRules.isValidAndHigherSet(cards), false,
            reason: "PHOENIX should not be higher than the DRAKE");
    });
  });

  group('Check Full House', () {
    final tichuRules = TichuRules();
    test('two pairs are not a full house (or anything else, if not consecutive', () {
      List<CardModel> cards = getSetOfCardsOfSameRank(3, 2, false);
      CardModel card = new CardModel();
      card.rank = 11;
      cards.add(card);
      card = new CardModel();
      card.rank = 11;
      cards.add(card);

      expect(tichuRules.isValidAndHigherSet(cards), false);
      expect(tichuRules.getHighestRankIfFullHouse(cards).isPresent, false);
    });

    test('two triplets are are never valid', () {
      List<CardModel> cards = getSetOfCardsOfSameRank(7, 3, false);

      CardModel card = new CardModel();
      card.rank = 8;
      cards.add(card);
      card = new CardModel();
      card.rank = 8;
      cards.add(card);
      card = new CardModel();
      card.rank = 8;
      cards.add(card);

      expect(tichuRules.isValidAndHigherSet(cards), false);
      expect(tichuRules.getHighestRankIfFullHouse(cards).isPresent, false);
    });

    test('two triplets are are never valid, even with a Phoenix', () {
      tichuRules.setCurrentHighestPlay([]);
      List<CardModel> cards = getSetOfCardsOfSameRank(11, 3, false);
      CardModel card = new CardModel();
      card.rank = 12;
      cards.add(card);
      card = new CardModel();
      card.rank = 0;
      cards.add(card);
      card = new CardModel();
      card.rank = 12;
      cards.add(card);

      expect(tichuRules.isValidAndHigherSet(cards), false);
      expect(tichuRules.getHighestRankIfFullHouse(cards).isPresent, false);
    });

    test('three twos and two queens are a full house with rank 2', () {
      tichuRules.setCurrentHighestPlay([]);
      List<CardModel> cards = getSetOfCardsOfSameRank(12, 2, false);
      CardModel card = new CardModel();
      card.rank = 2;
      cards.add(card);
      card = new CardModel();
      card.rank = 2;
      cards.add(card);
      card = new CardModel();
      card.rank = 2;
      cards.add(card);

      expect(tichuRules.isValidAndHigherSet(cards), true, reason: "not a valid set");
      expect(tichuRules.getHighestRankIfFullHouse(cards).isPresent, true, reason: "not a full house");
      expect(tichuRules.getHighestRankIfFullHouse(cards).value, 2, reason: "not of rank 2");
    });

    test('two nines and two fives and a Phoenix are a full house with rank 9', () {
      tichuRules.setCurrentHighestPlay([]);
      List<CardModel> cards = getSetOfCardsOfSameRank(5, 2, false);
      CardModel card = new CardModel();
      card.rank = 0;
      cards.add(card);
      card = new CardModel();
      card.rank = 9;
      cards.add(card);
      card = new CardModel();
      card.rank = 9;
      cards.add(card);

      expect(tichuRules.isValidAndHigherSet(cards), true, reason: "not a valid set");
      Optional<int> rankOpt = tichuRules.getHighestRankIfFullHouse(cards);
      expect(rankOpt.isPresent, true, reason: "not a full house");
      expect(rankOpt.value, 9, reason: "not of rank 9");
    });

    test('a full house with sixes is higher than a full house with fours', () {
      {
        List<CardModel> cards = getSetOfCardsOfSameRank(4, 3, false);
        CardModel card = new CardModel();
        card = new CardModel();
        card.rank = 0;
        cards.add(card);
        card = new CardModel();
        card.rank = 14;
        cards.add(card);

        tichuRules.setCurrentHighestPlay(cards);
      }

      List<CardModel> cards = getSetOfCardsOfSameRank(14, 2, false);
      CardModel card = new CardModel();
      card.rank = 6;
      cards.add(card);
      card = new CardModel();
      card.rank = 6;
      cards.add(card);
      card = new CardModel();
      card.rank = 6;
      cards.add(card);

      expect(tichuRules.isValidAndHigherSet(cards), true, reason: "not a valid set");
      expect(tichuRules.getHighestRankIfFullHouse(cards).isPresent, true, reason: "not a full house");
      expect(tichuRules.getHighestRankIfFullHouse(cards).value, 6, reason: "not of rank 6");
    });

  });

  group('Sequence of Pairs', () {
    final tichuRules = TichuRules();
    test('two consecutive pairs are ok', () {
      tichuRules.setCurrentHighestPlay([]);
      List<CardModel> cards = getSetOfCardsOfSameRank(10, 2, false);
      CardModel card = new CardModel();
      card.rank = 11;
      cards.add(card);
      card = new CardModel();
      card.rank = 11;
      cards.add(card);

      expect(tichuRules.isValidAndHigherSet(cards), true);
      expect(tichuRules.getHighestRankIfFullHouse(cards).isPresent, false);
      Optional<int> rankOpt = tichuRules.getHighestRankIfSequenceOfPairs(cards);
      expect(rankOpt.isPresent, true);
      expect(rankOpt.value, 11);
    });

    test('n > 1 consecutive pairs are ok', () {
      tichuRules.setCurrentHighestPlay([]);
      for (int numPairs = 1; numPairs < 8; numPairs++) {
        List<CardModel> cards = [];
        for (int rank = 0; rank < numPairs; rank++) {
          CardModel card = new CardModel();
          card.rank = rank + 2;
          cards.add(card);
          card = new CardModel();
          card.rank = rank + 2;
          cards.add(card);
        }

        expect(tichuRules.isValidAndHigherSet(cards), true);
        expect(tichuRules
            .getHighestRankIfStraight(cards)
            .isPresent, false);
        Optional<int> rankOpt = tichuRules.getHighestRankIfSequenceOfPairs(
            cards);
        expect(rankOpt.isPresent, numPairs > 1, reason: "not a valid sequence of " + numPairs.toString() + " pairs");
        if (numPairs > 1) {
          expect(rankOpt.value, numPairs + 1);
        }
      }
    });

    test('n not-consecutive pairs are not ok', () {
      tichuRules.setCurrentHighestPlay([]);
      for (int numPairs = 2; numPairs < 8; numPairs++) {
        List<CardModel> cards = [];
        for (int rank = 0; rank < 2*numPairs; rank+=2) {
          CardModel card = new CardModel();
          card.rank = RANK_PHOENIX;
          cards.add(card);
          card = new CardModel();
          card.rank = rank + 2;
          cards.add(card);
        }

        expect(tichuRules.isValidAndHigherSet(cards), false,
            reason: "should not be valid and higher sequence of " + numPairs.toString() + " pairs");
        expect(tichuRules
            .getHighestRankIfStraight(cards)
            .isPresent, false);
        Optional<int> rankOpt = tichuRules.getHighestRankIfSequenceOfPairs(
            cards);
        expect(rankOpt.isPresent, false, reason: "should not be a valid sequence of " + numPairs.toString() + " pairs");
      }
    });


    test('compare sequences of pairs', () {
      tichuRules.setCurrentHighestPlay([]);
      for (int numPairs = 1; numPairs < 8; numPairs++) {
        for (int startRank = 3; startRank < 5; startRank++) {
          List<CardModel> cards = [];
          for (int rank = 0; rank < numPairs; rank++) {
            CardModel card = new CardModel();
            card.rank = rank + startRank;
            cards.add(card);
            card = new CardModel();
            card.rank = rank + startRank;
            cards.add(card);
          }

          expect(tichuRules.isValidAndHigherSet(cards), numPairs == 1 || startRank>3,
              reason: "not valid/higher for " + numPairs.toString() + " pair(s) and rank " + startRank.toString() + ".");
          expect(tichuRules
              .getHighestRankIfStraight(cards)
              .isPresent, false);
          Optional<int> rankOpt = tichuRules.getHighestRankIfSequenceOfPairs(
              cards);
          expect(rankOpt.isPresent, numPairs > 1,
              reason: "not a valid sequence of " + numPairs.toString() +
                  " pairs");
          if (numPairs > 1) {
            expect(rankOpt.value, numPairs + startRank - 1);
          }
          tichuRules.setCurrentHighestPlay(cards);
        }
      }
    });

  });

  group('Check Bombs', () {
    final tichuRules = TichuRules();
    test('4 jacks are a bomb', () {
      tichuRules.setCurrentHighestPlay([]);
      List<CardModel> cards = getSetOfCardsOfSameRank(11, 4, false);

      expect(tichuRules.isValidAndHigherSet(cards), true);
      expect(tichuRules.getHighestRankIfSequenceOfPairs(cards).isPresent, false);
      Optional<int> rankOpt = tichuRules.getHighestRankIfBomb(cards);
      expect(rankOpt.isPresent, true);
      expect(rankOpt.value, 411);
    });

    test('3 Aces and a Phoenix are not a bomb', () {
      tichuRules.setCurrentHighestPlay([]);
      List<CardModel> cards = getSetOfCardsOfSameRank(14, 4, true);

      expect(tichuRules.isValidAndHigherSet(cards), false);
      expect(tichuRules.getHighestRankIfSequenceOfPairs(cards).isPresent, false);
      Optional<int> rankOpt = tichuRules.getHighestRankIfBomb(cards);
      expect(rankOpt.isPresent, false);
    });

    test('4 nines are higher than 4 twos', () {
      tichuRules.setCurrentHighestPlay(getSetOfCardsOfSameRank(2, 4, false));
      List<CardModel> cards = getSetOfCardsOfSameRank(9, 4, false);

      expect(tichuRules.isValidAndHigherSet(cards), true);
      expect(tichuRules.getHighestRankIfSequenceOfPairs(cards).isPresent, false);
      Optional<int> rankOpt = tichuRules.getHighestRankIfBomb(cards);
      expect(rankOpt.isPresent, true);
      expect(rankOpt.value, 409);
    });

    test('Any straight bomb is higher than quadruplet bomb', () {
      tichuRules.setCurrentHighestPlay(getSetOfCardsOfSameRank(14, 4, false));
      List<CardModel> cards = getStraightOfLength(2, 5, color: COLORS[2]);

      expect(tichuRules.getHighestRankIfFullHouse(cards).isPresent, false, reason: "not a full house");
      Optional<int> rankOpt = tichuRules.getHighestRankIfBomb(cards);
      expect(rankOpt.isPresent, true, reason: "this is a bomb, really!");
      expect(rankOpt.value, 506);

      expect(tichuRules.isValidAndHigherSet(cards), true, reason: "should be a higher bomb");
    });


    test('no straight (unless a bomb) is higher than quadruplet bomb', () {
      tichuRules.setCurrentHighestPlay(getSetOfCardsOfSameRank(14, 4, false));
      List<CardModel> cards = getStraightOfLength(2, 5);

      Optional<int> rankOpt = tichuRules.getHighestRankIfBomb(cards);
      expect(rankOpt.isPresent, false, reason: "this is not a bomb");

      expect(tichuRules.isValidAndHigherSet(cards), false, reason: "is not a bomb");
    });

    test('Straight (bomb) may not start with the Mahjong!', () {
      List<CardModel> cards = getStraightOfLength(1, 5);
      Optional<int> rankOpt = tichuRules.getHighestRankIfBomb(cards);
      expect(rankOpt.isPresent, false);
    });


    test('a straight with 7 red cards is a bomb', () {
      tichuRules.setCurrentHighestPlay([]);
      List<CardModel> cards = [];
      for (int ix = 3; ix < 10; ix++) {
        CardModel card = new CardModel();
        card.rank = ix;
        card.color = COLORS[3];
        cards.add(card);
      }

      expect(tichuRules.isValidAndHigherSet(cards), true, reason: "this is straight");
      expect(tichuRules.getHighestRankIfSequenceOfPairs(cards).isPresent, false);
      Optional<int> rankOpt = tichuRules.getHighestRankIfBomb(cards);
      expect(rankOpt.isPresent, true, reason: "it is a bomb indeed");
      expect(rankOpt.value, 709);
    });

    test('a straight with 4 blue cards and a phoenix is not a bomb', () {
      tichuRules.setCurrentHighestPlay([]);
      List<CardModel> cards = [];
      for (int ix = 3; ix < 8; ix++) {
        CardModel card = new CardModel();
        if (ix == 5) {
          card.rank = RANK_PHOENIX;
        } else {
          card.rank = ix;
        }
        card.color = COLORS[2];
        cards.add(card);
      }

      expect(tichuRules.isValidAndHigherSet(cards), true, reason: "this is straight");
      expect(tichuRules.getHighestRankIfSequenceOfPairs(cards).isPresent, false);
      Optional<int> rankOpt = tichuRules.getHighestRankIfBomb(cards);
      expect(rankOpt.isPresent, false, reason: "it is not a bomb");
    });

    test('a straight with 10 mixed color cards is not a bomb', () {
      tichuRules.setCurrentHighestPlay([]);
      List<CardModel> cards = [];
      for (int ix = 3; ix < 13; ix++) {
        CardModel card = new CardModel();
        card.rank = ix;
        card.color = COLORS[ix % 4];
        cards.add(card);
      }

      expect(tichuRules.isValidAndHigherSet(cards), true, reason: "this is straight");
      expect(tichuRules.getHighestRankIfSequenceOfPairs(cards).isPresent, false);
      Optional<int> rankOpt = tichuRules.getHighestRankIfBomb(cards);
      expect(rankOpt.isPresent, false, reason: "it is not a bomb");
    });
  });

  group('Is player allowed to pass?', () {
    final tichuRules = TichuRules();
    test('not if first player', () {
      tichuRules.setCurrentHighestPlay([]);
      expect(tichuRules.isPassAllowed(), false);
    });

    test('not if only DOGS are on the table', () {
      CardModel card = new CardModel();
      card.rank = RANK_DOGS;
      tichuRules.setCurrentHighestPlay([card]);
      expect(tichuRules.isPassAllowed(), false);
    });

    test('but if any other card is on the table', () {
      CardModel card = new CardModel();
      card.rank = RANK_PHOENIX;
      tichuRules.setCurrentHighestPlay([card]);
      expect(tichuRules.isPassAllowed(), true);
    });


  });
}

List<CardModel> getStraightOfLength(int lowestRank, int straightLength, {String? color}) {
   List<CardModel> cards = [];
  for (int rank = lowestRank; rank < lowestRank + straightLength; rank++) {
    CardModel card = new CardModel();
    card.rank = rank;
    if (color != null) {
      card.color = color;
    } else {
      card.color = COLORS[rank % 4];
    }
    cards.add(card);
  }
  return cards;
}

List<CardModel> getSetOfCardsOfSameRank(int rank, int numCards, bool addPhoenix) {
  List<CardModel> cards = [];
  for (int i = 0; i<numCards; i++) {
    CardModel card = new CardModel();
    if (addPhoenix && i == numCards / 2) {
      card.rank = RANK_PHOENIX;
    } else {
      card.rank = rank;
    }
    cards.add(card);
  }
  return cards;
}
