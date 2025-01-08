//
//  UserPreferences.swift
//  FitMomentum
//
//  Updated by Lincoln Quick on 12/31/24.
//

import Foundation

/// Represents the user's preferences for the FitMomentum app.
class UserPreferences {
    static let shared = UserPreferences()

    // Appearance preferences
    enum AppearanceMode: String {
        case light = "Light Mode"
        case dark = "Dark Mode"
        case system = "System Settings"
    }

    var appearanceMode: AppearanceMode {
        didSet { saveToUserDefaults() }
    }

    // Unit preferences
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

        func saveToUserDefaults() {
            let defaults = UserDefaults.standard
            defaults.set(weightUnit.rawValue, forKey: "weightUnit")
            defaults.set(heightUnit.rawValue, forKey: "heightUnit")
            defaults.set(distanceUnit.rawValue, forKey: "distanceUnit")
            defaults.set(energyUnit.rawValue, forKey: "energyUnit")
        }

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

    var unitPreferences: UnitPreferences {
        didSet { unitPreferences.saveToUserDefaults() }
    }

    // Step goal
    var dailyStepGoal: Int {
        didSet { saveToUserDefaults() }
    }

    // Reminder notifications
    var weighInReminderEnabled: Bool {
        didSet { saveToUserDefaults() }
    }

    var weighInReminderTime: Date? {
        didSet { saveToUserDefaults() }
    }
    
    var useRecommendedMinimumCalorieTarget: Bool {
        didSet { saveToUserDefaults() }
    }

    init() {
        let defaults = UserDefaults.standard
        self.appearanceMode = AppearanceMode(rawValue: defaults.string(forKey: "appearanceMode") ?? "System Settings") ?? .system
        self.unitPreferences = UnitPreferences.loadFromUserDefaults()
        self.dailyStepGoal = defaults.integer(forKey: "dailyStepGoal")
        self.weighInReminderEnabled = defaults.bool(forKey: "weighInReminderEnabled")
        self.weighInReminderTime = defaults.object(forKey: "weighInReminderTime") as? Date
        self.useRecommendedMinimumCalorieTarget = defaults.bool(forKey: "useRecommendedMinimumCalorieTarget")
    }

    private func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(appearanceMode.rawValue, forKey: "appearanceMode")
        defaults.set(dailyStepGoal, forKey: "dailyStepGoal")
        defaults.set(weighInReminderEnabled, forKey: "weighInReminderEnabled")
        defaults.set(weighInReminderTime, forKey: "weighInReminderTime")
        defaults.set(useRecommendedMinimumCalorieTarget, forKey: "useRecommendedMinimumCalorieTarget")
    }
}
