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

    private init() {}

    // MARK: - Impact Feedback

    /// Light impact - for subtle interactions (like selecting a tab)
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact - for standard interactions (like tapping a button)
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact - for important interactions (like completing a task)
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Soft impact - gentle feedback (iOS 13+)
    @available(iOS 13.0, *)
    func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    /// Rigid impact - firm feedback (iOS 13+)
    @available(iOS 13.0, *)
    func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success notification - for successful actions
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification - for warning actions
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification - for error states
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed - for picker-style interactions
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Common Patterns (Opal-style)

    /// Button press - medium impact with slight delay for realism
    func buttonPress() {
        medium()
    }

    /// Toggle switch - soft impact
    func toggle() {
        if #available(iOS 13.0, *) {
            soft()
        } else {
            light()
        }
    }

    /// Swipe action - light impact
    func swipe() {
        light()
    }

    /// Pull to refresh - light impact
    func pullToRefresh() {
        light()
    }

    /// Delete/destructive action - heavy impact + error notification
    func destructive() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.error()
        }
    }

    /// Task completed - success pattern
    func taskCompleted() {
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.success()
        }
    }

    /// Payment successful - celebration pattern
    func paymentSuccess() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.success()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.light()
        }
    }

    /// Card flip/transition - medium + light sequence
    func cardFlip() {
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.light()
        }
    }

    /// Modal appear - soft impact
    func modalAppear() {
        if #available(iOS 13.0, *) {
            soft()
        } else {
            light()
        }
    }

    /// Modal dismiss - light impact
    func modalDismiss() {
        light()
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
