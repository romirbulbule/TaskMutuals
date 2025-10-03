//
//  ProfileView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 28) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Theme.accent)
                    .padding(.top, 32)

                Text("Your Name")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Logout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 48)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.background)
            .navigationTitle("Profile")
            .foregroundColor(.white)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}
