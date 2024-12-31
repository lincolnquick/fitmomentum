//
//  NutritionEntryMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/30/24.
//

import Foundation

/// Represents an entry in a daily nutrition log.
class NutritionEntryMeasurement: Measurement {
    var protein: Double // in grams
    var carbohydrates: Double // in grams
    var fats: Double // in grams
    var dietaryFiber: Double // in grams
    var sodium: Double // in milligrams
    var potassium: Double // in milligrams

    var id: UUID // Unique identifier for the entry
    var name: String? // Optional name for the entry
    var description: String? // Optional description for the entry
    var meal: MealType? // Meal type (e.g., breakfast, lunch, etc.)

    enum MealType: String {
        case breakfast
        case lunch
        case dinner
        case snack
    }

    required init(
        timestamp: Date,
        value: Double
    ) {
        self.protein = 0.0
        self.carbohydrates = 0.0
        self.fats = 0.0
        self.dietaryFiber = 0.0
        self.sodium = 0.0
        self.potassium = 0.0
        self.id = UUID()
        super.init(timestamp: timestamp, value: value)
    }

    convenience init(
        timestamp: Date,
        kilocalories: Double,
        protein: Double,
        carbohydrates: Double,
        fats: Double,
        dietaryFiber: Double,
        sodium: Double,
        potassium: Double,
        name: String? = nil,
        description: String? = nil,
        meal: MealType? = nil
    ) {
        self.init(timestamp: timestamp, value: kilocalories)
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fats = fats
        self.dietaryFiber = dietaryFiber
        self.sodium = sodium
        self.potassium = potassium
        self.name = name
        self.description = description
        self.meal = meal
    }

    /// Validate that all nutrition values are non-negative.
    override func validate() throws {
        guard value >= 0, protein >= 0, carbohydrates >= 0, fats >= 0 else {
            throw MeasurementError.invalidValue("Nutrition entry values must be non-negative.")
        }
    }
}
