//
//  UserViewModel.swift
//  FitMomentum
//

import Foundation
import HealthKit

class UserViewModel: ObservableObject {
    @Published var user: User
    @Published var healthKitHelper: HealthKitHelper
    @Published var isHealthKitAuthorized: Bool = false
    @Published var userPrefs: UserPreferences

    init(healthStore: HKHealthStore = HKHealthStore(), user: User = User(person: Person(), preferences: UserPreferences.shared)) {
        self.user = user
        self.userPrefs = user.preferences
        self.healthKitHelper = HealthKitHelper(healthStore: healthStore, user: user)
        authorizeHealthKit()
        refreshHealthKitData()
    }

    // MARK: - HealthKit Authorization
    private func authorizeHealthKit() {
        healthKitHelper.requestHealthKitAuthorization { success in
            DispatchQueue.main.async {
                self.isHealthKitAuthorized = success
            }
        }
    }

    // MARK: - Refresh HealthKit Data
    func refreshHealthKitData() {
        healthKitHelper.refreshHealthKitData()
    }

    // MARK: - Convert Height Based on User Preferences
    func getHeightFeet() -> Int {
        let totalInches = user.person.height * 0.393701 // Convert cm to inches
        return max(Int(totalInches / 12), 4) // Extract feet, minimum of 4
    }

    func getHeightInches() -> Int {
        let totalInches = user.person.height * 0.393701
        return Int(round(totalInches.truncatingRemainder(dividingBy: 12))) // Extract inches
    }

    func updateHeightFromFeetAndInches(feet: Int, inches: Int) {
        let totalInches = Double(feet * 12 + inches)
        user.person.height = totalInches / 0.393701 // Convert inches to cm
    }

    // MARK: - Convert Weight Based on User Preferences
    func formattedWeight() -> String {
        if let latestWeight = user.weightMeasurements.getMostRecentMeasurement() {
            let weightKg = latestWeight.weight
            let formattedDate = latestWeight.timestamp.formatted(.dateTime.month(.abbreviated).day().year())
            let weightString: String
            switch userPrefs.unitPreferences.weightUnit {
            case .kg:
                weightString = String(format: "%.1f kg", weightKg)
            case .lbs:
                weightString = String(format: "%.1f lbs", weightKg * 2.20462)
            case .stones:
                weightString = String(format: "%.1f st", weightKg * 0.157473)
            }
            return "\(weightString) as of \(formattedDate)"
        }
        return "No Weight Data"
    }
    
    func formattedBodyFat() -> String {
        if let latestBodyFat = user.bodyFatMeasurements.getMostRecentMeasurement() {
            let fatPercent = latestBodyFat.bodyFatPercentage
            let formattedDate = latestBodyFat.timestamp.formatted(.dateTime.month(.abbreviated).day().year())
            
            let bodyFatString = String(format: "%.1f%%", latestBodyFat.bodyFatPercentage)
            return "\(bodyFatString) as of \(formattedDate)"
        }
        return "No Body Fat Data"
    }
}
