package com.duckhunter.android.game.systems

import android.util.Log
import com.duckhunter.android.game.entities.GroundAnimal
import com.duckhunter.android.game.entities.Player
import com.duckhunter.android.game.utils.Constants
import kotlin.random.Random

class GroundAnimalSpawnManager(private val context: android.content.Context, private val animals: MutableList<GroundAnimal>, private var player: Player?) {

    private val TAG = "GroundAnimalSpawnManager"
    private var spawnTimer = 0f
    private val baseSpawnInterval = 2.5f // seconds (more frequent than ducks)

    fun update(deltaTime: Float) {
        // Decrease spawn interval based on score (more aggressive)
        val playerScore = player?.score ?: 0
        val spawnInterval = kotlin.math.max(0.8f, baseSpawnInterval - (playerScore / 5000f))

        spawnTimer += deltaTime
        if (spawnTimer >= spawnInterval) {
            spawnTimer = 0f
            spawnGroundAnimal()
        }
    }

    private fun spawnGroundAnimal() {
        // Choose animal type based on weighted probability
        val animalType = chooseAnimalType()

        // Create new animal at right edge of screen
        val newAnimal = GroundAnimal(context, animalType, Constants.SCREEN_WIDTH + 100f, 100f)

        animals.add(newAnimal)

        Log.d(TAG, "Spawned ${animalType.name} animal")
    }

    private fun chooseAnimalType(): GroundAnimal.AnimalType {
        val playerScore = player?.score ?: 0
        val animalTypes = GroundAnimal.AnimalType.values()

        // Base weights for different animals
        val weights = when {
            playerScore > 8000 -> doubleArrayOf(30.0, 25.0, 20.0, 15.0, 7.0, 3.0)   // High score - more rare animals
            playerScore > 4000 -> doubleArrayOf(35.0, 25.0, 20.0, 12.0, 6.0, 2.0)   // Medium-high score
            playerScore > 2000 -> doubleArrayOf(40.0, 25.0, 18.0, 10.0, 5.0, 2.0)   // Medium score
            else -> doubleArrayOf(40.0, 30.0, 25.0, 20.0, 10.0, 15.0)                // Low score - mostly common
        }

        // Adjust weights based on score (more rare animals at higher scores)
        val scoreBonus = kotlin.math.min(25.0, playerScore / 3000.0) // Cap at 25% bonus
        weights[3] = kotlin.math.min(35.0, weights[3] + scoreBonus) // Moose
        weights[4] = kotlin.math.min(20.0, weights[4] + scoreBonus * 0.8) // Bear
        weights[5] = kotlin.math.min(25.0, weights[5] + scoreBonus * 0.6) // Dinosaur

        // Normalize weights
        val totalWeight = weights.sum()
        val normalizedWeights = weights.map { it / totalWeight }

        return animalTypes.randomByWeight(normalizedWeights)
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
