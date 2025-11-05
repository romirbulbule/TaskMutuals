//
//  AnimationUtilities.swift
//  TaskMutual
//
//  Premium animation utilities for smooth, fluid interactions
//  Inspired by Opal's buttery animations
//

import SwiftUI

// MARK: - Animation Presets

struct AnimationPresets {
    // MARK: - Spring Animations (Opal-style)

    /// Smooth spring animation - perfect for most UI transitions
    static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)

    /// Bouncy spring animation - for playful interactions
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)

    /// Snappy spring animation - quick and responsive
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.85, blendDuration: 0)

    /// Gentle spring animation - subtle and elegant
    static let gentle = Animation.spring(response: 0.6, dampingFraction: 0.9, blendDuration: 0)

    /// Interactive spring - for drag gestures
    static let interactive = Animation.interactiveSpring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)

    // MARK: - Timing Curve Animations

    /// Ease in-out - standard comfortable animation
    static let easeInOut = Animation.easeInOut(duration: 0.3)

    /// Ease out - starts fast, ends slow
    static let easeOut = Animation.easeOut(duration: 0.25)

    /// Ease in - starts slow, ends fast
    static let easeIn = Animation.easeIn(duration: 0.25)

    // MARK: - Special Animations

    /// Button press animation - quick press and release
    static let buttonPress = Animation.spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0)

    /// Card flip animation - smooth flip transition
    static let cardFlip = Animation.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0)

    /// Modal presentation - elegant appear/dismiss
    static let modal = Animation.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0)

    /// Tab switch animation - snappy tab changes
    static let tabSwitch = Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)

    /// List item animation - staggered list appearances
    static let listItem = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)

    /// Shimmer/skeleton loading animation
    static let shimmer = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)

    /// Pulse animation - for attention-grabbing elements
    static let pulse = Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
}

// MARK: - View Extensions for Animations

extension View {
    // MARK: - Scale Animations

    /// Button press scale animation with haptic
    func pressableScale(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AnimationPresets.buttonPress, value: isPressed)
    }

    /// Bounce scale animation
    func bounceScale(trigger: Bool) -> some View {
        self
            .scaleEffect(trigger ? 1.1 : 1.0)
            .animation(AnimationPresets.bouncy, value: trigger)
    }

    // MARK: - Fade Animations

    /// Smooth fade in
    func smoothFadeIn(delay: Double = 0) -> some View {
        self
            .transition(.opacity)
            .animation(AnimationPresets.smooth.delay(delay), value: UUID())
    }

    /// Fade and slide transition
    func fadeAndSlide(edge: Edge = .bottom) -> some View {
        self
            .transition(.asymmetric(
                insertion: .move(edge: edge).combined(with: .opacity),
                removal: .opacity
            ))
            .animation(AnimationPresets.smooth, value: UUID())
    }

    // MARK: - Slide Animations

    /// Slide in from edge
    func slideIn(from edge: Edge, delay: Double = 0) -> some View {
        self
            .transition(.move(edge: edge))
            .animation(AnimationPresets.smooth.delay(delay), value: UUID())
    }

    // MARK: - Card Animations

    /// Card appear animation
    func cardAppear(delay: Double = 0) -> some View {
        self
            .transition(.asymmetric(
                insertion: .scale(scale: 0.9).combined(with: .opacity),
                removal: .scale(scale: 0.9).combined(with: .opacity)
            ))
            .animation(AnimationPresets.smooth.delay(delay), value: UUID())
    }

    // MARK: - Shimmer Effect

    /// Adds a shimmer/skeleton loading effect
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }

    // MARK: - Shake Animation

    /// Shake animation for errors
    func shake(trigger: Int) -> some View {
        self.modifier(ShakeEffect(shakes: trigger))
    }

    // MARK: - Spring Pop Animation

    /// Pop animation when appearing
    func springPop(trigger: Bool) -> some View {
        self
            .scaleEffect(trigger ? 1.0 : 0.5)
            .opacity(trigger ? 1.0 : 0.0)
            .animation(AnimationPresets.bouncy, value: trigger)
    }
}

// MARK: - Custom Animation Modifiers

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(AnimationPresets.shimmer) {
                    phase = 300
                }
            }
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat

    init(shakes: Int) {
        self.shakes = shakes
        self.animatableData = CGFloat(shakes)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: 10 * sin(animatableData * .pi * 2),
                y: 0
            )
        )
    }
}

// MARK: - Pressable Button Style

struct PressableButtonStyle: ButtonStyle {
    var haptic: HapticStyle = .buttonPress

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(AnimationPresets.buttonPress, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    HapticsManager.shared.trigger(haptic)
                }
            }
    }
}

// MARK: - Card Button Style

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(AnimationPresets.snappy, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    HapticsManager.shared.light()
                }
            }
    }
}

// MARK: - Staggered List Animation

struct StaggeredAnimation: ViewModifier {
    let index: Int
    let total: Int
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(
                AnimationPresets.smooth.delay(Double(index) * 0.05),
                value: appeared
            )
            .onAppear {
                appeared = true
            }
    }
}

extension View {
    func staggeredAnimation(index: Int, total: Int) -> some View {
        self.modifier(StaggeredAnimation(index: index, total: total))
    }
}

// MARK: - Loading Animations

struct BouncingDotsView: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 10, height: 10)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    let colors: [Color]

    init(colors: [Color] = [Theme.brandGreen, Theme.brandGreen.opacity(0.7)]) {
        self.colors = colors
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Success Checkmark Animation

struct AnimatedCheckmark: View {
    @State private var trimEnd: CGFloat = 0
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 60, weight: .bold))
            .foregroundColor(.green)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(AnimationPresets.bouncy) {
                    scale = 1.0
                    opacity = 1.0
                }
                HapticsManager.shared.success()
            }
    }
}
