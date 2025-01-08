//  WeightGoal.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//

import Foundation

/// Represents a single milestone in the weight goal.
struct Milestone {
    var milestoneWeight: Double // Target weight in kg
    var isCompleted: Bool = false // Completion status
    let order: Int // Order of the milestone in the sequence

    /// Initializes a new Milestone.
    /// - Parameters:
    ///   - targetWeight: Target weight in kilograms.
    ///   - order: The order of the milestone in the sequence.
    init(milestoneWeight: Double, order: Int) {
        self.milestoneWeight = milestoneWeight
        self.order = order
    }
}

class WeightGoal {
    var startWeight: WeightMeasurement
    var targetWeight: Double
    var startDate: Date
    var weightGoalStrategy: WeightGoalStrategy
    var user: User
    var milestones: [Milestone] = []
    private var nutritionStrategies: [(Date, NutritionStrategy)] = [] // Sorted array of strategies

    /// Initializes a new WeightGoal.
    /// - Parameters:
    ///   - startWeight: Starting weight measurement.
    ///   - targetWeight: Target weight in kilograms.
    ///   - weightGoalStrategy: Strategy for achieving the weight goal.
    init(startWeight: WeightMeasurement, targetWeight: Double, weightGoalStrategy: WeightGoalStrategy, user: User) {
        self.startWeight = startWeight
        self.targetWeight = targetWeight
        self.startDate = startWeight.timestamp
        self.weightGoalStrategy = weightGoalStrategy
        self.user = user
        self.generateDefaultMilestones()
    }
    
    /// Adds a new 'NutritionStrategy' for a specific date.
    ///  - Parameters:
    ///   - strategy: The 'NutritionStrategy' to add.
    ///   - date: The date for which the strategy to apply.
    func addNutritionStrategy(strategy: NutritionStrategy, for date: Date = Date()){
        nutritionStrategies.append((date, strategy))
        nutritionStrategies.sort { $0.0 < $1.0 }
    }
    
    /// Retrieves the most recent 'NutritionStrategy' on or before a given date.
    ///    - Parameters:
    ///     - date: The date for which to find the applicable strategy.
    ///    - Returns:
    ///     - The relevant 'NutritionStrategy' or 'nil' if no strategies exist.
    func getNutritionStrategy(for date: Date) -> NutritionStrategy? {
        let strategy = nutritionStrategies.last(where: { $0.0 <= date })
        return strategy?.1
    }

    /// Updates the start date and adjusts the starting weight to match the measurement on that date.
    /// - Parameter newStartDate: New start date.
    /// - Parameter measurementCollection: A collection of weight measurements.
    func updateStartDate(newStartDate: Date, measurementCollection: MeasurementCollection<WeightMeasurement>) {
        self.startDate = newStartDate
        if let measurement = measurementCollection.getMeasurement(for: newStartDate) {
            self.startWeight = measurement
        }
    }

    /// Calculates the target weight range for maintenance.
    /// - Parameter range: Plus or minus range in kilograms.
    /// - Returns: A tuple representing the lower and upper bounds of the target range.
    func calculateTargetRange(range: Double) -> (lower: Double, upper: Double) {
        return (lower: targetWeight - range, upper: targetWeight + range)
    }

    /// Generates default milestones based on increments of 2 kg or 5 lbs (stored in kg).
    func generateDefaultMilestones() {
        milestones.removeAll()
        let userPreferences = UserPreferences.shared
        let increment: Double

        if userPreferences.unitPreferences.weightUnit == .lbs {
            increment = 5.0 / 2.20462 // Convert 5 lbs to kg
        } else {
            increment = 2.0 // 2 kg increment
        }

        var currentWeight = startWeight.value
        var order = 1

        while abs(currentWeight - targetWeight) > increment {
            currentWeight += (targetWeight > startWeight.value ? increment : -increment)
            milestones.append(Milestone(milestoneWeight: currentWeight, order: order))
            order += 1
        }

        // Add the final milestone for the exact target weight
        milestones.append(Milestone(milestoneWeight: targetWeight, order: order))
    }

    /// Updates the completion status of milestones based on the current weight.
    /// - Parameter currentWeight: The current weight in kilograms.
    func updateMilestoneCompletion(currentWeight: Double) {
        for index in milestones.indices {
            milestones[index].isCompleted = targetWeight > startWeight.value
                ? currentWeight >= milestones[index].milestoneWeight
                : currentWeight <= milestones[index].milestoneWeight
        }
    }
    
    /// Calculates the target caloric imbalance for the weight goal.
    /// - Parameters:
    ///   - energyBalanceCalculator: Instance of EnergyBalanceCalculator.
    /// - Returns: The target caloric imbalance in kcal/day.
  func calculateTargetCaloricImbalance(using energyBalanceCalculator: EnergyBalanceCalculator) -> Double {
      return energyBalanceCalculator.calculateCaloricImbalanceForWeightChange(
          initialWeight: startWeight.value,
          targetWeight: targetWeight,
          weightGoalStrategy: self.weightGoalStrategy
      )
  }
    
}
extension WeightGoal {
    /// Calculates the daily calorie target.
    func calculateCalorieTarget(using energyBalanceCalculator: EnergyBalanceCalculator) -> Double {
        let caloricImbalance = calculateTargetCaloricImbalance(using: energyBalanceCalculator)
        let rmr = HealthMetricsCalculator.calculateRMR(
            weight: user.mostRecentWeight ?? 0.0,
            age: user.age,
            sex: user.sex)
        var tdee: Double = 0.0
        do {
            try tdee = HealthMetricsCalculator.calculateTDEEWithActivityFactor(
                rmr: rmr,
                activityFactor: weightGoalStrategy.activityFactor
            )
        } catch {
            print("Activity factor out of range when calculating TDEE.")
        }
        
        return max(tdee - caloricImbalance, 0.0)
    }
}
