//
//  WeightGoal.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//

import Foundation

/// Represents a single milestone in the weight goal.
struct Milestone {
    var targetWeight: Double // Target weight in kg
    var isCompleted: Bool = false // Completion status
    let order: Int // Order of the milestone in the sequence
}

/// Represents the strategy for achieving a weight goal.
struct Strategy {
    var weightChangeRate: Double // kg per week; negative for weight loss
    var macronutrientBalance: (protein: Double, carbs: Double, fats: Double) // Percentages (e.g., 30, 40, 30)
    var activityLevel: Double // Range: 1.4 (sedentary) to 2.5 (extremely active)

    init(weightChangeRate: Double, macronutrientBalance: (Double, Double, Double), activityLevel: Double) {
        self.weightChangeRate = weightChangeRate

        let total = macronutrientBalance.0 + macronutrientBalance.1 + macronutrientBalance.2
        let tolerance = 0.01 // Allow for small deviations up to +-0.01
        guard abs(total - 100.0) <= tolerance else {
            fatalError("Macronutrient percentages must sum to 100.")
        }

        self.macronutrientBalance = macronutrientBalance

        guard activityLevel >= 1.4 && activityLevel <= 2.5 else {
            fatalError("Activity level must be between 1.4 and 2.5.")
        }
        self.activityLevel = activityLevel
    }
}

/// Represents a weight goal with milestones and progress tracking.
class WeightGoal {
    var targetWeight: Double // Target weight in kg
    var strategy: Strategy
    var defaultMilestones: [Milestone] = [] // Default milestones
    var customMilestones: [Milestone]? // Custom milestones
    var estimatedTargetDate: Date?

    init(targetWeight: Double, strategy: Strategy, currentWeight: Double, isMetric: Bool) {
        self.targetWeight = targetWeight
        self.strategy = strategy
        self.generateDefaultMilestones(currentWeight: currentWeight, isMetric: isMetric)
        self.calculateTargetDate(currentWeight: currentWeight)
    }

    /// Generates default milestones based on current weight and user preference for units.
    private func generateDefaultMilestones(currentWeight: Double, isMetric: Bool) {
        defaultMilestones = [] // Reset milestones
        let increment = isMetric ? 5.0 : 4.53592 // 5kg or ~10lbs as default increments

        var weight = currentWeight
        let direction = strategy.weightChangeRate < 0 ? -1.0 : 1.0
        var order = 1

        while (direction < 0 && weight > targetWeight) || (direction > 0 && weight < targetWeight) {
            let nextMilestoneWeight = weight + direction * increment
            let milestoneWeight = (direction < 0 && nextMilestoneWeight <= targetWeight) ||
                                  (direction > 0 && nextMilestoneWeight >= targetWeight)
                                  ? targetWeight
                                  : nextMilestoneWeight
            defaultMilestones.append(Milestone(targetWeight: milestoneWeight, order: order))
            order += 1
            weight = milestoneWeight
        }
    }

    /// Calculates the estimated target date based on the current weight and strategy.
    private func calculateTargetDate(currentWeight: Double) {
        guard strategy.weightChangeRate != 0 else {
            estimatedTargetDate = nil
            return
        }

        let totalWeightChange = abs(targetWeight - currentWeight)
        let weeksToTarget = totalWeightChange / abs(strategy.weightChangeRate)
        let daysToTarget = Int(weeksToTarget * 7)

        estimatedTargetDate = Calendar.current.date(byAdding: .day, value: daysToTarget, to: Date())
    }

    /// Updates progress by checking if milestones are achieved.
    func updateProgress(currentWeight: Double) {
        let milestones = customMilestones ?? defaultMilestones
        for i in 0..<milestones.count {
            if currentWeight <= milestones[i].targetWeight {
                customMilestones?[i].isCompleted = true
            } else {
                customMilestones?[i].isCompleted = false
            }
        }
    }

    /// Allows the user to set custom milestones.
    func setCustomMilestones(_ milestones: [Milestone]) {
        customMilestones = milestones.sorted(by: { $0.order < $1.order })
    }

    /// Resets to default milestones.
    func resetToDefaultMilestones() {
        customMilestones = nil
    }
}
