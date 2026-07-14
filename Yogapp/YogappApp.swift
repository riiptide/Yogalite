//
//  YogappApp.swift
//  Yogapp
//
//  Created by Aaliyah Sayed on 7/13/26.
//

import SwiftUI
import SwiftData

@main
struct YogappApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [
            SavedPracticeRecord.self,
            PracticeCompletionRecord.self
        ])
    }
}
