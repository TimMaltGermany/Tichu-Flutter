class Cards {
	constructor() { }
	get_card_rank(card) {
		// console.log("Custom data - rank: " + card.frame.customData.rank + ", color: " + card.frame.customData.color)
		return card.frame.customData.rank;
	}
	get_card_color(card) {
		return card.frame.customData.color;
	}

}

let lastTime = 0;

const global_cards = new Cards();

function createCards(context) {
	const cards = context.textures.get('cards').getFrameNames();

	// target.card_images = {}
	for (let i = 0; i < cards.length; i++) {
		if (cards[i] !== 'xx_backside') {
			// const card = context.add.sprite(-10, -10, 'cards', cards[i]).setOrigin(0, 0).setInteractive();
			const card = context.physics.add.sprite(-10, -10, 'cards', cards[i]).setOrigin(0, 0).setScale(1.5, 1.5).setInteractive();
			card.body.setGravityY(0)
			card.setBounce(0);
			card.setCollideWorldBounds(true);
			card.body.allowGravity = false

			card.setVisible(false);
			card.setDataEnabled();
			card.setName(cards[i]); //.slice(0, -4)
			card.setData('type', 'card');
			// target.card_images[cards[i]] = card;
			context.input.setDraggable(card);
		}
	}
	create_listeners(context);
}

function create_listeners(context) {
	context.input.on('dragstart', function(_pointer, gameObject) {
		context.children.bringToTop(gameObject);
	}, this);

	context.input.on('drag', function(_pointer, gameObject, dragX, dragY) {
		gameObject.x = dragX;
		gameObject.y = dragY;
	});

	//context.input.on('dragenter', function(pointer, gameObject, dropZone) {
	//});
	//context.input.on('dragleave', function(pointer, gameObject, dropZone) {
	//});

	context.input.on('drop', function(_pointer, gameObject, dropZone) {
		removeCardFromDropZone(context.children.getByName('PLAY_AREA'), gameObject);
		removeCardFromDropZone(context.children.getByName(PLAYER_ROLE_AFTER), gameObject);
		removeCardFromDropZone(context.children.getByName(PLAYER_ROLE_BEFORE), gameObject);
		removeCardFromDropZone(context.children.getByName(PLAYER_ROLE_PARTNER), gameObject);
		if (dropZone.name == PLAYER_ROLE_ACTIVE) {
			if (dropZone.active) {
				context.check_play_button();
				context.check_schupfen_button();
			}
		} else if (dropZone.name == "PLAY_AREA") {
			if (dropZone.active) {
				addCardToDropZone(dropZone, gameObject);
				context.check_play_button();
			}
		} else {
			if (dropZone.active) {
				// const w = dropZone.width - CARD_WIDTH;
				gameObject.x = dropZone.x - 0.5 * CARD_WIDTH;
				gameObject.y = dropZone.y - 0.5 * CARD_HEIGHT;
				addCardToDropZone(dropZone, gameObject);
				context.check_schupfen_button();
			}
		}
	});

	context.input.on('dragend', function(pointer, gameObject, dropped) {
		if (gameObject.input.dragStartX - 1 < pointer.x < gameObject.input.dragStartX + 1) {
			if (gameObject.input.dragStartY - 1 < pointer.y < gameObject.input.dragStartY + 1) {
				dropped = true;
			}
		}
		if (!dropped) {
			gameObject.x = gameObject.input.dragStartX;
			gameObject.y = gameObject.input.dragStartY;
		}
	});
	context.input.on('pointerdown', function(_pointer, gameObject) {
		//var touchX = pointer.x;
		//var touchY = pointer.y;
		let clickDelay = context.time.now - lastTime;
		if (gameObject != null && gameObject.length > 0) {
			if (gameObject != null && gameObject.length > 1) {
				console.log("more than one object selected: " + gameObject.length);
			}
			if (clickDelay > 0 && clickDelay < 350) {
				if (context.process_double_click(gameObject[0])) {
					addCardToDropZone(context.children.getByName('PLAY_AREA'), gameObject[0]);
				}
				context.check_play_button();
			}
		}
		lastTime = context.time.now;
	});
}

function addCardToDropZone(zone, card) {
	const tmp = zone.getData(CARDS_IN_ZONE);
	tmp.add(card);
	// zone.setData(CARDS_IN_ZONE, tmp);
}

function removeCardFromDropZone(zone, card) {
	if (zone != null) {
		const tmp = zone.getData(CARDS_IN_ZONE);
		tmp.delete(card);
		// for (let i = 0; i < tmp.length; i++) {
		//	if (tmp[i] === card) {
		//		tmp.splice(i, 1);
		//	}
		//}
		//zone.setData(CARDS_IN_ZONE, tmp);
	}
}



function hideCards(context) {
	const cards = context.textures.get('cards').getFrameNames();

	for (let i = 0; i < cards.length; i++) {
		const card = context.children.getByName(cards[i]);
		if (card != null) {
			card.setVisible(false);
		}
	}
}

function createDropCards(context) {
	const cards = context.textures.get('cards').getFrameNames();

	for (let i = 0; i < cards.length; i++) {
		if (cards[i] !== 'xx_backside') {
			let card = context.children.getByName('drop-' + cards[i]);
			if (card == null) {
				card = context.physics.add.sprite(Phaser.Math.Between(0, SCREEN_WIDTH - CARD_WIDTH),
					Phaser.Math.Between(0, SCREEN_HEIGHT / 2), 'cards', cards[i]);
			} else {
				card.x = Phaser.Math.Between(0, SCREEN_WIDTH - CARD_WIDTH);
				card.y = Phaser.Math.Between(0, SCREEN_HEIGHT / 2);
			}
			card.body.setGravityY(300)
			card.setName('drop-' + cards[i]);
			card.setBounce(0.95);
			card.setCollideWorldBounds(true);
		}
	}
}

function hideDropCards(context) {
	const cards = context.textures.get('cards').getFrameNames();

	for (let i = 0; i < cards.length; i++) {
		if (cards[i] !== 'xx_backside') {
			const card = context.children.getByName('drop-' + cards[i]);
			if (card != null) {
				card.destroy();
			}
		}
	}
}

let cards_on_table = null;

function show_cards_on_table(current_trick) {
	if (PhaseGame.text === undefined) {
		//could happen at startup
		return;
	}
	let depth = 0;
	if (cards_on_table == null) {
		cards_on_table = new Phaser.GameObjects.Group(PhaseGame.text.scene);
	}
	//hide cards already on table
	const children = cards_on_table.getChildren();
	for (let j = 0; j < children.length; j++) {
		children[j].setVisible(false);
	}
	cards_on_table.clear();
	if (global_tichuRules.global_highest_play != null) {
		global_tichuRules.global_highest_play.clear();
	} else {
		global_tichuRules.global_highest_play = new Phaser.GameObjects.Group(PhaseGame.text.scene);
	}
	if (current_trick !== undefined) {
		for (let i = 0; i < current_trick.length; i++) {
			const cards_played = current_trick[i];
			//console.log(cards_played);
			for (let j = 0; j < cards_played.length; j++) {
				depth += 1;
				const data = cards_played[j];
				const card = PhaseGame.text.scene.children.getByName(data.key)
				card.depth = depth;
				card.x = data.x;
				card.y = data.y;
				card.setVisible(true);
				cards_on_table.add(card);
				if (i == current_trick.length - 1) {
					global_tichuRules.global_highest_play.add(card);
				}
			}
			if (cards_played.length == 1 && cards_played[0].key == '99') {
				//dogs don't matter here
				global_tichuRules.global_highest_play.clear();
			}
		}
	}
}

function annimate_trick_taken(trick_to_animate, highest_trick_owner) {
	const target_pos_x = highest_trick_owner.img.x;
	const target_pos_y = highest_trick_owner.img.y;


	for (let i = 0; i < trick_to_animate.length; i++) {
		const data = trick_to_animate[i];
		if (data.key != '99') {
			const card = PhaseGame.text.scene.children.getByName(data.key);
			card.setVisible(true);
			// console.log('moving from ' + card.x + '/' + card.y + ' to ' + target_pos_x + '/' + target_pos_y);
			tween_card(card, target_pos_x, target_pos_y, false);
		} else {
			card.x = target_pos_x;
			card.y = target_pos_y;
		}
	}
}

function tween_card(card, target_pos_x, target_pos_y, keep_visible) {
	// console.log("Tweening card " + card.name + " to (" + target_pos_x + ", " + target_pos_y + "), visible: " + keep_visible);
	card.scene.tweens.add({
		targets: card,
		x: target_pos_x,
		y: target_pos_y,
		ease: 'Power1',
		duration: 3000,
		yoyo: false,
		repeat: 0,
		onComplete: function() {
			card.setVisible(keep_visible);
		}
		/*
		,               onStart: function () {
						   console.log('onStart');
						   console.log(arguments);
					   },
					   onYoyo: function () {
						   console.log('onYoyo');
						   console.log(arguments);
					   },
					   onRepeat: function () {
						   console.log('onRepeat');
						   console.log(arguments);
					   },*/
	});
}


