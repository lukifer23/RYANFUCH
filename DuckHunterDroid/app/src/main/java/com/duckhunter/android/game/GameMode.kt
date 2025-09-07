package com.duckhunter.android.game

enum class GameMode(
    val displayName: String,
    val maxLives: Int,
    val maxAmmo: Int,
    val description: String
) {
    EASY("Easy Mode", 10, 15, "10 lives, 15 ammo - Perfect for beginners"),
    NORMAL("Normal Mode", 3, 8, "3 lives, 8 ammo - Balanced challenge"),
    HARD("Hard Mode", 1, 5, "1 life, 5 ammo - Hardcore difficulty"),
    GOD("God Mode", Int.MAX_VALUE, Int.MAX_VALUE, "∞ lives, ∞ ammo - Pure fun mode (5 min limit)");

    companion object {
        fun fromString(name: String): GameMode {
            return values().find { it.name == name } ?: NORMAL
        }
    }
}
