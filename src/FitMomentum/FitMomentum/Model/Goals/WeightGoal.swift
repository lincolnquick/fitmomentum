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
    var milestones: [Milestone] = []

    /// Initializes a new WeightGoal.
    /// - Parameters:
    ///   - startWeight: Starting weight measurement.
    ///   - targetWeight: Target weight in kilograms.
    ///   - weightGoalStrategy: Strategy for achieving the weight goal.
    init(startWeight: WeightMeasurement, targetWeight: Double, weightGoalStrategy: WeightGoalStrategy) {
        self.startWeight = startWeight
        self.targetWeight = targetWeight
        self.startDate = startWeight.timestamp
        self.weightGoalStrategy = weightGoalStrategy
        self.generateDefaultMilestones()
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
}
