
class TichuRules {
	constructor() {
		this.global_highest_play = null;
	}
	has_value(rank) {
		return this.get_value(rank) != 0;
	}
	card_has_value(card) {
		return this.has_value(global_cards.get_card_rank(card));
	}
	get_value(rank) {
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

	is_valid_and_higher_set(cards) {
		let need_to_beat = null;
		if (this.global_highest_play != null && this.global_highest_play.getLength() > 0) {
			need_to_beat = this.global_highest_play.getChildren();
		}
		if (need_to_beat != null) {
			if (cards.length != need_to_beat.length) {
				return false;
			}
		}

		if (this.is_valid_same_rank(cards, need_to_beat)) {
			return true;
		}
		const allowed_tichu_types = [this.get_straight_highest, this.get_full_house_highest, this.get_sequence_of_pairs];
		for (let i = 0; i < allowed_tichu_types.length; i++) {
			if (this.is_valid_play_of_type(allowed_tichu_types[i], cards, need_to_beat)) {
				return true;
			}
		}
		// console.log("not same")
		//		if (this.is_valid_straight_play(cards, need_to_beat)) {
		//			return true;
		//		}
		// or a full house
		//		if (this.is_valid_full_house_play(cards, need_to_beat)) {
		//			return true;
		//		}

		// or a sequence of pairs
		// console.log("not a straight");

		//		const rank = this.get_sequence_of_pairs(cards);
		//		if (rank != null) {
		//			// console.log("sequence of pairs found");
		//			if (need_to_beat != null) {
		//				const current_rank = this.get_sequence_of_pairs(need_to_beat);
		//				if (current_rank == null) {
		//					return false;
		//				}
		//				return (rank > current_rank);
		//			}
		//			return true;
		//		}


		//console.log("not a valid play");
		return false;
	}

	is_valid_play_of_type(type_func, cards, need_to_beat) {
		const rank = type_func(cards, true);
		if (rank != null) {
			// console.log('straight found');
			if (need_to_beat != null) {
				const current_rank = type_func(need_to_beat, true);
				if (current_rank == null) {
					return false;
				}
				return (rank > current_rank);
			}
			return true;
		}
		return false;
	}

	/*
		is_valid_straight_play(cards, need_to_beat) {
			const rank = this.get_straight_highest(cards, true);
			if (rank != null) {
				// console.log('straight found');
				if (need_to_beat != null) {
					const current_rank = this.get_straight_highest(need_to_beat, true);
					if (current_rank == null) {
						return false;
					}
					return (rank > current_rank);
				}
				return true;
			}
			return false;
		}
	
		is_valid_full_house_play(cards, need_to_beat) {
			const rank = this.get_full_house_highest(cards);
			if (rank != null) {
				// console.log('straight found');
				if (need_to_beat != null) {
					const current_rank = this.get_full_house_highest(need_to_beat);
					if (current_rank == null) {
						return false;
					}
					return (rank > current_rank);
				}
				return true;
			}
			return false;
		}
	*/

	is_valid_same_rank(cards, need_to_beat) {
		let rank = this.get_same_rank(cards, -1, true);
		if (rank != null) {
			if (rank == RANK_PHOENIX) {
				rank = RANK_DRAKE - 0.5;
			}
			if (rank == RANK_MAHJONG && cards.length > 1) {
				//Mahjong is only higher than Phoenix
				return false;
			}
			if (need_to_beat != null) {
				const current_rank = this.get_same_rank(need_to_beat, cards.length, true);
				if (current_rank == null) {
					return false;
				}
				// console.log("single, pair or triplet found, rank: " + rank + ", current: " + current_rank);
				return (rank > current_rank);
			}
			// this includes single cards
			return true;
		}
	}

	get_full_house_highest(cards) {
		if (cards.length != 5) {
			return null;
		}
		const ranks = {};
		let phoenix_found = false;
		for (let ix = 0; ix < cards.length; ix++) {
			const rank = global_cards.get_card_rank(cards[ix]);
			if (rank == RANK_PHOENIX) {
				phoenix_found = true;
			}
			else if (rank in ranks) {
				ranks[rank] += 1;
			}
			else {
				ranks[rank] = 1;
			}
		}
		if (Object.keys(ranks).length == 2) {
			let num_pairs_found = 0;
			let triplet_rank = -1;
			let phoenix_required = false;
			for (let rank in ranks) {
				const ctr = ranks[rank];
				if (ctr == 1) {
					phoenix_required = true;
				}
				else if (ctr == 2) {
					num_pairs_found += 1;
					if (num_pairs_found == 2) {
						phoenix_required = true;
					}
				}
				else if (ctr == 3) {
					triplet_rank = parseInt(rank);
				}
				else {
					return null;
				}
			}
			if (!phoenix_required) {
				if (num_pairs_found == 1 && triplet_rank != -1) {
					return triplet_rank;
				}
			}
			else if (phoenix_found) {
				if (num_pairs_found == 2) {
					const tmp = Object.keys(ranks);
					const v1 = parseInt(tmp[0]);
					const v2 = parseInt(tmp[1]);
					return Math.max(v1, v2);
				}
				if (triplet_rank != -1 && num_pairs_found == 0) {
					return triplet_rank;
				}
			}
		}
		return null;
	}

	is_valid_and_higher_bomb(cards) {
		let need_to_beat = null;
		if (this.global_highest_play != null && this.global_highest_play.getLength() > 0) {
			need_to_beat = this.global_highest_play.getChildren();
			if (this.get_same_rank(need_to_beat, 4, false) == null &&
				(this.get_straight_highest(need_to_beat, false) == null || !this.of_same_color(need_to_beat))) {
				need_to_beat = null;
			}
		}
		if (need_to_beat != null && need_to_beat.length > cards.length) {
			return false;
		}
		// either four of a kind
		let rank = this.get_same_rank(cards, 4, false);
		if (rank != null) {
			if (need_to_beat != null) {
				const current_rank = this.get_same_rank(need_to_beat, 4, false);
				if (current_rank != null && current_rank >= rank) {
					return false;
				}
			}
			return true;
		}
		// compare straight bombs
		// or a straight flush (all of the same color)
		rank = this.get_straight_highest(cards, false);
		if (rank != null && rank > 5) {
			if (this.of_same_color(cards)) {
				if (need_to_beat != null) {
					if (need_to_beat.length == cards.length) {
						const current_rank = this.get_straight_highest(need_to_beat, false);
						if (current_rank != null && current_rank >= rank) {
							return false;
						}
					}
				}
				return true;
			}
		}
		return false;
	}

	are_same_rank(cards, num_cards, allow_phoenix) {
		return this.get_same_rank(cards, num_cards, allow_phoenix) != null;
	}

	get_same_rank(cards, num_cards, allow_phoenix) {
		if (num_cards > 0 && num_cards != cards.length) {
			return null;
		}

		let rank = global_cards.get_card_rank(cards[0]);
		if (rank == RANK_PHOENIX) {
			if (cards.length == 1) {
				return RANK_PHOENIX;
			}
			rank = global_cards.get_card_rank(cards[1]);
		}
		if (num_cards < 2 && cards.length == 1) {
			return rank;
		}

		for (let ix = 0; ix < cards.length; ix++) {
			const r = global_cards.get_card_rank(cards[ix]);
			if (r == RANK_PHOENIX) {
				if (!allow_phoenix) {
					return null;
				}
			} else if (r == RANK_DRAKE || r == RANK_DOGS) {
				return null;
			}
			else if (r != rank) {
				return null;
			}
		}
		return rank;
	}


	is_full_house(cards) {
		return this.get_full_house_highest(cards) != null;
	}


	is_sequence_of_pairs(cards) {
		return this.get_sequence_of_pairs(cards) != null;
	}

	get_sequence_of_pairs(cards) {
		if (cards.length < 4) {
			return null;
		}

		let phoenix_found = false;
		const ranks = {};
		for (let ix = 0; ix < cards.length; ix++) {
			const rank = global_cards.get_card_rank(cards[ix]);
			if (rank == RANK_PHOENIX) {
				phoenix_found = true;
			} else if (rank == RANK_DRAKE) {
				return null;
			} else if (rank in ranks) {
				ranks[rank] += 1;
			} else {
				ranks[rank] = 1;
			}
		}

		// Create items array
		const ranks_sorted = Object.keys(ranks).map(function(key) {
			return [parseInt(key), ranks[key]];
		});

		// sort by key
		ranks_sorted.sort(function(rank1, rank2) {
			return rank1[0] - rank2[0];
		});


		let last_rank = null;
		for (let ix = 0; ix < ranks_sorted.length; ix++) {
			const rank = ranks_sorted[ix][0];
			const ctr = ranks_sorted[ix][1];
			if (last_rank != null) {
				if (rank != last_rank + 1) {
					return null;
				}
			}
			last_rank = rank;
			if (ctr == 1) {
				if (!phoenix_found) {
					return null;
				}
				phoenix_found = false;
			} else if (ctr != 2) {
				return null;
			}
		}
		return last_rank;
	}


	is_straight(cards, allow_phoenix = true) {
		return this.get_straight_highest(cards, allow_phoenix) != null;
	}


	get_straight_highest(cards, allow_phoenix = true) {
		// straights in Tichu must be at least 5 long
		if (cards.length < 5) {
			return null;
		}

		const ranks = new Set();
		let phoenix = null;
		for (let ix = 0; ix < cards.length; ix++) {
			const rank = global_cards.get_card_rank(cards[ix]);
			if (rank == RANK_PHOENIX) {
				if (!allow_phoenix) {
					return null;
				}
				phoenix = cards[ix];
			} else if (rank == RANK_DRAKE) {
				return null;
			} else {
				ranks.add(rank);
			}
		}

		const ranks_sorted = Array.from(ranks);
		let l = ranks_sorted.length;
		if (phoenix != null) {
			l += 1;
		}
		if (l != cards.length) {
			return null;
		}

		ranks_sorted.sort(function(rank1, rank2) {
			return rank1 - rank2;
		});


		let current_rank = ranks_sorted[0];
		for (let ix = 1; ix < ranks_sorted.length; ix++) {
			if (ranks_sorted[ix] != current_rank + 1) {
				// allow one leap if there is a phoenix
				if (phoenix == null || ranks_sorted[ix] != current_rank + 2) {
					return null;
				}
				//phoenix is 'used up'
				phoenix = null;
			}
			current_rank = ranks_sorted[ix];
		}

		if (phoenix != null) {
			// phoenix has not been used, place phoenix at end
			return current_rank + 1;
		} else {
			return current_rank;
		}
	}

	of_same_color(cards) {
		const color = global_cards.get_card_color(cards[0]);
		for (let ix = 1; ix < cards.length; ix++) {
			const next_color = global_cards.get_card_color(cards[ix]);
			if (next_color != color) {
				return false;
			}
		}
		return true;
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



const global_tichuRules = new TichuRules();

