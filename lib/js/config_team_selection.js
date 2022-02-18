/**
 * very simple scene for team selection
 */

document.currentScript = document.currentScript || (function () {
    const scripts = document.getElementsByTagName('script');
    return scripts[scripts.length - 1];
})();

const config_team = {
    type: Phaser.AUTO,
    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT,
    backgroundColor: BACKGROUND_COLOR,
	player_avatar: document.currentScript.getAttribute('name'), 
    scene: [TeamSelection]
};

let game = new Phaser.Game(config_team);
