/**
 * actual Tichu game configuration
 */

const config_phase_wait_for_players = {
    type: Phaser.AUTO,
    physics: {
        default: 'arcade',
        arcade: {
            gravity: { y: 300 },
            debug: false,
        }
    },

    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT,
    backgroundColor: BACKGROUND_COLOR,
    scene: [PhaseGame]
};
