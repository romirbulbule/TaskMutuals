//
//  UserProfile.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//


import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var username: String
    var dateOfBirth: Date
}







