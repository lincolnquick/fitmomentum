//
//  UserPreferences.swift
//  FitMomentum
//
//  Updated by Lincoln Quick on 12/31/24.
//

import Foundation
import Combine

/// Represents the user's preferences for the FitMomentum app.
class UserPreferences: ObservableObject {
    
    // MARK: - Singleton
    static let shared = UserPreferences()
    
    // MARK: - Appearance Mode
    enum AppearanceMode: String {
        case light = "Light Mode"
        case dark = "Dark Mode"
        case system = "System Settings"
    }

    // MARK: - Units
    enum WeightUnit: String {
        case kg, lbs, stones
    }

    enum HeightUnit: String {
        case cm, ftIn
    }

    enum DistanceUnit: String {
        case km, mi
    }

    enum EnergyUnit: String {
        case kcal, mj
    }

    struct UnitPreferences {
        var weightUnit: WeightUnit
        var heightUnit: HeightUnit
        var distanceUnit: DistanceUnit
        var energyUnit: EnergyUnit

        // Saves the unit settings to UserDefaults
        func saveToUserDefaults() {
            let defaults = UserDefaults.standard
            defaults.set(weightUnit.rawValue, forKey: "weightUnit")
            defaults.set(heightUnit.rawValue, forKey: "heightUnit")
            defaults.set(distanceUnit.rawValue, forKey: "distanceUnit")
            defaults.set(energyUnit.rawValue, forKey: "energyUnit")
        }

        // Loads the unit settings from UserDefaults
        static func loadFromUserDefaults() -> UnitPreferences {
            let defaults = UserDefaults.standard
            return UnitPreferences(
                weightUnit: WeightUnit(rawValue: defaults.string(forKey: "weightUnit") ?? "kg") ?? .kg,
                heightUnit: HeightUnit(rawValue: defaults.string(forKey: "heightUnit") ?? "cm") ?? .cm,
                distanceUnit: DistanceUnit(rawValue: defaults.string(forKey: "distanceUnit") ?? "km") ?? .km,
                energyUnit: EnergyUnit(rawValue: defaults.string(forKey: "energyUnit") ?? "kcal") ?? .kcal
            )
        }
    }
    
    // MARK: - @Published Properties

    @Published var appearanceMode: AppearanceMode {
        didSet { saveToUserDefaults() }
    }

    @Published var unitPreferences: UnitPreferences {
        didSet {
            unitPreferences.saveToUserDefaults()
            saveToUserDefaults()
        }
    }

    @Published var dailyStepGoal: Int {
        didSet { saveToUserDefaults() }
    }

    @Published var weighInReminderEnabled: Bool {
        didSet { saveToUserDefaults() }
    }

    @Published var weighInReminderTime: Date? {
        didSet { saveToUserDefaults() }
    }

    @Published var useRecommendedMinimumCalorieTarget: Bool {
        didSet { saveToUserDefaults() }
    }

    // MARK: - Initialization
    private init() {
        let defaults = UserDefaults.standard
        
        // Load appearance
        let appearanceStr = defaults.string(forKey: "appearanceMode") ?? "System Settings"
        self.appearanceMode = AppearanceMode(rawValue: appearanceStr) ?? .system
        
        // Load unit preferences
        self.unitPreferences = UnitPreferences.loadFromUserDefaults()
        
        // Load daily step goal
        self.dailyStepGoal = defaults.integer(forKey: "dailyStepGoal")
        
        // Load weigh-in reminder
        self.weighInReminderEnabled = defaults.bool(forKey: "weighInReminderEnabled")
        self.weighInReminderTime = defaults.object(forKey: "weighInReminderTime") as? Date
        
        // Load recommended calorie target
        self.useRecommendedMinimumCalorieTarget = defaults.bool(forKey: "useRecommendedMinimumCalorieTarget")
    }

    // MARK: - Persistence
    private func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(appearanceMode.rawValue, forKey: "appearanceMode")
        defaults.set(dailyStepGoal, forKey: "dailyStepGoal")
        defaults.set(weighInReminderEnabled, forKey: "weighInReminderEnabled")
        defaults.set(weighInReminderTime, forKey: "weighInReminderTime")
        defaults.set(useRecommendedMinimumCalorieTarget, forKey: "useRecommendedMinimumCalorieTarget")
    }
}
