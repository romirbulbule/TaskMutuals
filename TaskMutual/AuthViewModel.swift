//
//  AuthViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/22/25.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isNewUser: Bool = false
    @Published var authError: String?
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.isLoggedIn = (user != nil)
            }
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(email: String, password: String) {
        authError = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = error.localizedDescription
                } else {
                    self?.isNewUser = true
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        authError = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = error.localizedDescription
                } else {
                    self?.isNewUser = false
                }
            }
        }
    }

    func signOut(userVM: UserViewModel? = nil) {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.isNewUser = false
                self.authError = nil
                userVM?.clearProfile()
            }
        } catch {
            DispatchQueue.main.async {
                self.authError = error.localizedDescription
            }
        }
    }
}
