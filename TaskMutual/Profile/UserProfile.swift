//
//  UserProfile.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//


import Foundation
import FirebaseFirestore

enum UserType: String, Codable {
    case lookingForServices = "looking_for_services"
    case providingServices = "providing_services"
}

struct UserProfile: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var username: String
    var dateOfBirth: Date
    var bio: String?
    var profileImageURL: String?
    var userType: UserType? // User's service preference

    // Custom Equatable implementation (needed for @DocumentID)
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.id == rhs.id &&
               lhs.firstName == rhs.firstName &&
               lhs.lastName == rhs.lastName &&
               lhs.username == rhs.username &&
               lhs.dateOfBirth == rhs.dateOfBirth &&
               lhs.bio == rhs.bio &&
               lhs.profileImageURL == rhs.profileImageURL &&
               lhs.userType == rhs.userType
    }
}




