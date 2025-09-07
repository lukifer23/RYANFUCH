//
//  GameViewController.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view
        let skView = self.view as! SKView

        // Debug options (disable for production)
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        #endif

        // Create and configure the game scene
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill

        // Present the scene
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
