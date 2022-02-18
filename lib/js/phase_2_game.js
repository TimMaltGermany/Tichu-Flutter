const PhaseGame = new Phaser.Class({
	Extends: Phaser.Scene,
	initialize:
		function PhaseGame() {
			Phaser.Scene.call(this, { key: 'phase_game', active: true });
		},

	text: undefined,
	score_text: undefined,
	score_popup: undefined,
	playButtonAlwaysOn: false,

	preload: function() {
		console.log("Preload PhaseGame Scene")
		this.load.atlas('cards', 'static/assets/atlas/cards.png', 'static/assets/atlas/cards.json');
		this.load.image('card-backside', 'static/assets/icons/xx_backside.png');
		// created with https://www.codeandweb.com/free-sprite-sheet-packer
		this.load.atlas('buttons', 'static/assets/atlas/buttons.png', 'static/assets/atlas/buttons.json');
		this.load.audio('bark', ['static/assets/sound/bark1.ogg', 'static/assets/sound/bark1.wav']);
		this.load.audio('Grand Tichu', ['static/assets/sound/grand_tichu.ogg', 'static/assets/sound/grand_tichu.wav']);
		this.load.audio('Tichu', ['static/assets/sound/tichu.ogg', 'static/assets/sound/tichu.wav']);
	},

	create: function() {
		createAvatars(this);
		createCards(this);

		PhaseGame.text = this.add.text(100, 230, "", {
			font: '24px Courier',
			fill: WHITE,
			fillStyle: { color: BLACK, alpha: 1 }
		});

		PhaseGame.score_text = this.add.text(SCREEN_WIDTH / 2 + 100, 20, "", {
			font: '16px Courier',
			fill: WHITE,
			fillStyle: { color: BLACK, alpha: 1 }
		});

		this.addButton({ name: 'button_neues_spiel.png', x: 80, y: 80 });
		this.addButton({ name: 'button_restl_karten.png', x: SCREEN_WIDTH / 2, y: SCREEN_HEIGHT - 220 });
		this.addButton({ name: 'button_grand_tichu.png', x: 80, y: SCREEN_HEIGHT - 220 });
		// this.addButton({ name: 'button_tichu.png', x: SCREEN_WIDTH - 80, y: SCREEN_HEIGHT - 50 });
		this.addButton({ name: 'button_tichu.png', x: 80, y: SCREEN_HEIGHT - 220 });
		this.addButton({ name: 'button_spielen.png', x: SCREEN_WIDTH / 2 + 300, y: SCREEN_HEIGHT - 250 });
		this.addButton({ name: 'button_passen.png', x: SCREEN_WIDTH - 150, y: SCREEN_HEIGHT - 250 });
		this.addButton({ name: 'button_schupfen.png', x: SCREEN_WIDTH / 2, y: SCREEN_HEIGHT - 270 });
		this.addButton({ name: 'button_bombe.png', x: SCREEN_WIDTH - 150, y: SCREEN_HEIGHT - 150 });
		this.addButton({ name: 'button_nein.png', x: SCREEN_WIDTH / 2 + 150, y: SCREEN_HEIGHT / 2 });
		this.addButton({ name: 'button_ja.png', x: SCREEN_WIDTH / 2 - 150, y: SCREEN_HEIGHT / 2 });

		PhaseGame.score_popup = this.add_popup('', PhaseGame.score_text, PhaseGame.score_text.x, PhaseGame.score_text.y, 20);
		this.create_drop_zones();


		const spaceKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE);
		// const soundKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.S);
	    // var bark = this.sound.add('bark');

		//  Emits only when the SPACE BAR is pressed down, and dispatches from the local Key object.
		//  Call stopImmediatePropagation to stop it reaching the two global handlers in this Scene.
		//  Call stopPropagation to stop it reaching any other Scene.
		spaceKey.on('down', function(key, event) {

			// event.stopPropagation();
			// event.stopImmediatePropagation();
			PhaseGame.playButtonAlwaysOn = !PhaseGame.playButtonAlwaysOn;
		});

		//soundKey.on('down', function(key, event) {
        //	bark.play();
		//});

		console.log("Created PhaseGame Scene")
	},
	create_new_game_phase: function() {
		console.log("Create 'new game' game phase");
		createDropCards(this);
		this.activate_obj('PLAY_AREA_', false);
		setInitialText(PhaseGame.text, 'wir warten noch auf die anderen Spieler...');
	},
	create_grand_tichu_phase: function() {
		hideDropCards(this);
		setInitialText(PhaseGame.text, ' entscheide, ob du ein großes Tichu ansagen möchtest.');
		this.activate_obj('button_neues_spiel.png', true);
		this.activate_obj('button_grand_tichu.png', true);
		this.activate_obj('button_restl_karten.png', true);
		this.activate_obj('button_bombe.png', false);
		this.activate_obj('button_tichu.png', false);
		this.activate_obj('PLAY_AREA_', false);
		this.children.getByName('PLAY_AREA').active = false;
	},
	create_schupfen_phase: function() {
		console.log("Create 'schupfen' game phase");
		PhaseGame.text.setText('');
		this.activate_obj('button_neues_spiel.png', true);
		this.activate_obj('button_grand_tichu.png', false);
		this.activate_obj('button_restl_karten.png', false);
		this.activate_obj('button_tichu.png', true);
		this.activate_obj('schupf-zone-', true);
		this.children.getByName(PLAYER_ROLE_BEFORE).active = true;
		this.children.getByName(PLAYER_ROLE_PARTNER).active = true;
		this.children.getByName(PLAYER_ROLE_AFTER).active = true;
	},

	create_play_phase: function() {
		console.log("Create 'play' game phase");
		this.activate_obj('button_neues_spiel.png', true);
		this.activate_obj('button_tichu.png', true);
		// this.activate_obj('button_bombe.png', true);
		this.activate_obj('button_schupfen.png', false);
		this.activate_obj('schupf-zone-', false);
		this.children.getByName(PLAYER_ROLE_BEFORE).active = false;
		this.children.getByName(PLAYER_ROLE_PARTNER).active = false;
		this.children.getByName(PLAYER_ROLE_AFTER).active = false;
		this.activate_obj('PLAY_AREA_', true);
		this.children.getByName('PLAY_AREA').active = true;
		PhaseGame.text.x = 130;
		//PhaseGame.text.y = 350;
		PhaseGame.text.setText('');
		this.data.set('player_active', false);
	},

	update: function() {
		Messaging.setReady();
		// console.log("update called... actual fps: " + game.loop.actualFps + ", target: " + game.loop.targetFps);
	},


	addButton: function(btn) {
		// console.log("Showing button: " + btn.name + " at: (" + btn.x + "," + btn.y + ")")
		const image = this.add.image(btn.x, btn.y,
			'buttons', btn.name).setInteractive();
		image.setName(btn.name);
		image.depth = 99;
		image.on('pointerdown', function(_pointer) {
			this.setTint(BUTTON_TINT);
		});

		image.on('pointerout', function(_pointer) {
			this.clearTint();
		});

		image.on('pointerup', function(_pointer) {
			this.clearTint();
			Messaging.button_pressed(btn.name);
		});
		image.setVisible(false);
	},

	activate_obj: function(btn_name, enable) {
		const btn = this.children.getByName(btn_name);
		if (btn !== undefined && btn != null) {
			btn.setVisible(enable);
		} else {
			console.log("unknown game object: " + btn_name);
		}
	},

	add_popup: function(content, obj, x, y, offset) {

		const popup = this.add.text(x + offset, y + 20, content, {
			font: '16px Courier',
			fill: WHITE,
			fillStyle: { color: BLACK, alpha: 1 }
		});
		popup.setVisible(false);
		obj.setInteractive();
		obj.on('pointerover', function(_pointer) {
			popup.setVisible(true);
		});

		obj.on('pointerout', function(_pointer) {
			popup.setVisible(false);
		});
		return popup;
	},

	set_player_active: function(status, role) {
		if (role === PLAYER_ROLE_ACTIVE) {
			if (status === 'player active') {
				//show play and pass buttons
				const new_trick = (cards_on_table === undefined || cards_on_table.getLength() == 0);
				this.activate_obj('button_passen.png', !new_trick);
				this.data.set('player_active', true);
				this.check_play_button();
			} else {
				this.data.set('player_active', false);
				//hide play and pass buttons
				this.activate_obj('button_spielen.png', false);
				this.activate_obj('button_passen.png', false);
				if (status === 'player done') {
					this.activate_obj('PLAY_AREA_', false);
					this.activate_obj('button_tichu.png', false);
				}
			}
		}
	},
	create_drop_zones() {
		let graphics = this.add.graphics({ lineStyle: { width: 2, color: 0x0000aa }, fillStyle: { color: 0xaa0000 } });
		graphics.lineStyle(3, BLACK);

		const width = CARD_WIDTH + CARD_BOUNDARY;
		const height = CARD_HEIGHT + CARD_BOUNDARY;
		//home zone
		const zone = this.add.zone(0, 0,
			SCREEN_WIDTH, SCREEN_HEIGHT).setOrigin(0, 0).setRectangleDropZone(SCREEN_WIDTH, SCREEN_HEIGHT);
		zone.setName(PLAYER_ROLE_ACTIVE);
		zone.depth = -10;

		this.create_single_zone(0.75 * SCREEN_WIDTH - 0.5 * width, 0.5 * SCREEN_HEIGHT, width, height, graphics, PLAYER_ROLE_AFTER);
		this.create_single_zone(0.5 * SCREEN_WIDTH - 0.5 * width, 0.3 * SCREEN_HEIGHT, width, height, graphics, PLAYER_ROLE_PARTNER);
		this.create_single_zone(0.25 * SCREEN_WIDTH - 0.5 * width, 0.5 * SCREEN_HEIGHT, width, height, graphics, PLAYER_ROLE_BEFORE);

		graphics = this.add.graphics({ lineStyle: { width: 2, color: 0x0000aa }, fillStyle: { color: 0xaa0000 } });
		graphics.lineStyle(3, BLACK);

		const play_zone = this.add.zone(SCREEN_WIDTH / 2 - 200, SCREEN_HEIGHT - 400,
			400, 200).setOrigin(0, 0).setRectangleDropZone(400, 200);
		play_zone.setName("PLAY_AREA");
		play_zone.setData(CARDS_IN_ZONE, new Set());
		play_zone.depth = -7;
		play_zone.active = false;
		let obj = new Phaser.Geom.Rectangle(play_zone.x, play_zone.y,
			play_zone.input.hitArea.width, play_zone.input.hitArea.height - 2);
		obj = graphics.strokeRectShape(obj);
		obj.setName('PLAY_AREA_');
		obj.setVisible(false);
		obj.depth = -5;
	},

	create_single_zone: function(x, y, width, height, graphics, role) {
		const zone = this.add.zone(x + width, y + height,
			width, height).setRectangleDropZone(width, height);
		zone.setName(role);
		zone.depth = -5;
		zone.setData(CARDS_IN_ZONE, new Set());
		const rect = graphics.strokeRectShape(new Phaser.Geom.Rectangle(zone.x - zone.input.hitArea.width / 2,
			zone.y - zone.input.hitArea.height / 2,
			zone.input.hitArea.width, zone.input.hitArea.height));
		rect.setName('schupf-zone-'); // + role);
		rect.setVisible(false);
		return rect;
	},
	create_end_phase: function() {
		this.activate_obj('button_neues_spiel.png', true);
		hideCards(this);
	},

	player_done: function() {
		console.log("Player " + Messaging.name + " is done");
		this.activate_obj('button_spielen.png', false);
		this.activate_obj('button_passen.png', false);
		this.activate_obj('PLAY_AREA_', false);
		this.activate_obj('button_bombe.png', false);
	},

	process_double_click: function(card) {
		// console.log("obj selected: " + obj_name)
		//if (obj_name !== undefined && obj_name != null) {
		//	const card = this.children.getByName(obj_name);
		const tmp = card.getData('type');
		if (card != null && tmp === 'card') {
			if (card.visible) {
				if (Messaging.game_phase === GAME_STATE_5_PLAY) {
					// console.log("card selected: " + obj_name)
					card.x = Phaser.Math.Between(SCREEN_WIDTH / 2 - 200, SCREEN_WIDTH / 2 + 150);
					card.y = Phaser.Math.Between(SCREEN_HEIGHT - 400, SCREEN_HEIGHT - 300);
					return true;
				}
			}
		}
		//}
		return false;
	},
	check_play_button: function() {
		const cards = this.get_cards_in_area('PLAY_AREA', false);
		if (cards != null) {
			cards.sort(function(c1, c2) { return global_cards.get_card_rank(c1) - global_cards.get_card_rank(c2) });
			let x = SCREEN_WIDTH / 2 - 180;
			const y = SCREEN_HEIGHT - 350;
			depth = 10;
			for (let ix = 0; ix < cards.length; ix++) {
				cards[ix].x = x;
				cards[ix].y = y;
				cards[ix].depth = depth;
				x += 15;
				depth += 1;
			}
		}
		this.activate_obj('button_spielen.png', false);
		if (this.data.get('player_active')) {
			if (PhaseGame.playButtonAlwaysOn) {
				this.activate_obj('button_spielen.png', true);
			} else {
				if (cards.length > 0 && global_tichuRules.is_valid_and_higher_set(cards)) {
					this.activate_obj('button_spielen.png', true);
				}
			}
		}

		if (cards != null && global_tichuRules.is_valid_and_higher_bomb(cards)) {
			this.activate_obj('button_bombe.png', true);
		} else {
			this.activate_obj('button_bombe.png', false);
		}
	},
	check_schupfen_button: function() {
		const zone = this.children.getByName('schupf-zone-');
		if (zone.visible) {
			const cards = this.get_cards_in_schupf_areas(false);
			if (cards != null) {
				this.activate_obj('button_schupfen.png', true);
			} else {
				this.activate_obj('button_schupfen.png', false);
			}
		}
	},
	get_cards_in_area: function(areaName, clear) {
		const area = this.children.getByName(areaName);
		if (area != null) {
			const cards = Array.from(area.getData(CARDS_IN_ZONE));
			if (clear) {
				area.setData(CARDS_IN_ZONE, new Set());
			}
			return cards.filter(function(c) {
			 	return c.visible;
			});
		} else {
			return null;
		}
	},
	get_cards_in_schupf_areas: function(clear) {
		const cards_after = this.get_cards_in_area(PLAYER_ROLE_AFTER, clear);
		if (cards_after.length != 1) {
			return null;
		}
		const cards_before = this.get_cards_in_area(PLAYER_ROLE_BEFORE, clear);
		if (cards_before.length != 1) {
			return null;
		}
		const cards_partner = this.get_cards_in_area(PLAYER_ROLE_PARTNER, clear);
		if (cards_partner.length != 1) {
			return null;
		}
		return {
			PLAYER_ROLE_AFTER: cards_after[0], PLAYER_ROLE_PARTNER: cards_partner[0],
			PLAYER_ROLE_BEFORE: cards_before[0]
		}
	}

});

PhaseGame.showPlayerAvatars = function(players) {
	if (PhaseGame.text === undefined) {
		return;
	}
	if (Messaging.game_phase === GAME_STATE_NEW) {
		let txt = Messaging.name;
		//if (Messaging.id !== undefined) {
		//    txt = txt + " (" + Messaging.id + ")";
		//}
		if (players.length < 4) {
			PhaseGame.text.setText(txt + ', wir warten noch auf ' + (4 - players.length) + ' Spieler...');
		} else {
			PhaseGame.text.setText(txt + ', alle Spieler sind eingetroffen. Es kann losgehen!');
			// show 'deal new game button
			PhaseGame.text.scene.activate_obj('button_neues_spiel.png', true);
		}
	}
	for (let i = 0; i < players.length; i++) {
		updateAvatar(PhaseGame.text.scene, players[i]);
	}
}


PhaseGame.get_cards_to_play = function() {
	const cards = PhaseGame.text.scene.get_cards_in_area('PLAY_AREA', true);
	const cards_to_play = [];
	for (let i = 0; i < cards.length; i++) {
		cards_to_play.push(cards[i].name);
	}
	return cards_to_play;
}

PhaseGame.get_cards_schupfen = function() {
	const schupf_card = PhaseGame.text.scene.get_cards_in_schupf_areas(true);
	if (schupf_card != null) {
		const schupf_card_names = {};
		schupf_card_names[PLAYER_ROLE_AFTER] = schupf_card.PLAYER_ROLE_AFTER.name;
		schupf_card_names[PLAYER_ROLE_PARTNER] = schupf_card.PLAYER_ROLE_PARTNER.name;
		schupf_card_names[PLAYER_ROLE_BEFORE] = schupf_card.PLAYER_ROLE_BEFORE.name;

		schupf_card.PLAYER_ROLE_AFTER.setVisible(false);
		schupf_card.PLAYER_ROLE_PARTNER.setVisible(false);
		schupf_card.PLAYER_ROLE_BEFORE.setVisible(false);

		return schupf_card_names;
	} else {
		return null;
	}
}

PhaseGame.assignDrake = function(_player_id) {
	const avatar1 = game.registry.get(PLAYER_ROLE_BEFORE);
	avatar1.img.setInteractive();
	avatar1.img.on('pointerdown', function(_pointer) {
		this.setTint(BUTTON_TINT);
	});

	avatar1.img.on('pointerout', function(_pointer) {
		this.clearTint();
	});

	avatar1.img.on('pointerup', function(_pointer) {
		PhaseGame.text.setText('');
		this.clearTint();
		Messaging.drake_given_to(PLAYER_ROLE_BEFORE);
		this.removeInteractive();
	});

	const avatar2 = game.registry.get(PLAYER_ROLE_AFTER);
	avatar2.img.setInteractive();
	avatar2.img.on('pointerdown', function(_pointer) {
		this.setTint(BUTTON_TINT);
	});

	avatar2.img.on('pointerout', function(_pointer) {
		this.clearTint();
	});

	avatar2.img.on('pointerup', function(_pointer) {
		PhaseGame.text.setText('');
		this.clearTint();
		Messaging.drake_given_to(PLAYER_ROLE_AFTER);
		this.removeInteractive();
	});

	PhaseGame.text.setText('Bitte verschenke den Stich mit dem Drachen (klicke auf den Avatar des Empfängers).');
}

PhaseGame.askConfirmation = function(msg, func_ok, func_abort) {

	const btnAbort = PhaseGame.text.scene.children.getByName('button_nein.png');
	btnAbort.setVisible(true);
	const btnOk = PhaseGame.text.scene.children.getByName('button_ja.png');
	btnOk.setVisible(true);

	btnAbort.on('pointerdown', function(_pointer) {
		this.setTint(BUTTON_TINT);
	});

	btnAbort.on('pointerout', function(_pointer) {
		this.clearTint();
	});

	btnAbort.on('pointerup', function(_pointer) {
		PhaseGame.text.setText('');
		this.clearTint();
		if (func_abort != null) {
			func_abort();
		}
		btnAbort.setVisible(false);
		btnOk.setVisible(false);
	});

	btnOk.on('pointerdown', function(_pointer) {
		this.setTint(BUTTON_TINT);
	});

	btnOk.on('pointerout', function(_pointer) {
		this.clearTint();
	});

	btnOk.on('pointerup', function(_pointer) {
		PhaseGame.text.setText('');
		this.clearTint();
		if (func_ok != null) {
			func_ok();
		}
		btnAbort.setVisible(false);
		btnOk.setVisible(false);
	});


	PhaseGame.text.setText(msg);
}

PhaseGame.start_phase = function(game_phase) {
	if (PhaseGame.text === undefined) {
		return;
	}
	console.log("New game phase: " + game_phase);
	if (game_phase === GAME_STATE_NEW) {
		hideCards(PhaseGame.text.scene);
		PhaseGame.text.scene.create_new_game_phase();
	} else if (game_phase === GAME_STATE_2_GRAND_TICHU) {
		hideCards(PhaseGame.text.scene);
		PhaseGame.text.scene.create_grand_tichu_phase();
	} else if (game_phase === GAME_STATE_3_SCHUPFEN) {
		PhaseGame.text.scene.create_schupfen_phase();
	} else if (game_phase === GAME_STATE_5_PLAY) {
		PhaseGame.text.scene.create_play_phase();
	} else if (game_phase === GAME_STATE_6_END) {
		PhaseGame.text.scene.create_end_phase();
	}
}

PhaseGame.clear_scores = function() {
	PhaseGame.score_text.setText('');
	PhaseGame.score_text.removeInteractive();
}

PhaseGame.play_sound = function(sound) {
	PhaseGame.text.scene.sound.add(sound).play();
}

PhaseGame.show_scores = function(game_scores) {

	let total_scores_team = 0;
	let total_scores_opp_team = 0;
	let name_opp_team = '';
	const content = [];

	for (let i = 0; i < game_scores.length; i++) {
		let our_score = 0;
		let opp_score = 0;
		for (let j = 0; j < game_scores[i].length; j++) {
			const team_score = game_scores[i][j];
			//console.log(team_score);
			//console.log(team_score.team);
			//console.log(team_score.score);
			if (team_score.team == Messaging.team) {
				total_scores_team += team_score.score;
				our_score = team_score.score;
			} else {
				total_scores_opp_team += team_score.score;
				name_opp_team = team_score.team;
				opp_score = team_score.score;
			}
		}
		content.push(our_score + " : " + opp_score);
	}

	if (total_scores_team != 0 || total_scores_opp_team != 0) {
		// "Punktestand: " + 
		const txt = Messaging.team + ": " + total_scores_team + " vs "
			+ name_opp_team + ": " + total_scores_opp_team;
		PhaseGame.score_text.setText(txt);
		const len = PhaseGame.score_text.width;
		PhaseGame.score_text.x = SCREEN_WIDTH - len - 5;
		PhaseGame.score_popup.x = PhaseGame.score_text.x + 0.5 * len;
		PhaseGame.score_popup.y = PhaseGame.score_text.y + 20;
		PhaseGame.score_popup.setText(content);
		//add_popup(PhaseGame.score_text, content, 0.5 * len);
	}
}

