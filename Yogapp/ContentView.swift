//
//  ContentView.swift
//  Yogapp
//
//  Created by Aaliyah Sayed on 7/13/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
