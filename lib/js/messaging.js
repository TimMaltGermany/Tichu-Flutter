/**
 * TimMaltGermany, 2020-05
 */
const namespace = '/tichu';


document.currentScript = document.currentScript || (function() {
	const scripts = document.getElementsByTagName('script');
	return scripts[scripts.length - 1];
})();

let game = new Phaser.Game(config_phase_wait_for_players);
game.loop.targetFps = 10;


const Messaging = {
	id: null,
	uuid: document.currentScript.getAttribute('uuid'),
	team: decodeURI(document.currentScript.getAttribute('team')),
	name: decodeURI(document.currentScript.getAttribute('name')),
	socket: io(namespace),
	scene: PhaseGame,
	ready: false,
	game_phase: null
};

Messaging.setReady = function() {
	const first = Messaging.ready;
	Messaging.ready = true;
	if (!first) {
		Messaging.socket.emit('update_player', {
			uuid: Messaging.uuid, player_id: Messaging.id
		});
	}
}

Messaging.socket.on('connect', function() {
	console.log("Player '" + Messaging.name + "' is connected!");
	console.log("START: registering new player '" + Messaging.name + "' for team '" + Messaging.team + "' on server...");
	Messaging.socket.emit('register_player', {
		uuid: Messaging.uuid, player_name: Messaging.name, team_name: Messaging.team
	});
});

Messaging.socket.on('disconnect', function() {
	console.log("Player '" + Messaging.name + "' is disconnected from server!");
});


Messaging.socket.on('register_player', function(data) {
	Messaging.id = data.player_id;
	console.log("DONE:  registered new player '" +
		Messaging.name + "' (id: '" + Messaging.id + "', seat no: '" +
		data.value[0] + "', team: '" + data.value[1] + "', phase: '" + data.game_phase + "') on server.");
	Messaging.team = data.value[1];
});

function create_game_for_phase(game_phase) {
	if (game_phase !== Messaging.game_phase || game_phase == GAME_STATE_NEW) {
		PhaseGame.start_phase(game_phase);
		Messaging.game_phase = game_phase;
	}
}


Messaging.socket.on('player_update', function(data) {
	if (Messaging.ready) {
		create_game_for_phase(data.game_phase);
		Messaging.scene.showPlayerAvatars(data.value);
	}
});

Messaging.socket.on('update_game_state', function(game_state) {
	if (Messaging.ready) {
		updateGameState(game_state);
	}
});

Messaging.socket.on('assign_drake', function(player_id) {
	PhaseGame.assignDrake(player_id);
});

Messaging.drake_given_to = function(target) {
	Messaging.socket.emit('assign_drake', { player_role: target, player_id: Messaging.id });
};


updateGameState = function(game_state) {

	show_cards_on_table(game_state.current_trick);

	if (game_state.highest_trick_owner !== undefined) {
		let highest_trick_owner = get_highest_trick_owner_avatar(game_state.highest_trick_owner);
		if (game_state.trick_to_animate !== undefined) {
			annimate_trick_taken(game_state.trick_to_animate, highest_trick_owner);
		}
	}

	if (game_state.game_scores !== undefined) {
		PhaseGame.show_scores(game_state.game_scores);
	} else {
		PhaseGame.clear_scores();
	}
}

Messaging.deal_new_game = function() {
	// tell server to deal new cards
	Messaging.socket.emit('deal_new_game');
};

Messaging.button_pressed = function(btn_name) {
	if (btn_name === 'button_neues_spiel.png') {
		if (Messaging.game_phase == null || Messaging.game_phase == GAME_STATE_NEW) {
			Messaging.deal_new_game();
		} else {
			// ask for confirmation first
			PhaseGame.askConfirmation("Soll wirklich neu gegeben werden?", Messaging.deal_new_game, null);
		}
	} else if (btn_name === 'button_grand_tichu.png') {
		Messaging.socket.emit('announce', { player_id: Messaging.id, value: 'Grand Tichu' });
		create_game_for_phase(GAME_STATE_3_SCHUPFEN);
	} else if (btn_name === 'button_tichu.png') {
		Messaging.socket.emit('announce', { player_id: Messaging.id, value: 'Tichu' });
	} else if (btn_name === 'button_restl_karten.png') {
		Messaging.socket.emit('announce', { player_id: Messaging.id });
		create_game_for_phase(GAME_STATE_3_SCHUPFEN);
	} else if (btn_name === 'button_schupfen.png') {
		const cards = PhaseGame.get_cards_schupfen();
		if (cards != null) {
			Messaging.socket.emit('geschupft', { player_id: Messaging.id, value: cards });
			create_game_for_phase(GAME_STATE_5_PLAY);
		}
	} else if (btn_name === 'button_spielen.png') {
		Messaging.socket.emit('turn_finished', { player_id: Messaging.id, value: PhaseGame.get_cards_to_play() });
	} else if (btn_name === 'button_bombe.png') {
		Messaging.socket.emit('turn_finished', { player_id: Messaging.id, value: PhaseGame.get_cards_to_play() });
	} else if (btn_name === 'button_passen.png') {
		Messaging.socket.emit('turn_finished', { player_id: Messaging.id, value: 'passen' });
	}
}

Messaging.socket.on('deal_new_game', function() {
	// server has dealt new cards as a response to emit message from above
	Messaging.game_phase = null;
	create_game_for_phase(GAME_STATE_2_GRAND_TICHU);
});

Messaging.socket.on('play_sound', function(data) {
	// play some sound as indicated by server
	PhaseGame.play_sound(data.value);
});
