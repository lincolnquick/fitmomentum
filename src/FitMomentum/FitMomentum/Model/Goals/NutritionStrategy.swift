//
//  NutritionStrategy.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/8/25.
//

import Foundation

/// Represents a strategy for daily caloric and macronutrient targets.
struct NutritionStrategy {
    // MARK: - Properties

    /// Daily kilocalorie target.
    private(set) var calorieTarget: Double {
        didSet {
            calorieTarget = max(calorieTarget, minimumCalorieTarget)
        }
    }

    /// Macronutrient distribution as percentages of kilocalories.
    /// Values represent (protein, carbohydrates, fats) and must sum to 100.0.
    private(set) var macroDistribution: MacroDistribution

    /// Minimum calorie target based on user preferences.
    private var minimumCalorieTarget: Double {
        return UserPreferences.shared.useRecommendedMinimumCalorieTarget ? 1500.0 : 1200.0
    }

    // MARK: - Initializers

    /// Initializes the `NutritionStrategy` with a calorie target and optional macronutrient distribution.
    /// - Parameters:
    ///   - calorieTarget: Desired daily kilocalorie target.
    ///   - macroDistribution: Optional macronutrient distribution. Defaults to "high protein."
    init(
        calorieTarget: Double,
        macroDistribution: MacroDistribution = MacroDistribution.highProtein
    ) {
        self.calorieTarget = max(calorieTarget, UserPreferences.shared.useRecommendedMinimumCalorieTarget ? 1500.0 : 1200.0)
        self.macroDistribution = macroDistribution

        guard macroDistribution.isValid else {
            fatalError("MacroDistribution percentages must sum to 100.0.")
        }
    }

    // MARK: - Computed Properties

    /// Minimum calorie target (10% lower than `calorieTarget`, rounded down to the nearest 100 kcal).
    var minCalorieTarget: Int {
        return Int(floor(calorieTarget * 0.9 / 100.0) * 100)
    }

    /// Maximum calorie target (10% higher than `calorieTarget`, rounded up to the nearest 100 kcal).
    var maxCalorieTarget: Int {
        return Int(ceil(calorieTarget * 1.1 / 100.0) * 100)
    }

    /// Target protein in grams, rounded to the nearest integer.
    var proteinGrams: Int {
        return macroDistribution.proteinGrams(forCalories: calorieTarget)
    }

    /// Target carbohydrates in grams, rounded to the nearest integer.
    var carbsGrams: Int {
        return macroDistribution.carbsGrams(forCalories: calorieTarget)
    }

    /// Target fats in grams, rounded to the nearest integer.
    var fatsGrams: Int {
        return macroDistribution.fatsGrams(forCalories: calorieTarget)
    }

    // MARK: - Mutating Methods

    /// Updates the macronutrient distribution.
    /// - Parameter newDistribution: The new macronutrient distribution to set.
    mutating func updateMacroDistribution(_ newDistribution: MacroDistribution) {
        guard newDistribution.isValid else {
            fatalError("MacroDistribution percentages must sum to 100.0.")
        }
        self.macroDistribution = newDistribution
    }
}

/// Represents macronutrient distribution as percentages of total calories.
struct MacroDistribution {
    let protein: Double // Percentage of calories from protein
    let carbs: Double // Percentage of calories from carbohydrates
    let fats: Double // Percentage of calories from fats

    /// Validates that the distribution percentages sum to 100.0.
    var isValid: Bool {
        return abs(protein + carbs + fats - 100.0) < 0.01
    }

    /// Returns protein grams for a given calorie target.
    func proteinGrams(forCalories calories: Double) -> Int {
        return Int(round(calories * (protein / 100.0) / 4.0))
    }

    /// Returns carbohydrate grams for a given calorie target.
    func carbsGrams(forCalories calories: Double) -> Int {
        return Int(round(calories * (carbs / 100.0) / 4.0))
    }

    /// Returns fat grams for a given calorie target.
    func fatsGrams(forCalories calories: Double) -> Int {
        return Int(round(calories * (fats / 100.0) / 9.0))
    }

    // MARK: - Preset Distributions

    
    static let highProtein = MacroDistribution(protein: 36.0, carbs: 42.0, fats: 22.0)
    static let veryHighProtein = MacroDistribution(protein: 40.0, carbs: 40.0, fats: 20.0)
    static let lowCarb = MacroDistribution(protein: 40.0, carbs: 20.0, fats: 40.0)
    static let lowFat = MacroDistribution(protein: 35.0, carbs: 50.0, fats: 15.0)

    /// Creates a custom macronutrient distribution.
    static func custom(protein: Double, carbs: Double, fats: Double) -> MacroDistribution {
        let distribution = MacroDistribution(protein: protein, carbs: carbs, fats: fats)
        guard distribution.isValid else {
            fatalError("Custom macronutrient percentages must sum to 100.0.")
        }
        return distribution
    }
}
