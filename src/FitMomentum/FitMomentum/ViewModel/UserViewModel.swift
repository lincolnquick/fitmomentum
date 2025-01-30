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
            
            let bodyFatString = String(format: "%.1f%%", fatPercent)
            return "\(bodyFatString) as of \(formattedDate)"
        }
        return "No Body Fat Data"
    }
    
    func getChartData(for metric: MetricType, interval: TimeIntervalType) -> [ChartData]? {
        let (startDate, endDate) = getDateRange(for: interval)

        switch metric {
        case .weight:
            switch userPrefs.unitPreferences.weightUnit {
            case .kg:
                return user.weightMeasurements.getMeasurements(from: startDate, to: endDate).map {
                    ChartData(date: $0.timestamp, value: $0.weight, secondaryValue: nil)
                }
            case .lbs:
                return user.weightMeasurements.getMeasurements(from: startDate, to: endDate).map {
                    ChartData(date: $0.timestamp, value: $0.weight * 2.20462, secondaryValue: nil)
                }
            case .stones:
                return user.weightMeasurements.getMeasurements(from: startDate, to: endDate).map {
                    ChartData(date: $0.timestamp, value: $0.weight * 0.157473, secondaryValue: nil)
                }
            }
            
        case .bodyFat:
            return user.bodyFatMeasurements.getMeasurements(from: startDate, to: endDate).map {
                ChartData(date: $0.timestamp, value: $0.value, secondaryValue: nil)
            }
        case .steps:
            return user.activityMeasurements.getMeasurements(from: startDate, to: endDate).map {
                ChartData(date: $0.timestamp, value: Double($0.steps), secondaryValue: nil)
            }
        case .distance:
            switch userPrefs.unitPreferences.distanceUnit {
            case .km:
                return user.activityMeasurements.getMeasurements(from: startDate, to: endDate).map {
                    ChartData(date: $0.timestamp, value: $0.distanceWalked, secondaryValue: nil)
                }
            case .mi:
                return user.activityMeasurements.getMeasurements(from: startDate, to: endDate).map {
                    ChartData(date: $0.timestamp, value: $0.distanceWalked * 0.621371 , secondaryValue: nil)
                }
            }
            
        case .activeCalories:
            switch userPrefs.unitPreferences.energyUnit {
            case .kcal:
                return user.activityMeasurements.getMeasurements(from: startDate, to: endDate).map {
                    ChartData(date: $0.timestamp, value: $0.activeCalories, secondaryValue: nil)
                }
            case .mj:
                return user.activityMeasurements.getMeasurements(from: startDate, to: endDate).map {
                    ChartData(date: $0.timestamp, value: $0.activeCalories * 0.004184 , secondaryValue: nil)
                }
            }
            
        case .caloriesConsumed:
            switch userPrefs.unitPreferences.energyUnit {
            case .kcal:
                return user.nutritionMeasurements.getMeasurements(from: startDate, to: endDate).map {
                    ChartData(date: $0.timestamp, value: $0.kilocalories, secondaryValue: nil)
                }
            case .mj:
                return user.nutritionMeasurements.getMeasurements(from: startDate, to: endDate).map {
                    ChartData(date: $0.timestamp, value: $0.kilocalories * 0.004184, secondaryValue: nil)
                }
            }
        case .energyBalance:
            let nutritionData = user.nutritionMeasurements.getMeasurements(from: startDate, to: endDate)
            let tdeeData = user.energyBalanceResults.getMeasurements(from: startDate, to: endDate)

            // Map into ChartData format, matching timestamps for TDEE overlay
            var chartData: [ChartData] = []
            for nutrition in nutritionData {
                let matchingTDEE = tdeeData.first(where: { $0.timestamp.onlyDate() == nutrition.timestamp.onlyDate() })
                let energyConsumed: Double
                let tdee: Double
                switch userPrefs.unitPreferences.energyUnit {
                case .kcal:
                    energyConsumed = nutrition.kilocalories
                    tdee = matchingTDEE?.teeKcal ?? 0.0
                case .mj:
                    energyConsumed = nutrition.kilocalories * 0.004184
                    tdee = (matchingTDEE?.teeKcal ?? 0.0) * 0.004184
                }
                chartData.append(
                    ChartData(
                        date: nutrition.timestamp,
                        value: energyConsumed,
                        secondaryValue: tdee
                    )
                )
            }

            return chartData
        default:
            return nil
        }
    }
    
    func getAllData(for metric: MetricType) -> [ChartData] {
        return getChartData(for: metric, interval: TimeIntervalType.allTime) ?? []
    }
    
    func formattedValue(_ value: Double, for metric: MetricType) -> String {
        switch metric {
        case .weight, .trendWeight:
            switch userPrefs.unitPreferences.weightUnit {
            case .kg:
                return String(format: "%.1f", value)
            case .lbs:
                return String(format: "%.1f", value)
            case .stones:
                return String(format: "%.1f", value)
            }
        case .distance:
            switch userPrefs.unitPreferences.distanceUnit {
            case .km:
                return String(format: "%.2f", value)
            case .mi:
                return String(format: "%.2f", value)
            }
        default:
            return String(format: "%.2f", value)
        }
    }
    func unitLabel(for metric: MetricType) -> String {
        switch metric {
        case .weight, .trendWeight: return userPrefs.unitPreferences.weightUnit.rawValue
        case .distance: return userPrefs.unitPreferences.distanceUnit.rawValue
        case .activeCalories, .caloriesConsumed, .energyBalance: return userPrefs.unitPreferences.energyUnit.rawValue
        case .steps: return "steps"
        case .bodyFat, .trendBodyFat: return "%"
        }
    }
    
    /// Returns the start and end date for the selected time interval
    private func getDateRange(for interval: TimeIntervalType) -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()

        let startDate: Date
        switch interval {
        case .weekly:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .monthly:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now)!
        case .yearly:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        case .allTime:
            startDate = Date.distantPast // Includes all available data
        }
        
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
        
        print("[DEBUG] Date range for \(interval.rawValue): \(startOfDay) to \(endOfDay)")

        return (startOfDay, endOfDay)
    }
}
