//
//  SearchView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//


/*

import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct SearchView: View {
    @State private var query: String = ""
    @State private var results: [Task] = []

    // 6 categories with 5 tasks each
    let categories: [(title: String, tasks: [String])] = [
        ("Fall Projects", ["TV Mounting", "Furniture Assembly", "Cleaning", "Yard Work", "Gutter Cleaning"]),
        ("Your Moving Checklist", ["Help Moving", "Unpacking", "Cleaning", "Box Disposal", "Furniture Setup"]),
        ("Home Improvement Help", ["Door Repair", "Caulking", "Electrical Work", "Painting", "Plumbing Fix"]),
        ("Outdoor Maintenance", ["Lawn Mowing", "Leaf Raking", "Fence Repair", "Deck Cleaning", "Patio Setup"]),
        ("Smart Home Setup", ["Wi-Fi Install", "Camera Mounting", "Thermostat Setup", "Light Automation", "Device Sync"]),
        ("Seasonal Tasks", ["Snow Shoveling", "AC Checkup", "Heater Tune-up", "Pool Cleaning", "Window Insulation"])
    ]

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 28) {

                    // Search bar
                    TextField("", text: $query)
                        .placeholder(when: query.isEmpty) {
                            Text("Search tasks, users and posts...")
                                .foregroundColor(.black)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.black.opacity(0.15))
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .padding(.horizontal)

                    // MARK: - Scrollable Category Sections
                    ForEach(categories, id: \.title) { category in
                        VStack(alignment: .leading, spacing: 15) {
                            // Section title
                            Text(category.title)
                                .font(.title3.bold())
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)

                            // Horizontal scroll of tasks
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(category.tasks, id: \.self) { task in
                                        VStack(spacing: 10) {
                                            // Enlarged main icon (replacing opaque box)
                                            Image(systemName: "wrench.and.screwdriver.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 150, height: 85) // reduced width for ~2.5 images on screen
                                                .foregroundColor(.black)
                                                .padding(.bottom, 6)

                                            // Task title beneath icon
                                            Text(task)
                                                .font(.subheadline)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.black)
                                                .frame(width: 130)
                                        }
                                    }
                                }
                                .padding(.horizontal, 13)
                            }
                        }
                    }

                    // Divider before results
                    Divider()
                        .background(Color.black.opacity(0.3))
                        .padding(.horizontal, 13)

                    // Search results (existing section)
                    if !results.isEmpty {
                        List {
                            ForEach(results) { task in
                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .font(.headline)
                                        .foregroundColor(Theme.accent)
                                    Text(task.description)
                                        .font(.subheadline)
                                        .foregroundColor(.black.opacity(0.8))
                                }
                                .padding(.vertical, 4)
                                .background(Theme.background)
                            }
                        }
                        .listStyle(.plain)
                        .frame(minHeight: 300)
                        .background(Theme.background)
                    }
                }
                .padding(.bottom, 30)
                .background(Theme.background)
                .navigationTitle("Search")
                .foregroundColor(.white)
            }
            .background(Theme.background.ignoresSafeArea())
        }
    }
}
*/
import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct SearchView: View {
    @State private var query: String = ""
    @State private var results: [Task] = []

    // 6 categories with 5 tasks each (each task now has imageName)
    let categories: [(title: String, tasks: [(name: String, imageName: String)])] = [
        ("Fall Projects", [
            ("TV Mounting", "tv_mounting_icon"),
            ("Furniture Assembly", "furniture_assembly_icon"),
            ("Cleaning", "cleaning_icon"),
            ("Yard Work", "yard_work_icon"),
            ("Gutter Cleaning", "gutter_cleaning_icon")
        ]),
        ("Your Moving Checklist", [
            ("Help Moving", "help_moving_icon"),
            ("Unpacking", "unpacking_icon"),
            ("Cleaning", "cleaning_icon_2"),
            ("Box Disposal", "box_disposal_icon"),
            ("Furniture Setup", "furniture_setup_icon")
        ]),
        ("Home Improvement Help", [
            ("Door Repair", "door_repair_icon"),
            ("Caulking", "caulking_icon"),
            ("Electrical Work", "electrical_work_icon"),
            ("Painting", "painting_icon"),
            ("Plumbing Fix", "plumbing_fix_icon")
        ]),
        ("Outdoor Maintenance", [
            ("Lawn Mowing", "lawn_mowing_icon"),
            ("Leaf Raking", "leaf_raking_icon"),
            ("Fence Repair", "fence_repair_icon"),
            ("Deck Cleaning", "deck_cleaning_icon"),
            ("Patio Setup", "patio_setup_icon")
        ]),
        ("Smart Home Setup", [
            ("Wi‑Fi Install", "wifi_install_icon"),
            ("Camera Mounting", "camera_mounting_icon"),
            ("Thermostat Setup", "thermostat_setup_icon"),
            ("Light Automation", "light_automation_icon"),
            ("Device Sync", "device_sync_icon")
        ]),
        ("Seasonal Tasks", [
            ("Snow Shoveling", "snow_shoveling_icon"),
            ("AC Checkup", "ac_checkup_icon"),
            ("Heater Tune‑up", "heater_tuneup_icon"),
            ("Pool Cleaning", "pool_cleaning_icon"),
            ("Window Insulation", "window_insulation_icon")
        ])
    ]

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 28) {

                    // Search bar
                    TextField("", text: $query)
                        .placeholder(when: query.isEmpty) {
                            Text("Search tasks, users and posts...")
                                .foregroundColor(.black)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.black.opacity(0.15))
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .padding(.horizontal)

                    // MARK: - Scrollable Category Sections
                    ForEach(categories, id: \.title) { category in
                        VStack(alignment: .leading, spacing: 15) {
                            // Section title
                            Text(category.title)
                                .font(.title3.bold())
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)

                            // Horizontal scroll of tasks
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(category.tasks, id: \.name) { task in
                                        VStack(spacing: 10) {
                                            Image(task.imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 150, height: 85)
                                                .foregroundColor(.black)
                                                .padding(.bottom, 6)

                                            Text(task.name)
                                                .font(.subheadline)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.black)
                                                .frame(width: 130)
                                        }
                                    }
                                }
                                .padding(.horizontal, 13)
                            }
                        }
                    }

                    // Divider before results
                    Divider()
                        .background(Color.black.opacity(0.3))
                        .padding(.horizontal, 13)

                    // Search results (existing section)
                    if !results.isEmpty {
                        List {
                            ForEach(results) { task in
                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .font(.headline)
                                        .foregroundColor(Theme.accent)
                                    Text(task.description)
                                        .font(.subheadline)
                                        .foregroundColor(.black.opacity(0.8))
                                }
                                .padding(.vertical, 4)
                                .background(Theme.background)
                            }
                        }
                        .listStyle(.plain)
                        .frame(minHeight: 300)
                        .background(Theme.background)
                    }
                }
                .padding(.bottom, 30)
                .background(Theme.background)
                .navigationTitle("Search")
                .foregroundColor(.white)
            }
            .background(Theme.background.ignoresSafeArea())
        }
    }
}
