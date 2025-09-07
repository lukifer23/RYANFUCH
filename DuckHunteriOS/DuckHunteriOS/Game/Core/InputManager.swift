//
//  InputManager.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import UIKit

class InputManager {

    // MARK: - Properties
    private var touchStartTime: TimeInterval = 0
    private var touchStartLocation: CGPoint = .zero
    private var currentTouchLocation: CGPoint = .zero

    private var isTouching = false
    private var isDragging = false

    // Touch sensitivity settings
    private var crosshairSensitivity: Float = 1.0
    private var aimAssistEnabled = true
    private var aimAssistRadius: CGFloat = 30.0

    // MARK: - Touch Handling
    func handleTouchBegan(at location: CGPoint, timestamp: TimeInterval) {
        touchStartTime = timestamp
        touchStartLocation = location
        currentTouchLocation = location
        isTouching = true
        isDragging = false
    }

    func handleTouchMoved(to location: CGPoint) {
        currentTouchLocation = location

        // Check if this is a drag gesture
        let distance = touchStartLocation.distance(to: location)
        if distance > 10 { // Minimum drag distance
            isDragging = true
        }
    }

    func handleTouchEnded(at location: CGPoint, timestamp: TimeInterval) {
        let touchDuration = timestamp - touchStartTime
        currentTouchLocation = location

        // Determine gesture type
        if touchDuration < 0.3 && !isDragging {
            handleTap(at: location)
        } else if isDragging {
            handleDrag(from: touchStartLocation, to: location)
        }

        isTouching = false
        isDragging = false
    }

    // MARK: - Gesture Recognition
    private func handleTap(at location: CGPoint) {
        // Single tap = shoot
        NotificationCenter.default.post(
            name: .didTapToShoot,
            object: nil,
            userInfo: ["location": location]
        )
    }

    private func handleDrag(from start: CGPoint, to end: CGPoint) {
        // Drag = move crosshair
        NotificationCenter.default.post(
            name: .didDragCrosshair,
            object: nil,
            userInfo: [
                "startLocation": start,
                "endLocation": end,
                "sensitivity": crosshairSensitivity
            ]
        )
    }

    func handleDoubleTap(at location: CGPoint) {
        // Double tap = reload
        NotificationCenter.default.post(
            name: .didDoubleTapToReload,
            object: nil
        )
    }

    func handleLongPress(at location: CGPoint) {
        // Long press = show hit radius
        NotificationCenter.default.post(
            name: .didLongPress,
            object: nil,
            userInfo: ["location": location]
        )
    }

    func handlePinchGesture(scale: CGFloat) {
        // Pinch = zoom (future feature)
        NotificationCenter.default.post(
            name: .didPinchGesture,
            object: nil,
            userInfo: ["scale": scale]
        )
    }

    func handleSwipeGesture(direction: SwipeDirection) {
        // Swipe gestures for shortcuts
        NotificationCenter.default.post(
            name: .didSwipeGesture,
            object: nil,
            userInfo: ["direction": direction]
        )
    }

    // MARK: - Crosshair Position
    func getCrosshairPosition() -> CGPoint {
        return currentTouchLocation
    }

    func getSmoothedCrosshairPosition() -> CGPoint {
        // Apply sensitivity and smoothing
        let sensitivity = CGFloat(crosshairSensitivity)
        return currentTouchLocation * sensitivity
    }

    // MARK: - Aim Assist
    func getAimAssistTarget(from position: CGPoint, targets: [CGPoint]) -> CGPoint? {
        guard aimAssistEnabled else { return nil }

        // Find closest target within aim assist radius
        var closestTarget: CGPoint?
        var closestDistance = aimAssistRadius

        for target in targets {
            let distance = position.distance(to: target)
            if distance < closestDistance {
                closestDistance = distance
                closestTarget = target
            }
        }

        return closestTarget
    }

    // MARK: - Settings
    func setCrosshairSensitivity(_ sensitivity: Float) {
        crosshairSensitivity = max(0.1, min(2.0, sensitivity))
    }

    func getCrosshairSensitivity() -> Float {
        return crosshairSensitivity
    }

    func setAimAssist(enabled: Bool, radius: CGFloat? = nil) {
        aimAssistEnabled = enabled
        if let radius = radius {
            aimAssistRadius = max(10, min(100, radius))
        }
    }

    func getAimAssistSettings() -> (enabled: Bool, radius: CGFloat) {
        return (aimAssistEnabled, aimAssistRadius)
    }

    // MARK: - Touch State
    func isCurrentlyTouching() -> Bool {
        return isTouching
    }

    func isCurrentlyDragging() -> Bool {
        return isDragging
    }

    var currentTouchDuration: TimeInterval {
        if isTouching {
            return CACurrentMediaTime() - touchStartTime
        }
        return 0
    }
}

// MARK: - Supporting Types
enum SwipeDirection {
    case up, down, left, right
}

// MARK: - Notification Names
extension Notification.Name {
    static let didTapToShoot = Notification.Name("didTapToShoot")
    static let didDragCrosshair = Notification.Name("didDragCrosshair")
    static let didDoubleTapToReload = Notification.Name("didDoubleTapToReload")
    static let didLongPress = Notification.Name("didLongPress")
    static let didPinchGesture = Notification.Name("didPinchGesture")
    static let didSwipeGesture = Notification.Name("didSwipeGesture")
}
