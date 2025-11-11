//
//  ViewModifiers.swift
//  TaskMutual
//
//  Created by Romir Bulbule
//

import SwiftUI
import Combine

// Global tab bar visibility manager
class TabBarVisibility: ObservableObject {
    static let shared = TabBarVisibility()

    @Published var isHidden: Bool = false

    func hide() {
        isHidden = true
    }

    func show() {
        isHidden = false
    }
}

// ViewModifier to hide tab bar in detail views
extension View {
    func hideTabBar() -> some View {
        self
            .onAppear {
                TabBarVisibility.shared.hide()
            }
            .onDisappear {
                TabBarVisibility.shared.show()
            }
    }
}

// Custom ScrollView that tracks offset for tab bar hiding
struct ScrollViewWithTabBar<Content: View>: View {
    let content: Content
    @State private var lastDragValue: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let delta = value.translation.height - lastDragValue
                    lastDragValue = value.translation.height

                    // Scrolling down (drag up) - hide tab bar
                    if delta < -5 {
                        TabBarVisibility.shared.hide()
                    }
                    // Scrolling up (drag down) - show tab bar
                    else if delta > 5 {
                        TabBarVisibility.shared.show()
                    }
                }
                .onEnded { _ in
                    lastDragValue = 0
                }
        )
        .onAppear {
            TabBarVisibility.shared.show()
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
