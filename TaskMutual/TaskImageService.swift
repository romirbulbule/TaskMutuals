//
//  TaskImageService.swift
//  TaskMutual
//
//  Service for uploading and managing task images
//

import Foundation
import FirebaseStorage
import UIKit

class TaskImageService {
    private let storage = Storage.storage()

    // MARK: - Upload Multiple Task Images
    func uploadTaskImages(
        taskId: String,
        images: [UIImage],
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        guard !images.isEmpty else {
            completion(.success([]))
            return
        }

        let group = DispatchGroup()
        var uploadedURLs: [String] = []
        var uploadError: Error?

        for (index, image) in images.enumerated() {
            group.enter()

            uploadSingleTaskImage(taskId: taskId, image: image, index: index) { result in
                switch result {
                case .success(let url):
                    uploadedURLs.append(url)
                case .failure(let error):
                    uploadError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = uploadError {
                completion(.failure(error))
            } else {
                completion(.success(uploadedURLs))
            }
        }
    }

    // MARK: - Upload Single Task Image
    private func uploadSingleTaskImage(
        taskId: String,
        image: UIImage,
        index: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "TaskImageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])))
            return
        }

        // Create unique filename
        let filename = "\(taskId)_\(index)_\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("taskimages/\(filename)")

        // Upload
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Get download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "TaskImageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }

    // MARK: - Delete Task Images
    func deleteTaskImages(imageURLs: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard !imageURLs.isEmpty else {
            completion(.success(()))
            return
        }

        let group = DispatchGroup()
        var deleteError: Error?

        for urlString in imageURLs {
            group.enter()

            // Extract filename from URL and delete
            if let url = URL(string: urlString) {
                let storageRef = storage.reference(forURL: urlString)
                storageRef.delete { error in
                    if let error = error {
                        deleteError = error
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = deleteError {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
