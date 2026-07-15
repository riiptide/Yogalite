//
//  ContentView.swift
//  Yogapp
//
//  Created by Aaliyah Sayed on 7/13/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if didCompleteOnboarding {
                mainTabs
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            ProductAnalytics.recordAppBecameActive(modelContext: modelContext)
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                ProductAnalytics.recordAppBecameActive(modelContext: modelContext)
            case .background:
                ProductAnalytics.recordAppEnteredBackground()
            default:
                break
            }
        }
    }

    private var mainTabs: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "bookmark")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(FlowDesign.teal)
    }
}

#Preview {
    ContentView()
}
