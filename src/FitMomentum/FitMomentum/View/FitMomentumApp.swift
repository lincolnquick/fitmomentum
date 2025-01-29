//
//  FitMomentumApp.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/4/24.
//

import SwiftUI

@main
struct FitMomentumApp: App {
    // Provide a single instance for the app's lifetime
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var userPreferences = UserPreferences.shared

    var body: some Scene {
        WindowGroup {
            // The top-level ContentView (or tab bar, etc.)
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(userPreferences)
        }
    }
}
