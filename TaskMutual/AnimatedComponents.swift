//
//  AnimatedComponents.swift
//  TaskMutual
//
//  Reusable animated UI components with haptics
//  Premium feel inspired by Opal
//

import SwiftUI

// MARK: - Animated Primary Button

struct AnimatedPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool

    @State private var isPressed = false

    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticsManager.shared.buttonPress()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDisabled ? Color.gray : Theme.accent)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.accent.opacity(0.3), lineWidth: isPressed ? 3 : 0)
                    .animation(AnimationPresets.snappy, value: isPressed)
            )
        }
        .disabled(isDisabled || isLoading)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(AnimationPresets.buttonPress, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Animated Secondary Button

struct AnimatedSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    @State private var isPressed = false

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticsManager.shared.light()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(Theme.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.accent, lineWidth: 2)
            )
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Animated Card

struct AnimatedCard<Content: View>: View {
    let content: Content
    let onTap: (() -> Void)?

    @State private var isPressed = false

    init(onTap: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.onTap = onTap
        self.content = content()
    }

    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: {
                    HapticsManager.shared.light()
                    onTap()
                }) {
                    cardContent
                }
                .buttonStyle(CardButtonStyle())
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
}

// MARK: - Animated Toggle

struct AnimatedToggle: View {
    @Binding var isOn: Bool
    let label: String

    var body: some View {
        Toggle(isOn: $isOn.animation(AnimationPresets.smooth)) {
            Text(label)
                .foregroundColor(.white)
        }
        .tint(Theme.accent)
        .onChange(of: isOn) { _ in
            HapticsManager.shared.toggle()
        }
    }
}

// MARK: - Animated Tab Bar Item

struct AnimatedTabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsManager.shared.selectionChanged()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .foregroundColor(isSelected ? Theme.accent : .gray)

                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? Theme.accent : .gray)
            }
            .frame(maxWidth: .infinity)
            .animation(AnimationPresets.snappy, value: isSelected)
        }
    }
}

// MARK: - Animated Badge

struct AnimatedBadge: View {
    let count: Int
    @State private var appeared = false

    var body: some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, count > 9 ? 6 : 0)
                .frame(width: count > 9 ? nil : 20, height: 20)
                .background(
                    Capsule()
                        .fill(Color.red)
                )
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(AnimationPresets.bouncy) {
                        appeared = true
                    }
                    HapticsManager.shared.light()
                }
                .onChange(of: count) { newCount in
                    if newCount > 0 {
                        withAnimation(AnimationPresets.bouncy) {
                            appeared = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(AnimationPresets.bouncy) {
                                appeared = true
                            }
                        }
                    }
                }
        }
    }
}

// MARK: - Animated Progress Bar

struct AnimatedProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let color: Color

    @State private var animatedProgress: Double = 0

    init(progress: Double, color: Color = Theme.accent) {
        self.progress = progress
        self.color = color
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 8)

                // Progress
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: geometry.size.width * animatedProgress, height: 8)
                    .animation(AnimationPresets.smooth, value: animatedProgress)
            }
        }
        .frame(height: 8)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { newValue in
            withAnimation(AnimationPresets.smooth) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Animated Star Rating

struct AnimatedStarRating: View {
    @Binding var rating: Int
    let maximumRating: Int = 5
    let interactive: Bool

    @State private var scales: [CGFloat]

    init(rating: Binding<Int>, interactive: Bool = true) {
        self._rating = rating
        self.interactive = interactive
        self._scales = State(initialValue: Array(repeating: 1.0, count: 5))
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maximumRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: 32))
                    .foregroundColor(star <= rating ? .yellow : .gray)
                    .scaleEffect(scales[star - 1])
                    .onTapGesture {
                        guard interactive else { return }
                        HapticsManager.shared.light()
                        rating = star

                        // Animate the tapped star
                        withAnimation(AnimationPresets.bouncy) {
                            scales[star - 1] = 1.3
                        }
                        withAnimation(AnimationPresets.bouncy.delay(0.1)) {
                            scales[star - 1] = 1.0
                        }
                    }
            }
        }
    }
}

// MARK: - Animated Success Overlay

struct AnimatedSuccessOverlay: View {
    let title: String
    let message: String
    let onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .opacity(appeared ? 1 : 0)

            VStack(spacing: 24) {
                AnimatedCheckmark()

                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(message)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                AnimatedPrimaryButton("Done") {
                    withAnimation(AnimationPresets.smooth) {
                        appeared = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Theme.background.opacity(0.95))
            )
            .padding(40)
            .scaleEffect(appeared ? 1.0 : 0.8)
            .opacity(appeared ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(AnimationPresets.bouncy.delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Animated Loading View

struct AnimatedLoadingView: View {
    let message: String?

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 20) {
            BouncingDotsView()

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.opacity(0.95))
    }
}

// MARK: - Animated Empty State

struct AnimatedEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    @State private var appeared = false

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1.0 : 0.0)

            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .opacity(appeared ? 1.0 : 0.0)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(appeared ? 1.0 : 0.0)

            if let actionTitle = actionTitle, let action = action {
                AnimatedPrimaryButton(actionTitle, icon: "plus.circle.fill", action: action)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                    .opacity(appeared ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(AnimationPresets.smooth.delay(0.1)) {
                appeared = true
            }
        }
    }
}
