//
//  ModalManager.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//


import Foundation
import Combine
import SwiftUI

class ModalManager: ObservableObject {
    @Published var editTask: Task?
    @Published var responseTask: Task?
    
    var showEditSheet: Binding<Bool> {
        Binding(
            get: { self.editTask != nil },
            set: { if !$0 { self.editTask = nil } }
        )
    }
    
    var showResponseSheet: Binding<Bool> {
        Binding(
            get: { self.responseTask != nil },
            set: { if !$0 { self.responseTask = nil } }
        )
    }
    
    func showEdit(for task: Task) {
        editTask = task
    }
    
    func showResponse(for task: Task) {
        responseTask = task
    }
    
    func closeEdit() {
        editTask = nil
    }
    
    func closeResponse() {
        responseTask = nil
    }
}
