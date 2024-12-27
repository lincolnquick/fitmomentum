//
//  NutritionMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class NutritionMeasurement: Measurement {
    // macronutrients
    var protein: Double // in grams
    var carbohydrates: Double // in grams
    var fats: Double // in grams
    var dietaryFiber: Double // in grams
    
    // micronutrients
    var sodium: Double // in milligrams
    var potassium: Double // in milligrams
    
    // other micronutrients, minerals, and vitamins not used
    
    required init(
        timestamp: Date,
        value: Double
    ){
        self.protein = 0.0
        self.carbohydrates = 0.0
        self.fats = 0.0
        self.dietaryFiber = 0.0
        self.sodium = 0.0
        self.potassium = 0.0
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
        potassium: Double
    ) {
        self.init(timestamp: timestamp, value: kilocalories)
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fats = fats
        self.dietaryFiber = dietaryFiber
        self.sodium = sodium
        self.potassium = potassium
    }
    
    /// Kilocalories
    var kilocalories: Double { return value }
    
    /// Validate that all nutrition values are non-negative.
    override func validate() throws {
        guard value >= 0, protein >= 0, carbohydrates >= 0, fats >= 0 else {
            throw MeasurementError.invalidValue("Nutrition values must be non-negative.")
        }
    }

}
