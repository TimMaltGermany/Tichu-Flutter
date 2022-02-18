
import 'dart:collection';
import 'dart:math';
import 'package:optional/optional_internal.dart';

import 'package:tichu/enums/rank.dart';
import 'package:tichu/models/card-model.dart';

class TichuRules {
  
  List<CardModel> globalHighestPlay = [];

  TichuRules();

  setCurrentHighestPlay(List<CardModel> newHighestPlay) {
    // if new highest play is Phoenix, then just keep the last card (unless
    // the Phoenix is the very first card)
    if (newHighestPlay.length == 1 && newHighestPlay[0].rank == RANK_PHOENIX) {
      if (globalHighestPlay.isEmpty || globalHighestPlay[0].rank == RANK_DOGS) {
        globalHighestPlay = newHighestPlay;
      }
    } else {
      globalHighestPlay = newHighestPlay;
    }
  }

  bool hasValue(int rank) {
    return this.getValue(rank) != 0;
  }
  
  bool hasValueForCard(CardModel card) {
    return this.hasValue(card.rank);
  }

  int getValue(int rank) {
    if (rank == 10) {
      //a ten
      return 10;
    }
    if (rank == 13) {
      //KING
      return 10;
    }
    if (rank == 5) {
      // a 5
      return 5;
    }
    if (rank == 15) {
      //DRAKE
      return 25;
    }
    if (rank == 0) {
      // RANK_PHOENIX
      return -25;
    }
    return 0;
  }

  /// a player may pass iff
  /// - not start player
  /// - and not dogs are played (only so far)
  bool isPassAllowed() {
    return globalHighestPlay.isNotEmpty &&
        (globalHighestPlay.length > 1 ||
            globalHighestPlay[0].rank != RANK_DOGS);
  }

  bool isValidAndHigherSet(List<CardModel> cards) {
    if (cards.isEmpty) {
      return false;
    }
    bool needToBeatExistingSet = this.globalHighestPlay.isNotEmpty;
    if (isValidAnHigherBomb(cards)) {
      return true;
    }

    Optional<int> optRank = this.getRankIfAllOfSameRank(cards, -1);
    if (optRank.isPresent) {
      if (needToBeatExistingSet && this.isValidSameAndHigherRank(
          cards, optRank.value.toDouble(), globalHighestPlay)) {
        return true;
      } else {
        return !needToBeatExistingSet;
      }
    }

    optRank = this.getHighestRankIfStraight(cards, allowPhoenix: true);
    if (optRank.isPresent) {
      if (needToBeatExistingSet) {
        Optional<int> existingRank = this.getHighestRankIfStraight(
            globalHighestPlay, allowPhoenix: true);
        return existingRank.isPresent && existingRank.value < optRank.value;
      } else {
        return true;
      }
    }

    optRank = this.getHighestRankIfFullHouse(cards);
    if (optRank.isPresent) {
      if (needToBeatExistingSet) {
        Optional<int> existingRank = this.getHighestRankIfFullHouse(
            globalHighestPlay);
        return existingRank.isPresent && existingRank.value < optRank.value;
      } else {
        return true;
      }
    }

    optRank = this.getHighestRankIfSequenceOfPairs(cards);
    if (optRank.isPresent) {
      if (needToBeatExistingSet) {
        Optional<int> existingRank = this.getHighestRankIfSequenceOfPairs(
            globalHighestPlay);
        return existingRank.isPresent && existingRank.value < optRank.value;
      } else {
        return true;
      }
    }
    return false;
  }

  /// check whether all cards in list or cards are of the same rank
  /// if there is a list to beat, then both lists must be of the same length
  /// and the rank of the cards must be higher than the rank of the cards in needToBeat
  bool isValidSameAndHigherRank(List<CardModel> cards, double rank, List<CardModel> needToBeat) {
      if (rank == RANK_PHOENIX) {
        rank = RANK_DRAKE - 0.5;
      }
      if (rank == RANK_MAHJONG && cards.length > 1) {
        //Mahjong is only higher than Phoenix
        return false;
      }
      if (needToBeat.isNotEmpty) {
        Optional<int> currentRank = this.getRankIfAllOfSameRank(needToBeat, cards.length);
        if (currentRank.isEmpty) {
          return false;
        }
        // console.log("single, pair or triplet found, rank: " + rank + ", current: " + current_rank);
        return (rank > currentRank.value);
      }
      // this includes single cards
      return true;
  }

  /// a full house consists of a pair and a triplet, possibly with a Phoenix
  Optional<int> getHighestRankIfFullHouse(List<CardModel> cards) {
    if (cards.length != 5) {
      return Optional.empty();
    }

    Map<int, int> ranks = new Map();
    CardModel? phoenix;
    for (int ix = 0; ix < cards.length; ix++) {
      int rank = cards[ix].rank;
      if (rank == RANK_PHOENIX) {
        phoenix = cards[ix];
      } else if (rank == RANK_DRAKE) {
        return Optional.empty();
      } else {
          ranks[rank] = (ranks[rank] ?? 0) + 1;
      }
    }

    if (ranks.length == 2) {
      int numPairsFound = 0;
      int tripletRank = -1;
      bool phoenixRequired = false;
      bool isValid = true;
      for (MapEntry<int, int> entry in ranks.entries) {
        int rank = entry.key;
        int ctr = entry.value;
        if (ctr == 1) {
          phoenixRequired = true;
        }
        else if (ctr == 2) {
          numPairsFound += 1;
          if (numPairsFound == 2) {
            phoenixRequired = true;
          }
        }
        else if (ctr == 3) {
          tripletRank = rank;
        }
        else {
          isValid = false;
        }
      }

      if (!isValid) {
        return Optional.empty();
      }

      if (!phoenixRequired) {
        if (numPairsFound == 1 && tripletRank != -1) {
          return Optional.of(tripletRank);
        }
      }
      else if (phoenix != null) {
        if (numPairsFound == 2) {
          return Optional.of(max(ranks.keys.first, ranks.keys.last));
        }
        if (tripletRank != -1 && numPairsFound == 0) {
          return Optional.of(tripletRank);
        }
      }
    }
    return Optional.empty();
  }

  /// a bomb is either a quadruplet of identical cards or
  /// a straight of at least 5 cards of the same color
  /// the Phoenix is not allowed here!
  /// the rank of a bomb is 100 * length + rank of highest card
  /// longer bombs are always higher than shorter ones,
  /// the rank is only relevant when they have the same length
  Optional<int> getHighestRankIfBomb(List<CardModel> cards) {
    Optional<int> rankOpt = Optional.empty();
    if (cards.length >= 4) {
      if (cards.length == 4) {
        rankOpt = this.getRankIfAllOfSameRank(cards, -1);
      } else {
        rankOpt = this.getHighestRankIfStraight(cards, allowPhoenix: false);
        if (rankOpt.isPresent && !ofSameColor(cards)) {
          rankOpt = Optional.empty();
        }
      }
    }
    if (rankOpt.isPresent) {
      return (100 * cards.length + rankOpt.value).toOptional;
    } else {
      return Optional.empty();
    }
  }

  bool isValidAnHigherBomb(List<CardModel> cards) {
    Optional<int> rank = this.getHighestRankIfBomb(cards);
    if (rank.isPresent) {
      Optional<int> existingRank = this.getHighestRankIfBomb(globalHighestPlay);
       return existingRank.isEmpty || existingRank.value < rank.value;
    }
    return false;
  }

  bool ofSameColor(List<CardModel> cards) {
    String color = cards[0].color;
    for (int ix = 1; ix < cards.length; ix++) {
      if (cards[ix].color != color) {
        return false;
      }
    }
    return true;
  }


  /// check whether all cards in given list are of the same rank,
  /// if so, return the rank, otherwise null
  Optional<int> getRankIfAllOfSameRank(List<CardModel> cards, numCards) {
    bool allowPhoenix = cards.length < 4;
    if (cards.length > 4 || (numCards > 0 && numCards != cards.length)) {
      return Optional.empty();
    }

    int rank = cards[0].rank;
    if (rank == RANK_PHOENIX) {
      if (cards.length == 1) {
        return Optional.of(RANK_PHOENIX);
      }
      rank = cards[1].rank;
    } else if (rank == RANK_MAHJONG) {
      if (cards.length == 1) {
        return Optional.of(RANK_MAHJONG);
      } else {
        return Optional.empty();
      }
    }

    if (numCards < 2 && cards.length == 1) {
      return Optional.of(rank);
    }

    for (int ix = 1; ix < cards.length; ix++) {
      int r = cards[ix].rank;
      if (r == RANK_PHOENIX) {
        if (!allowPhoenix) {
          return Optional.empty();
        }
      } else if (r == RANK_DRAKE || r == RANK_DOGS) {
        return Optional.empty();
      }
      else if (r != rank) {
        return Optional.empty();
      }
    }
    return Optional.of(rank);
  }

  /// check whether list contains a consecutive sequence of pairs
  /// a single pair is not a sequence of pairs
  Optional<int> getHighestRankIfSequenceOfPairs(List<CardModel> cards) {
    if (cards.length < 4 || cards.length % 2 != 0) {
      return Optional.empty();
    }

    SplayTreeMap<int, int> ranks = new SplayTreeMap();
    CardModel? phoenix;
    for (int ix = 0; ix < cards.length; ix++) {
      int rank = cards[ix].rank;
      if (rank == RANK_PHOENIX) {
        phoenix = cards[ix];
      } else if (rank == RANK_DRAKE) {
        return Optional.empty();
      } else {
        ranks[rank] = (ranks[rank] ?? 0) + 1;
      }
    }


    int? lastRank;
    for (MapEntry<int, int> entry in ranks.entries) {
      int rank = entry.key;
      int ctr = entry.value;
      if (lastRank != null) {
        if (rank != lastRank + 1) {
          return Optional.empty();
        }
      }
      lastRank = rank;
      if (ctr == 1) {
        if (phoenix == null) {
          return Optional.empty();
        }
        phoenix = null;
      } else if (ctr != 2) {
        return Optional.empty();
      }
    }
    if (lastRank != null) {
      return Optional.of(lastRank);
    } else {
      return Optional.empty();
    }
  }

  Optional<int> getHighestRankIfStraight(List<CardModel> cards, {bool allowPhoenix = true}) {
    // straights in Tichu must be at least 5 long
    if (cards.length < 5) {
      return Optional.empty();
    }

    SplayTreeSet<int> ranks = new SplayTreeSet();
    CardModel? phoenix;
    for (int ix = 0; ix < cards.length; ix++) {
      int rank = cards[ix].rank;
      if (rank == RANK_PHOENIX) {
        if (!allowPhoenix) {
          return Optional.empty();
        }
        phoenix = cards[ix];
      } else if (rank == RANK_DRAKE) {
        return Optional.empty();
      } else {
        ranks.add(rank);
      }
    }

    int l = ranks.length;
    if (phoenix != null) {
      l += 1;
    }
    if (l != cards.length) {
      return Optional.empty();
    }

    int currentRank = ranks.first;
    for (int ix = 1; ix < ranks.length; ix++) {
      if (ranks.elementAt(ix) != currentRank + 1) {
        // allow one leap if there is a phoenix
        if (phoenix == null || ranks.elementAt(ix) != currentRank + 2) {
          return Optional.empty();
        }
        //phoenix is 'used up'
        phoenix = null;
      }
      currentRank = ranks.elementAt(ix);
    }

    if (phoenix != null) {
      // phoenix has not been used, place phoenix at end
      return Optional.of(currentRank + 1);
    } else {
      return Optional.of(currentRank);
    }
  }
}


/*
function counts_points(cards) { Dict, card_ids) -> int) {
points = 0
for c_id in card_ids) {
	c = cards[c_id]
points += get_value(c.card_rank)
return points

*/

