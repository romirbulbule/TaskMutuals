//
//  EnhancedMainTabView.swift
//  TaskMutual
//
//  Enhanced tab view with smooth animations and haptics
//

import SwiftUI

struct EnhancedMainTabView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tasksVM: TasksViewModel
    @StateObject private var tabBarVisibility = TabBarVisibility.shared
    @State private var selectedTab: Tab = .feed
    @State private var previousTab: Tab = .feed
    @Namespace private var animation

    enum Tab: String, CaseIterable {
        case feed, search, chat, profile

        var icon: String {
            switch self {
            case .feed: return "house.fill"
            case .search: return "magnifyingglass"
            case .chat: return "message.fill"
            case .profile: return "person.crop.circle.fill"
            }
        }

        var title: String {
            rawValue.capitalized
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            Group {
                switch selectedTab {
                case .feed:
                    FeedView()
                        .environmentObject(userVM)
                        .environmentObject(tasksVM)
                        .transition(.asymmetric(
                            insertion: slideTransition(for: selectedTab),
                            removal: slideTransition(for: previousTab, isRemoval: true)
                        ))

                case .search:
                    SearchView()
                        .environmentObject(userVM)
                        .environmentObject(tasksVM)
                        .transition(.asymmetric(
                            insertion: slideTransition(for: selectedTab),
                            removal: slideTransition(for: previousTab, isRemoval: true)
                        ))

                case .chat:
                    ChatView()
                        .environmentObject(userVM)
                        .transition(.asymmetric(
                            insertion: slideTransition(for: selectedTab),
                            removal: slideTransition(for: previousTab, isRemoval: true)
                        ))

                case .profile:
                    ProfileView()
                        .environmentObject(userVM)
                        .transition(.asymmetric(
                            insertion: slideTransition(for: selectedTab),
                            removal: slideTransition(for: previousTab, isRemoval: true)
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
        .offset(y: tabBarVisibility.isHidden ? 100 : 0)
        .opacity(tabBarVisibility.isHidden ? 0 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: tabBarVisibility.isHidden)
    }

    private func tabButton(for tab: Tab) -> some View {
        Button(action: {
            selectTab(tab)
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == tab {
                        Capsule()
                            .fill(Theme.accent.opacity(0.2))
                            .frame(width: 60, height: 36)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? Theme.accent : .gray)
                        .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                }
                .frame(height: 36)

                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(selectedTab == tab ? .semibold : .regular)
                    .foregroundColor(selectedTab == tab ? Theme.accent : .gray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func selectTab(_ tab: Tab) {
        guard selectedTab != tab else { return }

        // Strong haptic feedback for tab switches
        HapticsManager.shared.heavy()

        // Show tab bar when switching tabs
        TabBarVisibility.shared.show()

        // Update tabs with animation
        withAnimation(AnimationPresets.tabSwitch) {
            previousTab = selectedTab
            selectedTab = tab
        }
    }

    private func slideTransition(for tab: Tab, isRemoval: Bool = false) -> AnyTransition {
        let tabIndex = Tab.allCases.firstIndex(of: tab) ?? 0
        let previousIndex = Tab.allCases.firstIndex(of: previousTab) ?? 0

        let edge: Edge = tabIndex > previousIndex ? .trailing : .leading

        return .asymmetric(
            insertion: .move(edge: isRemoval ? (edge == .leading ? .trailing : .leading) : edge)
                .combined(with: .opacity),
            removal: .move(edge: isRemoval ? edge : (edge == .leading ? .trailing : .leading))
                .combined(with: .opacity)
        )
    }
}

#Preview {
    EnhancedMainTabView()
        .environmentObject(UserViewModel())
        .environmentObject(TasksViewModel())
}
