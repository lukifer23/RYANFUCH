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

        initializeViews()
        setupClickListeners()
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
        easyButton.setOnClickListener { startGame(GameMode.EASY) }
        normalButton.setOnClickListener { startGame(GameMode.NORMAL) }
        hardButton.setOnClickListener { startGame(GameMode.HARD) }
        godButton.setOnClickListener { startGame(GameMode.GOD) }
    }

    private fun startGame(gameMode: GameMode) {
        val intent = Intent(this, GameActivity::class.java).apply {
            putExtra("GAME_MODE", gameMode.name)
        }
        startActivity(intent)
        // Add transition animation
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
    }

    override fun onResume() {
        super.onResume()
        // Hide system UI for immersive experience
        hideSystemUI()
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
