//
//  InputManager.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

class InputManager {

    // MARK: - Properties
    private var inputStartTime: TimeInterval = 0
    private var inputStartLocation: CGPoint = .zero
    private var currentInputLocation: CGPoint = .zero

    private var isInputActive = false
    private var isDragging = false

    // Input sensitivity settings
    private var crosshairSensitivity: Float = 1.0
    private var aimAssistEnabled = true
    private var aimAssistRadius: CGFloat = 30.0

    // MARK: - Input Handling
    func handleInputBegan(at location: CGPoint, timestamp: TimeInterval) {
        inputStartTime = timestamp
        inputStartLocation = location
        currentInputLocation = location
        isInputActive = true
        isDragging = false
    }

    func handleInputMoved(to location: CGPoint) {
        currentInputLocation = location

        // Check if this is a drag gesture
        let distance = inputStartLocation.distance(to: location)
        if distance > 10 { // Minimum drag distance
            isDragging = true
        }
    }

    func handleInputEnded(at location: CGPoint, timestamp: TimeInterval) {
        let inputDuration = timestamp - inputStartTime
        currentInputLocation = location

        // Determine gesture type
        if inputDuration < 0.3 && !isDragging {
            handleTap(at: location)
        } else if isDragging {
            handleDrag(from: inputStartLocation, to: location)
        }

        isInputActive = false
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
        return currentInputLocation
    }

    func getSmoothedCrosshairPosition() -> CGPoint {
        // Apply sensitivity and smoothing
        let sensitivity = CGFloat(crosshairSensitivity)
        return currentInputLocation * sensitivity
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

    // MARK: - Input State
    func isCurrentlyInputActive() -> Bool {
        return isInputActive
    }

    func isCurrentlyDragging() -> Bool {
        return isDragging
    }

    var currentInputDuration: TimeInterval {
        if isInputActive {
            return CACurrentMediaTime() - inputStartTime
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
