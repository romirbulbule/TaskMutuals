//
//  HapticsManager.swift
//  TaskMutual
//
//  Centralized haptic feedback manager for consistent, premium feel
//  Inspired by Opal's smooth haptic interactions
//

import UIKit
import SwiftUI

class HapticsManager {
    static let shared = HapticsManager()

    // Pre-initialized generators for better performance
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    @available(iOS 13.0, *)
    private lazy var softGenerator = UIImpactFeedbackGenerator(style: .soft)

    @available(iOS 13.0, *)
    private lazy var rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)

    // Check if device supports haptics
    private var isHapticsSupported: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    private init() {
        // Prepare all generators on initialization
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Impact Feedback

    /// Light impact - now using medium for more noticeable feedback
    func light() {
        guard isHapticsSupported else { return }
        mediumGenerator.impactOccurred()
        mediumGenerator.prepare()
    }

    /// Medium impact - now using heavy for more noticeable feedback
    func medium() {
        guard isHapticsSupported else { return }
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
    }

    /// Heavy impact - triple heavy for maximum feedback
    func heavy() {
        guard isHapticsSupported else { return }
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.heavyGenerator.impactOccurred()
            self.heavyGenerator.prepare()
        }
    }

    /// Soft impact - now using medium for more noticeable feedback (iOS 13+)
    @available(iOS 13.0, *)
    func soft() {
        guard isHapticsSupported else { return }
        mediumGenerator.impactOccurred()
        mediumGenerator.prepare()
    }

    /// Rigid impact - now using heavy for more noticeable feedback (iOS 13+)
    @available(iOS 13.0, *)
    func rigid() {
        guard isHapticsSupported else { return }
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
    }

    // MARK: - Test Haptics

    /// Test function to verify haptics are working - fires a strong sequence
    func testHaptics() {
        print("🔔 Testing Haptics - Device: \(isHapticsSupported ? "iPhone with Taptic Engine" : "Not Supported")")
        guard isHapticsSupported else {
            print("❌ Haptics not supported on this device")
            return
        }

        // Fire a strong sequence
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.success()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.heavy()
        }
        print("✅ Haptics test fired!")
    }

    // MARK: - Notification Feedback

    /// Success notification - for successful actions
    func success() {
        guard isHapticsSupported else { return }
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    /// Warning notification - for warning actions
    func warning() {
        guard isHapticsSupported else { return }
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    /// Error notification - for error states
    func error() {
        guard isHapticsSupported else { return }
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }

    // MARK: - Selection Feedback

    /// Selection changed - for picker-style interactions
    func selectionChanged() {
        guard isHapticsSupported else { return }
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // MARK: - Common Patterns (More Aggressive for Better Feedback)

    /// Button press - heavy impact for noticeable feedback
    func buttonPress() {
        heavy()
    }

    /// Toggle switch - medium impact (more aggressive)
    func toggle() {
        medium()
    }

    /// Swipe action - medium impact (more aggressive)
    func swipe() {
        medium()
    }

    /// Pull to refresh - medium impact (more aggressive)
    func pullToRefresh() {
        medium()
    }

    /// Delete/destructive action - strong triple pattern
    func destructive() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.heavy()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.error()
        }
    }

    /// Task completed - strong success pattern
    func taskCompleted() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.heavy()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.success()
        }
    }

    /// Payment successful - strong celebration pattern
    func paymentSuccess() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.heavy()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.success()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.heavy()
        }
    }

    /// Card flip/transition - strong double pattern
    func cardFlip() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.medium()
        }
    }

    /// Modal appear - medium impact (more aggressive)
    func modalAppear() {
        medium()
    }

    /// Modal dismiss - medium impact (more aggressive)
    func modalDismiss() {
        medium()
    }
}

// MARK: - SwiftUI View Extension for Easy Haptics

extension View {
    /// Add haptic feedback to tap gesture
    func hapticTap(style: HapticStyle = .medium) -> some View {
        self.onTapGesture {
            HapticsManager.shared.trigger(style)
        }
    }

    /// Add haptic feedback with custom action
    func withHaptic(_ style: HapticStyle = .medium, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticsManager.shared.trigger(style)
            action()
        }) {
            self
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Haptic Style Enum

enum HapticStyle {
    case light, medium, heavy, soft, rigid
    case success, warning, error
    case selection
    case buttonPress, toggle, swipe
    case destructive, taskCompleted, paymentSuccess
    case cardFlip, modalAppear, modalDismiss
}

extension HapticsManager {
    func trigger(_ style: HapticStyle) {
        switch style {
        case .light: light()
        case .medium: medium()
        case .heavy: heavy()
        case .soft:
            if #available(iOS 13.0, *) { soft() } else { light() }
        case .rigid:
            if #available(iOS 13.0, *) { rigid() } else { heavy() }
        case .success: success()
        case .warning: warning()
        case .error: error()
        case .selection: selectionChanged()
        case .buttonPress: buttonPress()
        case .toggle: toggle()
        case .swipe: swipe()
        case .destructive: destructive()
        case .taskCompleted: taskCompleted()
        case .paymentSuccess: paymentSuccess()
        case .cardFlip: cardFlip()
        case .modalAppear: modalAppear()
        case .modalDismiss: modalDismiss()
        }
    }
}
