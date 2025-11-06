//
//  OnboardingView.swift
//  TaskMutual
//
//  Beautiful Opal-inspired onboarding tutorial with smooth animations and haptics
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    let userId: String
    @State private var currentPage = 0
    @State private var appeared = false
    @Namespace private var animation

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "hands.sparkles.fill",
            title: "Welcome to TaskMutuals",
            description: "Connect with your community to get things done together",
            color: Color(hex: "2C4F41")
        ),
        OnboardingPage(
            icon: "magnifyingglass.circle.fill",
            title: "Find Help Nearby",
            description: "Browse local tasks or post your own. From cleaning to moving, we've got you covered",
            color: Color(hex: "4A7C59")
        ),
        OnboardingPage(
            icon: "dollarsign.circle.fill",
            title: "Earn & Save Money",
            description: "Provide services to earn extra income, or find affordable help in your area",
            color: Color(hex: "F5EDE4")
        ),
        OnboardingPage(
            icon: "checkmark.seal.fill",
            title: "Safe & Secure",
            description: "Built-in payments, ratings, and dispute resolution keep everyone protected",
            color: Theme.accent
        )
    ]

    var body: some View {
        ZStack {
            // Animated gradient background
            OnboardingGradientBackground(currentPage: currentPage, totalPages: pages.count)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            HapticsManager.shared.light()
                            completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 60)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }

                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], appeared: appeared)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(AnimationPresets.smooth, value: currentPage)
                .onChange(of: currentPage) { newPage in
                    HapticsManager.shared.medium()
                }

                Spacer()

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 32 : 8, height: 8)
                            .animation(AnimationPresets.bouncy, value: currentPage)
                            .matchedGeometryEffect(id: "indicator_\(index)", in: animation)
                    }
                }
                .padding(.bottom, 24)

                // Action button
                if currentPage == pages.count - 1 {
                    AnimatedPrimaryButton("Get Started", icon: "arrow.right.circle.fill") {
                        completeOnboarding()
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Color.clear
                        .frame(height: 104)
                }
            }
        }
        .onAppear {
            withAnimation(AnimationPresets.bouncy.delay(0.3)) {
                appeared = true
            }
        }
    }

    private func completeOnboarding() {
        HapticsManager.shared.paymentSuccess()
        withAnimation(AnimationPresets.smooth) {
            hasCompletedOnboarding = true
        }
        // Store per-user completion flag
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding_\(userId)")
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let appeared: Bool
    @State private var iconAppeared = false
    @State private var textAppeared = false

    var body: some View {
        VStack(spacing: 32) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .scaleEffect(iconAppeared ? 1.0 : 0.5)
                    .opacity(iconAppeared ? 1.0 : 0.0)

                Image(systemName: page.icon)
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(iconAppeared ? 1.0 : 0.3)
                    .opacity(iconAppeared ? 1.0 : 0.0)
                    .rotationEffect(.degrees(iconAppeared ? 0 : -180))
            }

            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(textAppeared ? 1.0 : 0.0)
                    .offset(y: textAppeared ? 0 : 30)

                // Description
                Text(page.description)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                    .opacity(textAppeared ? 1.0 : 0.0)
                    .offset(y: textAppeared ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(AnimationPresets.bouncy.delay(0.2)) {
                iconAppeared = true
            }
            withAnimation(AnimationPresets.smooth.delay(0.5)) {
                textAppeared = true
            }
        }
        .onChange(of: appeared) { _ in
            iconAppeared = true
            textAppeared = true
        }
    }
}

// MARK: - Onboarding Gradient Background

struct OnboardingGradientBackground: View {
    let currentPage: Int
    let totalPages: Int

    var gradientColors: [Color] {
        let progress = Double(currentPage) / Double(max(totalPages - 1, 1))

        // Transition from dark green -> lighter green -> cream -> accent
        if progress < 0.33 {
            return [Color(hex: "1A2F28"), Color(hex: "2C4F41")]
        } else if progress < 0.66 {
            return [Color(hex: "2C4F41"), Color(hex: "4A7C59")]
        } else {
            return [Color(hex: "4A7C59"), Theme.accent]
        }
    }

    var body: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .animation(AnimationPresets.smooth, value: currentPage)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false), userId: "preview_user")
}
