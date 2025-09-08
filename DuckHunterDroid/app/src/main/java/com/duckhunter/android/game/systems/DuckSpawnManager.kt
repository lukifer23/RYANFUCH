package com.duckhunter.android.game.systems

import android.util.Log
import com.duckhunter.android.game.entities.Duck
import com.duckhunter.android.game.entities.Player
import com.duckhunter.android.game.utils.Constants
import kotlin.random.Random

class DuckSpawnManager(private val ducks: MutableList<Duck>, private var player: Player?) {

    private val TAG = "DuckSpawnManager"
    private var spawnTimer = 0f
    private val baseSpawnInterval = 2.0f // seconds

    fun update(deltaTime: Float) {
        // Decrease spawn interval and increase speed based on score
        val playerScore = player?.score ?: 0
        val spawnInterval = kotlin.math.max(0.5f, baseSpawnInterval - (playerScore / 5000f))

        spawnTimer += deltaTime
        if (spawnTimer >= spawnInterval) {
            spawnTimer = 0f
            spawnDuck()
        }
    }

    private fun spawnDuck() {
        // Spawn from the left side at a random height
        val yPos = Random.nextInt(50, Constants.SCREEN_HEIGHT - 200)

        // Choose duck type based on weighted probability
        val duckType = chooseDuckType()
        val newDuck = Duck(duckType, -50f, yPos.toFloat())

        // Increase duck speed based on score
        val speedBonus = (player?.score ?: 0) / 100
        newDuck.speed += speedBonus

        ducks.add(newDuck)

        Log.d(TAG, "Spawned ${duckType.name} duck at y=$yPos with speed bonus: $speedBonus")
    }

    private fun chooseDuckType(): Duck.DuckType {
        // Duck type weights (higher score = more rare ducks)
        val playerScore = player?.score ?: 0
        val duckTypes = Duck.DuckType.values()
        val weights = when {
            playerScore > 5000 -> doubleArrayOf(40.0, 30.0, 20.0, 10.0) // High score - more rare ducks
            playerScore > 2000 -> doubleArrayOf(50.0, 30.0, 15.0, 5.0)   // Medium score
            else -> doubleArrayOf(60.0, 25.0, 10.0, 5.0)                 // Low score - mostly common
        }

        // Adjust weights based on score (more rare ducks at higher scores)
        val scoreBonus = kotlin.math.min(20.0, playerScore / 1000.0) // Cap at 20% bonus
        weights[1] = kotlin.math.min(35.0, weights[1] + scoreBonus)  // Rare ducks
        weights[2] = kotlin.math.min(20.0, weights[2] + scoreBonus * 0.5)  // Golden ducks
        weights[3] = kotlin.math.min(10.0, weights[3] + scoreBonus * 0.3)  // Boss ducks

        // Normalize weights
        val totalWeight = weights.sum()
        val normalizedWeights = weights.map { it / totalWeight }

        return duckTypes.randomByWeight(normalizedWeights)
    }

    // Extension function for weighted random selection
    private fun <T> Array<T>.randomByWeight(weights: List<Double>): T {
        val randomValue = Random.nextDouble()
        var cumulativeWeight = 0.0

        for (i in indices) {
            cumulativeWeight += weights[i]
            if (randomValue <= cumulativeWeight) {
                return this[i]
            }
        }

        return this[0] // Fallback
    }
}
