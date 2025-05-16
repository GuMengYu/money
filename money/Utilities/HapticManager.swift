//
//  HapticManager.swift
//  money
//
//  Created by Yoda on 2025/5/16.
//

import UIKit
import SwiftUI

/**
 * HapticFeedbackManager
 *
 * A manager class to easily trigger haptic feedback.
 * It ensures that feedback generators are used on the main thread.
 *
 * How to use:
 * 1. Create an instance (or use a shared instance if you prefer):
 * `let hapticManager = HapticManager()`
 *
 * 2. Call the desired feedback method:
 * `hapticManager.impact(.heavy)`
 * `hapticManager.notification(.success)`
 * `hapticManager.selectionChanged()`
 *
 * If using in SwiftUI and wanting a shared instance accessible via @EnvironmentObject:
 * ```
 * // In your App struct:
 * @main
 * struct YourApp: App {
 * let hapticManager = HapticManager() // Create an instance
 *
 * var body: some Scene {
 * WindowGroup {
 * ContentView()
 * .environmentObject(hapticManager) // Provide it to the environment
 * }
 * }
 * }
 *
 * // In your View:
 * @EnvironmentObject var hapticManager: HapticManager
 *
 * Button("Tap me for haptics") {
 * hapticManager.impact(.medium)
 * }
 * ```
 * For simpler, direct use without EnvironmentObject in SwiftUI:
 * ```
 * let hapticManager = HapticManager() // Can be a @StateObject or just an instance
 *
 * Button("Tap me") {
 * hapticManager.impact(.light)
 * }
 * ```
 */
@MainActor // Ensures all methods are called on the main thread
class HapticManager: ObservableObject { // ObservableObject if you plan to use it with @EnvironmentObject

    // MARK: - Impact Feedback Generators
    // We can create generators on demand or keep instances.
    // For impact, creating on demand is often fine as they are lightweight.
    // If you notice latency, you might consider keeping prepared instances.

    /// Triggers an impact feedback.
    /// - Parameter style: The style of the impact (e.g., .light, .medium, .heavy, .soft, .rigid).
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare() // Prepare the engine for lower latency.
        generator.impactOccurred()
    }

    // Convenience methods for specific impact styles
    public func lightImpact() {
        impact(.light)
    }

    public func mediumImpact() {
        impact(.medium)
    }

    public func heavyImpact() {
        impact(.heavy)
    }

    @available(iOS 13.0, *)
    public func softImpact() {
        impact(.soft)
    }

    @available(iOS 13.0, *)
    public func rigidImpact() {
        impact(.rigid)
    }

    // MARK: - Notification Feedback Generator

    /// Triggers a notification feedback.
    /// - Parameter type: The type of notification (e.g., .success, .warning, .error).
    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    // Convenience methods for specific notification types
    public func successNotification() {
        notification(.success)
    }

    public func warningNotification() {
        notification(.warning)
    }

    public func errorNotification() {
        notification(.error)
    }

    // MARK: - Selection Feedback Generator
    // It's good practice to create and prepare this generator before a sequence of selection changes.
    // And release it when done. However, for a single selection change, creating on demand is also fine.
    private var selectionGenerator: UISelectionFeedbackGenerator?

    /// Prepares the selection feedback generator. Call this before a series of selection changes.
    public func prepareSelectionFeedback() {
        if selectionGenerator == nil {
            selectionGenerator = UISelectionFeedbackGenerator()
        }
        selectionGenerator?.prepare()
    }

    /// Triggers a selection changed feedback.
    /// It's recommended to call `prepareSelectionFeedback()` once before the first expected change.
    public func selectionChanged() {
        if selectionGenerator == nil {
            // If not prepared, create and trigger
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        } else {
            // If already prepared
            selectionGenerator?.selectionChanged()
        }
    }

    /// Releases the selection feedback generator. Call this when selection changes are no longer expected.
    public func releaseSelectionFeedback() {
        selectionGenerator = nil
    }

    // MARK: - Singleton (Optional)
    // If you prefer a singleton pattern for easy access throughout your app.
    /*
    static let shared = HapticManager()
    private init() {} // Private initializer for singleton
    */
    // If using as a singleton, ensure thread safety if you add mutable state,
    // though for these generators, UIKit handles much of that internally if used on main thread.

    // Standard initializer if not using singleton
    init() {}
}
