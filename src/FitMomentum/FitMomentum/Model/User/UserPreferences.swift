//
//  UserPreferences.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
class UserPreferences {
    var preferredUnits: String // "metric" or "imperial"
    var darkModeEnabled: Bool
    
    init(preferredUnits: String = "metric", darkModeEnabled: Bool = false) {
        self.preferredUnits = preferredUnits
        self.darkModeEnabled = darkModeEnabled
    }
}
