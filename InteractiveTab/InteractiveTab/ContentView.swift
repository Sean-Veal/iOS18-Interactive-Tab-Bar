//
//  ContentView.swift
//  InteractiveTab
//
//  Created by Sean Veal on 1/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: TabItem = .home
    @State private var isFloating: Bool = false
    var body: some View {
        // This project supports iOS 17 as well
        Toggle("isFloating", isOn: $isFloating)
        ZStack(alignment: .bottom) {
            if #available(iOS 18, *) {
                TabView(selection: $activeTab) {
                    // Replace with your tab's view
                    ForEach(TabItem.allCases, id: \.rawValue) { tab in
                        Tab.init(value: tab) {
                            Text(tab.rawValue)
                            // Must hide the native tab bar
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                }
            } else {
                TabView(selection: $activeTab) {
                    // Replace with your tab's view
                    ForEach(TabItem.allCases, id: \.rawValue) { tab in
                            Text(tab.rawValue)
                            .tag(tab)
                            // Must hide the native tab bar
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
            if isFloating {
                FloatingInteractiveTabBar(activeTab: $activeTab)
            } else {
                InteractiveTabBar(activeTab: $activeTab)
            }
        }
    }
}

struct FloatingInteractiveTabBar: View {
    @Binding var activeTab: TabItem
    
    @Namespace private var animation
    
    @State private var tabButtonLocations: [CGRect] = Array(repeating: .zero, count: TabItem.allCases.count)
    @State private var activeDraggingTab: TabItem?
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                TabButton(tab)
            }
        }
        .frame(height: 40)
        .padding(5)
        .background {
            Capsule()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
        }
        .coordinateSpace(.named("TABBAR"))
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
    
    // Each Individual Tab Button View
    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? activeTab) == tab
        VStack(spacing: 6) {
            Image(systemName: tab.symbolImage)
                .symbolVariant(.fill)
                .foregroundStyle(isActive ? .white : .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if isActive {
                Capsule()
                    .fill(.blue.gradient)
                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
            }
        }
        // Now let's make it interactive
        .contentShape(.rect)
        .onGeometryChange(for: CGRect.self, of: {
            $0.frame(in: .named("TABBAR"))
        }, action: { newValue in
            tabButtonLocations[tab.index] = newValue
        })
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.snappy) {
                activeTab = tab
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .named("TABBAR"))
                .onChanged({ value in
                    let location = value.location
                    
                    // Checking if location falls in stored locations
                    if let index = tabButtonLocations.firstIndex(where: {
                        $0.contains(location)
                    }) {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            activeDraggingTab = TabItem.allCases[index]
                        }
                    }
                })
                .onEnded({ _ in
                    // Pushing changes to the active tab view
                    if let activeDraggingTab {
                        activeTab = activeDraggingTab
                    }
                    
                    activeDraggingTab = nil
                }),
            // This will immediately become false after dragging
            isEnabled: activeTab == tab
        )
    }
}


struct InteractiveTabBar: View {
    @Binding var activeTab: TabItem
    
    @Namespace private var animation
    
    @State private var tabButtonLocations: [CGRect] = Array(repeating: .zero, count: TabItem.allCases.count)
    @State private var activeDraggingTab: TabItem?
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                TabButton(tab)
            }
        }
        .frame(height: 70)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        .background {
            Rectangle()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
                .ignoresSafeArea()
                .padding(.top, 20)
        }
        .coordinateSpace(.named("TABBAR"))
    }
    
    // Each Individual Tab Button View
    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? activeTab) == tab
        VStack(spacing: 6) {
            Image(systemName: tab.symbolImage)
                .symbolVariant(.fill)
                .frame(width: isActive ? 50 : 25, height: isActive ? 50 : 25)
                .background {
                    if isActive {
                        Circle()
                            .fill(.blue.gradient)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                    }
                }
            
            // This gives us the elevation we needed to push the active tab
                .frame(width: 25, height: 25, alignment: .bottom)
                .foregroundStyle(isActive ? .white : .primary)
            
            Text(tab.rawValue)
                .font(.caption2)
                .foregroundStyle(isActive ? .blue : .gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        // Now let's make it interactive
        .contentShape(.rect)
        .padding(.top, isActive ? 0 : 20)
        .onGeometryChange(for: CGRect.self, of: {
            $0.frame(in: .named("TABBAR"))
        }, action: { newValue in
            tabButtonLocations[tab.index] = newValue
        })
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.snappy) {
                activeTab = tab
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .named("TABBAR"))
                .onChanged({ value in
                    let location = value.location
                    
                    // Checking if location falls in stored locations
                    if let index = tabButtonLocations.firstIndex(where: {
                        $0.contains(location)
                    }) {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            activeDraggingTab = TabItem.allCases[index]
                        }
                    }
                })
                .onEnded({ _ in
                    // Pushing changes to the active tab view
                    if let activeDraggingTab {
                        activeTab = activeDraggingTab
                    }
                    
                    activeDraggingTab = nil
                }),
            // This will immediately become false after dragging
            isEnabled: activeTab == tab
        )
    }
}

#Preview {
    ContentView()
}

enum TabItem: String, CaseIterable {
    case home = "Home"
    case search = "Search"
    case notifications = "Notifications"
    case settings = "Settings"
    
    var symbolImage: String {
        switch self {
        case .home:
            "house"
        case .search:
            "magnifyingglass"
        case .notifications:
            "bell"
        case .settings:
            "gear"
        }
    }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}
