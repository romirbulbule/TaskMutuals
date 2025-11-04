//
//  UserTypeSelectionView.swift
//  TaskMutual
//
//  User type selection during onboarding
//

import SwiftUI

struct UserTypeSelectionView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var selectedType: UserType?
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Header
                VStack(spacing: 10) {
                    Text("What are you looking for?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("This helps us personalize your experience")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)

                Spacer()

                // Options
                VStack(spacing: 20) {
                    UserTypeOptionCard(
                        icon: "magnifyingglass",
                        title: "I'm looking for services",
                        description: "Find people who can help with your tasks",
                        isSelected: selectedType == .lookingForServices,
                        action: {
                            selectedType = .lookingForServices
                        }
                    )

                    UserTypeOptionCard(
                        icon: "briefcase.fill",
                        title: "I'm looking to provide services",
                        description: "Help others by completing tasks",
                        isSelected: selectedType == .providingServices,
                        action: {
                            selectedType = .providingServices
                        }
                    )
                }
                .padding(.horizontal, 30)

                Spacer()

                // Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                // Continue button
                Button(action: handleContinue) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedType != nil ? Theme.accent : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(selectedType == nil || isLoading)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }

    private func handleContinue() {
        guard let userType = selectedType else {
            errorMessage = "Please select an option"
            return
        }

        errorMessage = ""
        isLoading = true

        userVM.updateUserType(userType) { result in
            isLoading = false
            switch result {
            case .success:
                print("✅ User type saved: \(userType.rawValue)")
                // Navigation happens automatically via RootSwitcherView
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct UserTypeOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? Theme.accent : .white)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.white : Color.white.opacity(0.2))
                    .cornerRadius(10)

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)

                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.accent)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(isSelected ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? Theme.accent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    UserTypeSelectionView()
        .environmentObject(UserViewModel())
}
