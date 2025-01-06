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
    var activityFactor: Double // Activity multiplier (e.g., 1.2 for sedentary, 1.55 for moderately active)
    var macroDistribution: (protein: Double, carbs: Double, fat: Double)
    
    // Preset macronutrient distributions
    static let presets: [String: (protein: Double, carbs: Double, fat: Double)] = [
        "high protein": (36.0, 42.0, 22.0),
        "very high protein": (40.0, 40.0, 20.0),
        "low carb": (40.0, 20.0, 40.0),
        "low fat": (35.0, 50.0, 15.0)
    ]
    
    /// Initializes the WeightGoalStrategy with a body weight change rate.
    /// - Parameter bodyWeightChangeRate: Percentage of weekly body weight change.
    init(
        bodyWeightChangeRate: Double,
        activityFactor: Double = 1.2,
        macroDistribution: (protein: Double, carbs: Double, fat: Double)? = nil) {
            self.bodyWeightChangeRate = bodyWeightChangeRate
            self.activityFactor = activityFactor
            self.macroDistribution = macroDistribution ?? WeightGoalStrategy.presets["high protein"]!
        }
    
    // Method to set macronutrient distribution from a preset
    func setMacroDistribution(preset: String) {
        if let distribution = WeightGoalStrategy.presets[preset] {
            self.macroDistribution = distribution
        } else {
            fatalError("Preset \(preset) not found.")
        }
    }
    
    // Method to customize macronutrient distribution manually
    func customizeMacroDistribution(protein: Double? = nil, carbs: Double? = nil, fat: Double? = nil) {
        var remaining = 100.0
        let newProtein = protein ?? macroDistribution.protein
        let newCarbs = carbs ?? macroDistribution.carbs
        let newFat = fat ?? macroDistribution.fat
        
        if protein != nil { remaining -= newProtein }
        if carbs != nil { remaining -= newCarbs }
        if fat != nil { remaining -= newFat }
        
        if remaining < 0 {
            fatalError("Macronutrient percentages exceed 100%")
        }
        
        // Adjust the remaining nutrient to fill the gap
        if protein == nil { macroDistribution.protein = remaining }
        else if carbs == nil { macroDistribution.carbs = remaining }
        else if fat == nil { macroDistribution.fat = remaining }
        
        self.macroDistribution = (newProtein, newCarbs, newFat)
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
extension WeightGoalStrategy {
    func calculateMacroGrams(for caloricTarget: Double) -> (protein: Double, carbs: Double, fat: Double) {
        let proteinKcal = caloricTarget * (macroDistribution.protein / 100.0)
        let carbsKcal = caloricTarget * (macroDistribution.carbs / 100.0)
        let fatKcal = caloricTarget * (macroDistribution.fat / 100.0)

        return (
            protein: proteinKcal / 4.0, // 4 kcal/g for protein
            carbs: carbsKcal / 4.0,    // 4 kcal/g for carbs
            fat: fatKcal / 9.0         // 9 kcal/g for fat
        )
    }
}

