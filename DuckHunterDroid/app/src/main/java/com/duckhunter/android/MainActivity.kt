package com.duckhunter.android

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.duckhunter.android.game.GameActivity
import com.duckhunter.android.game.GameMode

class MainActivity : AppCompatActivity() {

    private lateinit var titleText: TextView
    private lateinit var subtitleText: TextView
    private lateinit var easyButton: Button
    private lateinit var normalButton: Button
    private lateinit var hardButton: Button
    private lateinit var godButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Don't hide system UI for main menu - we want the menu to be visible
        // hideSystemUI() // Commented out - let system UI show for menu

        initializeViews()
        setupClickListeners()

        // Add debugging to verify views are loaded
        android.util.Log.i("MainActivity", "MainActivity created successfully")
        android.util.Log.i("MainActivity", "Title text: ${titleText.text}")
    }

    private fun initializeViews() {
        titleText = findViewById(R.id.titleText)
        subtitleText = findViewById(R.id.subtitleText)
        easyButton = findViewById(R.id.easyButton)
        normalButton = findViewById(R.id.normalButton)
        hardButton = findViewById(R.id.hardButton)
        godButton = findViewById(R.id.godButton)
    }

    private fun setupClickListeners() {
        android.util.Log.i("MainActivity", "Setting up click listeners")
        easyButton.setOnClickListener {
            android.util.Log.i("MainActivity", "Easy button clicked")
            startGame(GameMode.EASY)
        }
        normalButton.setOnClickListener {
            android.util.Log.i("MainActivity", "Normal button clicked")
            startGame(GameMode.NORMAL)
        }
        hardButton.setOnClickListener {
            android.util.Log.i("MainActivity", "Hard button clicked")
            startGame(GameMode.HARD)
        }
        godButton.setOnClickListener {
            android.util.Log.i("MainActivity", "God button clicked")
            startGame(GameMode.GOD)
        }
        android.util.Log.i("MainActivity", "Click listeners setup complete")
    }

    private fun startGame(gameMode: GameMode) {
        android.util.Log.i("MainActivity", "Starting game with mode: ${gameMode.displayName}")
        val intent = Intent(this, GameActivity::class.java).apply {
            putExtra("GAME_MODE", gameMode.name)
        }
        startActivity(intent)
        // Add transition animation
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
    }

    override fun onResume() {
        super.onResume()
        // Don't hide system UI for main menu - we want navigation visible
        // hideSystemUI() // Commented out for menu visibility
    }

    private fun hideSystemUI() {
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_FULLSCREEN
        )
    }
}
