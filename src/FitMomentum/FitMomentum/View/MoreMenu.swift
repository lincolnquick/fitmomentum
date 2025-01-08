//
//  MoreMenu.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/8/25.
//

import SwiftUI

struct MoreMenu: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ProfilePage()) {
                    Text("Profile")
                }
//                NavigationLink(destination: TutorialPage()) {
//                    Text("Tutorial")
//                }
//                NavigationLink(destination: SettingsPage()) {
//                    Text("Settings")
//                }
            }
            .navigationTitle("More")
        }
    }
}
