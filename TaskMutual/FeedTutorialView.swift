//
//  FeedTutorialView.swift
//  TaskMutual
//
//  Interactive feed tutorial that teaches users what they can do based on their user type
//

import SwiftUI

struct FeedTutorialView: View {
    let userType: UserType
    let userId: String
    @Binding var showTutorial: Bool

    @State private var currentStep = 0
    @State private var appeared = false

    // Different tutorial steps for service seekers vs providers
    var tutorialSteps: [TutorialStep] {
        if userType == .lookingForServices {
            return [
                TutorialStep(
                    icon: "plus.circle.fill",
                    title: "Post Your Tasks",
                    description: "Tap the + button in the top left to post a task you need help with",
                    highlightArea: .topLeft,
                    color: Theme.accent
                ),
                TutorialStep(
                    icon: "bubble.left.fill",
                    title: "Review Proposals",
                    description: "Service providers will submit proposals. Tap any task card to see responses and choose who to work with",
                    highlightArea: .taskCard,
                    color: .blue
                ),
                TutorialStep(
                    icon: "checkmark.circle.fill",
                    title: "Accept & Complete",
                    description: "Accept a proposal, complete the task, and rate your experience to help the community",
                    highlightArea: .center,
                    color: .green
                )
            ]
        } else {
            return [
                TutorialStep(
                    icon: "magnifyingglass.circle.fill",
                    title: "Browse Available Tasks",
                    description: "Scroll through the feed to find tasks you can help with. Each card shows the budget and location",
                    highlightArea: .taskCard,
                    color: Theme.accent
                ),
                TutorialStep(
                    icon: "hand.raised.fill",
                    title: "Submit Proposals",
                    description: "Tap any task card to view details and submit your proposal with your quoted price and message",
                    highlightArea: .taskCard,
                    color: .blue
                ),
                TutorialStep(
                    icon: "dollarsign.circle.fill",
                    title: "Get Hired & Earn",
                    description: "When your proposal is accepted, complete the task and get paid. Build your reputation with great ratings!",
                    highlightArea: .center,
                    color: .green
                )
            ]
        }
    }

    var body: some View {
        ZStack {
            // Semi-transparent overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent accidental dismissal
                }

            VStack(spacing: 0) {
                Spacer()

                // Tutorial content card
                VStack(spacing: 24) {
                    // Animated icon
                    ZStack {
                        Circle()
                            .fill(tutorialSteps[currentStep].color.opacity(0.2))
                            .frame(width: 120, height: 120)

                        Image(systemName: tutorialSteps[currentStep].icon)
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(tutorialSteps[currentStep].color)
                    }
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1.0 : 0.0)

                    // Step indicator
                    HStack(spacing: 8) {
                        ForEach(0..<tutorialSteps.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentStep ? tutorialSteps[currentStep].color : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentStep ? 1.2 : 1.0)
                        }
                    }
                    .animation(AnimationPresets.bouncy, value: currentStep)

                    // Title
                    Text(tutorialSteps[currentStep].title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1.0 : 0.0)
                        .offset(y: appeared ? 0 : 20)

                    // Description
                    Text(tutorialSteps[currentStep].description)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 32)
                        .opacity(appeared ? 1.0 : 0.0)
                        .offset(y: appeared ? 0 : 20)

                    // Action buttons
                    HStack(spacing: 16) {
                        if currentStep > 0 {
                            Button(action: {
                                HapticsManager.shared.medium()
                                withAnimation(AnimationPresets.smooth) {
                                    appeared = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    currentStep -= 1
                                    withAnimation(AnimationPresets.bouncy) {
                                        appeared = true
                                    }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }

                        Button(action: {
                            HapticsManager.shared.heavy()
                            if currentStep < tutorialSteps.count - 1 {
                                withAnimation(AnimationPresets.smooth) {
                                    appeared = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    currentStep += 1
                                    withAnimation(AnimationPresets.bouncy) {
                                        appeared = true
                                    }
                                }
                            } else {
                                completeTutorial()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text(currentStep < tutorialSteps.count - 1 ? "Next" : "Got It!")
                                    .fixedSize()
                                if currentStep < tutorialSteps.count - 1 {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(tutorialSteps[currentStep].color)
                            .cornerRadius(12)
                            .shadow(color: tutorialSteps[currentStep].color.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.top, 8)

                    // Skip button
                    Button(action: {
                        HapticsManager.shared.light()
                        completeTutorial()
                    }) {
                        Text("Skip Tutorial")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 8)
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "1A2F28"))
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 24)

                Spacer()
            }

            // Highlight areas (visual cues) - only show for service seekers on first step
            if currentStep == 0 && userType == .lookingForServices && tutorialSteps[currentStep].highlightArea == .topLeft {
                VStack {
                    HStack {
                        Circle()
                            .strokeBorder(tutorialSteps[currentStep].color, lineWidth: 3)
                            .frame(width: 60, height: 60)
                            .padding(.top, 60)
                            .padding(.leading, 20)
                            .opacity(appeared ? 1.0 : 0.0)
                            .animation(AnimationPresets.smooth, value: appeared)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(AnimationPresets.bouncy.delay(0.3)) {
                appeared = true
            }
        }
    }

    private func completeTutorial() {
        HapticsManager.shared.paymentSuccess()
        // Store per-user feed tutorial completion
        UserDefaults.standard.set(true, forKey: "hasSeenFeedTutorial_\(userId)")
        withAnimation(AnimationPresets.smooth) {
            showTutorial = false
        }
    }
}

// MARK: - Tutorial Step Model

struct TutorialStep {
    let icon: String
    let title: String
    let description: String
    let highlightArea: HighlightArea
    let color: Color
}

enum HighlightArea {
    case topLeft
    case taskCard
    case center
    case none
}

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        FeedTutorialView(
            userType: .lookingForServices,
            userId: "preview_user",
            showTutorial: .constant(true)
        )
    }
}
