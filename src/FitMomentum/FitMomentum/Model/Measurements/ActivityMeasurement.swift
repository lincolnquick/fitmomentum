import Foundation

/// Represents an activity measurement retrieved from HealthKit or similar sources.
class ActivityMeasurement: Measurement {
    var steps: Int // Number of steps taken
    var distanceWalked: Double // Distance walked in kilometers
    var activeCalories: Double // Active calories burned (assumed inaccurate)

    /// Required initializer to meet the Measurement superclass contract.
    /// - Parameters:
    ///   - timestamp: The date and time of the measurement.
    ///   - value: The main value (e.g., steps or a placeholder if no specific value is applicable).
    required init(timestamp: Date, value: Double) {
        self.steps = 0
        self.distanceWalked = 0.0
        self.activeCalories = 0.0
        super.init(timestamp: timestamp, value: value)
    }

    /// Convenience initializer with all activity data.
    /// - Parameters:
    ///   - timestamp: The timestamp of the measurement.
    ///   - steps: The number of steps taken.
    ///   - distanceWalked: The distance walked in kilometers.
    ///   - activeCalories: The active calories burned (assumed inaccurate).
    convenience init(timestamp: Date, steps: Int, distanceWalked: Double, activeCalories: Double) {
        self.init(timestamp: timestamp, value: Double(steps)) // Value defaults to steps
        self.steps = steps
        self.distanceWalked = distanceWalked
        self.activeCalories = activeCalories
    }

    /// Converts distance to the user's preferred units.
    /// - Returns: The converted distance (e.g., miles or kilometers).
    func getConvertedDistance() -> Double {
        let userPreferences = UserPreferences.shared
        switch userPreferences.unitPreferences.distanceUnit {
        case .mi:
            return distanceWalked * 0.621371 // Kilometers to miles
        case .km:
            return distanceWalked // Already in kilometers
        }
    }
    
    override var description: String {
        let formattedDate = timestamp.formatted(.dateTime.month(.abbreviated).day().year())
        return "ActivityMeasurement - Steps: \(steps), Distance: \(getConvertedDistance()), Active Calories: \(activeCalories)), Timestamp: \(formattedDate)"
    }

    /// Validates that all measurement values are non-negative.
    override func validate() throws {
        guard steps >= 0, distanceWalked >= 0, activeCalories >= 0 else {
            throw MeasurementError.invalidValue("Activity measurement values must be non-negative.")
        }
    }
}
