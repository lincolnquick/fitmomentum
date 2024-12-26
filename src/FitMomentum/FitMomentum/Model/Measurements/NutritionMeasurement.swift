//
//  NutritionMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class NutritionMeasurement: Measurement {
    var kilocalories: Double
    var protein: Double // in grams
    var carbohydrates: Double // in grams
    var fats: Double // in grams
    var dietaryFiber: Double // in grams
    var sodium: Double // in milligrams
    var potassium: Double // in milligrams
    
    init(kilocalories: Double, protein: Double, carbohydrates: Double, fats: Double, dietaryFiber: Double, sodium: Double, potassium: Double, timestamp: Date = Date()) {
        self.kilocalories = kilocalories
        self.carbohydrates = carbohydrates
        self.protein = protein
        self.fats = fats
        self.dietaryFiber = dietaryFiber
        self.sodium = sodium
        self.potassium = potassium
        super.init(timestamp: timestamp)
        
    }
}
