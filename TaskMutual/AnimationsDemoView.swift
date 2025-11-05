//
//  AnimationsDemoView.swift
//  TaskMutual
//
//  Demo view showcasing all animations and haptics
//  Use this to preview and test all animation components
//

import SwiftUI

struct AnimationsDemoView: View {
    @State private var selectedTab = 0
    @State private var showSuccess = false
    @State private var showLoading = false
    @State private var rating = 0
    @State private var toggleOn = false
    @State private var progress: Double = 0.0
    @State private var badgeCount = 0

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Section 1: Buttons
                        sectionHeader("Animated Buttons")

                        AnimatedPrimaryButton(
                            "Primary Button",
                            icon: "checkmark.circle.fill"
                        ) {
                            print("Primary tapped")
                        }
                        .padding(.horizontal)

                        AnimatedSecondaryButton(
                            "Secondary Button",
                            icon: "xmark"
                        ) {
                            print("Secondary tapped")
                        }
                        .padding(.horizontal)

                        AnimatedPrimaryButton(
                            "Loading Button",
                            isLoading: true
                        ) { }
                        .padding(.horizontal)

                        AnimatedPrimaryButton(
                            "Disabled Button",
                            isDisabled: true
                        ) { }
                        .padding(.horizontal)

                        // Section 2: Cards
                        sectionHeader("Animated Cards")

                        AnimatedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Interactive Card")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text("Tap this card to see the animation")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                        }
                        .padding(.horizontal)

                        // Section 3: Star Rating
                        sectionHeader("Star Rating")

                        AnimatedStarRating(rating: $rating, interactive: true)
                            .padding()

                        Text("Rating: \(rating) stars")
                            .foregroundColor(.white)
                            .font(.caption)

                        // Section 4: Toggle
                        sectionHeader("Animated Toggle")

                        AnimatedToggle(isOn: $toggleOn, label: "Enable Notifications")
                            .padding(.horizontal)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)

                        // Section 5: Badge
                        sectionHeader("Animated Badge")

                        HStack {
                            Text("Notifications")
                                .foregroundColor(.white)

                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Theme.accent)

                                AnimatedBadge(count: badgeCount)
                                    .offset(x: 8, y: -8)
                            }
                        }

                        HStack {
                            Button("Add Badge") {
                                badgeCount += 1
                            }
                            .buttonStyle(PressableButtonStyle())

                            Button("Reset") {
                                badgeCount = 0
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                        .foregroundColor(.white)

                        // Section 6: Progress Bar
                        sectionHeader("Progress Bar")

                        VStack(spacing: 12) {
                            AnimatedProgressBar(progress: progress)

                            HStack {
                                Button("25%") { progress = 0.25 }
                                Button("50%") { progress = 0.50 }
                                Button("75%") { progress = 0.75 }
                                Button("100%") { progress = 1.00 }
                            }
                            .buttonStyle(PressableButtonStyle())
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // Section 7: Loading View
                        sectionHeader("Loading Animation")

                        Button("Show Loading") {
                            showLoading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showLoading = false
                            }
                        }
                        .buttonStyle(PressableButtonStyle())
                        .foregroundColor(.white)

                        BouncingDotsView()

                        // Section 8: Success Overlay
                        sectionHeader("Success Overlay")

                        Button("Show Success") {
                            HapticsManager.shared.success()
                            showSuccess = true
                        }
                        .buttonStyle(PressableButtonStyle())
                        .foregroundColor(.white)

                        // Section 9: Haptics Test
                        sectionHeader("Haptic Feedback")

                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                            HapticButton("Light", style: .light)
                            HapticButton("Medium", style: .medium)
                            HapticButton("Heavy", style: .heavy)
                            HapticButton("Soft", style: .soft)
                            HapticButton("Success", style: .success)
                            HapticButton("Error", style: .error)
                        }
                        .padding(.horizontal)

                        // Section 10: Empty State
                        sectionHeader("Empty State")

                        AnimatedEmptyState(
                            icon: "tray",
                            title: "No items found",
                            message: "Add your first item to get started",
                            actionTitle: "Add Item",
                            action: {
                                print("Add item tapped")
                            }
                        )
                        .frame(height: 300)

                        // Section 11: Task Cards
                        sectionHeader("Task Cards")

                        ForEach(0..<2, id: \.self) { index in
                            EnhancedTaskCardView(
                                task: Task(
                                    id: "\(index)",
                                    title: "Sample Task \(index + 1)",
                                    description: "This is a sample task showing the enhanced card animation with haptics.",
                                    creatorUserId: "demo",
                                    creatorUsername: "demo_user",
                                    budget: Double((index + 1) * 50),
                                    location: "Boston, MA",
                                    category: .cleaning
                                ),
                                index: index
                            ) {
                                print("Card \(index) tapped")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }

                // Overlays
                if showLoading {
                    AnimatedLoadingView(message: "Loading awesome animations...")
                }

                if showSuccess {
                    AnimatedSuccessOverlay(
                        title: "Success!",
                        message: "This is a beautiful success animation with haptics."
                    ) {
                        showSuccess = false
                    }
                }
            }
            .navigationTitle("Animations Demo")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 8)
    }
}

struct HapticButton: View {
    let title: String
    let style: HapticStyle

    init(_ title: String, style: HapticStyle) {
        self.title = title
        self.style = style
    }

    var body: some View {
        Button(action: {
            HapticsManager.shared.trigger(style)
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.accent)
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AnimationsDemoView()
}
