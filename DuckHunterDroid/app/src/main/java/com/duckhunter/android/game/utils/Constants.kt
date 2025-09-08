package com.duckhunter.android.game.utils

object Constants {
    // Screen dimensions
    const val SCREEN_WIDTH = 1920
    const val SCREEN_HEIGHT = 1080
    const val FPS = 60

    // Colors (RGB)
    val BLACK = Triple(0, 0, 0)
    val WHITE = Triple(255, 255, 255)

    // Game states
    const val MAIN_MENU = "main_menu"
    const val GAMEPLAY = "gameplay"
    const val GAME_OVER = "game_over"

    // File paths
    const val ASSETS_PATH = "assets"
    const val SPRITES_PATH = "$ASSETS_PATH/sprites"
    const val AUDIO_PATH = "$ASSETS_PATH/audio"
    const val FONTS_PATH = "$ASSETS_PATH/fonts"
    const val DATA_PATH = "$ASSETS_PATH/data"
    const val SAVES_PATH = "saves"
    const val CONFIG_PATH = "config"
    const val SETTINGS_FILE = "$CONFIG_PATH/settings.json"
    const val KEYBINDS_FILE = "$CONFIG_PATH/keybinds.json"
}
