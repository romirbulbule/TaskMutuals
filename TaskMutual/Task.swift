//
//  Task.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/2/25.
//


import Foundation
import FirebaseFirestore

// MARK: - Service Categories
enum ServiceCategory: String, Codable, CaseIterable {
    case lawnCare = "Lawn Care"
    case cleaning = "Cleaning"
    case plumbing = "Plumbing"
    case electrical = "Electrical"
    case painting = "Painting"
    case moving = "Moving & Delivery"
    case handyman = "Handyman"
    case petCare = "Pet Care"
    case tutoring = "Tutoring"
    case automotive = "Automotive"
    case carpentry = "Carpentry"
    case appliance = "Appliance Repair"
    case landscaping = "Landscaping"
    case roofing = "Roofing"
    case other = "Other"

    var icon: String {
        switch self {
        case .lawnCare: return "leaf.fill"
        case .cleaning: return "sparkles"
        case .plumbing: return "drop.fill"
        case .electrical: return "bolt.fill"
        case .painting: return "paintbrush.fill"
        case .moving: return "shippingbox.fill"
        case .handyman: return "hammer.fill"
        case .petCare: return "pawprint.fill"
        case .tutoring: return "book.fill"
        case .automotive: return "car.fill"
        case .carpentry: return "ruler.fill"
        case .appliance: return "washer.fill"
        case .landscaping: return "tree.fill"
        case .roofing: return "house.fill"
        case .other: return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - Task Status
enum TaskStatus: String, Codable {
    case open = "open"
    case assigned = "assigned"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .assigned: return "Assigned"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    var color: String {
        switch self {
        case .open: return "blue"
        case .assigned: return "orange"
        case .inProgress: return "purple"
        case .completed: return "green"
        case .cancelled: return "red"
        }
    }
}

// MARK: - Task Model
struct Task: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var creatorUserId: String
    var creatorUsername: String
    var creatorUserType: String? // "looking_for_services" or "providing_services"
    var timestamp: Date = Date()
    var responses: [Response] = []
    var isArchived: Bool = false

    // Phase 1: Marketplace features
    var budget: Double? // Budget in dollars
    var location: String? // Address or area (e.g., "Boston, MA" or "Downtown Austin")
    var category: ServiceCategory?
    var status: TaskStatus = .open
    var deadline: Date? // When the task needs to be completed
    var estimatedDuration: String? // e.g., "2-3 hours", "Half day"
    var assignedProviderId: String? // ID of provider who was accepted
    var assignedProviderUsername: String? // Username of accepted provider
}

// MARK: - Task Extensions
extension Task {
    func hasUserResponded(userId: String) -> Bool {
        return responses.contains { response in
            response.fromUserId == userId
        }
    }
    
    func getUserResponse(userId: String) -> Response? {
        return responses.first { response in
            response.fromUserId == userId
        }
    }
}

// MARK: - Response Model
struct Response: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var fromUserId: String
    var fromUsername: String
    var message: String
    var timestamp: Date = Date()
    var quotedPrice: Double? // Provider's quoted price for the job
    var isAccepted: Bool = false // Whether this response was accepted by the task creator
}
