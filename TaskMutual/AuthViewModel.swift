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

    // Updated with completion support
    func signUp(email: String, password: String, completion: ((Bool) -> Void)? = nil) {
        authError = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = error.localizedDescription
                    completion?(false)
                } else {
                    self?.isNewUser = true
                    completion?(true)
                }
            }
        }
    }

    // Updated with completion support
    func signIn(email: String, password: String, completion: ((Bool) -> Void)? = nil) {
        authError = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = error.localizedDescription
                    completion?(false)
                } else {
                    self?.isNewUser = false
                    completion?(true)
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
            // Clear username cache on sign out
            UserService.shared.clearUsernameCache()
        } catch {
            DispatchQueue.main.async {
                self.authError = error.localizedDescription
            }
        }
    }
}
