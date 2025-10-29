//
//  UserProfile.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//


import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var username: String
    var dateOfBirth: Date
    var bio: String? // <- new
    var profileImageURL: String? // <- new
}




