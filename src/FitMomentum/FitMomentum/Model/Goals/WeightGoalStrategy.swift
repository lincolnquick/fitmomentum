//
//  WeightGoalStrategy.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/30/24.
//

import Foundation

/// Represents the strategy for achieving a weight goal.
class WeightGoalStrategy {
    var bodyWeightChangeRate: Double // Percentage of weekly weight change, e.g., -1.0 = -1% for loss, 1.0 = 1% for gain

    /// Initializes the WeightGoalStrategy with a body weight change rate.
    /// - Parameter bodyWeightChangeRate: Percentage of weekly body weight change.
    init(bodyWeightChangeRate: Double) {
        self.bodyWeightChangeRate = bodyWeightChangeRate
    }

    /// Calculates the body weight change rate given a starting weight, target weight, and target date.
    /// - Parameters:
    ///   - startWeight: Starting weight in kilograms.
    ///   - targetWeight: Target weight in kilograms.
    ///   - targetDate: Target completion date.
    /// - Returns: Calculated body weight change rate as a percentage of the starting weight.
    static func calculateChangeRate(startWeight: Double, targetWeight: Double, targetDate: Date) -> Double {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: Date(), to: targetDate).weekOfYear ?? 0
        guard weeks > 0 else { return 0 }
        let totalChange = targetWeight - startWeight
        let averageChangePerWeek = totalChange / Double(weeks)
        return (averageChangePerWeek / startWeight) * 100.0
    }

    /// Calculates the body weight change rate given a starting weight, target weight, and initial change in mass per week.
    /// - Parameters:
    ///   - startWeight: Starting weight in kilograms.
    ///   - targetWeight: Target weight in kilograms.
    ///   - initialChangePerWeek: Initial change in mass per week (kg).
    /// - Returns: Calculated body weight change rate as a percentage of the starting weight.
    static func calculateChangeRate(startWeight: Double, targetWeight: Double, initialChangePerWeek: Double) -> Double {
        guard initialChangePerWeek != 0 else { return 0 }
        let totalChange = targetWeight - startWeight
        let totalWeeks = totalChange / initialChangePerWeek
        return (initialChangePerWeek / startWeight) * 100.0
    }

    /// Checks if the body weight change rate is within a safe range.
    /// - Returns: A warning string if the rate is outside the recommended range, otherwise `nil`.
    func checkForWarnings() -> String? {
        if bodyWeightChangeRate > 2.0 {
            return "Warning: A weight gain rate of more than 2% per week may be unsafe."
        } else if bodyWeightChangeRate < -2.0 {
            return "Warning: A weight loss rate of more than 2% per week may be unsafe."
        } else if abs(bodyWeightChangeRate) < 0.2 {
            return "Note: A weight change rate of less than 0.2% per week may result in slow progress."
        }
        return nil
    }

    /// Calculates the initial body weight change in mass for the first week.
    /// - Parameter startWeight: The starting weight in kilograms.
    /// - Returns: Initial body weight change in mass (kg).
    func calculateInitialChange(startWeight: Double) -> Double {
        return startWeight * (bodyWeightChangeRate / 100.0)
    }

    /// Calculates the final week's body weight change in mass.
    /// - Parameter startWeight: The starting weight in kilograms.
    /// - Returns: Final week's body weight change in mass (kg).
    func calculateFinalChange(startWeight: Double, weeks: Int) -> Double {
        let finalWeekStartWeight = startWeight * pow((1 + bodyWeightChangeRate / 100.0), Double(weeks - 1))
        return finalWeekStartWeight * (bodyWeightChangeRate / 100.0)
    }

    /// Calculates the estimated target date based on starting weight and target weight.
    /// - Parameters:
    ///   - startWeight: The starting weight in kilograms.
    ///   - targetWeight: The target weight in kilograms.
    ///   - startDate: The starting date of the goal.
    /// - Returns: The estimated target date.
    func calculateEstimatedTargetDate(startWeight: Double, targetWeight: Double, startDate: Date) -> Date {
        var currentWeight = startWeight
        var weeks = 0
        while abs(currentWeight - targetWeight) > 0.01 {
            let weeklyChange = calculateInitialChange(startWeight: currentWeight)
            currentWeight += weeklyChange
            weeks += 1
        }
        return Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: startDate) ?? startDate
    }
}

